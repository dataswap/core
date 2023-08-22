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

/// @title Matching Library
/// @notice This library provides functions for managing matchings and their states.
/// @dev This library is used to manage the lifecycle and states of matchings.
library MatchingStateMachineLIB {
    /// @notice Post an event to update the matching's state.
    /// @dev This internal function is used to update the matching's state based on the event.
    /// @param _event The event that triggers the state update.
    function _emitMatchingEvent(
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

    /// @notice Get the current state of a matching.
    /// @dev This internal function is used to retrieve the current state of a matching.
    function _getMatchingState(
        MatchingType.Matching storage self
    ) internal view returns (MatchingType.State) {
        return self.state;
    }
}
