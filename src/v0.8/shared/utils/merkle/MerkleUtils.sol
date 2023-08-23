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

/// @title MerkleUtils
library MerkleUtils {
    /// @notice Validate a Merkle proof.
    /// @dev This function checks if a given Merkle proof is valid.
    function isValidMerkleProof(
        bytes32 /*_rootHash*/,
        bytes32[] calldata /*_leafHashes*/
    ) internal pure returns (bool) {
        // TODO: https://github.com/dataswap/core/issues/31
        // Implement the validation logic for the Merkle proof here.
        // You can use libraries like OpenZeppelin's MerkleProof to validate the proof.
        // If the validation fails, you can use a require statement to revert with an error message.
        return true;
    }
}
