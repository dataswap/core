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
import {TestHelpers} from "src/v0.8/shared/utils/common/TestHelpers.sol";
import {DatasetType} from "src/v0.8/types/DatasetType.sol";
import {IDatasets} from "src/v0.8/interfaces/module/IDatasets.sol";

// Contract definition for test helper functions
contract Generator {
    uint64 private nonce = 0;

    function generateRoot() public returns (bytes32) {
        nonce++;
        return TestHelpers.convertUint64ToBytes32(nonce);
    }

    function generateLeaves(uint64 _count) public returns (bytes32[] memory) {
        bytes32[] memory leaves = new bytes32[](_count);
        for (uint64 i = 0; i < _count; i++) {
            nonce++;
            leaves[i] = TestHelpers.convertUint64ToBytes32(nonce);
        }
        return leaves;
    }

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

    function generateLeavesAndSizes(
        uint64 _count
    ) public returns (bytes32[] memory, uint64[] memory, uint64 totalSize) {
        bytes32[] memory leaves = new bytes32[](_count);
        uint64[] memory sizes = new uint64[](_count);
        leaves = generateLeaves(_count);
        (sizes, totalSize) = generateSizes(_count);
        return (leaves, sizes, totalSize);
    }

    function generateNonce() public returns (uint64) {
        nonce++;
        return nonce;
    }

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

    function generateFilecoinDealId() external returns (uint64) {
        nonce++;
        return nonce;
    }
}
