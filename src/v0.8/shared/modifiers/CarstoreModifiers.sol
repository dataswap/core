/*******************************************************************************
 *   (c) 2023 Dataswap
 *
 *  Licensed under the GNU General Public License, Version 3.0 or later (the "License");
 *  you may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at
 *
 *      https://www.gnu.org/licenses/gpl-3.0.en.html
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 ********************************************************************************/

// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity ^0.8.21;

///interface
import {IFilecoin} from "src/v0.8/interfaces/core/IFilecoin.sol";
import {ICarstore} from "src/v0.8/interfaces/core/ICarstore.sol";
///shared
import {RolesModifiers} from "src/v0.8/shared/modifiers/RolesModifiers.sol";
import {FilplusModifiers} from "src/v0.8/shared/modifiers/FilplusModifiers.sol";
import {Errors} from "src/v0.8/shared/errors/Errors.sol";
///types
import {CarReplicaType} from "src/v0.8/types/CarReplicaType.sol";
import {FilecoinType} from "src/v0.8/types/FilecoinType.sol";

/// @title storages
/// @dev Manages the storage of matched data after successful matching with Filecoin storage deals.
contract CarstoreModifiers is RolesModifiers, FilplusModifiers {
    /// @dev Modifier to ensure that a car with the given ID exists.
    modifier onlyCarExist(ICarstore _carstore, uint64 _id) {
        if (!_carstore.hasCar(_id)) {
            revert Errors.CarNotExist(_id);
        }
        _;
    }

    /// @dev Modifier to ensure that a car with the given hash does not exist.
    modifier onlyCarNotExist(ICarstore _carstore, bytes32 _hash) {
        if (_carstore.hasCarHash(_hash)) {
            revert Errors.CarAlreadyExists(_carstore.getCarId(_hash), _hash);
        }
        _;
    }

    /// @dev Modifier to ensure that a replica of a car exists.
    modifier onlyCarReplicaExist(
        ICarstore _carstore,
        uint64 _id,
        uint64 _matchingId
    ) {
        if (!_carstore.hasCarReplica(_id, _matchingId)) {
            revert Errors.ReplicaNotExist(_id, _matchingId);
        }
        _;
    }

    /// @dev Modifier to ensure that a replica of a car not exists.
    modifier onlyCarReplicaNotExist(
        ICarstore _carstore,
        uint64 _id,
        uint64 _matchingId
    ) {
        if (_carstore.hasCarReplica(_id, _matchingId)) {
            revert Errors.ReplicaAlreadyExists(_id, _matchingId);
        }
        _;
    }

    /// @dev Modifier to ensure that a replica of a car exists.
    modifier onlyUnsetCarReplicaFilecoinClaimId(
        ICarstore _carstore,
        uint64 _id,
        uint64 _matchingId
    ) {
        if (_carstore.getCarReplicaFilecoinClaimId(_id, _matchingId) != 0) {
            revert Errors.ReplicaFilecoinClaimIdExists(_id, _matchingId);
        }
        _;
    }

    /// @dev Modifier to ensure that a replica state before function do.
    modifier onlyCarReplicaState(
        ICarstore _carstore,
        uint64 _id,
        uint64 _matchingId,
        CarReplicaType.State _state
    ) {
        if (_state != _carstore.getCarReplicaState(_id, _matchingId)) {
            revert Errors.InvalidReplicaState(_id, _matchingId);
        }
        _;
    }

    /// @dev Modifier to ensure that a replica filecoin deal state before function do.
    modifier onlyCarReplicaFilecoinDealState(
        ICarstore _carstore,
        IFilecoin _filecoin,
        uint64 _id,
        uint64 _claimId,
        FilecoinType.DealState _filecoinDealState
    ) {
        if (
            _filecoinDealState !=
            _filecoin.getReplicaDealState(_carstore.getCarHash(_id), _claimId)
        ) {
            revert Errors.InvalidReplicaFilecoinDealState(_id, _claimId);
        }
        _;
    }
}
