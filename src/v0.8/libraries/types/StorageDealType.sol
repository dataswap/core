// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity ^0.8.21;

library StorageDealType {
    enum State {
        DataCapChunkAllocated,
        SubmitPreviousDataCapProofExpired,
        PreviousDataCapDataProofSubmitted,
        PreviousDataCapChunkVerificationFailed,
        StorageFailed,
        StoragePartiallyCompleted,
        StorageCompleted
    }
    enum Event {
        SubmitPreviousDataCapProof
    }
}
