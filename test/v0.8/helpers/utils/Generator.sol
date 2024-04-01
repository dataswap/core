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
import {DatasetType} from "src/v0.8/types/DatasetType.sol";
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
    ///  @param _dataType The data type of the dataset.
    /// @param _count The number of sizes to generate.
    /// @return An array of uint64 sizes and the total size.
    function generateSizes(
        DatasetType.DataType _dataType,
        uint64 _count
    ) public returns (uint64[] memory, uint64 totalSize) {
        uint64[] memory sizes = new uint64[](_count);
        for (uint64 i = 0; i < _count; i++) {
            nonce++;
            if (_dataType == DatasetType.DataType.Source) {
                sizes[i] = nonce * 100 + 1024 * 1024 * 1024 * 30;
            } else {
                sizes[i] = nonce;
            }
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
        DatasetType.DataType _dataType,
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
        (sizes, totalSize) = generateSizes(_dataType, _count);
        return (leaves, indexs, sizes, totalSize);
    }

    /// @notice Generate an array of uint16 for testing.
    /// @param _count The number of row element's count.
    /// @param _duplicate The duplicate number of row elements.
    /// @return An array of uint16[].
    function generateGeolocationPositions(
        uint16 _count,
        uint16 _duplicate
    ) external returns (uint16[] memory) {
        return generateArrayUint16(_count, _duplicate);
    }

    /// @notice Generate an two-dimensional of uint32 for testing.
    /// @param _rowCount The number of row element's count.
    /// @param _columnCount The number of column element's count.
    /// @param _rowDuplicate The duplicate number of row elements.
    /// @param _columnDuplicate The duplicate number of column elements.
    /// @return An array of uint32[][].
    function generateGeolocationCitys(
        uint16 _rowCount,
        uint16 _columnCount,
        uint16 _rowDuplicate,
        uint16 _columnDuplicate
    ) external returns (uint32[][] memory) {
        uint32[][] memory elements = new uint32[][](_rowCount);
        for (uint16 i = 0; i < _rowCount; i++) {
            elements[i] = generateArrayUint32(_columnCount, _columnDuplicate);
            nonce++;
            if (i < _rowDuplicate) {
                elements[i][0] = elements[0][0];
            }
        }
        return (elements);
    }

    /// @notice Generate an two-dimensional of address for testing.
    /// @param _rowCount The number of row element's count.
    /// @param _columnCount The number of column element's count.
    /// @param _rowDuplicate The duplicate number of row elements.
    /// @param _columnDuplicate The duplicate number of column elements.
    /// @param _contain The address defined in replica's requirements
    /// @return An array of address[][].
    function generateGeolocationActors(
        uint16 _rowCount,
        uint16 _columnCount,
        uint16 _rowDuplicate,
        uint16 _columnDuplicate,
        address _contain
    ) external returns (address[][] memory) {
        address[][] memory elements = new address[][](_rowCount);
        for (uint16 i = 0; i < _rowCount; i++) {
            elements[i] = generateArrayAddress(_columnCount, _columnDuplicate);
            nonce++;
            if (i < _rowDuplicate) {
                elements[i][0] = _contain;
            }
        }
        if (elements.length > 0) {
            if (elements[0].length > 0) {
                elements[0][0] = _contain;
            }
        }
        return (elements);
    }

    /// @notice Generate an array of address for testing.
    /// @param _count The number of element's count.
    /// @param _duplicate The duplicate number of element's.
    /// @return An array of address[].
    function generateArrayAddress(
        uint16 _count,
        uint16 _duplicate
    ) public returns (address[] memory) {
        require(_count >= _duplicate, "count not match");

        address[] memory elements = new address[](_count);
        for (uint16 i = 0; i < _count; i++) {
            nonce++;
            elements[i] = generateAddress(i + 1);
        }
        for (uint16 i = 0; i < _duplicate; i++) {
            elements[i] = elements[0];
        }
        return (elements);
    }

    /// @notice Generate an array of uint16 for testing.
    /// @param _count The number of element's count.
    /// @param _duplicate The duplicate number of element's.
    /// @return An array of uint16[].
    function generateArrayUint16(
        uint16 _count,
        uint16 _duplicate
    ) public returns (uint16[] memory) {
        require(_count >= _duplicate, "count not match");
        uint16[] memory elements = new uint16[](_count);
        for (uint64 i = 0; i < _count; i++) {
            nonce++;
            elements[i] = uint16(generateUint(i + 1));
        }
        for (uint64 i = 0; i < _duplicate; i++) {
            elements[i] = elements[0];
        }
        return (elements);
    }

    /// @notice Generate an array of uint32 for testing.
    /// @param _count The number of element's count.
    /// @param _duplicate The duplicate number of element's.
    /// @return An array of uint32[].
    function generateArrayUint32(
        uint16 _count,
        uint16 _duplicate
    ) public returns (uint32[] memory) {
        require(_count >= _duplicate, "count not match");
        uint32[] memory elements = new uint32[](_count);
        for (uint64 i = 0; i < _count; i++) {
            nonce++;
            elements[i] = uint32(generateUint(i + 1));
        }
        for (uint64 i = 0; i < _duplicate; i++) {
            elements[i] = elements[0];
        }
        return (elements);
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
    function generateAddress(uint64 random) public returns (address) {
        nonce++;
        return address(uint160(999999 + nonce + random));
    }

    /// @notice Generate a uint for testing.
    /// @return An address.
    function generateUint(uint64 random) public returns (uint256) {
        nonce++;
        return uint256(99 + nonce + random);
    }
}
