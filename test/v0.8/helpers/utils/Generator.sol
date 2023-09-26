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

// Import required external contracts and interfaces
import {CommonHelpers} from "test/v0.8/helpers/utils/CommonHelpers.sol";

// Contract definition for test helper functions
contract Generator {
    uint64 private nonce = 0;

    /// @notice Generate a root hash for testing.
    /// @return A bytes32 root hash.
    function generateRoot() public returns (bytes32) {
        nonce++;
        return CommonHelpers.convertUint64ToBytes32(nonce);
    }

    /// @notice Generate an array of leaves for testing.
    /// @param _count The number of leaves to generate.
    /// @param _offset The offset of leaves to generate.
    /// @return An array of bytes32 leaves, an array of uint64 indexes.
    function generateLeaves(
        uint64 _count,
        uint64 _offset
    ) public returns (bytes32[] memory, uint64[] memory) {
        bytes32[] memory leaves = new bytes32[](_count);
        uint64[] memory indexs = new uint64[](_count);
        for (uint64 i = 0; i < _count; i++) {
            nonce++;
            indexs[i] = i + _offset;
            leaves[i] = CommonHelpers.convertUint64ToBytes32(nonce);
        }
        return (leaves, indexs);
    }

    /// @notice Generate an array of sizes for testing.
    /// @param _count The number of sizes to generate.
    /// @return An array of uint64 sizes and the total size.
    function generateSizes(
        uint64 _count
    ) public returns (uint64[] memory, uint64 totalSize) {
        uint64[] memory sizes = new uint64[](_count);
        for (uint64 i = 0; i < _count; i++) {
            nonce++;
            sizes[i] = nonce;
            totalSize += sizes[i];
        }
        return (sizes, totalSize);
    }

    /// @notice Generate an array of leaves and sizes for testing.
    /// @param _count The number of leaves and sizes to generate.
    /// @param _offset The offset of leaves and sizes to generate.
    /// @return An array of bytes32 leaves, an array of uint64 indexes, an array of uint64 sizes, and the total size.
    function generateLeavesAndSizes(
        uint64 _count,
        uint64 _offset
    )
        public
        returns (
            bytes32[] memory,
            uint64[] memory,
            uint64[] memory,
            uint64 totalSize
        )
    {
        bytes32[] memory leaves = new bytes32[](_count);
        uint64[] memory indexs = new uint64[](_count);
        uint64[] memory sizes = new uint64[](_count);
        (leaves, indexs) = generateLeaves(_count, _offset);
        (sizes, totalSize) = generateSizes(_count);
        return (leaves, indexs, sizes, totalSize);
    }

    /// @notice Generate a nonce for testing.
    /// @return A uint64 nonce.
    function generateNonce() public returns (uint64) {
        nonce++;
        return nonce;
    }

    /// @notice Generate an array of Filecoin claim IDs for testing.
    /// @param _count The number of claim IDs to generate.
    /// @return filecoinClaimIds  An array of uint64 claim IDs.
    function generateFilecoinClaimIds(
        uint64 _count
    ) external returns (uint64[] memory filecoinClaimIds) {
        uint64[] memory ids = new uint64[](_count);
        for (uint64 i = 0; i < _count; i++) {
            nonce++;
            ids[i] = nonce;
        }
        return ids;
    }

    /// @notice Generate a Filecoin claim ID for testing.
    /// @return A uint64 claim ID.
    function generateFilecoinClaimId() external returns (uint64) {
        nonce++;
        return nonce;
    }

    /// @notice Generate a address for testing.
    /// @return An address.
    function generateAddress(uint64 random) external returns (address) {
        nonce++;
        return address(uint160(nonce + random));
    }
}
