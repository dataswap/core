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
import {MerkleUtils} from "../../../shared/merkle/MerkleUtils.sol";

/// @title DatasetVerificationLIB Library,include add,get,verify.
/// @notice This library provides functions for managing verification associated with datasets.
/// @dev Note:Need to check carefully,Need rewrite verification logic.
library DatasetVerificationLIB {
    /// @notice Validates the submitted verification proofs.
    /// @dev This function checks the validity of the submitted Merkle proofs for both the source dataset and mapping files.
    /// @param _sourceDatasetProofRootHashes The array of root hashes of the Merkle proofs for the source dataset.
    /// @param _sourceDatasetProofLeafHashes The array of arrays of leaf hashes of the Merkle proofs for the source dataset.
    /// @param _sourceToCarMappingFilesProofRootHashes The array of root hashes of the Merkle proofs for mapping files from source to car.
    /// @param _sourceToCarMappingFilesProofLeafHashes The array of arrays of leaf hashes of the Merkle proofs for mapping files from source to car.
    function _requireValidVerification(
        bytes32[] calldata _sourceDatasetProofRootHashes,
        bytes32[][] calldata _sourceDatasetProofLeafHashes,
        bytes32[] calldata _sourceToCarMappingFilesProofRootHashes,
        bytes32[][] calldata _sourceToCarMappingFilesProofLeafHashes
    ) private pure {
        require(
            _sourceDatasetProofRootHashes.length ==
                _sourceDatasetProofLeafHashes.length,
            "Invalid number of source dataset proofs"
        );

        require(
            _sourceToCarMappingFilesProofRootHashes.length ==
                _sourceToCarMappingFilesProofLeafHashes.length,
            "Invalid number of source to car mapping files proofs"
        );

        for (uint256 i = 0; i < _sourceDatasetProofRootHashes.length; i++) {
            require(
                MerkleUtils.isValidMerkleProof(
                    _sourceDatasetProofRootHashes[i],
                    _sourceDatasetProofLeafHashes[i]
                ),
                "Invalid source dataset proof"
            );
        }

        for (
            uint256 i = 0;
            i < _sourceToCarMappingFilesProofRootHashes.length;
            i++
        ) {
            require(
                MerkleUtils.isValidMerkleProof(
                    _sourceToCarMappingFilesProofRootHashes[i],
                    _sourceToCarMappingFilesProofLeafHashes[i]
                ),
                "Invalid source to car mapping files proof"
            );
        }
    }

    /// @notice Submit a verification for a dataset.
    /// @dev This function allows submitting a verification for a dataset and triggers appropriate actions based on verification results.
    /// @param self The dataset to which the verification will be submitted.
    /// @param _randomSeed Random seed used for verification.
    /// @param _sourceDatasetProofRootHashes Array of root hashes for source dataset proofs.
    /// @param _sourceDatasetProofLeafHashes Array of arrays of leaf hashes for source dataset proofs.
    /// @param _sourceToCarMappingFilesProofRootHashes Array of root hashes for source-to-car mapping files proofs.
    /// @param _sourceToCarMappingFilesProofLeafHashes Array of arrays of leaf hashes for source-to-car mapping files proofs.
    function _submitDatasetVerification(
        DatasetType.Dataset storage self,
        uint64 _randomSeed,
        bytes32[] calldata _sourceDatasetProofRootHashes,
        bytes32[][] calldata _sourceDatasetProofLeafHashes,
        bytes32[] calldata _sourceToCarMappingFilesProofRootHashes,
        bytes32[][] calldata _sourceToCarMappingFilesProofLeafHashes
    ) internal returns (bool) {
        // TODO: Verify that _randomSeed corresponds to the DatasetRootHash of the challenged dataset's leaf node
        require(_randomSeed > 0, "Invalid random seed");

        _requireValidVerification(
            _sourceDatasetProofRootHashes,
            _sourceDatasetProofLeafHashes,
            _sourceToCarMappingFilesProofRootHashes,
            _sourceToCarMappingFilesProofLeafHashes
        );

        // Update the dataset state here
        self.VerificationsCount++;
        DatasetType.Verification storage verification = self.Verifications[
            msg.sender
        ];
        verification.randomSeed = _randomSeed;

        // Initialize storage arrays for source dataset and mapping files proofs
        DatasetType.MerkleTree[]
            storage sourceDatasetChallengeProofs = verification
                .proof
                .sourceDatasetChallengeProofs;
        DatasetType.MerkleTree[]
            storage sourceToCarMappingFilesChallengeProofs = verification
                .proof
                .sourceToCarMappingFilesChallengeProofs;

        // Populate sourceDatasetChallengeProofs and sourceToCarMappingFilesChallengeProofs
        for (uint256 i = 0; i < _sourceDatasetProofRootHashes.length; i++) {
            sourceDatasetChallengeProofs.push(
                DatasetType.MerkleTree({
                    rootHash: _sourceDatasetProofRootHashes[i],
                    leafHashes: _sourceDatasetProofLeafHashes[i]
                })
            );

            sourceToCarMappingFilesChallengeProofs.push(
                DatasetType.MerkleTree({
                    rootHash: _sourceToCarMappingFilesProofRootHashes[i],
                    leafHashes: _sourceToCarMappingFilesProofLeafHashes[i]
                })
            );
        }

        // Update verification.proof with the modified arrays
        verification
            .proof
            .sourceDatasetChallengeProofs = sourceDatasetChallengeProofs;
        verification
            .proof
            .sourceToCarMappingFilesChallengeProofs = sourceToCarMappingFilesChallengeProofs;

        return true;
    }

    /// @notice Get the verification details for a specific index of a dataset.
    /// @dev This function returns the verification details for a specific verification conducted on the dataset.
    /// @param self The dataset for which to retrieve verification details.
    /// @param _auditor address of the auditor.
    function getDatasetVerification(
        DatasetType.Dataset storage self,
        address _auditor
    )
        public
        view
        returns (
            uint64 randomSeed,
            bytes32[] memory sourceDatasetProofRootHashes,
            bytes32[][] memory sourceDatasetProofLeafHashes,
            bytes32[] memory sourceToCarMappingFilesProofRootHashes,
            bytes32[][] memory sourceToCarMappingFilesProofLeafHashes
        )
    {
        require(_auditor != address(0), "Invalid auditor address");

        DatasetType.Verification storage verification = self.Verifications[
            _auditor
        ];
        randomSeed = verification.randomSeed;

        // Handle sourceDatasetChallengeProofs
        sourceDatasetProofRootHashes = new bytes32[](
            verification.proof.sourceDatasetChallengeProofs.length
        );
        sourceDatasetProofLeafHashes = new bytes32[][](
            verification.proof.sourceDatasetChallengeProofs.length
        );
        for (
            uint256 i = 0;
            i < verification.proof.sourceDatasetChallengeProofs.length;
            i++
        ) {
            sourceDatasetProofRootHashes[i] = verification
                .proof
                .sourceDatasetChallengeProofs[i]
                .rootHash;
            sourceDatasetProofLeafHashes[i] = verification
                .proof
                .sourceDatasetChallengeProofs[i]
                .leafHashes;
        }

        // Handle sourceToCarMappingFilesChallengeProofs
        sourceToCarMappingFilesProofRootHashes = new bytes32[](
            verification.proof.sourceToCarMappingFilesChallengeProofs.length
        );
        sourceToCarMappingFilesProofLeafHashes = new bytes32[][](
            verification.proof.sourceToCarMappingFilesChallengeProofs.length
        );
        for (
            uint256 i = 0;
            i <
            verification.proof.sourceToCarMappingFilesChallengeProofs.length;
            i++
        ) {
            sourceToCarMappingFilesProofRootHashes[i] = verification
                .proof
                .sourceToCarMappingFilesChallengeProofs[i]
                .rootHash;
            sourceToCarMappingFilesProofLeafHashes[i] = verification
                .proof
                .sourceToCarMappingFilesChallengeProofs[i]
                .leafHashes;
        }
    }

    /// @notice Get the count of verifications for a dataset.
    /// @dev This function returns the count of verifications conducted on the dataset.
    /// @param self The dataset for which to retrieve the verification count.
    function getDatasetVerificationsCount(
        DatasetType.Dataset storage self
    ) public view returns (uint256) {
        return self.VerificationsCount;
    }
}
