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

import {CarReplicaType} from "src/v0.8/types/CarReplicaType.sol";
import {IRoles} from "src/v0.8/interfaces/core/IRoles.sol";
import {IFilplus} from "src/v0.8/interfaces/core/IFilplus.sol";
import {IFilecoin} from "src/v0.8/interfaces/core/IFilecoin.sol";

/// @title ICarstoreReadOnly
/// @notice This interface defines the functions for get car status.
interface ICarstoreReadOnly {
    /// @notice Get the dataset ID associated with a car.
    /// @param _id Car ID to check.
    /// @return The car size of the car.
    function getCarSize(uint64 _id) external view returns (uint64);

    /// @notice Get the total size of cars based on an array of car IDs.
    /// @param _ids An array of car IDs for which to calculate the size.
    /// @return The total size of cars.
    function getCarsSize(uint64[] memory _ids) external view returns (uint64);

    /// @notice Get the dataset ID associated with a car.
    /// @param _id Car ID to check.
    /// @return The dataset ID of the car.
    /// NOTE: a car only belongs a datasets
    function getCarDatasetId(uint64 _id) external view returns (uint64);

    /// @notice Get the matching ids of a replica associated with a car.
    /// @param _id Car ID associated with the replica.
    /// @return The matching ids of the car's replica.
    function getCarMatchingIds(
        uint64 _id
    ) external view returns (uint64[] memory);

    /// @notice Get the replica details associated with a car.
    /// @param _id Car ID associated with the replica.
    /// @param _matchingId Matching ID of the replica.
    /// @return The dataset ID, state, and Filecoin claim ID of the replica.
    function getCarReplica(
        uint64 _id,
        uint64 _matchingId
    ) external view returns (CarReplicaType.State, uint64);

    /// @notice Get the count of replicas associated with a car.
    /// @param _id Car ID for which to retrieve the replica count.
    /// @return The count of replicas associated with the car.
    function getCarReplicasCount(uint64 _id) external view returns (uint16);

    /// @notice Get the Filecoin claim ID associated with a specific replica of a car.
    /// @param _id Car ID associated with the replica.
    /// @param _matchingId Matching ID of the replica.
    /// @return The Filecoin claim ID of the replica.
    function getCarReplicaFilecoinClaimId(
        uint64 _id,
        uint64 _matchingId
    ) external view returns (uint64);

    /// @notice Get the state of a replica associated with a car.
    /// @param _id Car ID associated with the replica.
    /// @param _matchingId Matching ID of the replica.
    /// @return The state of the replica.
    function getCarReplicaState(
        uint64 _id,
        uint64 _matchingId
    ) external view returns (CarReplicaType.State);

    /// @notice Get the hash of car based on the car id.
    /// @param _id Car ID which to get car hash.
    /// @return The hash of the car.
    function getCarHash(uint64 _id) external view returns (bytes32);

    /// @notice Get the hashs of cars based on an array of car IDs.
    /// @param _ids An array of car IDs for which to get car hashs.
    /// @return The hashs of cars.
    function getCarsHashs(
        uint64[] memory _ids
    ) external view returns (bytes32[] memory);

    /// @notice Get the car's id based on the car's hash.
    /// @param _hash The hash which to get car id.
    /// @return The id of the car.
    function getCarId(bytes32 _hash) external view returns (uint64);

    /// @notice Get the ids of cars based on an array of car hashs.
    /// @param _hashs An array of car hashs for which to cat car hashs.
    /// @return The ids of cars.
    function getCarsIds(
        bytes32[] memory _hashs
    ) external view returns (uint64[] memory);

    /// @notice Check if a car exists based on its Hash.
    /// @param _hash Car Hash to check.
    /// @return True if the car exists, false otherwise.
    function hasCarHash(bytes32 _hash) external view returns (bool);

    /// @notice Check if a car exists based on its ID.
    /// @param _id Car ID to check.
    /// @return True if the car exists, false otherwise.
    function hasCar(uint64 _id) external view returns (bool);

    /// @notice Check if a replica exists within a car based on its matching ID.
    /// @param _id Car ID to check.
    /// @param _matchingId Matching ID of the replica to check.
    /// @return True if the replica exists, false otherwise.
    function hasCarReplica(
        uint64 _id,
        uint64 _matchingId
    ) external view returns (bool);

    /// @notice Check if a car exists based on its Hashs.
    /// @dev This function returns whether a car exists or not.
    /// @param _hashs  Array of car Hashs to check.
    /// @return True if the car exists, false otherwise.
    function hasCarsHashs(bytes32[] memory _hashs) external view returns (bool);

    /// @notice Check if multiple cars exist based on their IDs.
    /// @param _ids Array of car IDs to check.
    /// @return True if all specified cars exist, false if any one does not exist.
    function hasCars(uint64[] memory _ids) external view returns (bool);

    // Default getter functions for public variables
    function carsCount() external view returns (uint64);

    /// @notice get filecoin object
    function filecoin() external view returns (IFilecoin);

    /// @notice get filplus object
    function filplus() external view returns (IFilplus);
}

/// @title ICarStore
/// @notice This interface defines the functions for managing car data and associated replicas.
interface ICarstore is ICarstoreReadOnly {
    /// @dev Internal function to add a car based on its CID.
    ///      tips: diffent dataset has the same car is dones't matter,maybe need limit replicas count for a car.
    ///      filplus requires dataset replicas,but not limit for car replicas
    /// @param _cid Car CID to be added.
    /// @param _datasetId dataset index of approved dataset.
    /// @param _size car size.
    /// @param _replicaCount count of car's replicas.
    /// @return The id of the car.
    function addCar(
        bytes32 _cid,
        uint64 _datasetId,
        uint64 _size,
        uint16 _replicaCount
    ) external returns (uint64);

    /// @notice Add multiple cars to the storage.
    /// @dev This function allows the addition of multiple cars at once.
    /// @param _cids Array of car CIDs to be added.
    /// @param _datasetId dataset index of approved dataset.
    /// @param _sizes car size array.
    /// @param _replicaCount count of car's replicas.
    /// @return The ids of the cars and the size.
    function addCars(
        bytes32[] memory _cids,
        uint64 _datasetId,
        uint64[] memory _sizes,
        uint16 _replicaCount
    ) external returns (uint64[] memory, uint64);

    /// @notice Regist a replica to a car.
    /// @dev This function allows adding a replica to an existing car.
    /// @param _id Car ID to which the replica will be added.
    /// @param _matchingId Matching ID for the new replica.
    /// @param _replicaIndex The index of the replica.
    function registCarReplica(
        uint64 _id,
        uint64 _matchingId,
        uint16 _replicaIndex
    ) external;

    /// @notice Report that matching's state for a replica.
    /// @dev This function allows reporting that the matching for a replica is failed.
    /// @param _id Car ID associated with the replica.
    /// @param _matchingId Matching ID of the replica.
    /// @param _matchingState Matching's state of the replica, true for success ,false for failed.
    function reportCarReplicaMatchingState(
        uint64 _id,
        uint64 _matchingId,
        bool _matchingState
    ) external;

    /// @notice Report that storage deal for a replica has expired.
    /// @dev This function allows reporting that the storage deal for a replica has expired.
    /// @param _id Car ID associated with the replica.
    /// @param _matchingId Matching ID of the replica.
    function reportCarReplicaExpired(
        uint64 _id,
        uint64 _matchingId,
        uint64 _claimId
    ) external;

    /// @notice Report that storage of a replica has been slashed.
    /// @dev This function allows reporting that the storage of a replica has been slashed.
    /// @param _id Car ID associated with the replica.
    /// @param _matchingId Matching ID of the replica.
    function reportCarReplicaSlashed(
        uint64 _id,
        uint64 _matchingId,
        uint64 _claimId
    ) external;

    /// @notice Set the Filecoin claim ID for a replica's storage.
    /// @dev This function allows setting the Filecoin claim ID for a specific replica's storage.
    /// @param _id Car ID associated with the replica.
    /// @param _matchingId Matching ID of the replica.
    /// @param _claimId New Filecoin claim ID to set for the replica's storage.
    function setCarReplicaFilecoinClaimId(
        uint64 _id,
        uint64 _matchingId,
        uint64 _claimId
    ) external;
}
