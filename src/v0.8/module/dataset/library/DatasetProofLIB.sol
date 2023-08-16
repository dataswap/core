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

import {DatasetType} from "../../../types/DatasetType.sol";
import {DatasetStateMachineLIB} from "./DatasetStateMachineLIB.sol";
import {DatasetProofInnernalLIB} from "./proof/DatasetProofInnernalLIB.sol";
import {CidUtils} from "../../../shared/utils/cid/CidUtils.sol";
import {MerkleUtils} from "../../../shared/utils/merkle/MerkleUtils.sol";

/// @title DatasetProofLIB Library,include add,get,verify.
/// @notice This library provides functions for managing proofs associated with datasets.
library DatasetProofLIB {
    using DatasetStateMachineLIB for DatasetType.Dataset;
    using DatasetProofInnernalLIB for DatasetType.DatasetProof;

    /// @notice Submit a proof for a dataset.
    /// @dev This function allows submitting a proof for a dataset and emits the SubmitDatasetProof event.
    /// @param self The dataset to which the proof will be submitted.
    function submitDatasetProof(
        DatasetType.Dataset storage self,
        DatasetType.DataType _dataType,
        bytes32 _rootHash,
        bytes32[] calldata _leafHashes,
        uint32[] calldata _leafSizes,
        bool _completed
    ) external {
        DatasetType.DatasetProof storage proof;
        if (_dataType == DatasetType.DataType.Dataset) {
            proof = self.sourceProof;
        } else {
            proof = self.mappingFilesProof;
        }
        proof.submitDatasetProof(
            _rootHash,
            _leafHashes,
            _leafSizes,
            _completed
        );
    }

    /// @notice Get the source dataset proof from the submitted dataset proof.
    /// @dev This function returns the root hash and array of leaf hashes of the Merkle proof for the source dataset.
    /// @param self The dataset from which to retrieve the source dataset proof.
    function getDatasetChunkProof(
        DatasetType.Dataset storage self,
        DatasetType.DataType _dataType,
        uint32 _chunkId
    ) public view returns (bytes32[] memory cids, uint32[] memory sizes) {
        DatasetType.DatasetProof storage proof;
        if (_dataType == DatasetType.DataType.Dataset) {
            proof = self.sourceProof;
        } else {
            proof = self.mappingFilesProof;
        }
        return proof.getDatasetChunkProof(_chunkId);
    }

    /// @notice Get the source dataset CID array from the submitted dataset proof.
    /// @dev This function returns the array of CIDs for the source dataset from the submitted dataset proof.
    /// @param self The dataset from which to retrieve the source dataset proof.
    /// @return The array of CIDs for the source dataset.
    function getDatasetChunkCars(
        DatasetType.Dataset storage self,
        DatasetType.DataType _dataType,
        uint32 _chunkId
    ) public view returns (bytes32[] memory, uint32[] memory) {
        DatasetType.DatasetProof storage proof;
        if (_dataType == DatasetType.DataType.Dataset) {
            proof = self.sourceProof;
        } else {
            proof = self.mappingFilesProof;
        }
        return proof.getDatasetChunkCars(_chunkId);
    }
}
