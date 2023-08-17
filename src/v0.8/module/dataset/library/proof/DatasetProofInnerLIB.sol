// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.21;

import {DatasetType} from "../../../../types/DatasetType.sol";
import {DatasetStateMachineLIB} from "../DatasetStateMachineLIB.sol";
import {CidUtils} from "../../../../shared/utils/cid/CidUtils.sol";
import {MerkleUtils} from "../../../../shared/utils/merkle/MerkleUtils.sol";

library DatasetProofInnerLIB {
    using DatasetStateMachineLIB for DatasetType.Dataset;

    /// @notice Set the root hash of the data's Merkle tree for a dataset proof.
    /// @dev This function allows setting the root hash of the Merkle tree associated with a dataset proof.
    /// @param self The dataset proof to which the root hash will be set.
    /// @param _rootHash The root hash of the data's Merkle tree.
    function setRootHash(
        DatasetType.DatasetProof storage self,
        bytes32 _rootHash
    ) external {
        self.rootHash = _rootHash;
    }

    /// @notice Get the root hash of the data's Merkle tree from a dataset proof.
    /// @dev This function allows getting the root hash of the Merkle tree associated with a dataset proof.
    /// @param self The dataset proof from which the root hash will be retrieved.
    /// @return The root hash of the data's Merkle tree.
    function getRootHash(
        DatasetType.DatasetProof storage self
    ) external view returns (bytes32) {
        return self.rootHash;
    }

    /// @notice Set the completion status for all proof batches in a dataset proof.
    /// @dev This function allows setting the completion status for all proof batches in a dataset proof.
    /// @param self The dataset proof for which the completion status will be set.
    /// @param _completed The completion status to be set.
    function setAllBatchCompleted(
        DatasetType.DatasetProof storage self,
        bool _completed
    ) external {
        self.allBatchCompleted = _completed;
    }

    /// @notice Get the completion status for all proof batches in a dataset proof.
    /// @dev This function allows getting the completion status for all proof batches in a dataset proof.
    /// @param self The dataset proof from which the completion status will be retrieved.
    /// @return The completion status for all proof batches.
    function getAllBatchCompleted(
        DatasetType.DatasetProof storage self
    ) external view returns (bool) {
        return self.allBatchCompleted;
    }

    /// @notice Set a specific proof batch for a dataset proof.
    /// @dev This function allows setting a specific proof batch in a dataset proof.
    /// @param self The dataset proof to which the proof batch will be added.
    /// @param _leafHashes Array of leaf hashes representing items in the data.
    function addProofBatch(
        DatasetType.DatasetProof storage self,
        bytes32[] calldata _leafHashes
    ) external {
        self.proofBatchsCount++;
        self.proofBatchs[self.proofBatchsCount] = _leafHashes;
    }

    /// @notice Get a specific proof batch from a dataset proof.
    /// @dev This function allows getting a specific proof batch from a dataset proof.
    /// @param self The dataset proof from which the proof batch will be retrieved.
    /// @param batchIndex The index of the proof batch.
    /// @return Array of leaf hashes representing items in the data.
    function getProofBatch(
        DatasetType.DatasetProof storage self,
        uint64 batchIndex
    ) external view returns (bytes32[] memory) {
        return self.proofBatchs[batchIndex];
    }
}