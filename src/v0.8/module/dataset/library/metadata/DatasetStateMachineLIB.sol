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

import {DatasetType} from "src/v0.8/types/DatasetType.sol";

/// @title DatasetStateMachineLIB Library,include add,get,verify.
/// @notice This library defines the state machine for managing the states of datasets.
library DatasetStateMachineLIB {
    /// @notice Post an event for a dataset.
    /// @dev This function updates the dataset's state based on the event and emits the corresponding event.
    /// @param self The dataset for which the event will be posted.
    /// @param _event The event to be posted.
    function _emitDatasetEvent(
        DatasetType.Dataset storage self,
        DatasetType.Event _event
    ) internal {
        DatasetType.State currentState = self.state;
        DatasetType.State newState;
        // Apply the state transition based on the event
        if (_event == DatasetType.Event.SubmitMetadata) {
            if (currentState == DatasetType.State.None) {
                newState = DatasetType.State.MetadataSubmitted;
            }
        } else if (_event == DatasetType.Event.SubmitRequirements) {
            if (currentState == DatasetType.State.MetadataSubmitted) {
                newState = DatasetType.State.RequirementSubmitted;
            }
        } else if (_event == DatasetType.Event.ProofCompleted) {
            if (currentState == DatasetType.State.RequirementSubmitted) {
                newState = DatasetType.State.ProofSubmitted;
            }
        } else if (_event == DatasetType.Event.InsufficientEscrowFunds) {
            if (currentState == DatasetType.State.RequirementSubmitted) {
                newState = DatasetType.State.WaitEscrow;
            }
        } else if (_event == DatasetType.Event.EscrowCompleted) {
            if (currentState == DatasetType.State.WaitEscrow) {
                newState = DatasetType.State.RequirementSubmitted;
            }
        } else if (_event == DatasetType.Event.Approved) {
            if (currentState == DatasetType.State.ProofSubmitted) {
                newState = DatasetType.State.Approved;
            }
        } else if (_event == DatasetType.Event.Rejected) {
            if (currentState == DatasetType.State.ProofSubmitted) {
                newState = DatasetType.State.Rejected;
            }
        } else if (_event == DatasetType.Event.WorkflowTimeout) {
            if (
                currentState == DatasetType.State.MetadataSubmitted ||
                currentState == DatasetType.State.RequirementSubmitted ||
                currentState == DatasetType.State.WaitEscrow ||
                currentState == DatasetType.State.ProofSubmitted
            ) {
                newState = DatasetType.State.Rejected;
            }
        }

        // Update the state if newState is not None (i.e., a valid transition)
        if (newState != DatasetType.State.None) {
            self.state = newState;
        }
    }

    /// @notice Get the state of a dataset.
    /// @dev This function returns the current state of a dataset.
    /// @param self The dataset for which to retrieve the state.
    /// @return The current state of the dataset.
    function getDatasetState(
        DatasetType.Dataset storage self
    ) internal view returns (DatasetType.State) {
        return self.state;
    }
}
