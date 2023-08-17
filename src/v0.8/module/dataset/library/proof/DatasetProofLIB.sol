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
import {DatasetProofInnerLIB} from "./DatasetProofInnerLIB.sol";
import {CidUtils} from "../../../../shared/utils/cid/CidUtils.sol";
import {MerkleUtils} from "../../../../shared/utils/merkle/MerkleUtils.sol";

/// @title DatasetProofLIB Library,include add,get,verify.
/// @notice This library provides functions for managing proofs associated with datasets.
library DatasetProofLIB {
    using DatasetStateMachineLIB for DatasetType.Dataset;
    using DatasetProofInnerLIB for DatasetType.DatasetProof;

    /// @notice Submit a proof for a dataset.
    /// @dev This function allows submitting a proof for a dataset and emits the SubmitDatasetProof event.
    /// @param self The dataset to which the proof will be submitted.
    function addDatasetProofBatch(
        DatasetType.Dataset storage self,
        DatasetType.DataType _dataType,
        bytes32 _rootHash,
        bytes32[] calldata _leafHashes,
        uint64[] calldata _leafSizes,
        bool _allBatchCompleted
    ) external {
        require(_leafHashes.length == _leafSizes.length);
        DatasetType.DatasetProof storage proof;
        if (_dataType == DatasetType.DataType.Source) {
            proof = self.sourceProof;
        } else {
            proof = self.mappingFilesProof;
        }
        if (proof.proofBatchsCount == 0) {
            require(_rootHash.length == 32);
            proof.rootHash = _rootHash;
        }
        if (proof.allBatchCompleted == false && _allBatchCompleted == true)
            proof.allBatchCompleted = _allBatchCompleted;
        proof.addProofBatch(_leafHashes);

        for (uint64 i; i < _leafSizes.length; i++) {
            proof.datasetSize += _leafSizes[i];
        }
    }

    /// @notice Get the source dataset proof from the submitted dataset proof.
    /// @dev This function returns the root hash and array of leaf hashes of the Merkle proof for the source dataset.
    /// @param self The dataset from which to retrieve the source dataset proof.
    function getDatasetProofBatch(
        DatasetType.Dataset storage self,
        DatasetType.DataType _dataType,
        uint64 _batchIndex
    ) public view returns (bytes32[] memory) {
        DatasetType.DatasetProof storage proof;
        if (_dataType == DatasetType.DataType.Source) {
            proof = self.sourceProof;
        } else {
            proof = self.mappingFilesProof;
        }
        return proof.getProofBatch(_batchIndex);
    }

    /// @notice Get the source dataset proof from the submitted dataset proof.
    /// @dev This function returns the root hash and array of leaf hashes of the Merkle proof for the source dataset.
    /// @param self The dataset from which to retrieve the source dataset proof.
    function getDatasetCarsBatch(
        DatasetType.Dataset storage self,
        DatasetType.DataType _dataType,
        uint64 _batchIndex
    ) public view returns (bytes32[] memory) {
        bytes32[] memory hashes = getDatasetProofBatch(
            self,
            _dataType,
            _batchIndex
        );
        //TODO: hashes to cid
        return hashes;
    }

    /// @notice Get the source dataset proof from the submitted dataset proof.
    /// @dev This function returns the root hash and array of leaf hashes of the Merkle proof for the source dataset.
    /// @param self The dataset from which to retrieve the source dataset proof.
    function getDatasetProofBatchsCount(
        DatasetType.Dataset storage self,
        DatasetType.DataType _dataType
    ) public view returns (uint64) {
        DatasetType.DatasetProof storage proof;
        if (_dataType == DatasetType.DataType.Source) {
            proof = self.sourceProof;
        } else {
            proof = self.mappingFilesProof;
        }
        return proof.proofBatchsCount;
    }

    /// @notice Get the source dataset proof from the submitted dataset proof.
    /// @dev This function returns the root hash and array of leaf hashes of the Merkle proof for the source dataset.
    /// @param self The dataset from which to retrieve the source dataset proof.
    function getDatasetCarsBatchsCount(
        DatasetType.Dataset storage self,
        DatasetType.DataType _dataType
    ) public view returns (uint64) {
        return getDatasetProofBatchsCount(self, _dataType);
    }

    /// @notice Get the source dataset proof from the submitted dataset proof.
    /// @dev This function returns the root hash and array of leaf hashes of the Merkle proof for the source dataset.
    /// @param self The dataset from which to retrieve the source dataset proof.
    function getDatasetSize(
        DatasetType.Dataset storage self,
        DatasetType.DataType _dataType
    ) public view returns (uint64) {
        DatasetType.DatasetProof storage proof;
        if (_dataType == DatasetType.DataType.Source) {
            proof = self.sourceProof;
        } else {
            proof = self.mappingFilesProof;
        }
        return proof.datasetSize;
    }
}
