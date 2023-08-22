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
import {MatchingType} from "../../../../../../src/v0.8/types/MatchingType.sol";
import {MatchingsEvents} from "../../../../../../src/v0.8/shared/events/MatchingsEvents.sol";
import {DatasetType} from "../../../../../../src/v0.8/types/DatasetType.sol";
import {MatchingType} from "../../../../../../src/v0.8/types/MatchingType.sol";
import {RolesType} from "../../../../../../src/v0.8/types/RolesType.sol";
import {MatchingMappingFilesPublishTestHelpers} from "./MatchingMappingFilesPublishTestHelpers.sol";

// Contract definition for test functions
contract MatchingBiddingTestHelpers is
    Test,
    MatchingMappingFilesPublishTestHelpers
{
    /// @dev step 1: setup the env for bidding
    function setupForBidding() internal {
        assertMatchingMappingFilesPublishExpectingSuccess();
    }

    // step 2: do bidding action,not decouple it if this function simple
    function bidding(
        address _bidder,
        uint256 _amount,
        uint64 _blocknumber
    ) internal {
        uint64 matchingId = matchings.matchingsCount();
        role.grantRole(RolesType.STORAGE_PROVIDER, address(_bidder));
        vm.prank(address(_bidder));
        vm.roll(_blocknumber);
        matchings.bidding(matchingId, _amount);
    }

    /// @dev step 3: assert result after bidding
    function assertBidded() internal {
        ///assert bids count
        uint64 matchingId = matchings.matchingsCount();
        assertEq(3, matchings.getMatchingBidsCount(matchingId));

        ///assert bidder's amount
        assertEq(
            999,
            matchings.getMatchingBidAmount(matchingId, address(1999))
        );
        assertEq(
            10000,
            matchings.getMatchingBidAmount(matchingId, address(999))
        );

        ///assert if bidder already bid
        assertTrue(matchings.hasMatchingBid(matchingId, address(999)));
        assertTrue(!matchings.hasMatchingBid(matchingId, address(998)));

        ///assert all bids
        (address[] memory bidders, uint256[] memory amounts) = matchings
            .getMatchingBids(matchingId);
        assertEq(3, bidders.length);
        assertEq(3, amounts.length);
        assertEq(1000, amounts[0]);
        assertEq(10000, amounts[1]);
        assertEq(999, amounts[2]);
        assertEq(address(999), bidders[0]);
        assertEq(address(999), bidders[1]);
        assertEq(address(1999), bidders[2]);
    }

    ///@dev success test and  as env set for other module
    function assertBiddingExpectingSuccess() internal {
        /// @dev step 1: setup the env for bidding
        vm.roll(1);
        setupForBidding();

        /// @dev step 2: do bidding action,not decouple it if this function simple
        bidding(address(999), 1000, 101);
        bidding(address(999), 10000, 102);
        bidding(address(1999), 999, 200);

        /// @dev step 3: assert result after bidding
        assertBidded();
    }
}
