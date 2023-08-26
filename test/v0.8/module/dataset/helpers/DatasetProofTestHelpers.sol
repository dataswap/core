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

// Import required external contracts and interfaces
import {Test} from "forge-std/Test.sol";
import {TestHelpers} from "src/v0.8/shared/utils/common/TestHelpers.sol";
import {DatasetType} from "src/v0.8/types/DatasetType.sol";
import {DatasetMetadataAuditTestHelpers} from "test/v0.8/module/dataset/helpers/DatasetMetadataAuditTestHelpers.sol";

// Contract definition for test helper functions
contract DatasetProofTestHelpers is Test, DatasetMetadataAuditTestHelpers {
    uint64 private nonce = 0;

    /// @dev step 1: setup the env for dataset proof submission
    function setupForProofSubmission() internal {
        assertApproveDatasetMetadataExpectingSuccess(
            "a",
            "b",
            "c",
            "d",
            "e",
            "_source_accessMethod",
            123456789,
            true,
            0
        );

        assertEq(
            uint8(DatasetType.State.MetadataApproved),
            uint8(datasets.getDatasetState(1))
        );
    }

    /// @dev step 2: do dataset proof(single) submission action,NOTE:private for submitDatasetProofBatch
    function submitDatasetProofSingle(
        uint64 _datasetId,
        DatasetType.DataType _dataType,
        bytes32 _rootHash,
        uint64 _leavesCount,
        uint64 _leafSize,
        bool _complete
    ) private {
        string memory accessMethod;
        bytes32[] memory leafHashes = new bytes32[](_leavesCount);
        uint64[] memory leafSizes = new uint64[](_leavesCount);
        for (uint64 i = 0; i < _leavesCount; i++) {
            leafSizes[i] = _leafSize;
            nonce++; //make sure every car cid is different
            if (DatasetType.DataType.Source == _dataType) {
                leafHashes[i] = TestHelpers.convertUint64ToBytes32(nonce);
            } else {
                leafHashes[i] = TestHelpers.convertUint64ToBytes32(nonce);
            }
        }
        if (DatasetType.DataType.Source == _dataType) {
            accessMethod = "";
        } else {
            accessMethod = "mappingFilesAccessMethod";
        }
        datasets.submitDatasetProof(
            _datasetId,
            _dataType,
            accessMethod,
            _rootHash,
            leafHashes,
            leafSizes,
            _complete
        );
    }

    /// @dev step 2: do dataset proof(batch) submission action
    function submitDatasetProofBatch(
        uint64 _datasetId,
        DatasetType.DataType _dataType,
        uint64 _leavesCount,
        uint64 _leafSize,
        uint64 _proofSubmissionCount
    ) internal {
        nonce++;
        bytes32 rootHash = TestHelpers.convertUint64ToBytes32(
            nonce + 999999999999999999
        );
        bool submitComplete;
        for (uint64 i = 0; i < _proofSubmissionCount; i++) {
            if (i < _proofSubmissionCount - 1) {
                submitComplete = false;
            } else {
                submitComplete = true;
            }
            submitDatasetProofSingle(
                _datasetId,
                _dataType,
                rootHash,
                _leavesCount,
                _leafSize,
                submitComplete
            );
        }
    }

    /// @dev step 3: assert result after dataset proof submitted
    function assertDatasetProofSubmtted(
        uint64 _datasetId,
        uint64 _sourceLeavesCount,
        uint64 _sourceLeafSize,
        uint64 _sourceProofSubmissionCount,
        uint64 _mappingFilesLeavesCount,
        uint64 _mappingFilesLeafSize,
        uint64 _mappingFilesProofSubmissionCount
    ) internal {
        /// @dev step 1: setup the env for dataset proof submission
        assertEq(
            uint8(DatasetType.State.DatasetProofSubmitted),
            uint8(datasets.getDatasetState(_datasetId))
        );

        assertTrue(
            datasets.isDatasetContainsCars(
                _datasetId,
                datasets.getDatasetProof(
                    _datasetId,
                    DatasetType.DataType.Source,
                    0,
                    _sourceLeavesCount
                )
            )
        );
        assertTrue(
            datasets.isDatasetContainsCars(
                _datasetId,
                datasets.getDatasetCars(
                    _datasetId,
                    DatasetType.DataType.MappingFiles,
                    0,
                    _mappingFilesLeavesCount
                )
            )
        );
        assertEq(
            _sourceLeafSize * _sourceLeavesCount * _sourceProofSubmissionCount,
            datasets.getDatasetSize(_datasetId, DatasetType.DataType.Source)
        );
        assertEq(
            _mappingFilesLeafSize *
                _mappingFilesLeavesCount *
                _mappingFilesProofSubmissionCount,
            datasets.getDatasetSize(
                _datasetId,
                DatasetType.DataType.MappingFiles
            )
        );

        assertEq(
            _sourceLeavesCount * _mappingFilesProofSubmissionCount,
            datasets.getDatasetCarsCount(
                _datasetId,
                DatasetType.DataType.Source
            )
        );
        assertEq(
            _mappingFilesLeavesCount * _mappingFilesProofSubmissionCount,
            datasets.getDatasetProofCount(
                _datasetId,
                DatasetType.DataType.MappingFiles
            )
        );
    }

    ///@dev success test and  as env set for other module
    function assertDatasetProofSubmissionExpectingSuccess() internal {
        setupForProofSubmission();

        uint64 datasetId = datasets.datasetsCount();

        /// @dev step 2.1: do dataset proof(batch) submission action for source
        uint64 sourceLeavesCount = 100;
        uint64 sourceLeafSize = 1000000;
        uint64 sourceProofSubmissionCount = 10;
        submitDatasetProofBatch(
            datasetId,
            DatasetType.DataType.Source,
            sourceLeavesCount,
            sourceLeafSize,
            sourceProofSubmissionCount
        );

        // assert state
        assertEq(
            uint8(DatasetType.State.MetadataApproved),
            uint8(datasets.getDatasetState(datasetId))
        );

        /// @dev step 2.2: do dataset proof(batch) submission action for mappingFiles
        uint64 mappingFilesLeavesCount = 10;
        uint64 mappingFilesLeafSize = 1000;
        uint64 mappingFilesProofSubmissionCount = 10;
        submitDatasetProofBatch(
            datasetId,
            DatasetType.DataType.MappingFiles,
            mappingFilesLeavesCount,
            mappingFilesLeafSize,
            mappingFilesProofSubmissionCount
        );

        /// @dev step 3: assert result after dataset proof submitted
        assertDatasetProofSubmtted(
            datasetId,
            sourceLeavesCount,
            sourceLeafSize,
            sourceProofSubmissionCount,
            mappingFilesLeavesCount,
            mappingFilesLeafSize,
            mappingFilesProofSubmissionCount
        );
    }
}
