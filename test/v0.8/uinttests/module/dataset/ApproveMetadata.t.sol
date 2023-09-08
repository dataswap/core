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

import {Test} from "forge-std/Test.sol";
import "test/v0.8/testcases/module/dataset/ApproveMetadataTestSuite.sol";
import {DatasetTestSetup} from "test/v0.8/uinttests/module/dataset/setup/DatasetTestSetup.sol";

contract ApproveMetadataTest is Test, DatasetTestSetup {
    /// @notice test case with success
    function testApproveMetadataWithSuccess() public {
        setup();
        ApproveMetadataTestCaseWithSuccess testCase = new ApproveMetadataTestCaseWithSuccess(
                datasets,
                datasetsRequirement,
                datasetsProof,
                datasetsChallenge,
                helpers,
                assertion
            );
        testCase.run();
    }

    /// @notice test case with invalid address
    function testApproveMetadataWithInvalidAddress() public {
        setup();
        ApproveMetadataTestCaseWithInvalidAddress testCase = new ApproveMetadataTestCaseWithInvalidAddress(
                datasets,
                datasetsRequirement,
                datasetsProof,
                datasetsChallenge,
                helpers,
                assertion
            );
        testCase.run();
    }

    /// @notice test case with zero dataset id
    function testApproveMetadataWithZeroID() public {
        setup();
        ApproveMetadataTestCaseWithZeroID testCase = new ApproveMetadataTestCaseWithZeroID(
                datasets,
                datasetsRequirement,
                datasetsProof,
                datasetsChallenge,
                helpers,
                assertion
            );
        testCase.run();
    }

    /// @notice test case with invalid state
    function testApproveMetadataWithInvalidState() public {
        setup();
        ApproveMetadataTestCaseWithInvalidState testCase = new ApproveMetadataTestCaseWithInvalidState(
                datasets,
                datasetsRequirement,
                datasetsProof,
                datasetsChallenge,
                helpers,
                assertion
            );
        testCase.run();
    }
}
