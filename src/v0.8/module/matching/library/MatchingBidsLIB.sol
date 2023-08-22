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

import {MatchingType} from "../../../types/MatchingType.sol";
import {MatchingStateMachineLIB} from "./MatchingStateMachineLIB.sol";

/// @title Matching Bids Library
/// @notice This library provides functions for managing bids in matchings.
library MatchingBidsLIB {
    using MatchingStateMachineLIB for MatchingType.Matching;

    /// @notice Add a bid to the matching.
    /// @dev This function adds a bid to the matching and updates the bids count.
    /// @param self The bids in the matching.
    /// @param _amount The bid amount.
    function _matchingBidding(
        MatchingType.Matching storage self,
        uint256 _amount
    ) internal {
        if (
            self.bidSelectionRule == MatchingType.BidSelectionRule.HighestBid ||
            self.bidSelectionRule ==
            MatchingType.BidSelectionRule.ImmediateAtLeast
        ) {
            require(_amount >= self.biddingThreshold, "Invalid amount");
        }
        if (
            self.bidSelectionRule == MatchingType.BidSelectionRule.LowestBid ||
            self.bidSelectionRule ==
            MatchingType.BidSelectionRule.ImmediateAtMost
        ) {
            require(_amount <= self.biddingThreshold, "Invalid amount");
        }
        require(self.state == MatchingType.State.InProgress, "Invalid state");
        require(
            block.number >=
                self.createdBlockNumber + self.biddingDelayBlockCount,
            "Matching: Bidding is not start"
        );
        require(
            block.number <
                self.createdBlockNumber +
                    self.biddingDelayBlockCount +
                    self.biddingPeriodBlockCount,
            "Matching: Bidding is end"
        );
        if (_hasMatchingBid(self, msg.sender)) {
            if (
                self.bidSelectionRule ==
                MatchingType.BidSelectionRule.HighestBid
            ) {
                require(
                    _amount > _getMatchingBidAmount(self, msg.sender),
                    "Invalid amount"
                );
            }
            if (
                self.bidSelectionRule == MatchingType.BidSelectionRule.LowestBid
            ) {
                require(
                    _amount < _getMatchingBidAmount(self, msg.sender),
                    "Invalid amount"
                );
            }
        }

        MatchingType.Bid memory _bid = MatchingType.Bid(msg.sender, _amount);
        self.bids.push(_bid);
    }

    /// @notice justify is has a winner for a closed matching.
    /// @dev This internal function is used to choose a winner for a closed matching based on the specified rule.
    function _chooseMatchingWinner(
        MatchingType.Matching storage self
    ) internal view returns (address) {
        require(
            self.state == MatchingType.State.Closed,
            "Matching: Invalid state for choosing winner"
        );
        require(
            block.number >=
                self.createdBlockNumber +
                    self.biddingDelayBlockCount +
                    self.biddingPeriodBlockCount,
            "Matching: Bidding period has not ended yet"
        );

        uint256 winningBid = self.biddingThreshold;
        address winner = address(0);
        for (uint64 i = 0; i < self.bids.length; i++) {
            if (
                self.bidSelectionRule ==
                MatchingType.BidSelectionRule.HighestBid
            ) {
                if (self.bids[i].bid > winningBid) {
                    winningBid = self.bids[i].bid;
                    winner = self.bids[i].bidder;
                }
            } else if (
                self.bidSelectionRule == MatchingType.BidSelectionRule.LowestBid
            ) {
                if (self.bids[i].bid < winningBid) {
                    winningBid = self.bids[i].bid;
                    winner = self.bids[i].bidder;
                }
            }
        }

        return winner;
    }

    /// @notice Get the bid amount of a bidder in the matching.
    /// @dev This function retrieves the bid amount of a bidder.
    /// @param self The bids in the matching.
    /// @param _bidder The address of the bidder.
    /// @return The bid amount.
    function _getMatchingBidAmount(
        MatchingType.Matching storage self,
        address _bidder
    ) internal view returns (uint256) {
        for (uint64 i = uint64(self.bids.length - 1); i >= 0; i--) {
            if (_bidder == self.bids[i].bidder) {
                return self.bids[i].bid;
            }
        }
        return 0;
    }

    /// @notice Get the bids.
    function _getMatchingBids(
        MatchingType.Matching storage self
    ) internal view returns (address[] memory, uint256[] memory) {
        address[] memory bidders = new address[](self.bids.length);
        uint256[] memory amounts = new uint256[](self.bids.length);
        for (uint64 i = 0; i < self.bids.length; i++) {
            bidders[i] = self.bids[i].bidder;
            amounts[i] = self.bids[i].bid;
        }
        return (bidders, amounts);
    }

    /// @notice Get the total number of bids in the matching.
    /// @dev This function retrieves the total number of bids in the matching.
    /// @param self The bids in the matching.
    /// @return The total number of bids.
    function _getMatchingBidsCount(
        MatchingType.Matching storage self
    ) internal view returns (uint64) {
        return uint64(self.bids.length);
    }

    /// @notice Check if a bidder has placed a bid in the matching.
    /// @dev This function checks if a bidder has placed a bid.
    /// @param self The bids in the matching.
    /// @param _bidder The address of the bidder.
    /// @return True if the bidder has placed a bid, otherwise false.
    function _hasMatchingBid(
        MatchingType.Matching storage self,
        address _bidder
    ) internal view returns (bool) {
        for (uint64 i = 0; i < self.bids.length; i++) {
            if (_bidder == self.bids[i].bidder) {
                return true;
            }
        }
        return false;
    }
}
