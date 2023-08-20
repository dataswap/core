/*******************************************************************************
 *   (c) 2023 DataSwap
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
import {IRoles} from "../../../interfaces/core/IRoles.sol";
import {IFilplus} from "../../../interfaces/core/IFilplus.sol";
import {IFilecoin} from "../../../interfaces/core/IFilecoin.sol";
import {ICarstore} from "../../../interfaces/core/ICarstore.sol";
///shared
import {CarstoreModifiers} from "../../../shared/modifiers/CarstoreModifiers.sol";
///library
import {CarLIB} from "../library/CarLIB.sol";
///type
import {CarReplicaType} from "../../../types/CarReplicaType.sol";

/// @title CarsStorageBase
/// @notice This contract allows adding cars and managing their associated replicas.
/// @dev This contract provides functionality for managing car data and associated replicas.
abstract contract CarstoreBase is ICarstore, CarstoreModifiers {
    using CarLIB for CarReplicaType.Car;

    uint64 public carsCount;
    ///Car CID=> Car
    mapping(bytes32 => CarReplicaType.Car) internal cars;

    IRoles internal roles;
    IFilplus internal filplus;
    IFilecoin internal filecoin;

    constructor(
        IRoles _roles,
        IFilplus _filplus,
        IFilecoin _filecoin
    ) CarstoreModifiers(_roles, _filplus, _filecoin, this) {
        roles = _roles;
        filplus = _filplus;
        filecoin = _filecoin;
    }

    /// @notice Post an event for a car's replica based on the matching ID, triggering state transitions.
    /// @param _cid Car CID associated with the replica.
    /// @param _matchingId Matching ID of the replica.
    /// @param _event Event to be posted.
    function _emitRepicaEvent(
        bytes32 _cid,
        uint64 _matchingId,
        CarReplicaType.Event _event
    )
        internal
        onlyCarExist(_cid)
        onlyNotZero(_matchingId)
        onlyCarReplicaExist(_cid, _matchingId)
    {
        CarReplicaType.Car storage car = cars[_cid];
        car._emitRepicaEvent(_matchingId, _event);
    }
}
