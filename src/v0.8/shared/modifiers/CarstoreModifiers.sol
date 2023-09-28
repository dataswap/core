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
import {IRoles} from "src/v0.8/interfaces/core/IRoles.sol";
import {IFilplus} from "src/v0.8/interfaces/core/IFilplus.sol";
import {IFilecoin} from "src/v0.8/interfaces/core/IFilecoin.sol";
import {ICarstore} from "src/v0.8/interfaces/core/ICarstore.sol";
///shared
import {RolesModifiers} from "src/v0.8/shared/modifiers/RolesModifiers.sol";
import {FilplusModifiers} from "src/v0.8/shared/modifiers/FilplusModifiers.sol";
import {Errors} from "src/v0.8/shared/errors/Errors.sol";
///types
import {CarReplicaType} from "src/v0.8/types/CarReplicaType.sol";
import {FilecoinType} from "src/v0.8/types/FilecoinType.sol";

import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

/// @title storages
/// @dev Manages the storage of matched data after successful matching with Filecoin storage deals.
contract CarstoreModifiers is Initializable, RolesModifiers, FilplusModifiers {
    IRoles private roles;
    IFilplus private filplus;
    ICarstore private carstore;
    IFilecoin private filecoin;

    /// @notice initialize function to initialize the contract and grant the default admin role to the deployer.
    function carstoreModifiersInitialize(
        address _roles,
        address _filplus,
        address _filecoin,
        address _carstore
    ) public onlyInitializing {
        RolesModifiers.rolesModifiersInitialize(_roles);
        FilplusModifiers.filplusModifiersInitialize(_filplus);
        roles = IRoles(_roles);
        filplus = IFilplus(_filplus);
        carstore = ICarstore(_carstore);
        filecoin = IFilecoin(_filecoin);
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
    modifier onlyUnsetCarReplicaFilecoinClaimId(
        bytes32 _cid,
        uint64 _matchingId
    ) {
        if (carstore.getCarReplicaFilecoinClaimId(_cid, _matchingId) != 0) {
            revert Errors.ReplicaFilecoinClaimIdExists(_cid, _matchingId);
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
        uint64 _claimId,
        FilecoinType.DealState _filecoinDealState
    ) {
        if (
            _filecoinDealState != filecoin.getReplicaDealState(_cid, _claimId)
        ) {
            revert Errors.InvalidReplicaFilecoinDealState(_cid, _claimId);
        }
        _;
    }
}
