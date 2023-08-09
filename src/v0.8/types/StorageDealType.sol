// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity ^0.8.21;

import "./CarReplicaType.sol";

library StorageDealType {
    enum State {
        None,
        DataCapChunkAllocated,
        SubmitPreviousDataCapProofExpired,
        PreviousDataCapDataProofSubmitted,
        PreviousDataCapChunkVerificationFailed,
        Failed,
        PartiallyCompleted,
        Completed
    }

    enum Event {
        MatchingCompleted,
        SubmitPreviousDataCapProofExpired,
        SubmitPreviousDataCapProof,
        DataCapChunkProofVerificationFailed,
        DataCapChunkProofVerified_And_PreviousDataCapIsNotLastChunk,
        DataCapChunkProofVerified_And_PreviousDataCapIsLastChunk,
        Failed_PreviousDataCapChunkIsInitailChunk,
        Failed_PreviousDataCapChunkIsNotInitailChunk
    }

    struct CarProof {
        bytes32 car; //TODO: delete
        uint256 filcoinDealId;
    }

    struct StorageDeal {
        uint256 matchingId;
        uint256 storedCarsCount;
        State state;
    }
}
