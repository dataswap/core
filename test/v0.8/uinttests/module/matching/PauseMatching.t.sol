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
import "test/v0.8/testcases/module/matching/PauseTestSuite.sol";

contract PauseMatchingTest is Test, MatchingTestSetup {
    /// @notice test case with success
    function testPauseMatchingWithSuccess(uint64 _amount) public {
        setup();
        PauseTestCaseWithSuccess testCase = new PauseTestCaseWithSuccess(
            matchings,
            matchingsTarget,
            matchingsBids,
            helpers,
            assertion
        );
        testCase.run(MatchingType.BidSelectionRule.HighestBid, _amount);
    }

    /// @notice test case with invalid sender
    function testPauseMatchingWithInvalidSender(uint64 _amount) public {
        setup();
        PauseTestCaseWithInvalidSender testCase = new PauseTestCaseWithInvalidSender(
                matchings,
                matchingsTarget,
                matchingsBids,
                helpers,
                assertion
            );
        testCase.run(MatchingType.BidSelectionRule.HighestBid, _amount);
    }

    /// @notice test case with invalid state
    function testPauseMatchingWithInvalidState() public {
        setup();
        PauseTestCaseWithInvalidState testCase = new PauseTestCaseWithInvalidState(
                matchings,
                matchingsTarget,
                matchingsBids,
                helpers,
                assertion
            );
        testCase.run();
    }

    /// @notice test case with already paused
    function testPauseMatchingWithAlreadyPaused(uint64 _amount) public {
        setup();
        PauseTestCaseWithAlreadyPaused testCase = new PauseTestCaseWithAlreadyPaused(
                matchings,
                matchingsTarget,
                matchingsBids,
                helpers,
                assertion
            );
        testCase.run(MatchingType.BidSelectionRule.HighestBid, _amount);
    }

    /// @notice test case with already bidding
    function testPauseMatchingWithAlreadyBidding(uint64 _amount) public {
        setup();
        PauseTestCaseWithAlreadyBidding testCase = new PauseTestCaseWithAlreadyBidding(
                matchings,
                matchingsTarget,
                matchingsBids,
                helpers,
                assertion
            );
        testCase.run(MatchingType.BidSelectionRule.HighestBid, _amount);
    }
}
