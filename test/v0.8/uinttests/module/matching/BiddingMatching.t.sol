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
import "test/v0.8/testcases/module/matching/BiddingTestSuite.sol";

contract BiddingMatchingTest is Test, MatchingTestSetup {
    /// @notice test case with success
    function testBiddingMatchingWithSuccess(uint64 _amount) public {
        setup();
        BiddingTestCaseWithSuccess testCase = new BiddingTestCaseWithSuccess(
            matchings,
            matchingsTarget,
            matchingsBids,
            helpers,
            assertion
        );
        testCase.run(MatchingType.BidSelectionRule.HighestBid, _amount);
    }

    /// @notice test case with invalid role
    function testBiddingMatchingWithInvalidRole(uint64 _amount) public {
        setup();
        BiddingTestCaseWithInvlalidRole testCase = new BiddingTestCaseWithInvlalidRole(
                matchings,
                matchingsTarget,
                matchingsBids,
                helpers,
                assertion
            );
        testCase.run(MatchingType.BidSelectionRule.HighestBid, _amount);
    }

    /// @notice test case with invalid amount
    function testBiddingMatchingWithInvalidAmount(uint64 _amount) public {
        setup();
        BiddingTestCaseWithInvlalidAmount testCase = new BiddingTestCaseWithInvlalidAmount(
                matchings,
                matchingsTarget,
                matchingsBids,
                helpers,
                assertion
            );
        testCase.run(MatchingType.BidSelectionRule.HighestBid, _amount);

        setup();
        testCase = new BiddingTestCaseWithInvlalidAmount(
            matchings,
            matchingsTarget,
            matchingsBids,
            helpers,
            assertion
        );
        testCase.run(MatchingType.BidSelectionRule.ImmediateAtLeast, _amount);
    }

    /// @notice test case with duplicate bid
    function testBiddingMatchingWithDuplicateBid(uint64 _amount) public {
        setup();
        BiddingTestCaseWithInvlalidDuplicateBid testCase = new BiddingTestCaseWithInvlalidDuplicateBid(
                matchings,
                matchingsTarget,
                matchingsBids,
                helpers,
                assertion
            );
        testCase.run(MatchingType.BidSelectionRule.HighestBid, _amount);
    }

    /// @notice test case with invalid state
    function testBiddingMatchingWithInvalidState(uint64 _amount) public {
        setup();
        BiddingTestCaseWithInvlalidState testCase = new BiddingTestCaseWithInvlalidState(
                matchings,
                matchingsTarget,
                matchingsBids,
                helpers,
                assertion
            );
        testCase.run(MatchingType.BidSelectionRule.HighestBid, _amount);
    }

    /// @notice test case with bid not start
    function testBiddingMatchingWithNotStart(uint64 _amount) public {
        setup();
        BiddingTestCaseWithNotStart testCase = new BiddingTestCaseWithNotStart(
            matchings,
            matchingsTarget,
            matchingsBids,
            helpers,
            assertion
        );
        testCase.run(MatchingType.BidSelectionRule.HighestBid, _amount);
    }

    /// @notice test case with bid is end
    function testBiddingMatchingWithBidIsEnd(uint64 _amount) public {
        setup();
        BiddingTestCaseWithBidIsEnd testCase = new BiddingTestCaseWithBidIsEnd(
            matchings,
            matchingsTarget,
            matchingsBids,
            helpers,
            assertion
        );
        testCase.run(MatchingType.BidSelectionRule.HighestBid, _amount);
    }

    /// @notice test case with invalid storage provider
    function testBiddingWithInvalidStorageProvider(uint64 _amount) public {
        setup();
        BiddingTestCaseWithInvalidStorageProvider testCase = new BiddingTestCaseWithInvalidStorageProvider(
                matchings,
                matchingsTarget,
                matchingsBids,
                helpers,
                assertion
            );
        testCase.run(MatchingType.BidSelectionRule.HighestBid, _amount);
    }
}
