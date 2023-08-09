// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity ^0.8.21;

import "../../../types/MatchingType.sol";
import "../../../core/carsStorage/abstract/CarsStorageBase.sol";

library MatchingLIB {
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

    function pause(MatchingType.Matching storage self) external {
        require(
            self.state == MatchingType.State.InProgress,
            "Matching: Invalid state for pausing"
        );
        postEvent(self, MatchingType.Event.Pause);
    }

    function reportPauseExpired(MatchingType.Matching storage self) external {
        require(
            self.state == MatchingType.State.Paused,
            "Matching: Invalid state for reportPauseExpired"
        );
        postEvent(self, MatchingType.Event.PauseExpired);
    }

    function resume(MatchingType.Matching storage self) external {
        require(
            self.state == MatchingType.State.Paused,
            "Matching: Invalid state for resuming"
        );
        postEvent(self, MatchingType.Event.Resume);
    }

    function cancel(MatchingType.Matching storage self) external {
        require(
            self.state == MatchingType.State.Published ||
                self.state == MatchingType.State.InProgress ||
                self.state == MatchingType.State.Paused,
            "Matching: Invalid state for canceling"
        );
        postEvent(self, MatchingType.Event.Cancel);
    }

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

    function close(
        MatchingType.Matching storage self,
        MatchingType.WinnerBidRule _rule,
        address _carsStorageContract,
        uint256 _matchingId
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
        chooseWinner(self, _rule, _carsStorageContract, _matchingId);
    }

    function chooseWinner(
        MatchingType.Matching storage self,
        MatchingType.WinnerBidRule _rule,
        address _carsStorageContract,
        uint256 _matchingId
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
            postCompletionAction(self, _carsStorageContract, _matchingId);
            self.winner = winner;
            postEvent(self, MatchingType.Event.HasWinner);
        }
    }

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

    function filPlusCheck(
        MatchingType.Matching storage /*self*/
    ) internal pure returns (bool) {
        return true;
    }

    function getState(
        MatchingType.Matching storage self
    ) internal view returns (MatchingType.State) {
        return self.state;
    }

    function postCompletionAction(
        MatchingType.Matching storage self,
        address _carsStorageContract,
        uint256 _matchingId
    ) internal {
        CarsStorageBase cars = CarsStorageBase(_carsStorageContract);
        require(cars.hasCars(self.target.cars), "cars cids invalid");
        for (uint256 i = 0; i < self.target.cars.length; i++) {
            cars.addReplica(self.target.cars[i], _matchingId);
        }
    }
}
