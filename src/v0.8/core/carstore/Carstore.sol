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

import {CarReplicaType} from "../../types/CarReplicaType.sol";
import {FilecoinStorageDealState} from "../../types/FilecoinDealType.sol";
import {CommonModifiers} from "../../shared/modifiers/CommonModifiers.sol";
import {FilecoinDealUtils} from "../../shared/filecoin/FilecoinDealUtils.sol";
import {ICarstore} from "../../interfaces/core/ICarstore.sol";
import {CarReplicaLIB} from "./library/CarReplicaLIB.sol";
import {CarLIB} from "./library/CarLIB.sol";

/// @title CarsStorageBase
/// @notice This contract allows adding cars and managing their associated replicas.
/// @dev This contract provides functionality for managing car data and associated replicas.
contract Carstore is ICarstore, CommonModifiers {
    using CarLIB for CarReplicaType.Car;

    uint256 public carsCount;
    ///Car CID=> Car
    mapping(bytes32 => CarReplicaType.Car) private cars;

    /// @notice Emitted when multiple cars are added to the storage.
    event CarsAdded(bytes32[] _cids);

    /// @notice Emitted when a replica is added to a car.
    event CarReplicaAdded(bytes32 indexed _cid, uint256 _matchingId);

    /// @notice Report that storage deal for a replica has expired.
    /// @dev This function allows reporting that the storage deal for a replica has expired.
    /// @param _cid Car CID associated with the replica.
    /// @param _matchingId Matching ID of the replica.
    event CarReplicaExpired(bytes32 indexed _cid, uint256 _matchingId);

    /// @notice Report that storage of a replica has failed.
    /// @dev This function allows reporting that the storage of a replica has failed.
    /// @param _cid Car CID associated with the replica.
    /// @param _matchingId Matching ID of the replica.
    event CarReplicaFailed(bytes32 indexed _cid, uint256 _matchingId);

    /// @notice Emitted when the Filecoin deal ID is set for a replica's storage.
    event CarReplicaFilecoinDealIdSet(
        bytes32 indexed _cid,
        uint256 _matchingId,
        uint256 _filecoinDealId
    );

    /// @notice Report that storage of a replica has been slashed.
    /// @dev This function allows reporting that the storage of a replica has been slashed.
    /// @param _cid Car CID associated with the replica.
    /// @param _matchingId Matching ID of the replica.
    event CarReplicaSlashed(bytes32 indexed _cid, uint256 _matchingId);

    /// @dev Modifier to ensure that a car with the given CID exists.
    modifier carExist(bytes32 _cid) {
        require(hasCar(_cid), "Car is not exists");
        _;
    }

    /// @dev Modifier to ensure that a car with the given CID does not exist.
    modifier carNotExist(bytes32 _cid) {
        require(!hasCar(_cid), "Car already exists");
        _;
    }

    /// @dev Modifier to ensure that a replica filecoin deal state before function do.
    modifier onlyCarReplicaFilecoinDealState(
        bytes32 _cid,
        uint256 _matchingId,
        FilecoinStorageDealState _filecoinDealState
    ) {
        require(hasCar(_cid), "Car is not exists");
        require(hasCarReplica(_cid, _matchingId), "replica is not exists");
        require(
            CarReplicaType.State.Stored ==
                getCarReplicaState(_cid, _matchingId),
            "Invalid replica state"
        );
        require(
            FilecoinStorageDealState.Successed ==
                FilecoinDealUtils.getFilecoinStorageDealState(
                    _cid,
                    // TODO:_filecoinDealId, instead with _matchingId first https://github.com/dataswap/core/issues/27
                    _matchingId
                ),
            "Invalid replica filecoin deal state"
        );
        _;
    }

    /// @dev Modifier to ensure that a replica state before function do.
    modifier onlyCarReplicaState(
        bytes32 _cid,
        uint256 _matchingId,
        CarReplicaType.State _state
    ) {
        require(
            _state == getCarReplicaState(_cid, _matchingId),
            "Invalid replica state"
        );
        _;
    }

    /// @dev Modifier to ensure that a replica of a car exists.
    modifier carReplicaExist(bytes32 _cid, uint256 _matchingId) {
        require(hasCarReplica(_cid, _matchingId), "replica is not exists");
        _;
    }

    /// @dev Modifier to ensure that a replica of a car exists.
    modifier carReplicaFilecoinDealIdNotExist(
        bytes32 _cid,
        uint256 _matchingId
    ) {
        require(
            0 == getCarReplicaFilecoinDealId(_cid, _matchingId),
            "replica  filecoin deal id exists"
        );
        _;
    }

    /// @dev Modifier to ensure that a replica of a car not exists.
    modifier carReplicaNotExist(bytes32 _cid, uint256 _matchingId) {
        require(!hasCarReplica(_cid, _matchingId), "replica already exists");
        _;
    }

    /// @notice Post an event for a car's replica based on the matching ID, triggering state transitions.
    /// @param _cid Car CID associated with the replica.
    /// @param _matchingId Matching ID of the replica.
    /// @param _event Event to be posted.
    function __emitRepicaEvent(
        bytes32 _cid,
        uint256 _matchingId,
        CarReplicaType.Event _event
    )
        private
        carExist(_cid)
        notZeroId(_matchingId)
        carReplicaExist(_cid, _matchingId)
    {
        CarReplicaType.Car storage car = cars[_cid];
        car._emitRepicaEvent(_matchingId, _event);
    }

    /// @dev Internal function to add a car based on its CID.
    ///      tips: diffent dataset has the same car is dones't matter,maybe need limit replicas count for a car.
    ///      filplus requires dataset replicas,but not limit for car replicas
    /// @param _cid Car CID to be added.
    /// @param _datasetId dataset index of approved dataset
    function addCar(
        bytes32 _cid,
        uint256 _datasetId
    ) public carNotExist(_cid) notZeroId(_datasetId) {
        carsCount++;
        CarReplicaType.Car storage car = cars[_cid];
        car._setDatasetId(_datasetId);
    }

    /// @notice Add multiple cars to the storage.
    /// @dev This function allows the addition of multiple cars at once.
    /// @param _cids Array of car CIDs to be added.
    /// @param _datasetId dataset index of approved dataset
    function addCars(
        bytes32[] memory _cids,
        uint256 _datasetId
    ) external notZeroId(_datasetId) {
        for (uint256 i; i < _cids.length; i++) {
            addCar(_cids[i], _datasetId);
        }

        emit CarsAdded(_cids);
    }

    /// @notice Add a replica to a car.
    /// @dev This function allows adding a replica to an existing car.
    /// @param _cid Car CID to which the replica will be added.
    /// @param _matchingId Matching ID for the new replica.
    function addCarReplica(
        bytes32 _cid,
        uint256 _matchingId
    )
        external
        carExist(_cid)
        notZeroId(_matchingId)
        carReplicaNotExist(_cid, _matchingId)
    {
        CarReplicaType.Car storage car = cars[_cid];
        car._addRepica(_matchingId);

        emit CarReplicaAdded(_cid, _matchingId);
    }

    /// @notice Report that storage deal for a replica has expired.
    /// @dev This function allows reporting that the storage deal for a replica has expired.
    /// @param _cid Car CID associated with the replica.
    /// @param _matchingId Matching ID of the replica.
    function reportCarReplicaExpired(
        bytes32 _cid,
        uint256 _matchingId
    )
        external
        carExist(_cid)
        notZeroId(_matchingId)
        carReplicaExist(_cid, _matchingId)
        onlyCarReplicaFilecoinDealState(
            _cid,
            _matchingId,
            FilecoinStorageDealState.Expired
        )
    {
        __emitRepicaEvent(
            _cid,
            _matchingId,
            CarReplicaType.Event.StorageDealExpired
        );
        emit CarReplicaExpired(_cid, _matchingId);
    }

    /// @notice Report that storage of a replica has failed.
    /// @dev This function allows reporting that the storage of a replica has failed.
    /// @param _cid Car CID associated with the replica.
    /// @param _matchingId Matching ID of the replica.
    function reportCarReplicaFailed(
        bytes32 _cid,
        uint256 _matchingId
    )
        external
        carExist(_cid)
        notZeroId(_matchingId)
        carReplicaExist(_cid, _matchingId)
        onlyCarReplicaFilecoinDealState(
            _cid,
            _matchingId,
            FilecoinStorageDealState.Failed
        )
    {
        __emitRepicaEvent(
            _cid,
            _matchingId,
            CarReplicaType.Event.StorageFailed
        );
        emit CarReplicaFailed(_cid, _matchingId);
    }

    /// @notice Report that storage of a replica has been slashed.
    /// @dev This function allows reporting that the storage of a replica has been slashed.
    /// @param _cid Car CID associated with the replica.
    /// @param _matchingId Matching ID of the replica.
    function reportCarReplicaSlashed(
        bytes32 _cid,
        uint256 _matchingId
    )
        external
        carExist(_cid)
        notZeroId(_matchingId)
        carReplicaExist(_cid, _matchingId)
        onlyCarReplicaState(_cid, _matchingId, CarReplicaType.State.Stored)
        onlyCarReplicaFilecoinDealState(
            _cid,
            _matchingId,
            FilecoinStorageDealState.Slashed
        )
    {
        __emitRepicaEvent(
            _cid,
            _matchingId,
            CarReplicaType.Event.StorageSlashed
        );
        emit CarReplicaSlashed(_cid, _matchingId);
    }

    /// @notice Set the Filecoin deal ID for a replica's storage.
    /// @dev This function allows setting the Filecoin deal ID for a specific replica's storage.
    /// @param _cid Car CID associated with the replica.
    /// @param _matchingId Matching ID of the replica.
    /// @param _filecoinDealId New Filecoin deal ID to set for the replica's storage.
    function setCarReplicaFilecoinDealId(
        bytes32 _cid,
        uint256 _matchingId,
        uint64 _filecoinDealId
    )
        external
        carExist(_cid)
        notZeroId(_matchingId)
        notZeroId(_filecoinDealId)
        carReplicaExist(_cid, _matchingId)
        onlyCarReplicaState(_cid, _matchingId, CarReplicaType.State.Matched)
        carReplicaFilecoinDealIdNotExist(_cid, _matchingId)
    {
        CarReplicaType.Car storage car = cars[_cid];
        car._setReplicaFilecoinDealId(_matchingId, _filecoinDealId);

        emit CarReplicaFilecoinDealIdSet(_cid, _matchingId, _filecoinDealId);
    }

    /// @notice Get the dataset ID associated with a car.
    /// @param _cid Car CID to check.
    /// @return The dataset ID of the car.
    function getCarDatasetId(
        bytes32 _cid
    ) public view carExist(_cid) returns (uint256) {
        CarReplicaType.Car storage car = cars[_cid];
        return car._getDatasetId();
    }

    /// @notice Get the replica details associated with a car.
    /// @param _cid Car CID associated with the replica.
    /// @param _matchingId Matching ID of the replica.
    /// @return The dataset ID, state, and Filecoin deal ID of the replica.
    function getCarReplica(
        bytes32 _cid,
        uint256 _matchingId
    )
        public
        view
        carExist(_cid)
        notZeroId(_matchingId)
        carReplicaExist(_cid, _matchingId)
        returns (CarReplicaType.State, uint64)
    {
        CarReplicaType.Car storage car = cars[_cid];
        return (
            car._getReplicaState(_matchingId),
            car._getReplicaFilecoinDealId(_matchingId)
        );
    }

    /// @notice Get the count of replicas associated with a car.
    /// @dev This function returns the number of replicas associated with a car.
    /// @param _cid Car CID for which to retrieve the replica count.
    /// @return The count of replicas associated with the car.
    function getCarRepicasCount(
        bytes32 _cid
    ) public view carExist(_cid) returns (uint32) {
        CarReplicaType.Car storage car = cars[_cid];
        return car._getRepicasCount();
    }

    /// @notice Get the Filecoin deal ID associated with a specific replica of a car.
    /// @param _cid Car CID associated with the replica.
    /// @param _matchingId Matching ID of the replica.
    /// @return The Filecoin deal ID of the replica.
    function getCarReplicaFilecoinDealId(
        bytes32 _cid,
        uint256 _matchingId
    )
        public
        view
        carExist(_cid)
        notZeroId(_matchingId)
        carReplicaExist(_cid, _matchingId)
        onlyCarReplicaState(_cid, _matchingId, CarReplicaType.State.Stored)
        returns (uint64)
    {
        CarReplicaType.Car storage car = cars[_cid];
        return car._getReplicaFilecoinDealId(_matchingId);
    }

    /// @notice Get the state of a replica associated with a car.
    /// @param _cid Car CID associated with the replica.
    /// @param _matchingId Matching ID of the replica.
    /// @return The state of the replica.
    function getCarReplicaState(
        bytes32 _cid,
        uint256 _matchingId
    )
        public
        view
        carExist(_cid)
        notZeroId(_matchingId)
        carReplicaExist(_cid, _matchingId)
        returns (CarReplicaType.State)
    {
        CarReplicaType.Car storage car = cars[_cid];
        return car._getReplicaState(_matchingId);
    }

    /// @notice Check if a car exists based on its CID.
    /// @dev This function returns whether a car exists or not.
    /// @param _cid Car CID to check.
    /// @return True if the car exists, false otherwise.
    function hasCar(bytes32 _cid) public view returns (bool) {
        CarReplicaType.Car storage cid = cars[_cid];
        return cid.datasetId != 0;
    }

    /// @notice Check if a replica exists within a car based on its matching ID.
    /// @dev This function returns whether a replica with the specified matching ID exists within a car or not.
    /// @param _cid Car CID to check.
    /// @param _matchingId Matching ID of the replica to check.
    /// @return True if the replica exists, false otherwise.
    function hasCarReplica(
        bytes32 _cid,
        uint256 _matchingId
    ) public view carExist(_cid) returns (bool) {
        require(_matchingId != 0, "Invalid matching id");
        CarReplicaType.Car storage car = cars[_cid];
        return car._hasReplica(_matchingId);
    }

    /// @notice Check if multiple cars exist based on their CIDs.
    /// @dev This function returns whether all the specified cars exist or not.
    /// @param _cids Array of car CIDs to check.
    /// @return True if all specified cars exist, false if any one does not exist.
    function hasCars(bytes32[] memory _cids) public view returns (bool) {
        for (uint256 i; i < _cids.length; i++) {
            if (!hasCar(_cids[i])) return false;
        }
        return true;
    }
}
