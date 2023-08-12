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
import "./MatchingStateMachineLIB.sol";
import "./MatchingBidsLIB.sol";

/// @title Matching Library
/// @author waynewyang
/// @notice This library provides functions for managing matchings and their states.
/// @dev This library is used to manage the lifecycle and states of matchings.
library MatchingLIB {
    using MatchingStateMachineLIB for MatchingType.Matching;
    using MatchingBidsLIB for MatchingType.Matching;

    /// @notice Publish a matching.
    /// @dev This function is used to publish a matching and initiate the matching process.
    function _publishMatching(MatchingType.Matching storage self) internal {
        require(
            self.state == MatchingType.State.None,
            "Matching: Invalid state for publishing"
        );
        self._emitMatchingEvent(MatchingType.Event.Publish);
        //TODO:consider that if need audit,so keep the FilPlusCheckSuccessed here.
        self._emitMatchingEvent(MatchingType.Event.FilPlusCheckSuccessed);
    }

    /// @notice Pause a matching.
    /// @dev This function is used to pause a matching that is in progress.
    function _pauseMatching(MatchingType.Matching storage self) internal {
        require(
            self.state == MatchingType.State.InProgress,
            "Matching: Invalid state for pausing"
        );
        self._emitMatchingEvent(MatchingType.Event.Pause);
    }

    /// @notice Report that a pause has expired.
    /// @dev This function is used to report that a pause has expired for a paused matching.
    function _reportMatchingPauseExpired(
        MatchingType.Matching storage self
    ) internal {
        require(
            self.state == MatchingType.State.Paused,
            "Matching: Invalid state for reportPauseExpired"
        );
        self._emitMatchingEvent(MatchingType.Event.PauseExpired);
    }

    /// @notice Resume a paused matching.
    /// @dev This function is used to resume a paused matching.
    function _resumeMatching(MatchingType.Matching storage self) internal {
        require(
            self.state == MatchingType.State.Paused,
            "Matching: Invalid state for resuming"
        );
        self._emitMatchingEvent(MatchingType.Event.Resume);
    }

    /// @notice Cancel a matching.
    /// @dev This function is used to cancel a matching that is published, in progress, or paused.
    function _cancelMatching(MatchingType.Matching storage self) internal {
        require(
            self.state == MatchingType.State.Published ||
                self.state == MatchingType.State.InProgress ||
                self.state == MatchingType.State.Paused,
            "Matching: Invalid state for canceling"
        );
        self._emitMatchingEvent(MatchingType.Event.Cancel);
    }

    /// @notice Close a matching and choose a winner.
    /// @dev This function is used to close a matching and choose a winner based on the specified rule.
    function _closeMatching(MatchingType.Matching storage self) internal {
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
        self._emitMatchingEvent(MatchingType.Event.Close);
    }
}
