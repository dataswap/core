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
import {DatasetProofInnerLIB} from "src/v0.8/module/dataset/library/proof/DatasetProofInnerLIB.sol";
import {IDatasetsRequirement} from "src/v0.8/interfaces/module/IDatasetsRequirement.sol";
import {ICarstore} from "src/v0.8/interfaces/core/ICarstore.sol";

/// @title DatasetProofLIB Library,include add,get,verify.
/// @notice This library provides functions for managing proofs associated with datasets.
library DatasetProofLIB {
    using DatasetProofInnerLIB for DatasetType.Proof;

    /// @notice Submit a proof root for a dataset.
    /// @dev This function allows submitting a proof root for a dataset and emits the SubmitDatasetProof event.
    /// @param self The dataset to which the proof will be submitted.
    /// @param _dataType The type of the dataset proof.
    /// @param _rootHash The root hash of the dataset proofs.
    function addDatasetProofRoot(
        DatasetType.DatasetProof storage self,
        DatasetType.DataType _dataType,
        bytes32 _rootHash
    ) internal {
        DatasetType.Proof storage proof;
        if (_dataType == DatasetType.DataType.Source) {
            proof = self.sourceProof;
        } else {
            proof = self.mappingFilesProof;
        }
        if (proof.leafHashesCount == 0) {
            require(_rootHash.length == 32, "length must matched");
            proof.rootHash = _rootHash;
        }
    }

    /// @notice Submit a proof for a dataset.
    /// @dev This function allows submitting a proof for a dataset and emits the SubmitDatasetProof event.
    /// @param self The dataset to which the proof will be submitted.
    /// @param _dataType The type of the dataset proof.
    /// @param _leafHashes The leaf hashes of the proof.
    /// @param _leafIndex The sizes of the leaf hashes.
    /// @param _size The total size of the leaf hashes pieces.
    /// @param _unpadSize The total size of the leaf hashes cars.
    /// @param _allCompleted A boolean indicating if the proof is completed.
    function addDatasetProofBatch(
        DatasetType.DatasetProof storage self,
        DatasetType.DataType _dataType,
        uint64[] memory _leafHashes,
        uint64 _leafIndex,
        uint64 _size,
        uint64 _unpadSize,
        bool _allCompleted
    ) internal {
        DatasetType.Proof storage proof;
        if (_dataType == DatasetType.DataType.Source) {
            proof = self.sourceProof;
        } else {
            proof = self.mappingFilesProof;
        }

        if (proof.allCompleted == false && _allCompleted == true)
            proof.allCompleted = _allCompleted;
        proof.addProofBatch(_leafHashes, _leafIndex);

        proof.datasetSize += _size;
        proof.datasetUnpadSize += _unpadSize;
    }

    /// @notice Get the source dataset proof from the submitted dataset proof.
    /// @dev This function returns the root hash and array of leaf hashes of the Merkle proof for the source dataset.
    /// @param self The dataset from which to retrieve the source dataset proof.
    /// @param _dataType The type of the dataset proof.
    /// @param _index The starting index to get dataset proof..
    /// @param _len The length to get dataset proof..
    /// @return The car hashs of the dataset proof.
    function getDatasetProof(
        DatasetType.DatasetProof storage self,
        DatasetType.DataType _dataType,
        uint64 _index,
        uint64 _len
    ) internal view returns (uint64[] memory) {
        DatasetType.Proof storage proof;
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
    /// @param _dataType The type of the dataset proof.
    /// @param _index The starting index to get dataset proof..
    /// @param _len The length to get dataset proof..
    /// @return The car hashs of the dataset proof.
    function getDatasetCars(
        DatasetType.DatasetProof storage self,
        DatasetType.DataType _dataType,
        uint64 _index,
        uint64 _len
    ) internal view returns (uint64[] memory) {
        uint64[] memory hashes = getDatasetProof(self, _dataType, _index, _len);
        //TODO: hashes to cid
        return hashes;
    }

    /// @notice Get the source dataset proof from the submitted dataset proof.
    /// @dev This function returns the root hash and array of leaf hashes of the Merkle proof for the source dataset.
    /// @param self The dataset from which to retrieve the source dataset proof.
    /// @param _dataType The type of the dataset proof.
    /// @return The count of the hashs of dataset proof.
    function getDatasetCount(
        DatasetType.DatasetProof storage self,
        DatasetType.DataType _dataType
    ) internal view returns (uint64) {
        DatasetType.Proof storage proof;
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
    /// @param _dataType The type of the dataset proof.
    function getDatasetSize(
        DatasetType.DatasetProof storage self,
        DatasetType.DataType _dataType
    ) internal view returns (uint64) {
        DatasetType.Proof storage proof;
        if (_dataType == DatasetType.DataType.Source) {
            proof = self.sourceProof;
        } else {
            proof = self.mappingFilesProof;
        }
        return proof.datasetSize;
    }

    /// @dev Retrieves the unpadded size of the dataset for a given data type.
    /// @param self The storage reference to the dataset proof.
    /// @param _dataType The data type for which to retrieve the unpadded size.
    /// @return The unpadded size of the dataset.
    function getDatasetUnpadSize(
        DatasetType.DatasetProof storage self,
        DatasetType.DataType _dataType
    ) internal view returns (uint64) {
        DatasetType.Proof storage proof;
        if (_dataType == DatasetType.DataType.Source) {
            proof = self.sourceProof;
        } else {
            proof = self.mappingFilesProof;
        }
        return proof.datasetUnpadSize;
    }

    /// @notice Get submitter of dataset's proofs.
    /// @param self The dataset from which to retrieve the source dataset proof.
    /// @return The address of submitter
    function getDatasetSubmitter(
        DatasetType.DatasetProof storage self
    ) internal view returns (address) {
        return self.proofSubmitter;
    }

    /// @notice Retrieves the root hash of the dataset proof for the specified data type.
    /// @param self The storage reference to the dataset proof.
    /// @param _dataType The type of data for which to retrieve the root hash.
    /// @return The root hash of the dataset proof.
    function getDatasetRootHash(
        DatasetType.DatasetProof storage self,
        DatasetType.DataType _dataType
    ) internal view returns (bytes32) {
        DatasetType.Proof storage proof;
        if (_dataType == DatasetType.DataType.Source) {
            proof = self.sourceProof;
        } else {
            proof = self.mappingFilesProof;
        }
        return proof.rootHash;
    }

    /// @notice Check if a dataset has submitter
    /// @param self The dataset from which to retrieve the source dataset proof.
    /// @param submitter The address being compared.
    function isDatasetSubmitter(
        DatasetType.DatasetProof storage self,
        address submitter
    ) internal view returns (bool) {
        if (submitter == self.proofSubmitter) {
            return true;
        }
        return false;
    }

    /// @notice Check if a dataset proof has completed
    /// @param self The dataset from which to retrieve the source dataset proof.
    /// @param _dataType The type of the dataset proof.
    function isDatasetProofallCompleted(
        DatasetType.DatasetProof storage self,
        DatasetType.DataType _dataType
    ) internal view returns (bool) {
        if (_dataType == DatasetType.DataType.Source) {
            return self.sourceProof.allCompleted;
        } else {
            return self.mappingFilesProof.allCompleted;
        }
    }
}
