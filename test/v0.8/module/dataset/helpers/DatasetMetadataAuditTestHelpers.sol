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

// Import required external contracts and interfaces
import {Test} from "forge-std/Test.sol";
import {DatasetsEvents} from "src/v0.8/shared/events/DatasetsEvents.sol";
import {DatasetType} from "src/v0.8/types/DatasetType.sol";
import {DatasetMetadataTestHelpers} from "test/v0.8/module/dataset/helpers/DatasetMetadataTestHelpers.sol";

// Contract definition for test helper functions
contract DatasetMetadataAuditTestHelpers is Test, DatasetMetadataTestHelpers {
    /// @dev step 1: setup the env for dataset metadata audit
    function setupForMetadataAudit(
        string memory _title,
        string memory _industry,
        string memory _name,
        string memory _description,
        string memory _source,
        string memory _accessMethod,
        uint64 _sizeInBytes,
        bool _isPublic,
        uint64 _version
    ) internal {
        assertDatasetMetadataSubmissionExpectingSuccess(
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

    /// @dev step 2: do dataset audit metadata action,not decouple it because this function too simple

    /// @dev step 3: assert result after dataset metadata auditted
    function assertMetadataAuditted(
        uint64 _datasetId,
        DatasetType.State _state
    ) internal {
        assertEq(uint8(_state), uint8(datasets.getDatasetState(_datasetId)));
    }

    function assertApproveDatasetMetadataExpectingSuccess(
        string memory _title,
        string memory _industry,
        string memory _name,
        string memory _description,
        string memory _source,
        string memory _accessMethod,
        uint64 _sizeInBytes,
        bool _isPublic,
        uint64 _version
    ) internal {
        /// @dev step 1: setup the env for dataset metadata audit
        setupForMetadataAudit(
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

        /// @dev step 2: do dataset audit metadata action
        uint64 datasetId = datasets.datasetsCount();
        vm.prank(governanceContractAddresss);
        vm.expectEmit(true, false, false, true);
        emit DatasetsEvents.DatasetMetadataApproved(datasetId);
        datasets.approveDatasetMetadata(datasetId);

        /// @dev step 3: assert result after dataset metadata auditted
        assertMetadataAuditted(datasetId, DatasetType.State.MetadataApproved);
    }

    ///@dev success test and  as env set for other module
    function assertRejectDatasetMetadataExpectingSuccess(
        string memory _title,
        string memory _industry,
        string memory _name,
        string memory _description,
        string memory _source,
        string memory _accessMethod,
        uint64 _sizeInBytes,
        bool _isPublic,
        uint64 _version
    ) internal {
        setupForMetadataAudit(
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

        uint64 datasetId = datasets.datasetsCount();
        vm.prank(governanceContractAddresss);
        vm.expectEmit(true, false, false, true);
        emit DatasetsEvents.DatasetMetadataRejected(datasetId);
        datasets.rejectDatasetMetadata(datasetId);

        assertMetadataAuditted(datasetId, DatasetType.State.MetadataRejected);
    }
}