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
        string accessInfo; // Access information for the dataset.
        address submitter; // Address of the dataset's submitter.
        uint256 createdBlockNumber; // Block number at which the dataset was created.
        uint256 size; // Size of the dataset.
        bool isPublic; // Boolean indicating if the dataset is public.
        uint64 version; // Version of the dataset.
    }

    /// @notice Enum representing the possible states of a dataset.
    enum State {
        None, // No specific state.
        MetadataSubmitted, // Metadata submitted but not approved.
        MetadataApproved, // Metadata has been approved.
        MetadataRejected, // Metadata submission has been rejected.
        DatasetProofSubmitted, // Proof of dataset submitted.
        DatasetApproved, // Dataset has been approved.
        DatasetApprovalInDispute // Dataset approval is in dispute.
    }

    /// @notice Enum representing the events related to dataset management.
    enum Event {
        SubmitMetadata, // Metadata submission event.
        MetadataApproved, // Metadata approval event.
        MetadataRejected, // Metadata rejection event.
        SubmitDatasetProof, // Dataset proof submission event.
        DatasetApproved, // Dataset approval event.
        DatasetRejected, // Dataset rejection event.
        DatasetRequireDispute // Dataset requires dispute resolution.
    }

    /// @notice Struct representing proofs associated with a dataset.
    struct Proof {
        bytes32 rootHash; // Root hash of the dataset's Merkle tree.
        bytes32[] leafHashes; // Array of leaf hashes representing cars in the dataset.
        string leafAccessInfo; // Access information for leaf hashes.
        string metadataAccessInfo; // Access information for dataset metadata.
        bytes32 mappingFilesRootHash; // Root hash of mapping files' Merkle tree.
        bytes32[] mappingFilesLeafHashes; // Array of leaf hashes representing mapping files.
    }

    /// @notice Struct representing verification details of a dataset.
    struct Verification {
        uint64 randomSeed; // Random seed used for verification.
        address auditor; // Address of the auditor.
        DisputeByAuditor requireDipute; // Dispute raised by the auditor, if any.
        bytes32[] merkleProof; // Merkle proof provided by the auditor.
    }

    /// @notice Enum representing the verification results of a dataset.
    enum VerifyResult {
        NotFinalized, // Verification process not finalized.
        Approved, // Dataset verification approved.
        Rejected, // Dataset verification rejected.
        RequestDispute // Request dispute resolution for the verification.
    }

    /// @notice Enum representing dispute types raised by an auditor.
    enum DisputeByAuditor {
        None, // No dispute raised by the auditor.
        IncorrectMetadata, // Dispute regarding incorrect metadata.
        MetadataInaccessibility, // Dispute regarding metadata inaccessibility.
        Others // Other types of disputes raised by the auditor.
    }

    /// @notice Enum representing dispute types raised by a dataset submitter.
    enum DisputeBySubmitter {
        None, // No dispute raised by the dataset submitter.
        IncorrectVerificationInfo, // Dispute regarding incorrect verification information.
        Others // Other types of disputes raised by the dataset submitter.
    }

    /// @notice Struct representing a dataset including its metadata, state, proof, and verifications.
    struct Dataset {
        Metadata metadata; // Metadata of the dataset.
        State state; // Current state of the dataset.
        Proof proof; // Proof associated with the dataset.
        Verification[] verifications; // Array of verifications conducted on the dataset.
    }
}
