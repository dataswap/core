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

import {IRoles} from "src/v0.8/interfaces/core/IRoles.sol";
import {DatasetType} from "src/v0.8/types/DatasetType.sol";
import {MatchingType} from "src/v0.8/types/MatchingType.sol";

/// @title IMatchingsBid
interface IMatchingsBids {
    /// @notice  Function for bidding on a matching
    function bidding(uint64 _matchingId, uint256 _amount) external payable;

    /// @notice  Function for canceling a matching
    function cancelMatching(uint64 _matchingId) external;

    /// @notice  Function for closing a matching and choosing a winner
    function closeMatching(uint64 _matchingId) external;

    /// @notice Function for getting bids in a matching.
    /// @param _matchingId The matching id to get bids of matching.
    /// @return bidders The addresses of bidders who have placed bids in the current matching.
    /// @return amounts The highest bid placed by any bidder in the current matching.
    /// @return complyFilplusRules Whether the bidders who have placed bids in the current matching comply with Filplus rules.
    /// @return winner The winner of the current matching.
    function getMatchingBids(
        uint64 _matchingId
    )
        external
        view
        returns (
            address[] memory bidders,
            uint256[] memory amounts,
            bool[] memory complyFilplusRules,
            address winner
        );

    /// @notice  Function for getting bid amount of a bidder in a matching
    function getMatchingBidAmount(
        uint64 _matchingId,
        address _bidder
    ) external view returns (uint256);

    /// @notice  Function for getting the count of bids in a matching
    function getMatchingBidsCount(
        uint64 _matchingId
    ) external view returns (uint64);

    /// @notice  Function for getting winner of a matching
    function getMatchingWinner(
        uint64 _matchingId
    ) external view returns (address);

    /// @notice  Function for getting winners of a matchings
    function getMatchingWinners(
        uint64[] memory _matchingIds
    ) external view returns (address[] memory);

    /// @notice  Function for checking if a bidder has a bid in a matching
    function hasMatchingBid(
        uint64 _matchingId,
        address _bidder
    ) external view returns (bool);

    /// @notice Get the Roles contract.
    /// @return Roles contract address.
    function roles() external view returns (IRoles);
}
