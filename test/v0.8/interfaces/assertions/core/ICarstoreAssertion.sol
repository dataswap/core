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
    /// @param _cid The CID (Content Identifier) of the car.
    /// @param _datasetId The ID of the dataset to which the car is added.
    /// @param _size The size of the car in bytes.
    /// @param _replicaCount count of car's replicas
    function addCarAssertion(
        bytes32 _cid,
        uint64 _datasetId,
        uint64 _size,
        uint16 _replicaCount
    ) external;

    /// @dev Asserts the addition of multiple cars to the carstore.
    /// @param _cids An array of CIDs (Content Identifiers) of the cars.
    /// @param _datasetId The ID of the dataset to which the cars are added.
    /// @param _sizes An array of sizes of the cars in bytes.
    /// @param _replicaCount count of car's replicas
    function addCarsAssertion(
        bytes32[] memory _cids,
        uint64 _datasetId,
        uint64[] memory _sizes,
        uint16 _replicaCount
    ) external;

    /// @dev Asserts the addition of a car replica to a matching.
    /// @param _cid The CID (Content Identifier) of the car replica.
    /// @param _matchingId The ID of the matching to which the car replica is added.
    function registCarReplicaAssertion(
        bytes32 _cid,
        uint64 _matchingId,
        uint16 _replicaIndex
    ) external;

    /// @notice Assertion for the `reportCarReplicaMatchingState` function.
    /// @param _cid The CID (Content Identifier) of the car.
    /// @param _matchingId The matching ID associated with the car replica.
    /// @param _matchingState Matching's state of the replica, true for success ,false for failed.
    function reportCarReplicaMatchingStateAssertion(
        bytes32 _cid,
        uint64 _matchingId,
        bool _matchingState
    ) external;

    /// @dev Asserts the reporting of a car replica as expired.
    /// @param _cid The CID (Content Identifier) of the car replica.
    /// @param _matchingId The ID of the matching to which the car replica belongs.
    /// @param _claimId The ID of the Filecoin deal associated with the car replica.
    function reportCarReplicaExpiredAssertion(
        bytes32 _cid,
        uint64 _matchingId,
        uint64 _claimId
    ) external;

    /// @dev Asserts the reporting of a car replica as slashed.
    /// @param _cid The CID (Content Identifier) of the car replica.
    /// @param _matchingId The ID of the matching to which the car replica belongs.
    /// @param _claimId The ID of the Filecoin deal associated with the car replica.
    function reportCarReplicaSlashedAssertion(
        bytes32 _cid,
        uint64 _matchingId,
        uint64 _claimId
    ) external;

    /// @dev Asserts the setting of a Filecoin claim ID for a car replica.
    /// @param _cid The CID (Content Identifier) of the car replica.
    /// @param _matchingId The ID of the matching to which the car replica belongs.
    /// @param _claimId The ID of the Filecoin deal to set.
    function setCarReplicaFilecoinClaimIdAssertion(
        bytes32 _cid,
        uint64 _matchingId,
        uint64 _claimId
    ) external;

    /// @dev Asserts getting the size of a car.
    /// @param _inputCid The CID (Content Identifier) of the car.
    /// @param _expectSize The expected size of the car in bytes.
    function getCarSizeAssertion(
        bytes32 _inputCid,
        uint64 _expectSize
    ) external;

    /// @dev Asserts getting the dataset ID of a car.
    /// @param _inputCid The CID (Content Identifier) of the car.
    /// @param _expectDatasetId The expected dataset ID to which the car belongs.
    function getCarDatasetIdAssertion(
        bytes32 _inputCid,
        uint64 _expectDatasetId
    ) external;

    /// @dev Asserts getting information about a car replica.
    /// @param _inputCid The CID (Content Identifier) of the car replica.
    /// @param _inputmatchingId The ID of the matching to which the car replica belongs.
    /// @param _expectState The expected state of the car replica.
    /// @param _expectFilecoinClaimId The expected Filecoin claim ID associated with the car replica.
    function getCarReplicaAssertion(
        bytes32 _inputCid,
        uint64 _inputmatchingId,
        CarReplicaType.State _expectState,
        uint64 _expectFilecoinClaimId
    ) external;

    /// @dev Asserts getting the count of car replicas for a given car.
    /// @param _inputCid The CID (Content Identifier) of the car.
    /// @param _expectCount The expected count of car replicas.
    function getCarReplicasCountAssertion(
        bytes32 _inputCid,
        uint16 _expectCount
    ) external;

    /// @dev Asserts getting the Filecoin claim ID of a car replica.
    /// @param _inputCid The CID (Content Identifier) of the car replica.
    /// @param _inputMatchingId The ID of the matching to which the car replica belongs.
    /// @param _expectFilecoinClaimId The expected Filecoin claim ID associated with the car replica.
    function getCarReplicaFilecoinClaimIdAssertion(
        bytes32 _inputCid,
        uint64 _inputMatchingId,
        uint64 _expectFilecoinClaimId
    ) external;

    /// @dev Asserts getting the state of a car replica.
    /// @param _inputCid The CID (Content Identifier) of the car replica.
    /// @param _inputMatchingId The ID of the matching to which the car replica belongs.
    /// @param _expectState The expected state of the car replica.
    function getCarReplicaStateAssertion(
        bytes32 _inputCid,
        uint64 _inputMatchingId,
        CarReplicaType.State _expectState
    ) external;

    /// @dev Asserts whether a car with a given CID exists in the carstore.
    /// @param _inputCid The CID (Content Identifier) of the car.
    /// @param _expectIfExist True if the car is expected to exist, false otherwise.
    function hasCarAssertion(bytes32 _inputCid, bool _expectIfExist) external;

    /// @dev Asserts whether a car replica with a given CID and matching ID exists.
    /// @param _inputCid The CID (Content Identifier) of the car replica.
    /// @param _inputMatchingId The ID of the matching to which the car replica belongs.
    /// @param _expectIfExist True if the car replica is expected to exist, false otherwise.
    function hasCarReplicaAssertion(
        bytes32 _inputCid,
        uint64 _inputMatchingId,
        bool _expectIfExist
    ) external;

    /// @dev Asserts whether cars with given CIDs exist in the carstore.
    /// @param _inputCids An array of CIDs (Content Identifiers) of the cars.
    /// @param _expectIfExist True if the cars are expected to exist, false otherwise.
    function hasCarsAssertion(
        bytes32[] memory _inputCids,
        bool _expectIfExist
    ) external;

    /// @dev Asserts the total count of cars in the carstore.
    /// @param _expectCount The expected total count of cars.
    function carsCountAssertion(uint64 _expectCount) external;
}
