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

/// @title CidUtils
library CidUtils {
    /// @notice Convert a bytes32 hash to a CID.
    /// @dev This function converts a bytes32 hash to a CID using the specified encoding.
    ///      TODO:https://github.com/dataswap/core/issues/32
    /// @return The CID corresponding to the input hash.
    function hashToCID(bytes32 /*hash*/) internal pure returns (bytes32) {
        // Convert bytes32 hash to bytes
        return "";
    }

    /// @notice Convert an array of bytes32 hashes to an array of CIDs.
    /// @dev This function converts an array of bytes32 hashes to an array of CIDs using the specified encoding.
    /// @param hashes The array of bytes32 hashes to convert.
    /// @return The array of CIDs corresponding to the input hashes.
    function hashesToCIDs(
        bytes32[] memory hashes
    ) internal pure returns (bytes32[] memory) {
        bytes32[] memory cids = new bytes32[](hashes.length);
        for (uint256 i = 0; i < hashes.length; i++) {
            cids[i] = hashToCID(hashes[i]);
        }
        return cids;
    }
}
