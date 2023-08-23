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
import {DatasetsEvents} from "../../../../../../src/v0.8/shared/events/DatasetsEvents.sol";
import {DatasetType} from "../../../../../../src/v0.8/types/DatasetType.sol";
import {DatasetVerificationTestHelpers} from "./DatasetVerificationTestHelpers.sol";

// Contract definition for test helper functions
contract DatasetAuditTestHelpers is Test, DatasetVerificationTestHelpers {
    /// @dev step 1: setup the env for dataset audit
    function setupForDatasetAudit() internal {
        assertDatasetProofSubmissionExpectingSuccess();
        //TODO: need some verifications requirements
    }

    /// @dev step 2: do dataset audit action,not decouple it because this function too simple

    /// @dev step 3: assert result after dataset auditted
    function assertDatasetAuditted(
        uint64 _datasetId,
        DatasetType.State _state
    ) internal {
        assertEq(uint8(_state), uint8(datasets.getDatasetState(_datasetId)));
    }

    function assertApproveDatasetExpectingSuccess() internal {
        /// @dev step 1: setup the env for dataset audit
        setupForDatasetAudit();

        /// @dev step 2: do dataset audit action
        uint64 datasetId = datasets.datasetsCount();
        vm.prank(governanceContractAddresss);
        vm.expectEmit(true, false, false, true);
        emit DatasetsEvents.DatasetApproved(datasetId);
        datasets.approveDataset(datasetId);

        /// @dev step 3: assert result after dataset auditted
        assertDatasetAuditted(datasetId, DatasetType.State.DatasetApproved);
    }

    ///@dev success test and  as env set for other module
    function assertRejectDatasetExpectingSuccess() internal {
        /// @dev step 1: setup the env for dataset audit
        setupForDatasetAudit();

        /// @dev step 2: do dataset audit action
        uint64 datasetId = datasets.datasetsCount();
        vm.prank(governanceContractAddresss);
        vm.expectEmit(true, false, false, true);
        emit DatasetsEvents.DatasetRejected(datasetId);
        datasets.rejectDataset(datasetId);

        /// @dev step 3: assert result after dataset auditted
        assertDatasetAuditted(datasetId, DatasetType.State.MetadataApproved);
    }
}
