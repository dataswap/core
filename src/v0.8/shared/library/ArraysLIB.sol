/*******************************************************************************
 *   (c) 2023 Dataswap
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

/// @title Arrays Library
library ArraysLIB {
    /// @notice Check if array contain an item.
    /// @param self The arrays.
    /// @param _item The bid amount.
    function isContains(
        uint64[] memory self,
        uint64 _item
    ) internal pure returns (bool) {
        for (uint64 i = 0; i < self.length; i++) {
            if (self[i] == _item) {
                return true;
            }
        }
        return false;
    }

    /// @notice Removes duplicate elements from a uint64 array.
    /// @param self The input array containing duplicate and non-duplicate elements.
    /// @return output A new array with duplicate elements removed.
    function deDuplicate(
        uint64[] memory self
    ) public pure returns (uint64[] memory) {
        if (self.length <= 1) {
            return self;
        }

        uint64[] memory buf = new uint64[](self.length);
        uint64 newSize = 0;
        uint64 current = 0;

        for (uint64 i = 0; i < self.length; i++) {
            bool duplicate = false;
            for (uint64 j = 0; j < newSize; j++) {
                if (buf[j] == self[i]) {
                    duplicate = true;
                    break;
                }
            }
            if (!duplicate) {
                buf[current] = self[i];
                current++;
                newSize++;
            }
        }

        uint64[] memory output = new uint64[](newSize);
        for (uint64 i = 0; i < newSize; i++) {
            output[i] = buf[i];
        }

        return output;
    }
}

/// @title Arrays Library
library ArraysUINT16LIB {
    /// @notice Check if array contain an item.
    /// @param self The arrays.
    /// @param _item The bid amount.
    function isContains(
        uint64[] memory self,
        uint64 _item
    ) internal pure returns (bool) {
        for (uint64 i = 0; i < self.length; i++) {
            if (self[i] == _item) {
                return true;
            }
        }
        return false;
    }

    /// @notice Removes duplicate elements from a uint64 array.
    /// @param self The input array containing duplicate and non-duplicate elements.
    /// @return output A new array with duplicate elements removed.
    function deDuplicate(
        uint16[] memory self
    ) public pure returns (uint16[] memory) {
        if (self.length <= 1) {
            return self;
        }

        uint16[] memory buf = new uint16[](self.length);
        uint64 newSize = 0;
        uint64 current = 0;

        for (uint64 i = 0; i < self.length; i++) {
            bool duplicate = false;
            for (uint64 j = 0; j < newSize; j++) {
                if (buf[j] == self[i]) {
                    duplicate = true;
                    break;
                }
            }
            if (!duplicate) {
                buf[current] = self[i];
                current++;
                newSize++;
            }
        }

        uint16[] memory output = new uint16[](newSize);
        for (uint64 i = 0; i < newSize; i++) {
            output[i] = buf[i];
        }

        return output;
    }
}

/// @title Arrays Library
library ArraysUINT32LIB {
    /// @notice Check if array contain an item.
    /// @param self The arrays.
    /// @param _item The bid amount.
    function isContains(
        uint32[] memory self,
        uint32 _item
    ) internal pure returns (bool) {
        for (uint64 i = 0; i < self.length; i++) {
            if (self[i] == _item) {
                return true;
            }
        }
        return false;
    }

    function deDuplicate(
        uint32[] memory self
    ) public pure returns (uint32[] memory) {
        if (self.length <= 1) {
            return self;
        }

        uint32[] memory buf = new uint32[](self.length);
        uint64 newSize = 0;
        uint64 current = 0;

        for (uint64 i = 0; i < self.length; i++) {
            bool duplicate = false;
            for (uint64 j = 0; j < newSize; j++) {
                if (buf[j] == self[i]) {
                    duplicate = true;
                    break;
                }
            }
            if (!duplicate) {
                buf[current] = self[i];
                current++;
                newSize++;
            }
        }

        uint32[] memory output = new uint32[](newSize);
        for (uint64 i = 0; i < newSize; i++) {
            output[i] = buf[i];
        }

        return output;
    }
}
