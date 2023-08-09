// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.21;

import "../../../types/DatasetType.sol";

/// @notice Explain to an end user what this does
/// @dev Explain to a developer any extra details
library DatasetVerifier {
    /// @notice Explain to an end user what this does
    /// @dev Explain to a developer any extra details
    /// @param _dataset a parameter just like in doxygen (must be followed by parameter name)
    /// @return DatasetType.VerifyResult the return variables of a contract’s function state variable
    function verify(
        DatasetType.Dataset memory _dataset
    ) external returns (DatasetType.VerifyResult) {}
}
