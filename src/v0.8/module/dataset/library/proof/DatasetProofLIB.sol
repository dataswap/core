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
import {DatasetStateMachineLIB} from "src/v0.8/module/dataset/library/DatasetStateMachineLIB.sol";
import {DatasetProofInnerLIB} from "src/v0.8/module/dataset/library/proof/DatasetProofInnerLIB.sol";

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
        bool _allCompleted
    ) internal {
        require(_leafHashes.length == _leafSizes.length, "length must matched");
        DatasetType.DatasetProof storage proof;
        if (_dataType == DatasetType.DataType.Source) {
            proof = self.sourceProof;
        } else {
            proof = self.mappingFilesProof;
        }
        if (proof.leafHashesCount == 0) {
            require(_rootHash.length == 32, "length must matched");
            proof.rootHash = _rootHash;
        }
        if (proof.allCompleted == false && _allCompleted == true)
            proof.allCompleted = _allCompleted;
        proof.addProofBatch(_leafHashes);

        for (uint64 i; i < _leafSizes.length; i++) {
            proof.datasetSize += _leafSizes[i];
        }
    }

    /// @notice Get the source dataset proof from the submitted dataset proof.
    /// @dev This function returns the root hash and array of leaf hashes of the Merkle proof for the source dataset.
    /// @param self The dataset from which to retrieve the source dataset proof.
    function getDatasetProof(
        DatasetType.Dataset storage self,
        DatasetType.DataType _dataType,
        uint64 _index,
        uint64 _len
    ) internal view returns (bytes32[] memory) {
        DatasetType.DatasetProof storage proof;
        if (_dataType == DatasetType.DataType.Source) {
            proof = self.sourceProof;
        } else {
            proof = self.mappingFilesProof;
        }
        return proof.getProof(_index, _len);
    }

    /// @notice Get the source dataset proof from the submitted dataset proof.
    /// @dev This function returns the root hash and array of leaf hashes of the Merkle proof for the source dataset.
    /// @param self The dataset from which to retrieve the source dataset proof.
    function getDatasetCars(
        DatasetType.Dataset storage self,
        DatasetType.DataType _dataType,
        uint64 _index,
        uint64 _len
    ) internal view returns (bytes32[] memory) {
        bytes32[] memory hashes = getDatasetProof(
            self,
            _dataType,
            _index,
            _len
        );
        //TODO: hashes to cid
        return hashes;
    }

    /// @notice Get the source dataset proof from the submitted dataset proof.
    /// @dev This function returns the root hash and array of leaf hashes of the Merkle proof for the source dataset.
    /// @param self The dataset from which to retrieve the source dataset proof.
    function getDatasetCount(
        DatasetType.Dataset storage self,
        DatasetType.DataType _dataType
    ) internal view returns (uint64) {
        DatasetType.DatasetProof storage proof;
        if (_dataType == DatasetType.DataType.Source) {
            proof = self.sourceProof;
        } else {
            proof = self.mappingFilesProof;
        }
        return proof.leafHashesCount;
    }

    /// @notice Get the source dataset proof from the submitted dataset proof.
    /// @dev This function returns the root hash and array of leaf hashes of the Merkle proof for the source dataset.
    /// @param self The dataset from which to retrieve the source dataset proof.
    function getDatasetSize(
        DatasetType.Dataset storage self,
        DatasetType.DataType _dataType
    ) internal view returns (uint64) {
        DatasetType.DatasetProof storage proof;
        if (_dataType == DatasetType.DataType.Source) {
            proof = self.sourceProof;
        } else {
            proof = self.mappingFilesProof;
        }
        return proof.datasetSize;
    }

    /// @notice Get submitter of dataset's proofs.
    /// @param self The dataset from which to retrieve the source dataset proof.
    /// @return The address of submitter
    function getDatasetSubmitter(
        DatasetType.Dataset storage self
    ) internal view returns (address) {
        return self.proofSubmitter;
    }

    /// @notice Check if a dataset has submitter
    /// @param self The dataset from which to retrieve the source dataset proof.
    /// @param submitter The address being compared.
    function isDatasetSubmitter(
        DatasetType.Dataset storage self,
        address submitter
    ) internal view returns (bool) {
        if (submitter == self.proofSubmitter) {
            return true;
        }
        return false;
    }
}
