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
import {MatchingMappingFilesBiddingTestHelpers} from "test/v0.8/module/matching/helpers/MatchingMappingFilesBiddingTestHelpers.sol";
import {MatchingType} from "src/v0.8/types/MatchingType.sol";
import {RolesType} from "src/v0.8/types/RolesType.sol";

// Contract definition for test functions
contract MatchingMappingFilesControlTest is
    Test,
    MatchingMappingFilesBiddingTestHelpers
{
    function testPauseAndResumeMatching() external {
        /// @dev step1:set env
        assertMappingFilesBiddingExpectingSuccess();

        /// @dev step2:pause and assert
        uint64 matchingId = matchings.matchingsCount();
        vm.roll(99);
        matchings.pauseMatching(matchingId);
        /// @dev assert
        assertEq(
            uint8(MatchingType.State.Paused),
            uint8(matchings.getMatchingState(matchingId))
        );

        /// @dev step3:resume and assert
        vm.roll(1099);
        matchings.resumeMatching(matchingId);
        assertEq(
            uint8(MatchingType.State.InProgress),
            uint8(matchings.getMatchingState(matchingId))
        );
        // @dev step4.1:not staring bidding,can't bidding
        vm.prank(address(this));
        role.grantRole(RolesType.STORAGE_PROVIDER, address(address(9999)));
        vm.roll(1100);
        vm.prank(address(9999));
        vm.expectRevert(bytes("Matching: Bidding is not start"));
        matchings.bidding(matchingId, 10000);

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
        assertMappingFilesBiddingExpectingSuccess();

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
        assertMappingFilesBiddingExpectingSuccess();
    }

    function testCancelMatchingAtStateInProgress() external {
        assertMappingFilesBiddingExpectingSuccess();
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
        assertMatchingMappingFilesCloseExpectingSuccess();
        uint64 matchingId = matchings.matchingsCount();
        matchings.cancelMatching(matchingId);
    }

    function testCloseMatching() external {
        assertMatchingMappingFilesCloseExpectingSuccess();
    }
}
