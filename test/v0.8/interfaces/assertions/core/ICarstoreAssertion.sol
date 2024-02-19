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

// Interface for assert carstore action
/// @dev All methods that do not change the state must be tested by methods that will change the state to ensure test coverage.
interface ICarstoreAssertion {
    /// @dev Asserts the addition of a car to the carstore.
    /// @param _caller The address of the caller.
    /// @param _cid The CID (Content Identifier) of the car.
    /// @param _datasetId The ID of the dataset to which the car is added.
    /// @param _size The size of the car in bytes.
    /// @param _replicaCount count of car's replicas
    function addCarAssertion(
        address _caller,
        bytes32 _cid,
        uint64 _datasetId,
        uint64 _size,
        uint16 _replicaCount
    ) external;

    /// @dev Asserts the addition of multiple cars to the carstore.
    /// @param _caller The address of the caller.
    /// @param _cids An array of CIDs (Content Identifiers) of the cars.
    /// @param _datasetId The ID of the dataset to which the cars are added.
    /// @param _sizes An array of sizes of the cars in bytes.
    /// @param _replicaCount count of car's replicas
    function addCarsAssertion(
        address _caller,
        bytes32[] memory _cids,
        uint64 _datasetId,
        uint64[] memory _sizes,
        uint16 _replicaCount
    ) external;

    /// @dev Asserts the addition of a car replica to a matching.
    /// @param _caller The address of the caller.
    /// @param _id The ID (Content Identifier) of the car replica.
    /// @param _matchingId The ID of the matching to which the car replica is added.
    function registCarReplicaAssertion(
        address _caller,
        uint64 _id,
        uint64 _matchingId,
        uint16 _replicaIndex
    ) external;

    /// @notice Assertion for the `__reportCarReplicaMatchingState` function.
    /// @param _caller The address of the caller.
    /// @param _id The ID (Content Identifier) of the car.
    /// @param _matchingId The matching ID associated with the car replica.
    /// @param _matchingState Matching's state of the replica, true for success ,false for failed.
    function reportCarReplicaMatchingStateAssertion(
        address _caller,
        uint64 _id,
        uint64 _matchingId,
        bool _matchingState
    ) external;

    /// @dev Asserts the reporting of a car replica as expired.
    /// @param _caller The address of the caller.
    /// @param _id The ID (Content Identifier) of the car replica.
    /// @param _matchingId The ID of the matching to which the car replica belongs.
    /// @param _claimId The ID of the Filecoin deal associated with the car replica.
    function reportCarReplicaExpiredAssertion(
        address _caller,
        uint64 _id,
        uint64 _matchingId,
        uint64 _claimId
    ) external;

    /// @dev Asserts the reporting of a car replica as slashed.
    /// @param _caller The address of the caller.
    /// @param _id The ID (Content Identifier) of the car replica.
    /// @param _matchingId The ID of the matching to which the car replica belongs.
    /// @param _claimId The ID of the Filecoin deal associated with the car replica.
    function reportCarReplicaSlashedAssertion(
        address _caller,
        uint64 _id,
        uint64 _matchingId,
        uint64 _claimId
    ) external;

    /// @dev Asserts the setting of a Filecoin claim ID for a car replica.
    /// @param _caller The address of the caller.
    /// @param _id The ID (Content Identifier) of the car replica.
    /// @param _matchingId The ID of the matching to which the car replica belongs.
    /// @param _claimId The ID of the Filecoin deal to set.
    function setCarReplicaFilecoinClaimIdAssertion(
        address _caller,
        uint64 _id,
        uint64 _matchingId,
        uint64 _claimId
    ) external;

    /// @notice Updates the assertion of a car by a caller.
    /// @param _caller The address of the caller updating the assertion.
    /// @param _id The ID of the car to update.
    /// @param _datasetId The ID of the dataset associated with the car.
    /// @param _replicaCount The number of replicas associated with the car.
    function updateCarAssertion(
        address _caller,
        uint64 _id,
        uint64 _datasetId,
        uint16 _replicaCount
    ) external;

    /// @notice Updates the assertion of multiple cars by a caller.
    /// @param _caller The address of the caller updating the assertion.
    /// @param _ids The IDs of the cars to update.
    /// @param _datasetId The ID of the dataset associated with the cars.
    /// @param _replicaCount The number of replicas associated with each car.
    function updateCarsAssertion(
        address _caller,
        uint64[] memory _ids,
        uint64 _datasetId,
        uint16 _replicaCount
    ) external;

    /// @dev Asserts getting the size of a car.
    /// @param _inputId The ID (Content Identifier) of the car.
    /// @param _expectSize The expected size of the car in bytes.
    function getCarSizeAssertion(uint64 _inputId, uint64 _expectSize) external;

    /// @dev Asserts getting the dataset ID of a car.
    /// @param _inputId The ID (Content Identifier) of the car.
    /// @param _expectDatasetId The expected dataset ID to which the car belongs.
    function getCarDatasetIdAssertion(
        uint64 _inputId,
        uint64 _expectDatasetId
    ) external;

    /// @dev Asserts getting information about a car replica.
    /// @param _inputId The ID (Content Identifier) of the car replica.
    /// @param _inputmatchingId The ID of the matching to which the car replica belongs.
    /// @param _expectState The expected state of the car replica.
    /// @param _expectFilecoinClaimId The expected Filecoin claim ID associated with the car replica.
    function getCarReplicaAssertion(
        uint64 _inputId,
        uint64 _inputmatchingId,
        CarReplicaType.State _expectState,
        uint64 _expectFilecoinClaimId
    ) external;

    /// @dev Asserts getting the count of car replicas for a given car.
    /// @param _inputId The ID (Content Identifier) of the car.
    /// @param _expectCount The expected count of car replicas.
    function getCarReplicasCountAssertion(
        uint64 _inputId,
        uint16 _expectCount
    ) external;

    /// @dev Asserts getting the Filecoin claim ID of a car replica.
    /// @param _inputId The ID (Content Identifier) of the car replica.
    /// @param _inputMatchingId The ID of the matching to which the car replica belongs.
    /// @param _expectFilecoinClaimId The expected Filecoin claim ID associated with the car replica.
    function getCarReplicaFilecoinClaimIdAssertion(
        uint64 _inputId,
        uint64 _inputMatchingId,
        uint64 _expectFilecoinClaimId
    ) external;

    /// @dev Asserts getting the state of a car replica.
    /// @param _inputId The ID (Content Identifier) of the car replica.
    /// @param _inputMatchingId The ID of the matching to which the car replica belongs.
    /// @param _expectState The expected state of the car replica.
    function getCarReplicaStateAssertion(
        uint64 _inputId,
        uint64 _inputMatchingId,
        CarReplicaType.State _expectState
    ) external;

    /// @notice Assertion for getting the hash of car based on the car id.
    /// @param _id Car ID which to get car hash.
    /// @param _expectHash The expected hash of the car.
    function getCarHashAssertion(uint64 _id, bytes32 _expectHash) external;

    /// @notice Assertion for getting the hash of car based on the car ids.
    /// @param _ids Car IDs which to get car hashs.
    /// @param _expectHashs The expected hashs of the cars.
    function getCarsHashsAssertion(
        uint64[] memory _ids,
        bytes32[] memory _expectHashs
    ) external;

    ///// @notice Assertion for getting the car's id based on the car's hash.
    ///// @param _hash The hash which to get car id.
    ///// @param _expectId The expected which to get car hash.
    function getCarIdAssertion(bytes32 _hash, uint64 _expectId) external;

    ///// @notice Assertion for getting the ids of cars based on an array of car hashs.
    ///// @param _hashs An array of car hashs for which to cat car hashs.
    ///// @param _expectIds The expected which to get car hash.
    function getCarsIdsAssertion(
        bytes32[] memory _hashs,
        uint64[] memory _expectIds
    ) external;

    /// @dev Asserts whether a car with a given ID exists in the carstore.
    /// @param _inputId The ID (Content Identifier) of the car.
    /// @param _expectIfExist True if the car is expected to exist, false otherwise.
    function hasCarAssertion(uint64 _inputId, bool _expectIfExist) external;

    /// @notice Assertion for checking if a car exists.
    /// @param _inputHash The Hash (Content Identifier) of the car.
    /// @param _expectIfExist A boolean indicating whether the car is expected to exist or not.
    function hasCarHashAssertion(
        bytes32 _inputHash,
        bool _expectIfExist
    ) external;

    /// @dev Asserts whether a car replica with a given CD and matching ID exists.
    /// @param _inputId The ID (Content Identifier) of the car replica.
    /// @param _inputMatchingId The ID of the matching to which the car replica belongs.
    /// @param _expectIfExist True if the car replica is expected to exist, false otherwise.
    function hasCarReplicaAssertion(
        uint64 _inputId,
        uint64 _inputMatchingId,
        bool _expectIfExist
    ) external;

    /// @dev Asserts whether cars with given IDs exist in the carstore.
    /// @param _inputIds An array of IDs (Content Identifiers) of the cars.
    /// @param _expectIfExist True if the cars are expected to exist, false otherwise.
    function hasCarsAssertion(
        uint64[] memory _inputIds,
        bool _expectIfExist
    ) external;

    /// @notice Assertion for checking if multiple cars exist.
    /// @param _inputCids An array of Hashs (Content Identifiers) for the cars.
    /// @param _expectIfExist A boolean indicating whether the cars are expected to exist or not.
    function hasCarsHashsAssertion(
        bytes32[] memory _inputCids,
        bool _expectIfExist
    ) external;

    /// @dev Asserts the total count of cars in the carstore.
    /// @param _expectCount The expected total count of cars.
    function carsCountAssertion(uint64 _expectCount) external;
}
