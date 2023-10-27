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

import {DatasetType} from "src/v0.8/types/DatasetType.sol";
import {DatasetStateMachineLIB} from "src/v0.8/module/dataset/library/metadata/DatasetStateMachineLIB.sol";

library DatasetProofInnerLIB {
    using DatasetStateMachineLIB for DatasetType.Dataset;

    /// @notice Set the root hash of the data's Merkle tree for a dataset proof.
    /// @dev This function allows setting the root hash of the Merkle tree associated with a dataset proof.
    /// @param self The dataset proof to which the root hash will be set.
    /// @param _rootHash The root hash of the data's Merkle tree.
    function setRootHash(
        DatasetType.Proof storage self,
        bytes32 _rootHash
    ) internal {
        self.rootHash = _rootHash;
    }

    /// @notice Get the root hash of the data's Merkle tree from a dataset proof.
    /// @dev This function allows getting the root hash of the Merkle tree associated with a dataset proof.
    /// @param self The dataset proof from which the root hash will be retrieved.
    /// @return The root hash of the data's Merkle tree.
    function getRootHash(
        DatasetType.Proof storage self
    ) internal view returns (bytes32) {
        return self.rootHash;
    }

    /// @notice Set the completion status for all proof batches in a dataset proof.
    /// @dev This function allows setting the completion status for all proof batches in a dataset proof.
    /// @param self The dataset proof for which the completion status will be set.
    /// @param _completed The completion status to be set.
    function setAllCompleted(
        DatasetType.Proof storage self,
        bool _completed
    ) internal {
        self.allCompleted = _completed;
    }

    /// @notice Get the completion status for all proof batches in a dataset proof.
    /// @dev This function allows getting the completion status for all proof batches in a dataset proof.
    /// @param self The dataset proof from which the completion status will be retrieved.
    /// @return The completion status for all proof batches.
    function getAllCompleted(
        DatasetType.Proof storage self
    ) internal view returns (bool) {
        return self.allCompleted;
    }

    /// @notice Set a specific proof batch for a dataset proof.
    /// @dev This function allows setting a specific proof batch in a dataset proof.
    /// @param self The dataset proof to which the proof batch will be added.
    /// @param _leafHashes Array of leaf hashes representing items in the data.
    /// @param _leafIndex The sizes of the leaf hashes.
    function addProofBatch(
        DatasetType.Proof storage self,
        uint64[] memory _leafHashes,
        uint64 _leafIndex
    ) internal {
        uint64 index = _leafIndex;
        for (uint64 i; i < _leafHashes.length; i++) {
            require(index == self.leafHashesCount, "index must match Count");
            index++;
            self.leafHashesCount++;
            self.leafHashes.push(_leafHashes[i]);
        }
    }

    /// @notice Get a specific proof batch from a dataset proof.
    /// @dev This function allows getting a specific proof batch from a dataset proof.
    /// @param self The dataset proof from which the proof batch will be retrieved.
    function getProof(
        DatasetType.Proof storage self,
        uint64 _index,
        uint64 _len
    ) internal view returns (uint64[] memory) {
        require(
            _index + _len <= self.leafHashes.length,
            "Index+len out of bounds"
        );
        require(
            self.leafHashesCount == self.leafHashes.length,
            "length must matched"
        );
        uint64[] memory result = new uint64[](_len);
        for (uint64 i = 0; i < _len; i++) {
            result[i] = self.leafHashes[i + _index];
        }
        return result;
    }
}
