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
import {ServiceAssertionBase} from "test/v0.8/assertions/service/abstract/base/ServiceAssertionBase.sol";
import {DatasetType} from "src/v0.8/types/DatasetType.sol";

/// @title DatasetServiceAssertion
abstract contract DatasetServiceAssertion is ServiceAssertionBase {
    /// @notice Assertion function for approving a dataset.
    /// @param caller The address of the caller.
    /// @param _datasetId The ID of the dataset to approve.
    function approveDatasetAssertion(
        address caller,
        uint64 _datasetId
    ) external {
        datasetsAssertion.approveDatasetAssertion(caller, _datasetId);
    }

    /// @notice Assertion function for approving dataset metadata.
    /// @param caller The address of the caller.
    /// @param _datasetId The ID of the dataset for which to approve metadata.
    function approveDatasetMetadataAssertion(
        address caller,
        uint64 _datasetId
    ) external {
        datasetsAssertion.approveDatasetMetadataAssertion(caller, _datasetId);
    }

    /// @notice Assertion function for rejecting a dataset.
    /// @param caller The address of the caller.
    /// @param _datasetId The ID of the dataset to reject.
    function rejectDatasetAssertion(
        address caller,
        uint64 _datasetId
    ) external {
        datasetsAssertion.rejectDatasetAssertion(caller, _datasetId);
    }

    /// @notice Assertion function for rejecting dataset metadata.
    /// @param caller The address of the caller.
    /// @param _datasetId The ID of the dataset for which to reject metadata.
    function rejectDatasetMetadataAssertion(
        address caller,
        uint64 _datasetId
    ) external {
        datasetsAssertion.rejectDatasetMetadataAssertion(caller, _datasetId);
    }

    /// @notice Assertion function for submitting dataset metadata.
    /// @param caller The address of the caller.
    /// @param _title The title of the dataset.
    /// @param _industry The industry of the dataset.
    /// @param _name The name of the dataset.
    /// @param _description The description of the dataset.
    /// @param _source The source of the dataset.
    /// @param _accessMethod The access method of the dataset.
    /// @param _sizeInBytes The size of the dataset in bytes.
    /// @param _isPublic A boolean indicating if the dataset is public.
    /// @param _version The version of the dataset.
    function submitDatasetMetadataAssertion(
        address caller,
        string memory _title,
        string memory _industry,
        string memory _name,
        string memory _description,
        string memory _source,
        string memory _accessMethod,
        uint64 _sizeInBytes,
        bool _isPublic,
        uint64 _version
    ) external {
        datasetsAssertion.submitDatasetMetadataAssertion(
            caller,
            _title,
            _industry,
            _name,
            _description,
            _source,
            _accessMethod,
            _sizeInBytes,
            _isPublic,
            _version
        );
    }

    /// @notice Assertion function for submitting dataset proof.
    /// @param caller The address of the caller.
    /// @param _datasetId The ID of the dataset for which to submit proof.
    /// @param _dataType The data type of the proof.
    /// @param accessMethod The access method of the dataset.
    /// @param _rootHash The root hash of the proof.
    /// @param _leafHashes The leaf hashes of the proof.
    /// @param _leafSizes The sizes of the leaf hashes.
    /// @param _completed A boolean indicating if the proof is completed.
    function submitDatasetProofAssertion(
        address caller,
        uint64 _datasetId,
        DatasetType.DataType _dataType,
        string calldata accessMethod,
        bytes32 _rootHash,
        bytes32[] calldata _leafHashes,
        uint64[] calldata _leafSizes,
        bool _completed
    ) external {
        datasetsAssertion.submitDatasetProofAssertion(
            caller,
            _datasetId,
            _dataType,
            accessMethod,
            _rootHash,
            _leafHashes,
            _leafSizes,
            _completed
        );
    }

    /// @notice Assertion function for submitting dataset verification.
    /// @param caller The address of the caller.
    /// @param _datasetId The ID of the dataset for which to submit verification.
    /// @param _randomSeed The random seed for verification.
    /// @param _siblings The Merkle tree siblings for verification.
    /// @param _paths The Merkle tree paths for verification.
    function submitDatasetVerificationAssertion(
        address caller,
        uint64 _datasetId,
        uint64 _randomSeed,
        bytes32[] memory _leaves,
        bytes32[][] memory _siblings,
        uint32[] memory _paths
    ) external {
        datasetsAssertion.submitDatasetVerificationAssertion(
            caller,
            _datasetId,
            _randomSeed,
            _leaves,
            _siblings,
            _paths
        );
    }

    /// @notice Assertion function for getting dataset metadata.
    /// @param _datasetId The ID of the dataset.
    /// @param _expectAccessMethod The expected access method.
    /// @param _expectSubmitter The expected submitter address.
    /// @param _expectCreatedBlockNumber The expected block number when metadata was created.
    function getDatasetMetadataAssertion(
        uint64 _datasetId,
        string memory _expectAccessMethod,
        address _expectSubmitter,
        uint64 _expectCreatedBlockNumber
    ) public {
        datasetsAssertion.getDatasetMetadataAssertion(
            _datasetId,
            _expectAccessMethod,
            _expectSubmitter,
            _expectCreatedBlockNumber
        );
    }

    /// @notice Assertion function for getting dataset proof.
    /// @param _datasetId The ID of the dataset.
    /// @param _dataType The data type of the proof.
    /// @param _index The index of the proof.
    /// @param _len The length of the proof.
    /// @param _expectProof The expected proof.
    function getDatasetProofAssertion(
        uint64 _datasetId,
        DatasetType.DataType _dataType,
        uint64 _index,
        uint64 _len,
        bytes32[] memory _expectProof
    ) public {
        datasetsAssertion.getDatasetProofAssertion(
            _datasetId,
            _dataType,
            _index,
            _len,
            _expectProof
        );
    }

    /// @notice Assertion function for getting dataset cars (leaf hashes).
    /// @param _datasetId The ID of the dataset.
    /// @param _dataType The data type of the proof.
    /// @param _index The index of the proof.
    /// @param _len The length of the proof.
    /// @param _expectCars The expected cars (leaf hashes).
    function getDatasetCarsAssertion(
        uint64 _datasetId,
        DatasetType.DataType _dataType,
        uint64 _index,
        uint64 _len,
        bytes32[] memory _expectCars
    ) public {
        datasetsAssertion.getDatasetCarsAssertion(
            _datasetId,
            _dataType,
            _index,
            _len,
            _expectCars
        );
    }

    function getDatasetProofSubmitterAssertion(
        uint64 _datasetId,
        address _submitter
    ) public {
        datasetsAssertion.getDatasetProofSubmitterAssertion(
            _datasetId,
            _submitter
        );
    }

    /// @notice Assertion function for getting dataset proof count.
    /// @param _datasetId The ID of the dataset.
    /// @param _dataType The data type of the proof.
    /// @param _expectCount The expected proof count.
    function getDatasetProofCountAssertion(
        uint64 _datasetId,
        DatasetType.DataType _dataType,
        uint64 _expectCount
    ) public {
        datasetsAssertion.getDatasetProofCountAssertion(
            _datasetId,
            _dataType,
            _expectCount
        );
    }

    /// @notice Assertion function for getting dataset cars (leaf hashes) count.
    /// @param _datasetId The ID of the dataset.
    /// @param _dataType The data type of the proof.
    /// @param _expectCount The expected cars count.
    function getDatasetCarsCountAssertion(
        uint64 _datasetId,
        DatasetType.DataType _dataType,
        uint64 _expectCount
    ) public {
        datasetsAssertion.getDatasetCarsCountAssertion(
            _datasetId,
            _dataType,
            _expectCount
        );
    }

    /// @notice Assertion function for getting dataset size.
    /// @param _datasetId The ID of the dataset.
    /// @param _dataType The data type of the proof.
    /// @param _expectSize The expected dataset size.
    function getDatasetSizeAssertion(
        uint64 _datasetId,
        DatasetType.DataType _dataType,
        uint64 _expectSize
    ) public {
        datasetsAssertion.getDatasetSizeAssertion(
            _datasetId,
            _dataType,
            _expectSize
        );
    }

    /// @notice Assertion function for getting dataset state.
    /// @param _datasetId The ID of the dataset.
    /// @param _expectState The expected dataset state.
    function getDatasetStateAssertion(
        uint64 _datasetId,
        DatasetType.State _expectState
    ) public {
        datasetsAssertion.getDatasetStateAssertion(_datasetId, _expectState);
    }

    /// @notice Assertion function for getting dataset verification.
    /// @param _datasetId The ID of the dataset.
    /// @param _auditor The auditor address.
    /// @param _expectSiblings The expected Merkle tree siblings.
    /// @param _expectPaths The expected Merkle tree paths.
    function getDatasetVerificationAssertion(
        uint64 _datasetId,
        address _auditor,
        bytes32[][] memory _expectSiblings,
        uint32[] memory _expectPaths
    ) public {
        datasetsAssertion.getDatasetVerificationAssertion(
            _datasetId,
            _auditor,
            _expectSiblings,
            _expectPaths
        );
    }

    /// @notice Assertion function for getting dataset verification count.
    /// @param _datasetId The ID of the dataset.
    /// @param _expectCount The expected verification count.
    function getDatasetVerificationsCountAssertion(
        uint64 _datasetId,
        uint16 _expectCount
    ) public {
        datasetsAssertion.getDatasetVerificationsCountAssertion(
            _datasetId,
            _expectCount
        );
    }

    /// @notice Assertion function for checking if dataset metadata exists for a given access method.
    /// @param _accessMethod The access method to check.
    /// @param _expecthasDatasetMetadata The expected result, true if metadata exists, false otherwise.
    function hasDatasetMetadataAssertion(
        string memory _accessMethod,
        bool _expecthasDatasetMetadata
    ) public {
        datasetsAssertion.hasDatasetMetadataAssertion(
            _accessMethod,
            _expecthasDatasetMetadata
        );
    }

    /// @notice Assertion function for checking if a dataset contains a specific car (leaf hash).
    /// @param _datasetId The ID of the dataset.
    /// @param _cid The car (leaf hash) to check.
    /// @param _expectIsDatasetContainsCar The expected result, true if the car exists in the dataset, false otherwise.
    function isDatasetContainsCarAssertion(
        uint64 _datasetId,
        bytes32 _cid,
        bool _expectIsDatasetContainsCar
    ) public {
        datasetsAssertion.isDatasetContainsCarAssertion(
            _datasetId,
            _cid,
            _expectIsDatasetContainsCar
        );
    }

    /// @notice Assertion function for checking if a dataset contains multiple cars (leaf hashes).
    /// @param _datasetId The ID of the dataset.
    /// @param _cids The cars (leaf hashes) to check.
    /// @param _expectIsDatasetContainsCars The expected result, true if all the cars exist in the dataset, false otherwise.
    function isDatasetContainsCarsAssertion(
        uint64 _datasetId,
        bytes32[] memory _cids,
        bool _expectIsDatasetContainsCars
    ) public {
        datasetsAssertion.isDatasetContainsCarsAssertion(
            _datasetId,
            _cids,
            _expectIsDatasetContainsCars
        );
    }

    /// @notice Assertion function for checking if a _submitter of the dataset proof is the submitter of the dataset proof.
    /// @param _datasetId The ID of the dataset.
    /// @param _submitter The submitter to check.
    /// @param _expectIsDatasetProofSubmitter The expected result, true if _submitter is the submitter of the dataset proof.
    function isDatasetProofSubmitterAssertion(
        uint64 _datasetId,
        address _submitter,
        bool _expectIsDatasetProofSubmitter
    ) public {
        datasetsAssertion.isDatasetProofSubmitterAssertion(
            _datasetId,
            _submitter,
            _expectIsDatasetProofSubmitter
        );
    }

    /// @notice Assertion function for checking if a _randomSeed is duplicate in dataset or the _auditor is submitted.
    /// @param _datasetId The ID of the dataset.
    /// @param _auditor The _auditor to check.
    /// @param _randomSeed The _randomSeed to check.
    /// @param _expectIsDatasetVerificationDuplicate The expected result, true if dupulicated of the dataset varification.
    function isDatasetVerificationDuplicateAssertion(
        uint64 _datasetId,
        address _auditor,
        uint64 _randomSeed,
        bool _expectIsDatasetVerificationDuplicate
    ) public {
        datasetsAssertion.isDatasetVerificationDuplicateAssertion(
            _datasetId,
            _auditor,
            _randomSeed,
            _expectIsDatasetVerificationDuplicate
        );
    }

    /// @notice Assertion function for checking dataset count.
    /// @param _expectCount The expected dataset count.
    function datasetsCountAssertion(uint64 _expectCount) public {
        datasetsAssertion.datasetsCountAssertion(_expectCount);
    }

    /// @notice Assertion function for checking challenge count.
    /// @param _datasetId The ID of the dataset.
    /// @param _expectCount The expected challenge count.
    function getChallengeCountAssertion(
        uint64 _datasetId,
        uint64 _expectCount
    ) external {
        datasetsAssertion.getChallengeCountAssertion(_datasetId, _expectCount);
    }
}
