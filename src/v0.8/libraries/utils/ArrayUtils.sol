// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.21;

library ArrayUtil {
    function appendArrayBytes32(
        bytes32[] storage self,
        bytes32[] memory _newArray
    ) public {
        for (uint256 i = 0; i < _newArray.length; i++) {
            self.push(_newArray[i]);
        }
    }
}
