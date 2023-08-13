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

/// @title ArrayUtil Library
/// @notice This library provides utility functions for working with arrays.
library ArrayUtil {
    /// @notice Append an array of bytes32 elements to an existing storage bytes32 array.
    /// @param self The storage bytes32 array to which elements are appended.
    /// @param _newArray The memory array of bytes32 elements to be appended.
    function appendArrayBytes32(
        bytes32[] storage self,
        bytes32[] memory _newArray
    ) internal {
        for (uint256 i = 0; i < _newArray.length; i++) {
            self.push(_newArray[i]);
        }
    }
}
