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

import {IMerkleUtils} from "src/v0.8/interfaces/utils/IMerkleUtils.sol";

/// @title MerkleUtils
contract MerkleUtils is IMerkleUtils {
    /// @notice Validate a Merkle proof.
    /// @dev This function checks if a given Merkle proof is valid.
    function isValidMerkleProof(
        bytes32 _root,
        bytes32 _leaf,
        bytes32[] memory _siblings,
        uint32 _path
    ) external pure returns (bool) {
        return processProof(_siblings, _path, _leaf) == _root;
    }

    /// @notice processProof generate proof root hash
    /// @dev Generate proof root hash to verify
    /// @param _siblings Merkle proof _siblings
    /// @param _path Merkle proof _path
    /// @param _leaf Merkle proof _leaf
    /// @return Merkle proof rootHash
    function processProof(
        bytes32[] memory _siblings,
        uint32 _path,
        bytes32 _leaf
    ) internal pure returns (bytes32) {
        bytes32 computedHash = _leaf;
        for (uint256 i = 0; i < _siblings.length; i++) {
            if ((_path & 1) == 1) {
                computedHash = _hashFunction(
                    concatHash(computedHash, _siblings[i])
                );
            } else {
                computedHash = _hashFunction(
                    concatHash(_siblings[i], computedHash)
                );
            }
            _path >>= 1;
        }
        return computedHash;
    }

    /// @notice concatHash concatenates two bytes32, b1 and b2, in a sorted order.
    /// @dev Concatenates two bytes32, b1 and b2, in a sorted order.
    /// @param _b1 concat first hash.
    /// @param _b2 concat second hash.
    /// @return concat hash value.
    function concatHash(
        bytes32 _b1,
        bytes32 _b2
    ) internal pure returns (bytes memory) {
        return bytes.concat(_b1, _b2);
    }

    /// @notice Hash generate function
    /// @dev Hash generate function
    /// @param _data Input hash generate value.
    /// @return Output hash generate value.
    function _hashFunction(bytes memory _data) internal pure returns (bytes32) {
        bytes32 result = sha256(_data);

        // Extract the byte to modify
        bytes32 intermediate = result & (~bytes32(uint256(0xFF)));
        // Add the modified byte
        result = result & (intermediate | bytes32(uint256(0x3F)));

        return result;
    }

    /// @notice Mock function
    function setMockValidState(bool _state) external {}
}
