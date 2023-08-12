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

/// @title StringUtils Library
/// @author waynewyang
/// @notice This library provides utility functions for working with strings.
library StringUtils {
    /// @notice Concatenate two strings and return the result.
    /// @param a The first string.
    /// @param b The second string.
    /// @return The concatenated string.
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

    /// @notice Convert a uint256 value to a string.
    /// @param value The uint256 value to be converted.
    /// @return The string representation of the uint256 value.
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
