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
import {Test} from "forge-std/Test.sol";
import {CommonHelpers} from "test/v0.8/helpers/utils/CommonHelpers.sol";
import {DatasetType} from "src/v0.8/types/DatasetType.sol";
import {IDatasets} from "src/v0.8/interfaces/module/IDatasets.sol";

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
    /// @return An array of bytes32 leaves.
    function generateLeaves(uint64 _count) public returns (bytes32[] memory) {
        bytes32[] memory leaves = new bytes32[](_count);
        for (uint64 i = 0; i < _count; i++) {
            nonce++;
            leaves[i] = CommonHelpers.convertUint64ToBytes32(nonce);
        }
        return leaves;
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
    /// @return An array of bytes32 leaves, an array of uint64 sizes, and the total size.
    function generateLeavesAndSizes(
        uint64 _count
    ) public returns (bytes32[] memory, uint64[] memory, uint64 totalSize) {
        bytes32[] memory leaves = new bytes32[](_count);
        uint64[] memory sizes = new uint64[](_count);
        leaves = generateLeaves(_count);
        (sizes, totalSize) = generateSizes(_count);
        return (leaves, sizes, totalSize);
    }

    /// @notice Generate a nonce for testing.
    /// @return A uint64 nonce.
    function generateNonce() public returns (uint64) {
        nonce++;
        return nonce;
    }

    /// @notice Generate an array of Filecoin deal IDs for testing.
    /// @param _count The number of deal IDs to generate.
    /// @return filecoinDealIds  An array of uint64 deal IDs.
    function generateFilecoinDealIds(
        uint64 _count
    ) external returns (uint64[] memory filecoinDealIds) {
        uint64[] memory ids = new uint64[](_count);
        for (uint64 i = 0; i < _count; i++) {
            nonce++;
            ids[i] = nonce;
        }
        return ids;
    }

    /// @notice Generate a Filecoin deal ID for testing.
    /// @return A uint64 deal ID.
    function generateFilecoinDealId() external returns (uint64) {
        nonce++;
        return nonce;
    }
}
