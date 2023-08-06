// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.21;

import "./types/DatasetType.sol";
import "../interfaces/IDatasetVerify.sol";
import "../interfaces/IDataswapDAO.sol";
import "../libraries/utils/StringUtils.sol";

/// @notice Explain to an end user what this does
/// @dev Explain to a developer any extra details
library Dataset {
    /// @notice Explain to an end user what this does
    /// @dev Explain to a developer any extra details
    /// @param dataset a parameter just like in doxygen (must be followed by parameter name)
    /// @param _metadata  parameter just like in doxygen (must be followed by parameter name)
    function submitMetadata(
        DatasetType.Dataset storage dataset,
        DatasetType.Metadata calldata _metadata
    ) public {
        dataset.metadata = _metadata;
        updateState(dataset, DatasetType.Event.SubmitMetadata);
        //TODO:requestAudit
    }

    /// @notice Explain to an end user what this does
    /// @dev Explain to a developer any extra details
    /// @param dataset a parameter just like in doxygen (must be followed by parameter name)
    /// @param _proof parameter just like in doxygen (must be followed by parameter name)
    function submitProof(
        DatasetType.Dataset storage dataset,
        DatasetType.Proof calldata _proof
    ) public {
        dataset.proof = _proof;
        updateState(dataset, DatasetType.Event.SubmitDatasetProof);
        //TODO:requestAudit
    }

    /// @notice Explain to an end user what this does
    /// @dev Explain to a developer any extra details
    /// @param dataset a parameter just like in doxygen (must be followed by parameter name)
    /// @param _verification parameter just like in doxygen (must be followed by parameter name)
    /// @param _verification parameter just like in doxygen (must be followed by parameter name)
    /// @param _verifyContract parameter just like in doxygen (must be followed by parameter name)
    function submitVerification(
        DatasetType.Dataset storage dataset,
        DatasetType.Verification calldata _verification,
        address _verifyContract,
        address payable _governanceContract,
        uint256 datasetId,
        address callbackTarget
    ) public returns (DatasetType.VerifyResult) {
        dataset.verifications.push(_verification);
        IDatasetVerify verifyContract = IDatasetVerify(_verifyContract);
        DatasetType.VerifyResult result = verifyContract.verify(dataset);

        if (result == DatasetType.VerifyResult.Approved) {
            approveDataset(dataset);
        } else if (result == DatasetType.VerifyResult.Rejected) {
            rejectDataset(dataset);
        } else if (result == DatasetType.VerifyResult.RequestDispute) {
            requestAudit(
                dataset,
                IDataswapDAO(_governanceContract),
                "Dataset Verification Audit:",
                datasetId,
                callbackTarget
            );
            requireDipute(dataset);
        }

        return result;
    }

    /// @notice Explain to an end user what this does
    /// @dev Explain to a developer any extra details
    /// @param dataset a parameter just like in doxygen (must be followed by parameter name)
    function approveMetadata(DatasetType.Dataset storage dataset) public {
        require(
            dataset.state == DatasetType.State.MetadataSubmitted,
            "Invalid state for approval metadata"
        );
        updateState(dataset, DatasetType.Event.MetadataApproved);
    }

    /// @notice Explain to an end user what this does
    /// @dev Explain to a developer any extra details
    /// @param dataset a parameter just like in doxygen (must be followed by parameter name)
    function rejectMetadata(DatasetType.Dataset storage dataset) public {
        require(
            dataset.state == DatasetType.State.MetadataSubmitted,
            "Invalid state for rejection metadata"
        );
        updateState(dataset, DatasetType.Event.MetadataRejected);
    }

    /// @notice Explain to an end user what this does
    /// @dev Explain to a developer any extra details
    /// @param dataset a parameter just like in doxygen (must be followed by parameter name)
    function approveDataset(DatasetType.Dataset storage dataset) public {
        require(
            dataset.state == DatasetType.State.DatasetProofSubmitted ||
                dataset.state == DatasetType.State.DatasetApprovalInDispute,
            "Invalid state for approval dataset"
        );
        updateState(dataset, DatasetType.Event.DatasetApproved);
    }

    /// @notice Explain to an end user what this does
    /// @dev Explain to a developer any extra details
    /// @param dataset a parameter just like in doxygen (must be followed by parameter name)
    function rejectDataset(DatasetType.Dataset storage dataset) public {
        require(
            dataset.state == DatasetType.State.DatasetProofSubmitted ||
                dataset.state == DatasetType.State.DatasetApprovalInDispute,
            "Invalid state for rejection dataset"
        );
        updateState(dataset, DatasetType.Event.DatasetRejected);
    }

    /// @notice Explain to an end user what this does
    /// @dev Explain to a developer any extra details
    /// @param dataset a parameter just like in doxygen (must be followed by parameter name)
    function requireDipute(DatasetType.Dataset storage dataset) internal {
        require(
            dataset.state == DatasetType.State.DatasetProofSubmitted,
            "Invalid state for require dipute dataset"
        );
        updateState(dataset, DatasetType.Event.DatasetRequireDispute);
    }

    /// @notice Explain to an end user what this does
    /// @dev Explain to a developer any extra details
    /// @param dataset a parameter just like in doxygen (must be followed by parameter name)
    /// @param _event a parameter just like in doxygen (must be followed by parameter name)
    function updateState(
        DatasetType.Dataset storage dataset,
        DatasetType.Event _event
    ) internal {
        DatasetType.State currentState = dataset.state;
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
            dataset.state = newState;
        }
    }

    function requestAudit(
        DatasetType.Dataset storage /*dataset*/,
        IDataswapDAO dataswapDao,
        string memory _description,
        uint256 datasetId,
        address target
    ) internal returns (uint256) {
        // Perform any checks or operations required before creating the proposal

        address[] memory targets = new address[](1);
        targets[0] = address(target); // Use the address of this contract as the target

        uint256[] memory values = new uint256[](0); // Set values to an empty array
        bytes[] memory calldatas = new bytes[](0); // Set calldatas to an empty array
        string memory description = StringUtils.concat(
            _description,
            StringUtils.uint256ToString(datasetId)
        );

        return dataswapDao.propose(targets, values, calldatas, description);
    }
}
