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

/// @title DatasetType Library
/// @notice This library defines data structures for managing datasets, their metadata, states, and events.
library DatasetType {
    /// @notice Struct representing metadata associated with a dataset.
    struct Metadata {
        string title; // Title of the dataset.
        string industry; // Industry category of the dataset.
        string name; // Name of the dataset.
        string description; // Description of the dataset.
        string source; // Source of the dataset.
        string accessMethod; // Method of accessing the dataset (e.g., URL, API).
        address submitter; // Address of the dataset's submitter.
        uint64 createdBlockNumber; // Block number at which the dataset was created.
        uint64 sizeInBytes; // Size of the dataset in bytes.
        bool isPublic; // Boolean indicating if the dataset is public.
        uint64 version; // Version number of the dataset.
    }

    /// @notice Enum representing the possible states of a dataset.
    enum State {
        None, // No specific state.
        MetadataSubmitted, // Metadata submitted but not approved.
        MetadataApproved, // Metadata has been approved.
        MetadataRejected, // Metadata submission has been rejected.
        DatasetProofSubmitted, // Proof of dataset submitted.
        DatasetApproved // Dataset has been approved.
    }

    /// @notice Enum representing the events related to dataset management.
    enum Event {
        SubmitMetadata, // Metadata submission event.
        MetadataApproved, // Metadata approval event.
        MetadataRejected, // Metadata rejection event.
        SubmitDatasetProof, // Dataset proof submission event.
        DatasetApproved, // Dataset approval event.
        DatasetRejected // Dataset rejection event.
    }

    /// @notice Enum representing the type of data associated with a matching.
    enum DataType {
        MappingFiles, // Matching is associated with mapping files
        Dataset // Matching is associated with a dataset
    }

    struct Leaf {
        bytes32 hash_;
        uint64 size;
    }

    /// @notice Struct representing a Merkle proof for data.
    struct DatasetChunkProof {
        Leaf[] leaves; // Array of leaf hashes representing items in the data.
    }

    /// @notice Struct representing proofs associated with a dataset challenge submitted by reviewers.
    struct DatasetProof {
        bytes32 rootHash; // Root hash of the data's Merkle tree.
        uint64 proofCount;
        bool completed;
        mapping(uint64 => DatasetChunkProof) proof; // Proof associated with the dataset.
    }

    /// @notice Struct representing proofs associated with a dataset challenge submitted by reviewers.
    struct DatasetChallengeProof {
        bytes32[] siblings;
        uint32 path;
    }

    /// @notice Struct representing verification details of a dataset.
    struct Verification {
        uint64 randomSeed; // Random seed used for verification. This seed determines which nodes need to be challenged.
        DatasetChallengeProof[] challengeProof; // Merkle proof provided by the auditor to support their challenge.
    }

    /// @notice Struct representing a dataset including its metadata, state, proof, and verifications.
    /// @dev TODO: https://github.com/dataswap/core/issues/25
    struct Dataset {
        Metadata metadata; // Metadata of the dataset.
        State state; // Current state of the dataset.
        //proof
        string mappingFilesAccessMethod; // Method of accessing data (e.g., URL, API).
        DatasetProof sourceProof; // Proof associated with the dataset.
        DatasetProof mappingFilesProof; // Proof associated with the dataset.
        //verifications
        uint16 verificationsCount;
        mapping(address => Verification) verifications; // Address of the auditor who submits challenges.
    }
}
