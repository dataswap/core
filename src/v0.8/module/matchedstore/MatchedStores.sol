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

import "../../types/MatchedstoreType.sol";
import "../../types/FilecoinDealType.sol";
import "../../shared/modifiers/CommonModifiers.sol";
import "../../shared/modifiers/RolesModifiers.sol";
import "../../shared/filecoin/FilecoinDealUtils.sol";
import "../../interfaces/core/IRoles.sol";
import "../../interfaces/core/IFilplus.sol";
import "../../interfaces/core/ICarstore.sol";
import "../../interfaces/module/IDatasets.sol";
import "../../interfaces/module/IMatchings.sol";
import "../../interfaces/module/IMatchedStores.sol";

/// @title Matchedstores
/// @dev Manages the storage of matched data after successful matching with Filecoin storage deals.
contract MatchedStores is IMatchedStores, CommonModifiers, RolesModifiers {
    mapping(uint256 => MatchedstoreType.Matchedstore) private matchedstores; //matchingId=>Matchedstore

    address private governanceAddress;
    IRoles private roles;
    IFilplus private filplus;
    ICarstore private carstore;
    IDatasets private datasets;
    IMatchings private matchings;

    constructor(
        address _governanceAddress,
        IRoles _roles,
        IFilplus _filplus,
        ICarstore _carstore,
        IDatasets _datasets,
        IMatchings _matchings
    ) RolesModifiers(_roles) {
        governanceAddress = _governanceAddress;
        roles = _roles;
        filplus = _filplus;
        carstore = _carstore;
        datasets = _datasets;
        matchings = _matchings;
    }

    /// @notice  Modifier to restrict access to the matching initiator
    modifier onlyMatchingContainsCid(uint256 _matchingId, bytes32 _cid) {
        require(
            matchings.isMatchingContainsCar(_matchingId, _cid),
            "You are not the initiator of this matching"
        );
        _;
    }

    /// @dev Modifier to check if the Filecoin deal state is 'Successed'.
    modifier onlyMatchedStoreFilecoinDealStateSuccessed(
        bytes32 _cid,
        uint256 _filecoinDealId
    ) {
        require(
            FilecoinStorageDealState.Successed ==
                FilecoinDealUtils.getFilecoinStorageDealState(
                    _cid,
                    _filecoinDealId
                ),
            "filecoin deal Id is not setted"
        );
        _;
    }

    /// @dev Modifier to check if the Filecoin deal Id is not already set.
    modifier onlyMatchedStoreFilecoinDealIdNotSetted(
        uint256 _matchingId,
        bytes32 _cid,
        uint256 _filecoinDealId
    ) {
        require(
            !_isMatchedStoreFilecoinDealIdSetted(
                _matchingId,
                _cid,
                _filecoinDealId
            ),
            "filecoin deal Id is setted"
        );
        _;
    }

    /// @dev Internal function to check if a Filecoin deal Id is set for the matchedstore.
    function _isMatchedStoreFilecoinDealIdSetted(
        uint256 _matchingId,
        bytes32 _cid,
        uint256 /*_filecoinDealId*/
    ) internal view returns (bool) {
        return
            CarReplicaType.State.Stored ==
            carstore.getCarReplicaState(_cid, _matchingId);
    }

    /// @dev Internal function to set a Filecoin deal Id for the matchedstore.
    function _setMatchedStoreFilecoinDealId(
        uint256 _matchingId,
        bytes32 _cid,
        uint256 _filecoinDealId
    ) internal {
        carstore.setCarReplicaFilecoinDealId(
            _cid,
            _matchingId,
            _filecoinDealId
        );
    }

    /// @dev Submits a Filecoin deal Id for a matchedstore after successful matching.
    function submitMatchedStoreFilecoinDealId(
        uint256 _matchingId,
        bytes32 _cid,
        uint256 _filecoinDealId
    )
        public
        onlyMatchingContainsCid(_matchingId, _cid)
        onlyMatchedStoreFilecoinDealIdNotSetted(
            _matchingId,
            _cid,
            _filecoinDealId
        )
        onlyMatchedStoreFilecoinDealStateSuccessed(_cid, _filecoinDealId)
    {
        MatchedstoreType.Matchedstore storage matchedstore = matchedstores[
            _matchingId
        ];
        matchedstore.doneCars.push(_cid);
        _setMatchedStoreFilecoinDealId(_matchingId, _cid, _filecoinDealId);
    }

    /// @dev Submits multiple Filecoin deal Ids for a matchedstore after successful matching.
    function submitMatchedStoreFilecoinDealIds(
        uint256 _matchingId,
        bytes32[] memory _cids,
        uint256[] memory _filecoinDealIds
    ) external {
        require(
            _cids.length == _filecoinDealIds.length,
            "param length is not match!"
        );
        for (uint256 i = 0; i < _cids.length; i++) {
            submitMatchedStoreFilecoinDealId(
                _matchingId,
                _cids[i],
                _filecoinDealIds[i]
            );
        }
    }

    /// @dev Gets the list of done cars in the matchedstore.
    function getMatchedStoredCars(
        uint256 _matchingId
    ) public view returns (bytes32[] memory) {
        MatchedstoreType.Matchedstore storage matchedstore = matchedstores[
            _matchingId
        ];
        return matchedstore.doneCars;
    }

    /// @dev Gets the count of done cars in the matchedstore.
    function getMatchedStoredCarsCount(
        uint256 _matchingId
    ) public view returns (uint256) {
        MatchedstoreType.Matchedstore storage matchedstore = matchedstores[
            _matchingId
        ];
        return matchedstore.doneCars.length;
    }

    /// @dev Gets the stored size in the matchedstore.
    function getMatchedStoredTotalSize(
        uint256 _matchingId
    ) public view returns (uint256) {
        MatchedstoreType.Matchedstore storage matchedstore = matchedstores[
            _matchingId
        ];
        // TODO: need be do
        return matchedstore.doneCars.length * 32 * 1024 * 1024 * 1024;
    }

    /// @dev Checks if all cars are done in the matchedstore.
    function isMatchedStoreAllDone(
        uint256 _matchingId
    ) public view returns (bool) {
        MatchedstoreType.Matchedstore storage matchedstore = matchedstores[
            _matchingId
        ];
        return
            matchedstore.doneCars.length ==
            matchings.getMatchingCars(_matchingId).length;
    }
}
