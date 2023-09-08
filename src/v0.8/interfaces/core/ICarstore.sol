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
    /// @param _cid Car CID to check.
    /// @return The car size of the car.
    function getCarSize(bytes32 _cid) external view returns (uint64);

    /// @notice Get the total size of cars based on an array of car IDs.
    /// @param _cids An array of car IDs for which to calculate the size.
    /// @return The total size of cars.
    function getCarsSize(bytes32[] memory _cids) external view returns (uint64);

    /// @notice Get the dataset ID associated with a car.
    /// @param _cid Car CID to check.
    /// @return The dataset ID of the car.
    /// NOTE: a car only belongs a datasets
    function getCarDatasetId(bytes32 _cid) external view returns (uint64);

    /// @notice Get the matching ids of a replica associated with a car.
    /// @param _cid Car CID associated with the replica.
    /// @return The matching ids of the car's replica.
    function getCarMatchingIds(
        bytes32 _cid
    ) external view returns (uint64[] memory);

    /// @notice Get the replica details associated with a car.
    /// @param _cid Car CID associated with the replica.
    /// @param _matchingId Matching ID of the replica.
    /// @return The dataset ID, state, and Filecoin claim ID of the replica.
    function getCarReplica(
        bytes32 _cid,
        uint64 _matchingId
    ) external view returns (CarReplicaType.State, uint64);

    /// @notice Get the count of replicas associated with a car.
    /// @param _cid Car CID for which to retrieve the replica count.
    /// @return The count of replicas associated with the car.
    function getCarReplicasCount(bytes32 _cid) external view returns (uint16);

    /// @notice Get the Filecoin claim ID associated with a specific replica of a car.
    /// @param _cid Car CID associated with the replica.
    /// @param _matchingId Matching ID of the replica.
    /// @return The Filecoin claim ID of the replica.
    function getCarReplicaFilecoinClaimId(
        bytes32 _cid,
        uint64 _matchingId
    ) external view returns (uint64);

    /// @notice Get the state of a replica associated with a car.
    /// @param _cid Car CID associated with the replica.
    /// @param _matchingId Matching ID of the replica.
    /// @return The state of the replica.
    function getCarReplicaState(
        bytes32 _cid,
        uint64 _matchingId
    ) external view returns (CarReplicaType.State);

    /// @notice Check if a car exists based on its CID.
    /// @param _cid Car CID to check.
    /// @return True if the car exists, false otherwise.
    function hasCar(bytes32 _cid) external view returns (bool);

    /// @notice Check if a replica exists within a car based on its matching ID.
    /// @param _cid Car CID to check.
    /// @param _matchingId Matching ID of the replica to check.
    /// @return True if the replica exists, false otherwise.
    function hasCarReplica(
        bytes32 _cid,
        uint64 _matchingId
    ) external view returns (bool);

    /// @notice Check if multiple cars exist based on their CIDs.
    /// @param _cids Array of car CIDs to check.
    /// @return True if all specified cars exist, false if any one does not exist.
    function hasCars(bytes32[] memory _cids) external view returns (bool);

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
    /// @param _datasetId dataset index of approved dataset
    /// @param _size car size
    /// @param _replicaCount count of car's replicas
    function addCar(
        bytes32 _cid,
        uint64 _datasetId,
        uint64 _size,
        uint16 _replicaCount
    ) external;

    /// @notice Add multiple cars to the storage.
    /// @dev This function allows the addition of multiple cars at once.
    /// @param _cids Array of car CIDs to be added.
    /// @param _datasetId dataset index of approved dataset
    /// @param _sizes car size array
    /// @param _replicaCount count of car's replicas
    function addCars(
        bytes32[] memory _cids,
        uint64 _datasetId,
        uint64[] memory _sizes,
        uint16 _replicaCount
    ) external;

    /// @notice Regist a replica to a car.
    /// @dev This function allows adding a replica to an existing car.
    /// @param _cid Car CID to which the replica will be added.
    /// @param _matchingId Matching ID for the new replica.
    /// @param _replicaIndex The index of the replica.
    function registCarReplica(
        bytes32 _cid,
        uint64 _matchingId,
        uint16 _replicaIndex
    ) external;

    /// @notice Report that matching's state for a replica.
    /// @dev This function allows reporting that the matching for a replica is failed.
    /// @param _cid Car CID associated with the replica.
    /// @param _matchingId Matching ID of the replica.
    /// @param _matchingState Matching's state of the replica, true for success ,false for failed.
    function reportCarReplicaMatchingState(
        bytes32 _cid,
        uint64 _matchingId,
        bool _matchingState
    ) external;

    /// @notice Report that storage deal for a replica has expired.
    /// @dev This function allows reporting that the storage deal for a replica has expired.
    /// @param _cid Car CID associated with the replica.
    /// @param _matchingId Matching ID of the replica.
    function reportCarReplicaExpired(
        bytes32 _cid,
        uint64 _matchingId,
        uint64 _claimId
    ) external;

    /// @notice Report that storage of a replica has been slashed.
    /// @dev This function allows reporting that the storage of a replica has been slashed.
    /// @param _cid Car CID associated with the replica.
    /// @param _matchingId Matching ID of the replica.
    function reportCarReplicaSlashed(
        bytes32 _cid,
        uint64 _matchingId,
        uint64 _claimId
    ) external;

    /// @notice Set the Filecoin claim ID for a replica's storage.
    /// @dev This function allows setting the Filecoin claim ID for a specific replica's storage.
    /// @param _cid Car CID associated with the replica.
    /// @param _matchingId Matching ID of the replica.
    /// @param _claimId New Filecoin claim ID to set for the replica's storage.
    function setCarReplicaFilecoinClaimId(
        bytes32 _cid,
        uint64 _matchingId,
        uint64 _claimId
    ) external;
}
