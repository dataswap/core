// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity ^0.8.21;

library DatasetType {
    /// @notice Explain to an end user what this does
    /// @dev Explain to a developer any extra details
    /// @param title
    /// @param industry
    /// @param name
    /// @param description
    /// @param source where is the dataset from.
    /// @param accessInfo how to access the source dataset
    /// @param submitter
    /// @param createTime
    /// @param size dataset size
    /// @param isPublic wherther datast is public
    /// @param version
    /// @param noProofRequired
    struct Metadata {
        string title;
        string industry;
        string name;
        string description;
        string source;
        string accessInfo;
        address submitter;
        uint256 createTime;
        uint256 size;
        bool isPublic;
        uint64 version;
        bool noProofRequired;
    }

    /// @notice Explain to an end user what this does
    /// @dev Explain to a developer any extra details
    /// @param None
    /// @param MetadataSubmitted
    /// @param MetadataApproved
    /// @param MetadataRejected
    /// @param DatasetProofSubmitted
    /// @param DatasetApproved
    /// @param DatasetApprovalInDispute
    enum State {
        None,
        MetadataSubmitted,
        MetadataApproved,
        MetadataRejected,
        DatasetProofSubmitted,
        DatasetApproved,
        DatasetApprovalInDispute
    }

    /// @notice Explain to an end user what this does
    /// @dev Explain to a developer any extra details
    /// @param MetadataApproved
    /// @param MetadataRejected
    /// @param SubmitDatasetProof
    /// @param DatasetApproved
    /// @param DatasetRejected
    /// @param DatasetRequireDispute
    enum Event {
        SubmitMetadata,
        MetadataApproved,
        MetadataRejected,
        SubmitDatasetProof,
        DatasetApproved,
        DatasetRejected,
        DatasetRequireDispute
    }

    /// @notice Explain to an end user what this does
    /// @dev Explain to a developer any extra details
    /// @param rootHash
    /// @param leafHashes
    /// @param leafAccessInfo,filecoin network
    /// @param metadataAccessInfo the access info of DatasetProof metadata
    struct Proof {
        bytes32 rootHash;
        bytes32[] leafHashes; //cars
        string leafAccessInfo;
        string metadataAccessInfo;
        bytes32 mappingFilesRootHash;
        bytes32[] mappingFilesLeafHashes;
    }

    /// @notice Explain to an end user what this does
    /// @dev Explain to a developer any extra details
    /// @param randomSeed
    /// @param auditor
    /// @param requireDipute
    /// @param merkleProof
    struct Verification {
        uint64 randomSeed;
        address auditor;
        DisputeByAuditor requireDipute;
        bytes32[] merkleProof;
    }

    enum VerifyResult {
        NotFinalized,
        Approved,
        Rejected,
        RequestDispute
    }

    /// @notice Explain to an end user what this does
    /// @dev Explain to a developer any extra details
    /// @param None
    /// @param IncorrectMetadata
    /// @param MetadataInaccessibility
    /// @param Others
    enum DisputeByAuditor {
        None,
        IncorrectMetadata,
        MetadataInaccessibility,
        Others
    }

    /// @notice Explain to an end user what this does
    /// @dev Explain to a developer any extra details
    /// @param None
    /// @param IncorrectVerificationInfo
    /// @param Others
    enum DisputeBySubmitter {
        None,
        IncorrectVerificationInfo,
        Others
    }

    /// @notice Explain to an end user what this does
    /// @dev Explain to a developer any extra details
    /// @param metadata
    /// @param state
    /// @param proof
    /// @param verification
    struct Dataset {
        Metadata metadata;
        State state;
        Proof proof;
        Verification[] verifications;
    }
}
