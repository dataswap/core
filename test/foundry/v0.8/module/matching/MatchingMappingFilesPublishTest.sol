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
import {MatchingMappingFilesPublishTestHelpers} from "./helpers/MatchingMappingFilesPublishTestHelpers.sol";
import {MatchingType} from "../../../../../src/v0.8/types/MatchingType.sol";

// Contract definition for test functions
contract MatchingPublishTest is Test, MatchingMappingFilesPublishTestHelpers {
    function testPublishMatching() external {
        assertMatchingMappingFilesPublishExpectingSuccess();
    }
    // function testBidding(uint64 _matchingId, uint256 _amount) external {}
    // function testPauseMatching(uint64 _matchingId) external {}
    // function testReportMatchingPauseExpired(uint64 _matchingId) external {}
    // function testResumeMatching(uint64 _matchingId) external {}
    // function testCancelMatching(uint64 _matchingId) external {}
    // function testCloseMatching(uint64 _matchingId) external {}
}
