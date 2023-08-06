// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.21;

import "./types/DatasetType.sol";

library Common {
    function requireValidDataset(
        DatasetType.Metadata calldata _metadata
    ) internal pure {
        // Add data validation logic here
        require(bytes(_metadata.title).length > 0, "Title cannot be empty");
        // Add more validation rules as needed
    }
}
