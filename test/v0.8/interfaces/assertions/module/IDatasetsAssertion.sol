/*******************************************************************************
 *   (c) 2023 Dataswap
 *
 *  Licensed under the GNU General external License, Version 3.0 or later (the "License");
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

import {DatasetType} from "src/v0.8/types/DatasetType.sol";
import {IStatisticsBaseAssertion} from "test/v0.8/interfaces/assertions/core/IStatisticsBaseAssertion.sol";

/// @title IDatasetsAssertion
/// @dev This interface defines assertion methods for testing dataset-related functionality.
/// All methods that do not change the state must be tested by methods that will change the state to ensure test coverage.
interface IDatasetsAssertion is IStatisticsBaseAssertion {
    /// @notice Asserts the approval of a dataset.
    /// @param caller The caller's address.
    /// @param _datasetId The ID of the dataset being approved.
    function approveDatasetAssertion(
        address caller,
        uint64 _datasetId
    ) external;

    /// @notice Asserts the rejection of a dataset.
    /// @param caller The caller's address.
    /// @param _datasetId The ID of the dataset being rejected.
    function rejectDatasetAssertion(address caller, uint64 _datasetId) external;

    /// @notice Asserts the submission of dataset metadata.
    /// @param caller The caller's address.
    /// @param _client The client id of the dataset.
    /// @param _accessMethod The access method for the dataset.
    /// @param _sizeInBytes The size of the dataset in bytes.
    /// @param _associatedDatasetId The ID of the associated dataset with the same access method.
    function submitDatasetMetadataAssertion(
        address caller,
        uint64 _client,
        string memory _accessMethod,
        uint64 _sizeInBytes,
        uint64 _associatedDatasetId
    ) external;

    /// @notice Assertion function for submitting dataset replica requirement.
    /// @param caller The address of the caller.
    /// @param _datasetId The ID of the dataset for which proof is submitted.
    /// @param _dataPreparers The client specified data preparer, which the client can either specify or not, but the parameter cannot be empty.
    /// @param _storageProviders The client specified storage provider, which the client can either specify or not, but the parameter cannot be empty.
    /// @param _regions The region specified by the client, and the client must specify a region for the replicas.
    /// @param _countrys The country specified by the client, and the client must specify a country for the replicas.
    /// @param _citys The citys specified by the client, when the country of a replica is duplicated, citys must be specified and cannot be empty.
    function submitDatasetReplicaRequirementsAssertion(
        address caller,
        uint64 _datasetId,
        address[][] memory _dataPreparers,
        address[][] memory _storageProviders,
        uint16[] memory _regions,
        uint16[] memory _countrys,
        uint32[][] memory _citys
    ) external;

    /// @notice Asserts the submission of dataset proof.
    /// @param caller The caller's address.
    /// @param _datasetId The ID of the dataset for which proof is submitted.
    /// @param _dataType The data type of the proof.
    /// @param accessMethod The access method for the proof.
    /// @param _rootHash The root hash of the proof.
    function submitDatasetProofRootAssertion(
        address caller,
        uint64 _datasetId,
        DatasetType.DataType _dataType,
        string calldata accessMethod,
        bytes32 _rootHash
    ) external;

    /// @notice Asserts the submission of dataset proof.
    /// @param caller The caller's address.
    /// @param _datasetId The ID of the dataset for which proof is submitted.
    /// @param _dataType The data type of the proof.
    /// @param _leafHashes The leaf hashes of the proof.
    /// @param _leafSizes The sizes of the leaf hashes.
    /// @param _completed Indicates if the proof is completed.
    function submitDatasetProofAssertion(
        address caller,
        uint64 _datasetId,
        DatasetType.DataType _dataType,
        bytes32[] calldata _leafHashes,
        uint64 _leafIndex,
        uint64[] calldata _leafSizes,
        bool _completed
    ) external;

    /// @notice Asserts the submission of dataset verification.
    /// @param caller The caller's address.
    /// @param _datasetId The ID of the dataset for which verification is submitted.
    /// @param _randomSeed The random seed used for verification.
    /// @param _siblings The Merkle proof siblings.
    /// @param _paths The Merkle proof paths.
    function submitDatasetChallengeProofsAssertion(
        address caller,
        uint64 _datasetId,
        uint64 _randomSeed,
        bytes32[] memory _leaves,
        bytes32[][] memory _siblings,
        uint32[] memory _paths
    ) external;

    /// @notice Asserts the retrieval of dataset metadata.
    /// @param _datasetId The ID of the dataset for which metadata is retrieved.
    /// @param _expectAccessMethod The expected access method in the retrieved metadata.
    /// @param _expectSubmitter The expected submitter address in the retrieved metadata.
    /// @param _expectCreatedBlockNumber The expected block number when the dataset was created.
    function getDatasetMetadataAssertion(
        uint64 _datasetId,
        string memory _expectAccessMethod,
        address _expectSubmitter,
        uint64 _expectCreatedBlockNumber
    ) external;

    /// @notice Asserts the retrieval of dataset proof.
    /// @param _datasetId The ID of the dataset for which proof is retrieved.
    /// @param _dataType The data type of the proof being retrieved.
    /// @param _index The index of the proof.
    /// @param _len The length of the proof.
    /// @param _expectProof The expected proof data.
    function getDatasetProofAssertion(
        uint64 _datasetId,
        DatasetType.DataType _dataType,
        uint64 _index,
        uint64 _len,
        bytes32[] memory _expectProof
    ) external;

    /// @notice Asserts the retrieval of the count of dataset proofs.
    /// @param _datasetId The ID of the dataset for which the count of proofs is retrieved.
    /// @param _dataType The data type of the proofs.
    /// @param _expectCount The expected count of proofs.
    function getDatasetProofCountAssertion(
        uint64 _datasetId,
        DatasetType.DataType _dataType,
        uint64 _expectCount
    ) external;

    /// @notice Assertion function for getting replica's count of dataset.
    /// @param _datasetId The ID of the dataset.
    /// @param _expectCount The expected cars count.
    function getDatasetReplicasCountAssertion(
        uint64 _datasetId,
        uint16 _expectCount
    ) external;

    /// @notice Asserts the retrieval of dataset size.
    /// @param _datasetId The ID of the dataset for which the size is retrieved.
    /// @param _dataType The data type of the dataset.
    /// @param _expectSize The expected size of the dataset.
    function getDatasetSizeAssertion(
        uint64 _datasetId,
        DatasetType.DataType _dataType,
        uint64 _expectSize
    ) external;

    /// @notice Asserts the retrieval of dataset state.
    /// @param _datasetId The ID of the dataset for which the state is retrieved.
    /// @param _expectState The expected state of the dataset.
    function getDatasetStateAssertion(
        uint64 _datasetId,
        DatasetType.State _expectState
    ) external;

    /// @notice Retrieves and asserts challenge proofs submitters for a specific dataset.
    /// @dev This public function is used to get an array of addresses representing auditors for challenge proofs submitters for a given dataset and asserts against the expected auditors.
    /// @param _datasetId The unique identifier of the dataset.
    /// @param _expectAuditors An array of addresses representing the expected challenge proofs submitters (auditors).
    function getDatasetChallengeProofsSubmittersAssertion(
        uint64 _datasetId,
        address[] memory _expectAuditors
    ) external;

    /// @notice Asserts the retrieval of dataset verification.
    /// @param _datasetId The ID of the dataset for which verification is retrieved.
    /// @param _auditor The auditor address for which verification is retrieved.
    /// @param _expectSiblings The expected Merkle proof siblings.
    /// @param _expectPaths The expected Merkle proof paths.
    function getDatasetChallengeProofsAssertion(
        uint64 _datasetId,
        address _auditor,
        bytes32[] memory _expectLeaves,
        bytes32[][] memory _expectSiblings,
        uint32[] memory _expectPaths
    ) external;

    /// @notice Asserts the retrieval of the count of dataset verifications.
    /// @param _datasetId The ID of the dataset for which the count of verifications is retrieved.
    /// @param _expectCount The expected count of verifications.
    function getDatasetChallengeProofsCountAssertion(
        uint64 _datasetId,
        uint16 _expectCount
    ) external;

    /// @notice Asserts whether dataset metadata exists for a given access method.
    /// @param _accessMethod The access method to check for dataset metadata.
    /// @param _expecthasDatasetMetadata The expected result (true if metadata exists, false otherwise).
    function hasDatasetMetadataAssertion(
        string memory _accessMethod,
        bool _expecthasDatasetMetadata
    ) external;

    /// @notice Asserts whether a dataset contains a specific car.
    /// @param _datasetId The ID of the dataset to check.
    /// @param _id The hash of the car to check.
    /// @param _expectIsDatasetContainsCar The expected result (true if the dataset contains the car, false otherwise).
    function isDatasetContainsCarAssertion(
        uint64 _datasetId,
        uint64 _id,
        bool _expectIsDatasetContainsCar
    ) external;

    /// @notice Asserts whether a dataset contains a list of cars.
    /// @param _datasetId The ID of the dataset to check.
    /// @param _ids The list of hashs to check.
    /// @param _expectIsDatasetContainsCars The expected result (true if the dataset contains all the cars, false otherwise).
    function isDatasetContainsCarsAssertion(
        uint64 _datasetId,
        uint64[] memory _ids,
        bool _expectIsDatasetContainsCars
    ) external;

    /// @notice Asserts the count of datasets.
    /// @param _expectCount The expected count of datasets.
    function datasetsCountAssertion(uint64 _expectCount) external;

    /// @notice Assertion function for checking challenge count.
    /// @param _datasetId The ID of the dataset.
    /// @param _expectCount The expected challenge count.
    function getChallengeSubmissionCountAssertion(
        uint64 _datasetId,
        uint64 _expectCount
    ) external;
}
