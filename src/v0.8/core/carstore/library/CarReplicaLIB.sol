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

import {CarReplicaType} from "../../../types/CarReplicaType.sol";

/// @title CarReplicaLIB
/// @dev This library provides functions to manage the state and events of car replicas.
/// @notice Library for managing the lifecycle and events of car replicas.
library CarReplicaLIB {
    /// @notice Set the Filecoin deal ID for a car replica.
    /// @dev Requires a non-zero new Filecoin deal ID and that it's different from the existing one.
    ///      This should be called by an external  storage deal contract after a successful storage deal process.
    /// @param self The reference to the replica storage.
    /// @param _filecoinDealId The new Filecoin deal ID to set.
    function _setFilecoinDealId(
        CarReplicaType.Replica storage self,
        uint64 _filecoinDealId
    ) internal {
        require(_filecoinDealId != 0 && self.filecoinDealId != _filecoinDealId);
        self.filecoinDealId = _filecoinDealId;
    }

    /// @notice Emit an event for a car replica, triggering state transitions.
    /// @dev The state transition is based on the event and current state.
    ///      Invalid transitions do not change the state.
    /// @param self The reference to the replica storage.
    /// @param _event The event to post.
    function _emitEvent(
        CarReplicaType.Replica storage self,
        CarReplicaType.Event _event
    ) internal {
        CarReplicaType.State currentState = self.state;
        CarReplicaType.State newState;

        // Apply the state transition based on the event
        if (_event == CarReplicaType.Event.MatchingCompleted) {
            if (currentState == CarReplicaType.State.None) {
                newState = CarReplicaType.State.Matched;
            }
        } else if (_event == CarReplicaType.Event.StorageCompleted) {
            if (currentState == CarReplicaType.State.Matched) {
                newState = CarReplicaType.State.Stored;
            }
        } else if (_event == CarReplicaType.Event.StorageFailed) {
            if (currentState == CarReplicaType.State.Matched) {
                newState = CarReplicaType.State.None;
            }
        } else if (_event == CarReplicaType.Event.StorageDealExpired) {
            if (currentState == CarReplicaType.State.Stored) {
                newState = CarReplicaType.State.None;
            }
        } else if (_event == CarReplicaType.Event.StorageSlashed) {
            if (currentState == CarReplicaType.State.Stored) {
                newState = CarReplicaType.State.None;
            }
        }

        /// @notice Update the state if newState is not Approved (i.e., a valid transition)
        /// @dev The state variable self.state will be updated with the new state if newState is not Approved.
        if (newState != CarReplicaType.State.None) {
            self.state = newState;
        }
    }
}
