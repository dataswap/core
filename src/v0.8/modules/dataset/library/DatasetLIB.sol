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

import "../../../types/DatasetType.sol";
import "../../../core/dataswapDAO/DataswapDAO.sol";
import "../../../shared/utils/StringUtils.sol";
import "./DatasetVerifierLIB.sol";

/// @title Dataset Library
/// @notice This library provides functions to manage datasets and their metadata, proofs, and verifications.
/// @dev This library is intended to be used in conjunction with the Dataset contract.
library DatasetLIB {
    /// @notice Submit metadata for a dataset.
    /// @dev This function allows submitting metadata for a dataset and emits the SubmitMetadata event.
    /// @param self The dataset to which metadata will be submitted.
    /// @param _metadata The metadata to be submitted.
    function submitMetadata(
        DatasetType.Dataset storage self,
        DatasetType.Metadata calldata _metadata
    ) external {
        self.metadata = _metadata;
        postEvent(self, DatasetType.Event.SubmitMetadata);
    }

    /// @notice Submit a proof for a dataset.
    /// @dev This function allows submitting a proof for a dataset and emits the SubmitDatasetProof event.
    /// @param self The dataset to which the proof will be submitted.
    /// @param _proof The proof to be submitted.
    function submitProof(
        DatasetType.Dataset storage self,
        DatasetType.Proof calldata _proof
    ) external {
        //TODO:require check
        self.proof = _proof;
        postEvent(self, DatasetType.Event.SubmitDatasetProof);
    }

    /// @notice Submit a verification for a dataset.
    /// @dev This function allows submitting a verification for a dataset and triggers appropriate actions based on verification results.
    /// @param self The dataset to which the verification will be submitted.
    /// @param _verification The verification to be submitted.
    /// @param _governanceContract The address of the governance contract.
    /// @param _datasetId The ID of the dataset being verified.
    /// @param _callbackTarget The address of the callback target.
    /// @return The result of the verification.
    function submitVerification(
        DatasetType.Dataset storage self,
        DatasetType.Verification calldata _verification,
        address payable _governanceContract,
        uint256 _datasetId,
        address _callbackTarget
    ) external returns (DatasetType.VerifyResult) {
        //TODO: require check
        self.verifications.push(_verification);
        DatasetType.VerifyResult result = DatasetVerifierLIB.verify(self);

        if (result == DatasetType.VerifyResult.Approved) {
            approveDataset(self);
        } else if (result == DatasetType.VerifyResult.Rejected) {
            rejectDataset(self);
        } else if (result == DatasetType.VerifyResult.RequestDispute) {
            requestAudit(
                self,
                DataswapDAO(_governanceContract),
                "Dataset Verification Audit:",
                _datasetId,
                _callbackTarget
            );
            requireDipute(self);
        }

        return result;
    }

    /// @notice Approve the metadata of a dataset.
    /// @dev This function changes the state of the dataset to MetadataApproved and emits the MetadataApproved event.
    /// @param self The dataset for which metadata is being approved.
    function approveMetadata(DatasetType.Dataset storage self) external {
        require(
            self.state == DatasetType.State.MetadataSubmitted,
            "Invalid state for approval metadata"
        );
        postEvent(self, DatasetType.Event.MetadataApproved);
    }

    /// @notice Reject the metadata of a dataset.
    /// @dev This function changes the state of the dataset to MetadataRejected and emits the MetadataRejected event.
    /// @param self The dataset for which metadata is being rejected.
    function rejectMetadata(DatasetType.Dataset storage self) external {
        require(
            self.state == DatasetType.State.MetadataSubmitted,
            "Invalid state for rejection metadata"
        );
        postEvent(self, DatasetType.Event.MetadataRejected);
    }

    /// @notice Approve a dataset.
    /// @dev This function changes the state of the dataset to DatasetApproved and emits the DatasetApproved event.
    /// @param self The dataset to be approved.
    function approveDataset(DatasetType.Dataset storage self) public {
        require(
            self.state == DatasetType.State.DatasetProofSubmitted ||
                self.state == DatasetType.State.DatasetApprovalInDispute,
            "Invalid state for approval dataset"
        );
        postEvent(self, DatasetType.Event.DatasetApproved);
    }

    /// @notice Reject a dataset.
    /// @dev This function changes the state of the dataset to MetadataApproved and emits the DatasetRejected event.
    /// @param self The dataset to be rejected.
    function rejectDataset(DatasetType.Dataset storage self) public {
        require(
            self.state == DatasetType.State.DatasetProofSubmitted ||
                self.state == DatasetType.State.DatasetApprovalInDispute,
            "Invalid state for rejection dataset"
        );
        postEvent(self, DatasetType.Event.DatasetRejected);
    }

    /// @notice Request a dispute for a dataset.
    /// @dev This function changes the state of the dataset to DatasetApprovalInDispute and emits the DatasetRequireDispute event.
    /// @param self The dataset for which a dispute is being requested.
    function requireDipute(DatasetType.Dataset storage self) internal {
        require(
            self.state == DatasetType.State.DatasetProofSubmitted,
            "Invalid state for require dipute dataset"
        );
        postEvent(self, DatasetType.Event.DatasetRequireDispute);
    }

    /// @notice Post an event for a dataset.
    /// @dev This function updates the dataset's state based on the event and emits the corresponding event.
    /// @param self The dataset for which the event will be posted.
    /// @param _event The event to be posted.
    function postEvent(
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
        } else if (_event == DatasetType.Event.MetadataApproved) {
            if (currentState == DatasetType.State.MetadataSubmitted) {
                newState = DatasetType.State.MetadataApproved;
            }
        } else if (_event == DatasetType.Event.MetadataRejected) {
            if (currentState == DatasetType.State.MetadataSubmitted) {
                newState = DatasetType.State.MetadataRejected;
            }
        } else if (_event == DatasetType.Event.SubmitDatasetProof) {
            if (currentState == DatasetType.State.MetadataApproved) {
                newState = DatasetType.State.DatasetProofSubmitted;
            }
        } else if (_event == DatasetType.Event.DatasetApproved) {
            if (
                currentState == DatasetType.State.DatasetProofSubmitted ||
                currentState == DatasetType.State.DatasetApprovalInDispute
            ) {
                newState = DatasetType.State.DatasetApproved;
            }
        } else if (_event == DatasetType.Event.DatasetRejected) {
            if (
                currentState == DatasetType.State.DatasetProofSubmitted ||
                currentState == DatasetType.State.DatasetApprovalInDispute
            ) {
                newState = DatasetType.State.MetadataApproved;
            }
        } else if (_event == DatasetType.Event.DatasetRequireDispute) {
            if (currentState == DatasetType.State.DatasetProofSubmitted) {
                newState = DatasetType.State.DatasetApprovalInDispute;
            }
        }

        // Update the state if newState is not None (i.e., a valid transition)
        if (newState != DatasetType.State.None) {
            self.state = newState;
        }
    }

    /// @notice Request an audit for a dataset's verification.
    /// @dev This function triggers the creation of a governance proposal to request an audit for a dataset verification.
    /// @param _dataswapDao The address of the DataswapDAO contract.
    /// @param _description The description of the audit proposal.
    /// @param _datasetId The ID of the dataset being audited.
    /// @param _target The address to which the audit proposal is directed.
    /// @return The ID of the created governance proposal.
    function requestAudit(
        DatasetType.Dataset storage /*self*/,
        DataswapDAO _dataswapDao,
        string memory _description,
        uint256 _datasetId,
        address _target
    ) internal returns (uint256) {
        //TODO: Perform any checks or operations required before creating the proposal

        address[] memory targets = new address[](1);
        targets[0] = address(_target); // Use the address of this contract as the target

        uint256[] memory values = new uint256[](0); // Set values to an empty array
        bytes[] memory calldatas = new bytes[](0); // Set calldatas to an empty array
        string memory description = StringUtils.concat(
            _description,
            StringUtils.uint256ToString(_datasetId)
        );

        return _dataswapDao.propose(targets, values, calldatas, description);
    }

    /// @notice Get the state of a dataset.
    /// @dev This function returns the current state of a dataset.
    /// @param self The dataset for which to retrieve the state.
    /// @return The current state of the dataset.
    function getState(
        DatasetType.Dataset storage self
    ) public view returns (DatasetType.State) {
        return self.state;
    }
}
