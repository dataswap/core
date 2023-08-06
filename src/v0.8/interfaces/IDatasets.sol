// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity ^0.8.21;

import "../libraries/types/DatasetType.sol";

/// @notice Explain to an end user what this does
/// @dev Explain to a developer any extra details
interface IDatasets {
    /// @notice Explain to an end user what this does
    /// @dev Explain to a developer any extra details
    /// @param _metadata a parameter just like in doxygen (must be followed by parameter name)
    function submitMetadata(DatasetType.Metadata calldata _metadata) external;

    /// @notice Explain to an end user what this does
    /// @dev Explain to a developer any extra details
    /// @param datasetId a parameter just like in doxygen (must be followed by parameter name)
    /// @param _proof a parameter just like in doxygen (must be followed by parameter name)
    function submitProof(
        uint256 datasetId,
        DatasetType.Proof calldata _proof
    ) external;

    /// @notice Explain to an end user what this does
    /// @dev Explain to a developer any extra details
    /// @param datasetId a parameter just like in doxygen (must be followed by parameter name)
    /// @param _verification a parameter just like in doxygen (must be followed by parameter name)
    /// @return Documents the return variables of a contract’s function state variable
    function submitVerification(
        uint256 datasetId,
        DatasetType.Verification calldata _verification
    ) external returns (DatasetType.VerifyResult);

    /// @notice Explain to an end user what this does
    /// @dev Explain to a developer any extra details
    /// @param datasetId a parameter just like in doxygen (must be followed by parameter name)
    function approveMetadata(uint256 datasetId) external;

    /// @notice Explain to an end user what this does
    /// @dev Explain to a developer any extra details
    /// @param datasetId a parameter just like in doxygen (must be followed by parameter name)
    function rejectMetadata(uint256 datasetId) external;

    /// @notice Explain to an end user what this does
    /// @dev Explain to a developer any extra details
    /// @param datasetId a parameter just like in doxygen (must be followed by parameter name)
    function approveDataset(uint256 datasetId) external;

    /// @notice Explain to an end user what this does
    /// @dev Explain to a developer any extra details
    /// @param datasetId a parameter just like in doxygen (must be followed by parameter name)
    function rejectDataset(uint256 datasetId) external;
}
