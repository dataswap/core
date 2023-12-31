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
        MetadataSubmitted, // Metadata submitted but not approved.
        MetadataApproved, // Metadata has been approved.
        MetadataRejected, // Metadata submission has been rejected.
        FundsNotEnough, // Not enough collateral when submit proof or challenge proof.
        DatasetProofSubmitted, // Proof of dataset submitted.
        DatasetApproved // Dataset has been approved.
    }

    /// @notice Enum representing the events related to dataset management.
    enum Event {
        SubmitMetadata, // Metadata submission event.
        MetadataApproved, // Metadata approval event.
        MetadataRejected, // Metadata rejection event.
        NotEnoughCollateral, // Dataset not enough collateral event.
        EnoughCollateral, // Dataset enough collateral event.
        SubmitDatasetProof, // Dataset proof submission event.
        DatasetApproved, // Dataset approval event.
        DatasetRejected // Dataset rejection event.
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
    }

    struct Dataset {
        Metadata metadata;
        uint64 usedSizeInBytes; // Already matching size.
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

    struct DatasetChallengeProof {
        // challenges
        uint16 challengesCount;
        mapping(address => ChallengeProof) challengeProofs; // Address of the auditor who submits challenges.
        address[] auditors; // Records of auditors submitting verifications.
    }

    /// @notice The struct describes the storage requirements specified by the client.
    struct ReplicaRequirement {
        address[] dataPreparers; // The client can specify DP or choose not to specify
        address[] storageProviders; //The client can specify SP or choose not to specify.
        GeolocationType.Geolocation geolocations; // Geolocation requested by the client.
    }

    struct DatasetReplicasRequirement {
        ReplicaRequirement[] replicasRequirement; // Replica requirements requested by the client.
    }
}
