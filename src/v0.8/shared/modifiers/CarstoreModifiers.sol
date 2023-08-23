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

///interface
import {IRoles} from "../../interfaces/core/IRoles.sol";
import {IFilplus} from "../../interfaces/core/IFilplus.sol";
import {IFilecoin} from "../../interfaces/core/IFilecoin.sol";
import {ICarstore} from "../../interfaces/core/ICarstore.sol";
///shared
import {RolesModifiers} from "./RolesModifiers.sol";
import {FilplusModifiers} from "./FilplusModifiers.sol";
import {Errors} from "../errors/Errors.sol";
///types
import {CarReplicaType} from "../../types/CarReplicaType.sol";
import {FilecoinType} from "../../types/FilecoinType.sol";

/// @title storages
/// @dev Manages the storage of matched data after successful matching with Filecoin storage deals.
contract CarstoreModifiers is RolesModifiers, FilplusModifiers {
    IRoles private roles;
    IFilplus private filplus;
    ICarstore private carstore;
    IFilecoin private filecoin;

    // solhint-disable-next-line
    constructor(
        IRoles _roles,
        IFilplus _filplus,
        IFilecoin _filecoin,
        ICarstore _carstore
    ) RolesModifiers(_roles) FilplusModifiers(_filplus) {
        roles = _roles;
        filplus = _filplus;
        carstore = _carstore;
        filecoin = _filecoin;
    }

    /// @dev Modifier to ensure that a car with the given CID exists.
    modifier onlyCarExist(bytes32 _cid) {
        if (!carstore.hasCar(_cid)) {
            revert Errors.CarNotExist(_cid);
        }
        _;
    }

    /// @dev Modifier to ensure that a car with the given CID does not exist.
    modifier onlyCarNotExist(bytes32 _cid) {
        if (carstore.hasCar(_cid)) {
            revert Errors.CarAlreadyExists(_cid);
        }
        _;
    }

    /// @dev Modifier to ensure that a replica of a car exists.
    modifier onlyCarReplicaExist(bytes32 _cid, uint64 _matchingId) {
        if (!carstore.hasCarReplica(_cid, _matchingId)) {
            revert Errors.ReplicaNotExist(_cid, _matchingId);
        }
        _;
    }

    /// @dev Modifier to ensure that a replica of a car not exists.
    modifier onlyCarReplicaNotExist(bytes32 _cid, uint64 _matchingId) {
        if (carstore.hasCarReplica(_cid, _matchingId)) {
            revert Errors.ReplicaAlreadyExists(_cid, _matchingId);
        }
        _;
    }

    /// @dev Modifier to ensure that a replica of a car exists.
    modifier onlyUnsetCarReplicaFilecoinDealId(
        bytes32 _cid,
        uint64 _matchingId
    ) {
        if (carstore.getCarReplicaFilecoinDealId(_cid, _matchingId) != 0) {
            revert Errors.ReplicaFilecoinDealIdExists(_cid, _matchingId);
        }
        _;
    }

    /// @dev Modifier to ensure that a replica state before function do.
    modifier onlyCarReplicaState(
        bytes32 _cid,
        uint64 _matchingId,
        CarReplicaType.State _state
    ) {
        if (_state != carstore.getCarReplicaState(_cid, _matchingId)) {
            revert Errors.InvalidReplicaState(_cid, _matchingId);
        }
        _;
    }

    /// @dev Modifier to ensure that a replica filecoin deal state before function do.
    modifier onlyCarReplicaFilecoinDealState(
        bytes32 _cid,
        uint64 _filecoinDealId,
        FilecoinType.DealState _filecoinDealState
    ) {
        if (
            _filecoinDealState !=
            filecoin.getReplicaDealState(_cid, _filecoinDealId)
        ) {
            revert Errors.InvalidReplicaFilecoinDealState(
                _cid,
                _filecoinDealId
            );
        }
        _;
    }
}
