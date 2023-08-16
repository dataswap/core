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

import {DatasetType} from "../../../../types/DatasetType.sol";
import {DatasetStateMachineLIB} from "../DatasetStateMachineLIB.sol";
import {DatasetLeafLIB} from "./DatasetLeafLIB.sol";
import {CidUtils} from "../../../../shared/utils/cid/CidUtils.sol";
import {MerkleUtils} from "../../../../shared/utils/merkle/MerkleUtils.sol";

/// @title DatasetProofLIB Library,include add,get,verify.
/// @notice This library provides functions for managing proofs associated with datasets.
library DatasetChunkProofLIB {
    using DatasetStateMachineLIB for DatasetType.Dataset;
    using DatasetLeafLIB for DatasetType.Leaf[];

    /// @notice Validate a submitted dataset proof.
    /// @dev This function checks if a submitted dataset proof is valid.
    /// @param _rootHash The root hash of the Merkle proof.
    /// @param _leafHashes The array of leaf hashes of the Merkle proof for the source dataset.
    function _requireValidDatasetProof(
        bytes32 _rootHash,
        bytes32[] calldata _leafHashes
    ) private pure {
        require(
            MerkleUtils.isValidMerkleProof(_rootHash, _leafHashes),
            "Ivalid merkle proof"
        );
        //TODO:requre type and accessmethod
    }

    /// @notice Submit a proof for a dataset.
    /// @dev This function allows submitting a proof for a dataset and emits the SubmitDatasetProof event.
    /// @param self The dataset to which the proof will be submitted.
    /// @param _leafHashes The array of leaf hashes of the Merkle proof for the source dataset.
    function submitDatasetProof(
        DatasetType.DatasetChunkProof storage self,
        bytes32[] calldata _leafHashes,
        uint32[] calldata _leafSizes
    ) external {
        DatasetType.Leaf[] storage leaves = self.leaves;
        leaves.setLeaf(_leafHashes, _leafSizes);
    }

    /// @notice Get the source dataset CID array from the submitted dataset proof.
    /// @dev This function returns the array of CIDs for the source dataset from the submitted dataset proof.
    /// @param self The dataset from which to retrieve the source dataset proof.
    /// @return The array of CIDs for the source dataset.
    function getDatasetSourceCids(
        DatasetType.DatasetChunkProof storage self
    ) public view returns (bytes32[] memory, uint32[] memory) {
        DatasetType.Leaf[] storage sourceLeaves = self.leaves;
        return sourceLeaves.getLeaf();
    }

    /// @notice Get the source dataset proof from the submitted dataset proof.
    /// @dev This function returns the root hash and array of leaf hashes of the Merkle proof for the source dataset.
    /// @param self The dataset from which to retrieve the source dataset proof.
    function getDatasetProof(
        DatasetType.DatasetChunkProof storage self
    ) public view returns (bytes32[] memory cids, uint32[] memory sizes) {
        DatasetType.Leaf[] storage leaves = self.leaves;
        (cids, sizes) = leaves.getLeaf();
    }

    /// @notice Get the source to car mapping files CID array from the submitted dataset proof.
    /// @dev This function returns the array of CIDs for mapping files from source to car from the submitted dataset proof.
    /// @param self The dataset from which to retrieve the mapping files proof.
    /// @return The array of CIDs for mapping files from source to car.
    function getDatasetCars(
        DatasetType.DatasetChunkProof storage self
    ) public view returns (bytes32[] memory, uint32[] memory) {
        return getDatasetProof(self);
    }
}
