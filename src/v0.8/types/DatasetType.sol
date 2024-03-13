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

import {GeolocationType} from "src/v0.8/types/GeolocationType.sol";

/// @title DatasetType Library
/// @notice This library defines data structures for managing datasets, their metadata, states, and events.
library DatasetType {
    /// @notice Enum representing the possible states of a dataset.
    enum State {
        None, // No specific state.
        MetadataSubmitted, // Metadata submitted.
        RequirementSubmitted, // Requirements submitted.
        WaitEscrow, // Waiting for SC to complete escrow.
        ProofSubmitted, // Proof of dataset submitted.
        Approved, // Dataset has been approved.
        Rejected // Dataset has been rejected.
    }

    /// @notice Enum representing the events related to dataset management.
    enum Event {
        SubmitMetadata, // Metadata submission event.
        SubmitRequirements, // Requirements submission event.
        InsufficientEscrowFunds, // Insufficient escrow funds event.
        EscrowCompleted, // Complete escrow event.
        ProofCompleted, // Dataset proof submission event.
        WorkflowTimeout, // Workflow timeout event.
        Approved, // Dataset approval event.
        Rejected // Dataset rejection event.
    }

    /// @notice Enum representing the type of data associated with a matching.
    enum DataType {
        Source, // Matching is associated with a dataset
        MappingFiles // Matching is associated with mapping files
    }

    /// @notice Struct representing metadata associated with a dataset.
    struct Metadata {
        string title; // Title of the dataset.
        string industry; // Industry category of the dataset.
        string name; // Name of the dataset.
        string description; // Description of the dataset.
        string source; // Source of the dataset.
        string accessMethod; // Method of accessing the dataset (e.g., URL, API).
        address submitter; // Address of the dataset's submitter.
        uint64 client; // Filecoin actor id of the dataset's client.
        uint64 createdBlockNumber; // Block number at which the dataset was created.
        uint64 sizeInBytes; // Size of the dataset in bytes.
        bool isPublic; // Boolean indicating if the dataset is public.
        uint64 version; // Version number of the dataset.
        uint64 proofBlockCount; // The deadline for proof submission is specified in terms of the number of blocks.
        uint64 auditBlockCount; // The deadline for audit submission is specified in terms of the number of blocks.
        uint64 associatedDatasetId; // The ID of the associated dataset with the same access method.
    }

    struct Dataset {
        Metadata metadata;
        State state; // Current state of the dataset.
    }

    /// @notice Struct representing proofs associated with a dataset challenge submitted by reviewers.
    struct Proof {
        uint64 datasetSize;
        bytes32 rootHash; // Root hash of the data's Merkle tree.
        bool allCompleted;
        uint64 leafHashesCount;
        uint64[] leafHashes; // Proof associated with the dataset.
    }

    struct DatasetProof {
        //proof
        string mappingFilesAccessMethod; // Method of accessing data (e.g., URL, API).
        Proof sourceProof; // Proof associated with the dataset.
        Proof mappingFilesProof; // Note:mappingFiles includes mappingFiles and CarMerkleTree,Proof associated with the dataset.
        address proofSubmitter; // Address of the dataset proof's submitter.
        uint64 completedHeight;
    }

    /// @notice Struct representing proofs associated with a dataset challenge submitted by reviewers.
    struct Challenge {
        bytes32 leaf;
        bytes32[] siblings;
        uint32 path;
    }

    /// @notice Struct representing verification details of a dataset.
    struct ChallengeProof {
        uint64 randomSeed; // Random seed used for verification. This seed determines which nodes need to be challenged.
        Challenge[] challenges; // Merkle proof provided by the auditor to support their challenge.
    }

    struct DatasetAuditorElection {
        address[] candidates; // Records of candidates of auditors.
        bytes32 seed;
    }

    struct DatasetChallengeProof {
        // challenges
        uint16 challengesCount;
        mapping(address => ChallengeProof) challengeProofs; // Address of the auditor who submits challenges.
        address[] auditors; // Records of auditors submitting verifications.
        DatasetAuditorElection election; // Records of election of auditors.
    }

    /// @notice The struct describes the storage requirements specified by the client.
    struct ReplicaRequirement {
        address[] dataPreparers; // The client can specify DP or choose not to specify
        address[] storageProviders; //The client can specify SP or choose not to specify.
        GeolocationType.Geolocation geolocations; // Geolocation requested by the client.
    }

    struct DatasetReplicasRequirement {
        ReplicaRequirement[] replicasRequirement; // Replica requirements requested by the client.
        uint64 completedHeight;
    }
}
