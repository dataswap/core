// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.21;

import "../libraries/types/DatasetType.sol";

/// @notice Explain to an end user what this does
/// @dev Explain to a developer any extra details
interface IRoles {
    /// @notice Explain to an end user what this does
    /// @dev Explain to a developer any extra details
    /// @param _address a parameter just like in doxygen (must be followed by parameter name)
    /// @return DatasetType.VerifyResult the return variables of a contract’s function state variable
    function isDatasetAuditor(address _address) external returns (bool);
}
