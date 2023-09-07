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
import {MatchingTestSetup} from "test/v0.8/uinttests/module/matching/setup/MatchingTestSetup.sol";
import {MatchingType} from "src/v0.8/types/MatchingType.sol";
import "test/v0.8/testcases/module/matching/CloseTestSuite.sol";

contract CloseMatchingTest is Test, MatchingTestSetup {
    /// @notice test case with success
    function testCloseMatchingWithSuccess(uint64 _amount) public {
        setup();
        CloseTestCaseWithSuccess testCase = new CloseTestCaseWithSuccess(
            matchings,
            helpers,
            assertion
        );
        testCase.run(MatchingType.BidSelectionRule.HighestBid, _amount);
    }

    /// @notice test case with invalid state
    function testCloseMatchingWithInvalidState() public {
        setup();
        CloseTestCaseWithInvalidState testCase = new CloseTestCaseWithInvalidState(
                matchings,
                helpers,
                assertion
            );
        testCase.run();
    }

    /// @notice test case with at invalid block
    function testCloseMatchingWithAtInvalidBlock(uint64 _amount) public {
        setup();
        CloseTestCaseWithAtInvalidBlock testCase = new CloseTestCaseWithAtInvalidBlock(
                matchings,
                helpers,
                assertion
            );
        testCase.run(MatchingType.BidSelectionRule.HighestBid, _amount);

        setup();
        testCase = new CloseTestCaseWithAtInvalidBlock(
            matchings,
            helpers,
            assertion
        );
        testCase.run(MatchingType.BidSelectionRule.ImmediateAtMost, _amount);
    }
}
