/// SPDX-License-Identifier: GPL-3.0-or-later
/// (c) 2023 DataSwap
///
/// Licensed under the GNU General Public License, Version 3.0 or later (the "License");
/// you may not use this file except in compliance with the License.
/// You may obtain a copy of the License at
///     https://www.gnu.org/licenses/gpl-3.0.en.html
///
/// Unless required by applicable law or agreed to in writing, software
/// distributed under the License is distributed on an "AS IS" BASIS,
/// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
/// See the License for the specific language governing permissions and
/// limitations under the License.

pragma solidity ^0.8.21;

/// interface
import {IRoles} from "src/v0.8/interfaces/core/IRoles.sol";
import {IFilplus} from "src/v0.8/interfaces/core/IFilplus.sol";
import {IFilecoin} from "src/v0.8/interfaces/core/IFilecoin.sol";
import {ICarstore} from "src/v0.8/interfaces/core/ICarstore.sol";
import {IDatasets} from "src/v0.8/interfaces/module/IDatasets.sol";
import {IMatchings} from "src/v0.8/interfaces/module/IMatchings.sol";
import {IStorages} from "src/v0.8/interfaces/module/IStorages.sol";
/// shared
import {Errors} from "src/v0.8/shared/errors/Errors.sol";
import {StoragesEvents} from "src/v0.8/shared/events/StoragesEvents.sol";
import {StoragesModifiers} from "src/v0.8/shared/modifiers/StoragesModifiers.sol";
/// type
import {CarReplicaType} from "src/v0.8/types/CarReplicaType.sol";
import {StorageType} from "src/v0.8/types/StorageType.sol";

/// @title storages
/// @dev Manages the storage of matched data after successful matching with Filecoin storage deals.
contract Storages is IStorages, StoragesModifiers {
    mapping(uint64 => StorageType.Storage) private storages; //matchingId=>Matchedstore

    address private governanceAddress;
    IRoles private roles;
    IFilplus private filplus;
    IFilecoin private filecoin;
    ICarstore private carstore;
    IDatasets private datasets;
    IMatchings private matchings;

    // solhint-disable-next-line
    constructor(
        address _governanceAddress,
        IRoles _roles,
        IFilplus _filplus,
        IFilecoin _filecoin,
        ICarstore _carstore,
        IDatasets _datasets,
        IMatchings _matchings
    )
        StoragesModifiers(
            _roles,
            _filplus,
            _filecoin,
            _carstore,
            _datasets,
            _matchings,
            this
        )
    {
        governanceAddress = _governanceAddress;
        roles = _roles;
        filplus = _filplus;
        carstore = _carstore;
        datasets = _datasets;
        matchings = _matchings;
    }

    /// @dev Submits a Filecoin deal Id for a matchedstore after successful matching.
    //TODO: verify filecoin deal id matched cid
    function submitStorageDealId(
        uint64 _matchingId,
        bytes32 _cid,
        uint64 _filecoinDealId
    )
        public
        onlyAddress(matchings.getMatchingWinner(_matchingId))
        onlyMatchingContainsCar(_matchingId, _cid)
        onlyUnsetCarReplicaFilecoinDealId(_cid, _matchingId)
        onlyCarReplicaState(_cid, _matchingId, CarReplicaType.State.Matched)
    {
        StorageType.Storage storage storage_ = storages[_matchingId];
        storage_.doneCars.push(_cid);

        /// Note:set deal id in carstore berfore submitDealid
        carstore.setCarReplicaFilecoinDealId(
            _cid,
            _matchingId,
            _filecoinDealId
        );

        emit StoragesEvents.StorageDealIdSubmitted(
            _matchingId,
            _cid,
            _filecoinDealId
        );
    }

    /// @dev Submits multiple Filecoin deal Ids for a matchedstore after successful matching.
    function submitStorageDealIds(
        uint64 _matchingId,
        bytes32[] memory _cids,
        uint64[] memory _filecoinDealIds
    ) external {
        if (_cids.length != _filecoinDealIds.length) {
            revert Errors.ParamLengthMismatch(
                _cids.length,
                _filecoinDealIds.length
            );
        }
        for (uint64 i = 0; i < _cids.length; i++) {
            submitStorageDealId(_matchingId, _cids[i], _filecoinDealIds[i]);
        }
    }

    /// @dev Gets the list of done cars in the matchedstore.
    function getStoredCars(
        uint64 _matchingId
    ) public view returns (bytes32[] memory) {
        StorageType.Storage storage storage_ = storages[_matchingId];
        return storage_.doneCars;
    }

    /// @dev Gets the count of done cars in the matchedstore.
    function getStoredCarCount(
        uint64 _matchingId
    ) public view returns (uint64) {
        StorageType.Storage storage storage_ = storages[_matchingId];
        return uint64(storage_.doneCars.length);
    }

    /// @dev Gets the stored size in the matchedstore.
    function getTotalStoredSize(
        uint64 _matchingId
    ) public view returns (uint64) {
        StorageType.Storage storage storage_ = storages[_matchingId];
        uint64 size = 0;
        for (uint64 i = 0; i < storage_.doneCars.length; i++) {
            size += carstore.getCarSize(storage_.doneCars[i]);
        }
        return size;
    }

    /// @dev Checks if all cars are done in the matchedstore.
    function isAllStoredDone(uint64 _matchingId) public view returns (bool) {
        StorageType.Storage storage storage_ = storages[_matchingId];
        return
            storage_.doneCars.length ==
            matchings.getMatchingCars(_matchingId).length;
    }
}
