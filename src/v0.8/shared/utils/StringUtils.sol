// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.21;

library StringUtils {
    function concat(
        string memory a,
        string memory b
    ) internal pure returns (string memory) {
        bytes memory strBytesA = bytes(a);
        bytes memory strBytesB = bytes(b);
        bytes memory result = new bytes(strBytesA.length + strBytesB.length);

        uint256 k = 0;
        for (uint256 i = 0; i < strBytesA.length; i++) {
            result[k] = strBytesA[i];
            k++;
        }

        for (uint256 i = 0; i < strBytesB.length; i++) {
            result[k] = strBytesB[i];
            k++;
        }

        return string(result);
    }

    function uint256ToString(
        uint256 value
    ) internal pure returns (string memory) {
        if (value == 0) {
            return "0";
        }

        uint256 temp = value;
        uint256 digits;

        while (temp != 0) {
            digits++;
            temp /= 10;
        }

        bytes memory buffer = new bytes(digits);

        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + (value % 10)));
            value /= 10;
        }

        return string(buffer);
    }
}
