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

import "../../../types/MatchingType.sol";

/// @title Matching Library
/// @notice This library provides functions for managing matchings and their states.
/// @dev This library is used to manage the lifecycle and states of matchings.
library MatchingLIB {
    /// @notice Publish a matching.
    /// @dev This function is used to publish a matching and initiate the matching process.
    function publish(MatchingType.Matching storage self) external {
        require(
            self.state == MatchingType.State.None,
            "Matching: Invalid state for publishing"
        );
        postEvent(self, MatchingType.Event.Publish);

        if (filPlusCheck(self)) {
            //TODO:peherps add notary auditor
            postEvent(self, MatchingType.Event.FilPlusCheckSuccessed);
        } else {
            postEvent(self, MatchingType.Event.FilPlusCheckFailed);
        }
    }

    /// @notice Pause a matching.
    /// @dev This function is used to pause a matching that is in progress.
    function pause(MatchingType.Matching storage self) external {
        require(
            self.state == MatchingType.State.InProgress,
            "Matching: Invalid state for pausing"
        );
        postEvent(self, MatchingType.Event.Pause);
    }

    /// @notice Report that a pause has expired.
    /// @dev This function is used to report that a pause has expired for a paused matching.
    function reportPauseExpired(MatchingType.Matching storage self) external {
        require(
            self.state == MatchingType.State.Paused,
            "Matching: Invalid state for reportPauseExpired"
        );
        postEvent(self, MatchingType.Event.PauseExpired);
    }

    /// @notice Resume a paused matching.
    /// @dev This function is used to resume a paused matching.
    function resume(MatchingType.Matching storage self) external {
        require(
            self.state == MatchingType.State.Paused,
            "Matching: Invalid state for resuming"
        );
        postEvent(self, MatchingType.Event.Resume);
    }

    /// @notice Cancel a matching.
    /// @dev This function is used to cancel a matching that is published, in progress, or paused.
    function cancel(MatchingType.Matching storage self) external {
        require(
            self.state == MatchingType.State.Published ||
                self.state == MatchingType.State.InProgress ||
                self.state == MatchingType.State.Paused,
            "Matching: Invalid state for canceling"
        );
        postEvent(self, MatchingType.Event.Cancel);
    }

    /// @notice Submit a bid for a matching.
    /// @dev This function is used to submit a bid for a matching in progress.
    /// @param _bid The bid information to be submitted.
    function bidding(
        MatchingType.Matching storage self,
        MatchingType.Bid memory _bid
    ) external {
        require(
            self.state == MatchingType.State.InProgress,
            "Matching: Invalid state for bidding"
        );
        require(
            block.number >=
                self.createdBlockNumber + self.biddingDelayBlockCount,
            "Matching: Bidding is not start"
        );

        self.bids.push(_bid);
    }

    /// @notice Close a matching and choose a winner.
    /// @dev This function is used to close a matching and choose a winner based on the specified rule.
    /// @param _rule The rule for choosing the winner (highest or lowest bid).
    function close(
        MatchingType.Matching storage self,
        MatchingType.WinnerBidRule _rule
    ) external {
        require(
            self.state == MatchingType.State.InProgress,
            "Matching: Invalid state for closing"
        );
        require(
            block.number >=
                self.createdBlockNumber +
                    self.biddingDelayBlockCount +
                    self.biddingPeriodBlockCount,
            "Matching: Bidding period not expired"
        );
        postEvent(self, MatchingType.Event.Close);
        chooseWinner(self, _rule);
    }

    /// @notice Choose a winner for a closed matching.
    /// @dev This internal function is used to choose a winner for a closed matching based on the specified rule.
    /// @param _rule The rule for choosing the winner (highest or lowest bid).
    function chooseWinner(
        MatchingType.Matching storage self,
        MatchingType.WinnerBidRule _rule
    ) internal {
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
        require(
            _rule == MatchingType.WinnerBidRule.HighestBid ||
                _rule == MatchingType.WinnerBidRule.LowestBid,
            "Matching: Invalid winner bid rule"
        );

        uint256 winningBid = self.biddingThreshold;
        address winner = address(0);
        for (uint256 i = 0; i < self.bids.length; i++) {
            if (_rule == MatchingType.WinnerBidRule.HighestBid) {
                if (self.bids[i].bid > winningBid) {
                    winningBid = self.bids[i].bid;
                    winner = self.bids[i].bidder;
                }
            } else if (_rule == MatchingType.WinnerBidRule.LowestBid) {
                if (self.bids[i].bid < winningBid) {
                    winningBid = self.bids[i].bid;
                    winner = self.bids[i].bidder;
                }
            }
        }

        if (winner == address(0)) {
            postEvent(self, MatchingType.Event.NoWinner);
        } else {
            // postCompletionAction(self, _carsStorageContract, _matchingId);
            self.winner = winner;
            postEvent(self, MatchingType.Event.HasWinner);
        }
    }

    /// @notice Post an event to update the matching's state.
    /// @dev This internal function is used to update the matching's state based on the event.
    /// @param _event The event that triggers the state update.
    function postEvent(
        MatchingType.Matching storage self,
        MatchingType.Event _event
    ) internal {
        MatchingType.State currentState = self.state;
        MatchingType.State newState;

        // Apply the state transition based on the event
        if (_event == MatchingType.Event.Publish) {
            if (currentState == MatchingType.State.None) {
                newState = MatchingType.State.Published;
            }
        } else if (_event == MatchingType.Event.FilPlusCheckSuccessed) {
            if (currentState == MatchingType.State.Published) {
                newState = MatchingType.State.InProgress;
            }
        } else if (_event == MatchingType.Event.FilPlusCheckFailed) {
            if (currentState == MatchingType.State.Published) {
                newState = MatchingType.State.Failed;
            }
        } else if (_event == MatchingType.Event.Pause) {
            if (currentState == MatchingType.State.InProgress) {
                newState = MatchingType.State.Paused;
            }
        } else if (_event == MatchingType.Event.Resume) {
            if (currentState == MatchingType.State.Paused) {
                newState = MatchingType.State.InProgress;
            }
        } else if (_event == MatchingType.Event.PauseExpired) {
            if (currentState == MatchingType.State.Paused) {
                newState = MatchingType.State.Failed;
            }
        } else if (_event == MatchingType.Event.Cancel) {
            if (
                currentState == MatchingType.State.Published ||
                currentState == MatchingType.State.Paused ||
                currentState == MatchingType.State.InProgress
            ) {
                newState = MatchingType.State.Cancelled;
            }
        } else if (_event == MatchingType.Event.Close) {
            if (currentState == MatchingType.State.InProgress) {
                newState = MatchingType.State.Closed;
            }
        } else if (_event == MatchingType.Event.HasWinner) {
            if (currentState == MatchingType.State.Closed) {
                newState = MatchingType.State.Completed;
            }
        } else if (_event == MatchingType.Event.NoWinner) {
            if (currentState == MatchingType.State.Closed) {
                newState = MatchingType.State.Failed;
            }
        }

        // Update the state if newState is not None (i.e., a valid transition)
        if (newState != MatchingType.State.None) {
            self.state = newState;
        }
    }

    /// @notice Perform Fil+ check.
    /// @dev This internal function is used to perform a Fil+ check.
    function filPlusCheck(
        MatchingType.Matching storage /*self*/
    ) internal pure returns (bool) {
        return true;
    }

    /// @notice Get the current state of a matching.
    /// @dev This internal function is used to retrieve the current state of a matching.
    function getState(
        MatchingType.Matching storage self
    ) internal view returns (MatchingType.State) {
        return self.state;
    }

    /// TODO: place into matching  contract
    /// @notice Perform post-completion action.
    /// @dev This internal function is used to perform actions after a matching is completed.
    // function postCompletionAction(
    //     MatchingType.Matching storage self,
    //     address _carsStorageContract,
    //     uint256 _matchingId
    // ) internal {
    //     ICarStore cars = ICarStore(_carsStorageContract);
    //     require(cars.hasCars(self.target.cars), "cars cids invalid");
    //     for (uint256 i = 0; i < self.target.cars.length; i++) {
    //         cars.addReplica(self.target.cars[i], _matchingId);
    //     }
    // }
}
