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
import {MatchingMappingFilesBiddingTestHelpers} from "test/v0.8/module/matching/helpers/MatchingMappingFilesBiddingTestHelpers.sol";
import {MatchingBiddingTestHelpers} from "test/v0.8/module/matching/helpers/MatchingBiddingTestHelpers.sol";
import {MatchingType} from "src/v0.8/types/MatchingType.sol";
import {RolesType} from "src/v0.8/types/RolesType.sol";
import {DatasetType} from "src/v0.8/types/DatasetType.sol";

// Contract definition for test functions
contract MatchingSourceBidSelectionRuleTest is
    Test,
    MatchingBiddingTestHelpers,
    MatchingMappingFilesBiddingTestHelpers
{
    function testPublishMatchingForLowestBid() external {
        // @dev step1: set env mapping matching complete
        assertMatchingMappingFilesCloseExpectingSuccess();

        // @dev step2: publish source
        uint64 datasetId = datasets.datasetsCount();
        uint64 associatedMappingFilesMatchingId = matchings.matchingsCount();
        //NOTE:assertMatchingCloseExpectingSuccess set bock is >201;but where set 1,also can success.
        vm.roll(1);
        role.grantRole(RolesType.DATASET_PROVIDER, address(this));
        publishMatchingWithDeaultPeriodStrategy(
            datasetId,
            DatasetType.DataType.Source,
            associatedMappingFilesMatchingId,
            MatchingType.BidSelectionRule.LowestBid
        );
        uint64 sourceMatchingId = matchings.matchingsCount();

        // @dev step3:bidding
        vm.roll(101);
        bidding(address(10), 99, 101);
        bidding(address(100), 50, 102);
        bidding(address(1000), 1, 200);

        // @dev step4: close
        vm.roll(201);
        matchings.closeMatching(sourceMatchingId);
        assertEq(
            uint8(MatchingType.State.Completed),
            uint8(matchings.getMatchingState(sourceMatchingId))
        );
        assertEq(address(1000), matchings.getMatchingWinner(sourceMatchingId));
    }

    function testPublishMatchingForImmediateAtLeast() external {
        // @dev step1: set env mapping matching complete
        assertMatchingMappingFilesCloseExpectingSuccess();

        // @dev step2: publish source
        uint64 datasetId = datasets.datasetsCount();
        uint64 associatedMappingFilesMatchingId = matchings.matchingsCount();
        //NOTE:assertMatchingCloseExpectingSuccess set bock is >201;but where set 1,also can success.
        vm.roll(1);
        role.grantRole(RolesType.DATASET_PROVIDER, address(this));
        publishMatchingWithDeaultPeriodStrategy(
            datasetId,
            DatasetType.DataType.Source,
            associatedMappingFilesMatchingId,
            MatchingType.BidSelectionRule.ImmediateAtLeast
        );
        uint64 sourceMatchingId = matchings.matchingsCount();

        // @dev step3:bidding and end
        vm.roll(101);
        bidding(address(10), 1000, 101);
        assertEq(
            uint8(MatchingType.State.Completed),
            uint8(matchings.getMatchingState(sourceMatchingId))
        );
        assertEq(address(10), matchings.getMatchingWinner(sourceMatchingId));
    }

    function testPublishMatchingForImmediateAtMost() external {
        // @dev step1: set env mapping matching complete
        assertMatchingMappingFilesCloseExpectingSuccess();

        // @dev step2: publish source
        uint64 datasetId = datasets.datasetsCount();
        uint64 associatedMappingFilesMatchingId = matchings.matchingsCount();
        //NOTE:assertMatchingCloseExpectingSuccess set bock is >201;but where set 1,also can success.
        vm.roll(1);
        role.grantRole(RolesType.DATASET_PROVIDER, address(this));
        publishMatchingWithDeaultPeriodStrategy(
            datasetId,
            DatasetType.DataType.Source,
            associatedMappingFilesMatchingId,
            MatchingType.BidSelectionRule.ImmediateAtMost
        );
        uint64 sourceMatchingId = matchings.matchingsCount();

        // @dev step3:bidding and end
        vm.roll(101);
        bidding(address(10), 1, 101);
        assertEq(
            uint8(MatchingType.State.Completed),
            uint8(matchings.getMatchingState(sourceMatchingId))
        );
        assertEq(address(10), matchings.getMatchingWinner(sourceMatchingId));
    }
}