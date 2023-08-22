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
import "forge-std/Test.sol";
import {MatchingBiddingTestHelpers} from "./helpers/MatchingBiddingTestHelpers.sol";
import {MatchingType} from "../../../../../src/v0.8/types/MatchingType.sol";

// Contract definition for test functions
contract MatchingControlTest is Test, MatchingBiddingTestHelpers {
    function testPauseAndResumeMatching() external {
        /// @dev step1:set env
        assertBiddingExpectingSuccess();

        /// @dev step2:pause and assert
        uint64 matchingId = matchings.matchingsCount();
        vm.roll(100);
        matchings.pauseMatching(matchingId);
        /// @dev assert
        assertEq(
            uint8(MatchingType.State.Paused),
            uint8(matchings.getMatchingState(matchingId))
        );

        /// @dev step3:resume and assert
        vm.roll(1100);
        matchings.resumeMatching(matchingId);
        assertEq(
            uint8(MatchingType.State.InProgress),
            uint8(matchings.getMatchingState(matchingId))
        );
        // @dev TODO:step4.1:not staring bidding,can't bidding
        // info: [FAIL. Reason: Call did not revert as expected]
        // vm.expectRevert();
        // bidding(address(9999), 100000, 1100);

        // @dev step4.2:can normally bidding
        vm.roll(1101);
        bidding(address(9999), 100000, 1101);

        // @dev step5: can't pause again and can't resume
        vm.expectRevert();
        matchings.pauseMatching(matchingId);
        vm.expectRevert();
        matchings.resumeMatching(matchingId);

        // @dev step6: can normlly close
        vm.roll(1201);
        matchings.closeMatching(matchingId);
        assertEq(
            uint8(MatchingType.State.Completed),
            uint8(matchings.getMatchingState(matchingId))
        );
        assertEq(address(9999), matchings.getMatchingWinner(matchingId));
    }

    function testFailPauseMatchingAfterClosed() external {
        assertBiddingExpectingSuccess();

        uint64 matchingId = matchings.matchingsCount();
        vm.roll(201);
        matchings.pauseMatching(matchingId);
        /// @dev assert
        assertEq(
            uint8(MatchingType.State.Paused),
            uint8(matchings.getMatchingState(matchingId))
        );
    }

    function testResumeMatching() external {
        assertBiddingExpectingSuccess();
    }

    function testCancelMatchingAtStateInProgress() external {
        assertBiddingExpectingSuccess();
        uint64 matchingId = matchings.matchingsCount();
        matchings.cancelMatching(matchingId);
        /// @dev assert
        assertEq(
            uint8(MatchingType.State.Cancelled),
            uint8(matchings.getMatchingState(matchingId))
        );
    }

    function testCancelMatchingAtStatePublished() external {
        assertMatchingMappingFilesPublishExpectingSuccess();
        uint64 matchingId = matchings.matchingsCount();
        matchings.cancelMatching(matchingId);
        /// @dev assert
        assertEq(
            uint8(MatchingType.State.Cancelled),
            uint8(matchings.getMatchingState(matchingId))
        );
    }

    function testFailCancelMatchingAtClosed() external {
        assertMatchingCloseExpectingSuccess();
        uint64 matchingId = matchings.matchingsCount();
        matchings.cancelMatching(matchingId);
    }

    function testCloseMatching() external {
        assertMatchingCloseExpectingSuccess();
    }
}
