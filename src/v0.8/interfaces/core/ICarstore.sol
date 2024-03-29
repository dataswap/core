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
    /// @notice Get the car information associated with a car.
    /// @param _id Car ID to check.
    /// @return hash datasetId size replicasCount matchingIds, The car information.
    function getCar(
        uint64 _id
    )
        external
        view
        returns (
            bytes32 hash,
            uint64 datasetId,
            uint64 size,
            uint16 replicasCount,
            uint64[] memory matchingIds
        );

    /// @notice Get the dataset ID associated with a car.
    /// @param _id Car ID to check.
    /// @return The car size of the car.dsfasd
    function getCarSize(uint64 _id) external view returns (uint64);

    /// @notice Get the total size of cars based on an array of car IDs.
    /// @param _ids An array of car IDs for which to calculate the size.
    /// @return The total size of cars.
    function getCarsSize(uint64[] memory _ids) external view returns (uint64);

    /// @notice Get a car associated with piece size.
    /// @param _id Car ID to check.
    /// @return The car piece size of the car.dsfasd
    function getPieceSize(uint64 _id) external view returns (uint64);

    /// @notice Get the total size of cars associated with piece size based on an array of car IDs.
    /// @param _ids An array of car IDs for which to calculate the size.
    /// @return The total size of cars associated with piece.
    function getPiecesSize(uint64[] memory _ids) external view returns (uint64);

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
    /// @return state filecoinClaimId The dataset ID, state, and Filecoin claim ID of the replica.
    function getCarReplica(
        uint64 _id,
        uint64 _matchingId
    )
        external
        view
        returns (CarReplicaType.State state, uint64 filecoinClaimId);

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

    /// @notice get roles object
    function roles() external view returns (IRoles);
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
    function __addCar(
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
    /// @return ids totalSize The ids of the cars and the size.
    function __addCars(
        bytes32[] memory _cids,
        uint64 _datasetId,
        uint64[] memory _sizes,
        uint16 _replicaCount
    ) external returns (uint64[] memory ids, uint64 totalSize);

    /// @notice Regist a replica to a car.
    /// @dev This function allows adding a replica to an existing car.
    /// @param _id Car ID to which the replica will be added.
    /// @param _matchingId Matching ID for the new replica.
    /// @param _replicaIndex The index of the replica.
    function __registCarReplica(
        uint64 _id,
        uint64 _matchingId,
        uint16 _replicaIndex
    ) external;

    /// @notice Report that matching's state for a replica.
    /// @dev This function allows reporting that the matching for a replica is failed.
    /// @param _id Car ID associated with the replica.
    /// @param _matchingId Matching ID of the replica.
    /// @param _matchingState Matching's state of the replica, true for success ,false for failed.
    function __reportCarReplicaMatchingState(
        uint64 _id,
        uint64 _matchingId,
        bool _matchingState
    ) external;

    /// @dev Reports a failure in car replica storage.
    /// @param _id The ID associated with the car replica.
    /// @param _matchingId The ID of the matching process related to the storage failure.
    function __reportCarReplicaStorageFailed(
        uint64 _id,
        uint64 _matchingId
    ) external;

    /// @notice Report that storage deal for a replica has expired.
    /// @dev This function allows reporting that the storage deal for a replica has expired.
    /// @param _id Car ID associated with the replica.
    /// @param _matchingId Matching ID of the replica.
    function __reportCarReplicaExpired(
        uint64 _id,
        uint64 _matchingId,
        uint64 _claimId
    ) external;

    /// @notice Report that storage of a replica has been slashed.
    /// @dev This function allows reporting that the storage of a replica has been slashed.
    /// @param _id Car ID associated with the replica.
    /// @param _matchingId Matching ID of the replica.
    function __reportCarReplicaSlashed(
        uint64 _id,
        uint64 _matchingId,
        uint64 _claimId
    ) external;

    /// @notice Set the Filecoin claim ID for a replica's storage.
    /// @dev This function allows setting the Filecoin claim ID for a specific replica's storage.
    /// @param _id Car ID associated with the replica.
    /// @param _matchingId Matching ID of the replica.
    /// @param _claimId New Filecoin claim ID to set for the replica's storage.
    function __setCarReplicaFilecoinClaimId(
        uint64 _id,
        uint64 _matchingId,
        uint64 _claimId
    ) external;

    /// @notice Updates information for a car.
    /// @dev This function is intended to update various parameters associated with a car, such as its ID, dataset ID, and replica count.
    /// @param _id The ID of the car to be updated.
    /// @param _datasetId The dataset ID associated with the car.
    /// @param _replicaCount The count of replicas associated with the car.
    function __updateCar(
        uint64 _id,
        uint64 _datasetId,
        uint16 _replicaCount
    ) external;

    /// @notice Updates information for multiple cars and returns the total size of the updated cars.
    /// @dev This function is intended to update various parameters associated with multiple cars simultaneously, such as their IDs, dataset ID, and replica count, and then returns the total size of the updated cars.
    /// @param _ids An array containing the IDs of the cars to be updated.
    /// @param _datasetId The dataset ID associated with the cars.
    /// @param _replicaCount The count of replicas associated with each car.
    function __updateCars(
        uint64[] memory _ids,
        uint64 _datasetId,
        uint16 _replicaCount
    ) external;
    /// @notice Get the Roles contract.
    /// @return Roles contract address.
    function roles() external view returns (IRoles);
}
