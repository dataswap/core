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
import {DatasetsEvents} from "src/v0.8/shared/events/DatasetsEvents.sol";
import {RolesType} from "src/v0.8/types/RolesType.sol";
import {DatasetProofTestHelpers} from "test/v0.8/module/dataset/helpers/DatasetProofTestHelpers.sol";

// Contract definition for test helper functions
contract DatasetVerificationTestHelpers is Test, DatasetProofTestHelpers {
    uint64 private nonce = 0;

    /// @dev step 1: setup the env for dataset verification submission
    function setupForVerificationSubmission() internal {
        assertDatasetProofSubmissionExpectingSuccess();
    }

    /// @dev step 2: do dataset verification submission action
    function submitDatasetVerification(
        uint64 _datasetId,
        uint64 _pointCount,
        uint64 _pointLeafCount
    ) internal {
        nonce++;
        require(
            _datasetId > 0 && _datasetId <= datasets.datasetsCount(),
            "Invalid params"
        );
        bytes32[][] memory siblings = new bytes32[][](_pointCount);
        uint32[] memory paths = new uint32[](_pointCount);
        for (uint32 i = 0; i < _pointCount; i++) {
            bytes32[] memory leaves = new bytes32[](_pointLeafCount);
            for (uint32 j = 0; j < _pointCount; j++) {
                leaves[j] = TestHelpers.convertUint64ToBytes32(i * 100 + j);
            }
            siblings[i] = leaves;
            paths[i] = i;
        }
        role.grantRole(RolesType.DATASET_AUDITOR, address(this));
        vm.expectEmit(true, false, false, true);
        emit DatasetsEvents.DatasetVerificationSubmitted(1, address(this));
        datasets.submitDatasetVerification(_datasetId, nonce, siblings, paths);
    }

    /// @dev step 3: assert result after dataset verification submitted
    function assertDatasetVerificationSubmtted(
        uint64 _datasetId,
        uint64 _submitersCount
    ) internal {
        assertEq(
            _submitersCount,
            datasets.getDatasetVerificationsCount(_datasetId)
        );
        datasets.getDatasetVerification(_datasetId, address(this));
        assertEq(
            _submitersCount,
            datasets.getDatasetVerificationsCount(_datasetId)
        );
    }

    ///@dev success test and  as env set for other module
    function assertDatasetVerificationSubmissionExpectingSuccess() internal {
        /// @dev step 1: setup the env for dataset verification submission
        setupForVerificationSubmission();
        uint64 datasetId = datasets.datasetsCount();

        /// @dev step 2: do dataset verification submission action
        submitDatasetVerification(datasetId, 10, 1000);
        /// @dev step 3: assert result after dataset verification submitted
        assertDatasetVerificationSubmtted(datasetId, 1);

        /// do one more for getDatasetVerificationsCount test
        /// @dev step 2: do dataset verification submission action
        submitDatasetVerification(datasetId, 10, 1000);
        /// @dev step 3: assert result after dataset verification submitted
        assertDatasetVerificationSubmtted(datasetId, 2);
    }
}
