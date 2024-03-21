// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "../types/CommonTypes.sol";

/// @title TypeConstructor
/// @notice This library is a set a functions that allows to construct filecoin common types from solidity
/// @author Filecoin Project
library TypeConstructor {

    error InvalidLength();

    /// @notice Converts bytes to filecoin common type DealLabel
    /// @param data The data must be no longer than MAX_DEAL_LABEL_LENGTH bytes
    function dealLabelFromBytes(bytes memory data) internal pure returns (CommonTypes.DealLabel memory) {
        if (data.length > CommonTypes.MAX_DEAL_LABEL_LENGTH) {
            revert InvalidLength();
        }
        return CommonTypes.DealLabel(data, false);
    }

    /// @notice Converts a string to filecoin common type DealLabel
    /// @param data UTF-8 string, must be no longer MAX_DEAL_LABEL_LENGTH bytes when encoded
    function dealLabelFromString(string memory data) internal pure returns (CommonTypes.DealLabel memory) {
        bytes memory dataBytes = bytes(data);
        if (dataBytes.length > CommonTypes.MAX_DEAL_LABEL_LENGTH) {
            revert InvalidLength();
        }
        return CommonTypes.DealLabel(dataBytes, true);
    }
}
