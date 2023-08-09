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

import "../../types/CarReplicaType.sol";
import "./library/CarReplicaLIB.sol";
import "./library/CarLIB.sol";
import "./ICarStore.sol";

/// @title CarsStorageBase
/// @notice This contract allows adding cars and managing their associated replicas.
/// @dev This contract provides functionality for managing car data and associated replicas.
abstract contract CarStore is ICarStore {
    uint256 private carsCount;
    ///Car CID=> Car
    mapping(bytes32 => CarReplicaType.Car) private cars;

    using CarLIB for CarReplicaType.Car;

    /// @notice Emitted when multiple cars are added to the storage.
    event CarsAdded(bytes32[] _cids);

    /// @notice Emitted when a replica is added to a car.
    event ReplicaAdded(bytes32 indexed _cid, uint256 _matchingId);

    /// @notice Emitted when the Filecoin deal ID is set for a replica's storage.
    event ReplicaFilecoinDealIdSet(
        bytes32 indexed _cid,
        uint256 _matchingId,
        uint256 _filecoinDealId
    );

    /// @dev Modifier to check if a car exists based on its CID.
    modifier onlyCarExists(bytes32 _cid) {
        require(hasCar(_cid), "Car is not exists");
        _;
    }

    /// @dev Modifier to check if a car does not exist based on its CID.
    modifier onlyCarNotExists(bytes32 _cid) {
        require(!hasCar(_cid), "Car already exists");
        _;
    }

    /// @notice Add multiple cars to the storage.
    /// @dev This function allows the addition of multiple cars at once.
    /// @param _cids Array of car CIDs to be added.
    /// @param _datasetId dataset index of approved dataset
    function addCars(bytes32[] memory _cids, uint256 _datasetId) internal {
        for (uint256 i; i < _cids.length; i++) {
            addCar(_cids[i], _datasetId);
        }

        emit CarsAdded(_cids);
    }

    /// @dev Internal function to add a car based on its CID.
    /// @param _cid Car CID to be added.
    /// @param _datasetId dataset index of approved dataset
    /// TODO: diffent dataset has the same car?
    function addCar(
        bytes32 _cid,
        uint256 _datasetId
    ) internal onlyCarNotExists(_cid) {
        carsCount++;
        CarReplicaType.Car storage car = cars[_cid];
        car.setDatasetId(_datasetId);
    }

    /// @notice Add a replica to a car.
    /// @dev This function allows adding a replica to an existing car.
    /// @param _cid Car CID to which the replica will be added.
    /// @param _matchingId Matching ID for the new replica.
    function addReplica(
        bytes32 _cid,
        uint256 _matchingId
    ) internal onlyCarExists(_cid) {
        require(_matchingId != 0, "Invalid matching id");
        CarReplicaType.Car storage car = cars[_cid];
        car.addRepica(_matchingId);

        emit ReplicaAdded(_cid, _matchingId);
    }

    /// @notice Set the Filecoin deal ID for a replica's storage.
    /// @dev This function allows setting the Filecoin deal ID for a specific replica's storage.
    /// @param _cid Car CID associated with the replica.
    /// @param _matchingId Matching ID of the replica.
    /// @param _filecoinDealId New Filecoin deal ID to set for the replica's storage.
    function setReplicaFilecoinDealId(
        bytes32 _cid,
        uint256 _matchingId,
        uint256 _filecoinDealId
    ) internal onlyCarExists(_cid) {
        CarReplicaType.Car storage car = cars[_cid];
        require(
            _matchingId != 0 && _filecoinDealId != 0,
            "Invalid matching id or filecoin deal id for setReplicaFilecoinDealId"
        );
        car.setReplicaFilecoinDealId(_matchingId, _filecoinDealId);

        emit ReplicaFilecoinDealIdSet(_cid, _matchingId, _filecoinDealId);
    }

    /// @notice Get the count of replicas associated with a car.
    /// @dev This function returns the number of replicas associated with a car.
    /// @param _cid Car CID for which to retrieve the replica count.
    /// @return The count of replicas associated with the car.
    function getRepicasCount(
        bytes32 _cid
    ) public view onlyCarExists(_cid) returns (uint256) {
        CarReplicaType.Car storage car = cars[_cid];
        return car.getRepicasCount();
    }

    /// @notice Check if a car exists based on its CID.
    /// @dev This function returns whether a car exists or not.
    /// @param _cid Car CID to check.
    /// @return True if the car exists, false otherwise.
    function hasCar(bytes32 _cid) public view returns (bool) {
        CarReplicaType.Car storage cid = cars[_cid];
        return cid.datasetId != 0;
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

    /// @notice Check if a replica exists within a car based on its matching ID.
    /// @dev This function returns whether a replica with the specified matching ID exists within a car or not.
    /// @param _cid Car CID to check.
    /// @param _matchingId Matching ID of the replica to check.
    /// @return True if the replica exists, false otherwise.
    function hasReplica(
        bytes32 _cid,
        uint256 _matchingId
    ) public view onlyCarExists(_cid) returns (bool) {
        require(_matchingId != 0, "Invalid matching id");
        CarReplicaType.Car storage car = cars[_cid];
        return car.hasReplica(_matchingId);
    }

    /// @notice Report that storage of a replica has failed.
    /// @dev This function allows reporting that the storage of a replica has failed.
    /// @param _cid Car CID associated with the replica.
    /// @param _matchingId Matching ID of the replica.
    function reportReplicaStorageFailed(
        bytes32 _cid,
        uint256 _matchingId
    ) internal onlyCarExists(_cid) {
        require(
            _matchingId != 0,
            "Invalid matching id for reportReplicaStorageFailed"
        );
        emitRepicaEvent(_cid, _matchingId, CarReplicaType.Event.StorageFailed);
    }

    /// @notice Report that storage deal for a replica has expired.
    /// @dev This function allows reporting that the storage deal for a replica has expired.
    /// @param _cid Car CID associated with the replica.
    /// @param _matchingId Matching ID of the replica.
    function reportReplicaStorageDealExpired(
        bytes32 _cid,
        uint256 _matchingId
    ) internal onlyCarExists(_cid) {
        require(
            _matchingId != 0,
            "Invalid matching id for reportReplicaStorageDealExpired"
        );
        emitRepicaEvent(
            _cid,
            _matchingId,
            CarReplicaType.Event.StorageDealExpired
        );
    }

    /// @notice Report that storage of a replica has been slashed.
    /// @dev This function allows reporting that the storage of a replica has been slashed.
    /// @param _cid Car CID associated with the replica.
    /// @param _matchingId Matching ID of the replica.
    function reportReplicaStorageSlashed(
        bytes32 _cid,
        uint256 _matchingId
    ) external onlyCarExists(_cid) {
        require(
            _matchingId != 0,
            "Invalid matching id for reportReplicaStorageSlashed"
        );
        emitRepicaEvent(_cid, _matchingId, CarReplicaType.Event.StorageSlashed);
    }

    /// @dev Internal function to post an event for a replica based on its matching ID.
    /// @param _cid Car CID associated with the replica.
    /// @param _matchingId Matching ID of the replica.
    /// @param _event Event to be posted.
    function emitRepicaEvent(
        bytes32 _cid,
        uint256 _matchingId,
        CarReplicaType.Event _event
    ) private onlyCarExists(_cid) {
        require(
            _matchingId != 0,
            "Invalid matching id for updateRepicaStateByMatchingId"
        );
        CarReplicaType.Car storage car = cars[_cid];
        car.emitRepicaEvent(_matchingId, _event);
    }
}
