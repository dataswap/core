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
import {CidUtils} from "../../../shared/cid/CidUtils.sol";
import {MerkleUtils} from "../../../shared/merkle/MerkleUtils.sol";

/// @title DatasetProofLIB Library,include add,get,verify.
/// @notice This library provides functions for managing proofs associated with datasets.
library DatasetProofLIB {
    using DatasetStateMachineLIB for DatasetType.Dataset;

    /// @notice Validate a submitted dataset proof.
    /// @dev This function checks if a submitted dataset proof is valid.
    /// @param _sourceDatasetRootHash The root hash of the Merkle proof.
    /// @param _sourceDatasetLeafHashes The array of leaf hashes of the Merkle proof for the source dataset.
    /// @param _sourceToCarMappingFilesRootHashes The array of root hashes of the Merkle proof for mapping files from source to car.
    /// @param _sourceToCarMappingFilesLeafHashes The array of leaf hashes of the Merkle proof for mapping files from source to car.
    /// @param _sourceToCarMappingFilesAccessMethod The access method for mapping files from source to car.
    function _requireValidDatasetProof(
        bytes32 _sourceDatasetRootHash,
        bytes32[] calldata _sourceDatasetLeafHashes,
        bytes32 _sourceToCarMappingFilesRootHashes,
        bytes32[] calldata _sourceToCarMappingFilesLeafHashes,
        string calldata _sourceToCarMappingFilesAccessMethod
    ) private pure {
        require(
            MerkleUtils.isValidMerkleProof(
                _sourceDatasetRootHash,
                _sourceDatasetLeafHashes
            ) &&
                MerkleUtils.isValidMerkleProof(
                    _sourceToCarMappingFilesRootHashes,
                    _sourceToCarMappingFilesLeafHashes
                ),
            "Ivalid merkle proof"
        );
        require(
            bytes(_sourceToCarMappingFilesAccessMethod).length > 0,
            "Invalid SourceToCarMappingFiles access method"
        );
    }

    /// @notice Submit a proof for a dataset.
    /// @dev This function allows submitting a proof for a dataset and emits the SubmitDatasetProof event.
    /// @param self The dataset to which the proof will be submitted.
    /// @param _sourceDatasetRootHash The root hash of the Merkle proof.
    /// @param _sourceDatasetLeafHashes The array of leaf hashes of the Merkle proof for the source dataset.
    /// @param _sourceToCarMappingFilesLeafHashes The array of leaf hashes of the Merkle proof for mapping files from source to car.
    /// @param _sourceToCarMappingFilesAccessMethod The access method for mapping files from source to car.
    function submitDatasetProof(
        DatasetType.Dataset storage self,
        bytes32 _sourceDatasetRootHash,
        bytes32[] calldata _sourceDatasetLeafHashes,
        bytes32 _sourceToCarMappingFilesRootHashes,
        bytes32[] calldata _sourceToCarMappingFilesLeafHashes,
        string calldata _sourceToCarMappingFilesAccessMethod
    ) external {
        _requireValidDatasetProof(
            _sourceDatasetRootHash,
            _sourceDatasetLeafHashes,
            _sourceToCarMappingFilesRootHashes,
            _sourceToCarMappingFilesLeafHashes,
            _sourceToCarMappingFilesAccessMethod
        );
        self.proof.sourceDatasetProof.rootHash = _sourceDatasetRootHash;
        self.proof.sourceDatasetProof.leafHashes = _sourceDatasetLeafHashes;
        self
            .proof
            .sourceToCarMappingFilesProof
            .rootHash = _sourceToCarMappingFilesRootHashes;
        self
            .proof
            .sourceToCarMappingFilesProof
            .leafHashes = _sourceToCarMappingFilesLeafHashes;
        self
            .proof
            .sourceToCarMappingFilesAccessMethod = _sourceToCarMappingFilesAccessMethod;

        self._emitDatasetEvent(DatasetType.Event.SubmitDatasetProof);
    }

    /// @notice Get the source dataset CID array from the submitted dataset proof.
    /// @dev This function returns the array of CIDs for the source dataset from the submitted dataset proof.
    /// @param self The dataset from which to retrieve the source dataset proof.
    /// @return The array of CIDs for the source dataset.
    function getDatasetSourceCids(
        DatasetType.Dataset storage self
    ) public view returns (bytes32[] memory) {
        return CidUtils.hashesToCIDs(self.proof.sourceDatasetProof.leafHashes);
    }

    /// @notice Get the source dataset proof from the submitted dataset proof.
    /// @dev This function returns the root hash and array of leaf hashes of the Merkle proof for the source dataset.
    /// @param self The dataset from which to retrieve the source dataset proof.
    /// @return The root hash and array of leaf hashes for the source dataset.
    function getDatasetSourceProof(
        DatasetType.Dataset storage self
    ) public view returns (bytes32, bytes32[] memory) {
        DatasetType.MerkleTree memory proof = self.proof.sourceDatasetProof;
        return (proof.rootHash, proof.leafHashes);
    }

    /// @notice Get the source to car mapping files CID array from the submitted dataset proof.
    /// @dev This function returns the array of CIDs for mapping files from source to car from the submitted dataset proof.
    /// @param self The dataset from which to retrieve the mapping files proof.
    /// @return The array of CIDs for mapping files from source to car.
    function getDatasetSourceToCarMappingFilesCids(
        DatasetType.Dataset storage self
    ) public view returns (bytes32[] memory) {
        return
            CidUtils.hashesToCIDs(
                self.proof.sourceToCarMappingFilesProof.leafHashes
            );
    }

    /// @notice Get the source to car mapping files proof from the submitted dataset proof.
    /// @dev This function returns the root hash and array of leaf hashes of the Merkle proof for mapping files from source to car.
    /// @param self The dataset from which to retrieve the mapping files proof.
    /// @return The root hash and array of leaf hashes for mapping files from source to car.
    function getDatasetSourceToCarMappingFilesProof(
        DatasetType.Dataset storage self
    ) public view returns (bytes32, bytes32[] memory) {
        DatasetType.MerkleTree memory proof = self
            .proof
            .sourceToCarMappingFilesProof;
        return (proof.rootHash, proof.leafHashes);
    }
}
