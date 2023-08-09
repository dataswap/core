// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.21;

import "../../../types/DatasetType.sol";
import "../../../core/dataswapDAO/abstract/DataswapDAOBase.sol";
import "../../../shared/utils/StringUtils.sol";
import "../verifiers/DatasetVerifier.sol";

/// @notice Explain to an end user what this does
/// @dev Explain to a developer any extra details
library DatasetLIB {
    /// @notice Explain to an end user what this does
    /// @dev Explain to a developer any extra details
    /// @param self a parameter just like in doxygen (must be followed by parameter name)
    /// @param _metadata  parameter just like in doxygen (must be followed by parameter name)
    function submitMetadata(
        DatasetType.Dataset storage self,
        DatasetType.Metadata calldata _metadata
    ) external {
        self.metadata = _metadata;
        postEvent(self, DatasetType.Event.SubmitMetadata);
    }

    /// @notice Explain to an end user what this does
    /// @dev Explain to a developer any extra details
    /// @param self parameter just like in doxygen (must be followed by parameter name)
    /// @param _proof parameter just like in doxygen (must be followed by parameter name)
    function submitProof(
        DatasetType.Dataset storage self,
        DatasetType.Proof calldata _proof
    ) external {
        //TODO:require check
        self.proof = _proof;
        postEvent(self, DatasetType.Event.SubmitDatasetProof);
    }

    /// @notice Explain to an end user what this does
    /// @dev Explain to a developer any extra details
    /// @param self parameter just like in doxygen (must be followed by parameter name)
    /// @param _verification parameter just like in doxygen (must be followed by parameter name)
    /// @param _verification parameter just like in doxygen (must be followed by parameter name)
    function submitVerification(
        DatasetType.Dataset storage self,
        DatasetType.Verification calldata _verification,
        address payable _governanceContract,
        uint256 _datasetId,
        address _callbackTarget
    ) external returns (DatasetType.VerifyResult) {
        //TODO: require check
        self.verifications.push(_verification);
        DatasetType.VerifyResult result = DatasetVerifier.verify(self);

        if (result == DatasetType.VerifyResult.Approved) {
            approveDataset(self);
        } else if (result == DatasetType.VerifyResult.Rejected) {
            rejectDataset(self);
        } else if (result == DatasetType.VerifyResult.RequestDispute) {
            requestAudit(
                self,
                DataswapDAOBase(_governanceContract),
                "Dataset Verification Audit:",
                _datasetId,
                _callbackTarget
            );
            requireDipute(self);
        }

        return result;
    }

    /// @notice Explain to an end user what this does
    /// @dev Explain to a developer any extra details
    function approveMetadata(DatasetType.Dataset storage self) external {
        require(
            self.state == DatasetType.State.MetadataSubmitted,
            "Invalid state for approval metadata"
        );
        postEvent(self, DatasetType.Event.MetadataApproved);
    }

    /// @notice Explain to an end user what this does
    /// @dev Explain to a developer any extra details
    function rejectMetadata(DatasetType.Dataset storage self) external {
        require(
            self.state == DatasetType.State.MetadataSubmitted,
            "Invalid state for rejection metadata"
        );
        postEvent(self, DatasetType.Event.MetadataRejected);
    }

    /// @notice Explain to an end user what this does
    /// @dev Explain to a developer any extra details
    function approveDataset(DatasetType.Dataset storage self) public {
        require(
            self.state == DatasetType.State.DatasetProofSubmitted ||
                self.state == DatasetType.State.DatasetApprovalInDispute,
            "Invalid state for approval dataset"
        );
        postEvent(self, DatasetType.Event.DatasetApproved);
    }

    /// @notice Explain to an end user what this does
    /// @dev Explain to a developer any extra details
    function rejectDataset(DatasetType.Dataset storage self) public {
        require(
            self.state == DatasetType.State.DatasetProofSubmitted ||
                self.state == DatasetType.State.DatasetApprovalInDispute,
            "Invalid state for rejection dataset"
        );
        postEvent(self, DatasetType.Event.DatasetRejected);
    }

    /// @notice Explain to an end user what this does
    /// @dev Explain to a developer any extra details
    function requireDipute(DatasetType.Dataset storage self) internal {
        require(
            self.state == DatasetType.State.DatasetProofSubmitted,
            "Invalid state for require dipute dataset"
        );
        postEvent(self, DatasetType.Event.DatasetRequireDispute);
    }

    /// @notice Explain to an end user what this does
    /// @dev Explain to a developer any extra details
    /// @param _event a parameter just like in doxygen (must be followed by parameter name)
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

    function requestAudit(
        DatasetType.Dataset storage /*self*/,
        DataswapDAOBase _dataswapDao,
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

    function getState(
        DatasetType.Dataset storage self
    ) public view returns (DatasetType.State) {
        return self.state;
    }
}
