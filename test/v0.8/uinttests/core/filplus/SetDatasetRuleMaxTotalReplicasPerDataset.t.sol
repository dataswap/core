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
import {SetDatasetRuleMaxTotalReplicasPerDatasetTestCaseWithSuccess, SetDatasetRuleMaxTotalReplicasPerDatasetTestCaseWithInvalidGovernancer} from "test/v0.8/testcases/core/filplus/SetDatasetRuleMaxTotalReplicasPerDatasetTestSuite.sol";
import {FilplusTestSetup} from "test/v0.8/uinttests/core/filplus/setup/FilplusTestSetup.sol";

contract SetDatasetRuleMaxTotalReplicasPerDatasetTestPerDatasetTest is
    Test,
    FilplusTestSetup
{
    /// @notice test case with success
    function testSetDatasetRuleMaxTotalReplicasPerDatasetWithSuccess(
        uint16 _newValue
    ) public {
        setup();
        SetDatasetRuleMaxTotalReplicasPerDatasetTestCaseWithSuccess testCase = new SetDatasetRuleMaxTotalReplicasPerDatasetTestCaseWithSuccess(
                filplus,
                assertion,
                generator,
                governanceContractAddresss
            );
        testCase.run(_newValue);
    }

    /// @notice test case with invalid governancer
    function testSetDatasetRuleMaxTotalReplicasPerDatasetWithInvalidGovernancer(
        uint16 _newValue
    ) public {
        setup();
        SetDatasetRuleMaxTotalReplicasPerDatasetTestCaseWithInvalidGovernancer testCase = new SetDatasetRuleMaxTotalReplicasPerDatasetTestCaseWithInvalidGovernancer(
                filplus,
                assertion,
                generator,
                governanceContractAddresss
            );
        testCase.run(_newValue);
    }
}
