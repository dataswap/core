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

/// interface
import {IRoles} from "src/v0.8/interfaces/core/IRoles.sol";
import {IFilplus} from "src/v0.8/interfaces/core/IFilplus.sol";
import {IFilecoin} from "src/v0.8/interfaces/core/IFilecoin.sol";
import {ICarstore} from "src/v0.8/interfaces/core/ICarstore.sol";
///shared
import {CarstoreModifiers} from "../../../shared/modifiers/CarstoreModifiers.sol";
///library
import {CarLIB} from "../library/CarLIB.sol";
///type
import {CarReplicaType} from "../../../types/CarReplicaType.sol";

import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

/// @title CarsStorageBase
/// @notice This contract allows adding cars and managing their associated replicas.
/// @dev This contract provides functionality for managing car data and associated replicas.
abstract contract CarstoreBase is Initializable, ICarstore, CarstoreModifiers {
    using CarLIB for CarReplicaType.Car;

    uint64 public carsCount;
    ///Car CID=> Car
    mapping(bytes32 => CarReplicaType.Car) internal cars;
    mapping(uint64 => bytes32) internal carsIndexes;

    IRoles public roles;
    IFilplus public filplus;
    IFilecoin public filecoin;
    /// @dev This empty reserved space is put in place to allow future versions to add new
    uint256[32] private __gap;

    /// @notice carstoreBaseInitialize function to initialize the contract and grant the default admin role to the deployer.
    function carstoreBaseInitialize(
        address _roles,
        address _filplus,
        address _filecoin
    ) public virtual onlyInitializing {
        roles = IRoles(_roles);
        filplus = IFilplus(_filplus);
        filecoin = IFilecoin(_filecoin);
    }

    /// @notice Post an event for a car's replica based on the matching ID, triggering state transitions.
    /// @param _id Car ID associated with the replica.
    /// @param _matchingId Matching ID of the replica.
    /// @param _event Event to be posted.
    function _emitRepicaEvent(
        uint64 _id,
        uint64 _matchingId,
        CarReplicaType.Event _event
    )
        internal
        onlyCarExist(this, _id)
        onlyNotZero(_matchingId)
        onlyCarReplicaExist(this, _id, _matchingId)
    {
        CarReplicaType.Car storage car = _getCar(_id);
        car._emitRepicaEvent(_matchingId, _event);
    }

    /// @notice Get the car ID associated with a car.
    /// @param _id Car ID to check.
    /// @return The car struct.
    function _getCar(
        uint64 _id
    ) internal view returns (CarReplicaType.Car storage) {
        bytes32 cid = carsIndexes[_id];
        return cars[cid];
    }

    /// @notice Get a hash of a car based on car id.
    /// @param _id The car's id to get hash.
    /// @return  The hash of the car.
    function _getHash(uint64 _id) internal view returns (bytes32) {
        return carsIndexes[_id];
    }

    /// @notice Get car's id based on car's hash.
    /// @param _hash The car's hash to get ID.
    /// @return  The id of the car.
    function _getId(bytes32 _hash) internal view returns (uint64) {
        return cars[_hash].id;
    }
}
