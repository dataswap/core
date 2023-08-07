// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity ^0.8.21;

import "./types/StorageDealType.sol";

library StorageDealLIB {
    //TODO:require matching contract
    function submitMatchingCompletedEvent(
        StorageDealType.StorageDeal storage self
    ) external {
        require(
            self.state == StorageDealType.State.None,
            "Invalid state for submitMatchingCompletedEvent"
        );
        updateState(self, StorageDealType.Event.MatchingCompleted);
    }

    function reportSubmitPreviousDataCapProofExpired(
        StorageDealType.StorageDeal storage self
    ) external {
        require(
            self.state == StorageDealType.State.DataCapChunkAllocated,
            "Invalid state for report SubmitPreviousDataCapProofExpired"
        );
        //TODO:require expired condition
        updateState(
            self,
            StorageDealType.Event.SubmitPreviousDataCapProofExpired
        );
        //TODO:check PreviousDataCapChunkIsInitailChunk
        if (true) {
            updateState(
                self,
                StorageDealType.Event.Failed_PreviousDataCapChunkIsInitailChunk
            );
        } else {
            updateState(
                self,
                StorageDealType
                    .Event
                    .Failed_PreviousDataCapChunkIsNotInitailChunk
            );
        }
    }

    function submitPreviousDataCapProof(
        StorageDealType.StorageDeal storage self
    ) external {
        require(
            self.state == StorageDealType.State.DataCapChunkAllocated,
            "Invalid state for submitting previous data cap proof"
        );

        //TODO:require SubmitPreviousDataCapProof condition
        updateState(self, StorageDealType.Event.SubmitPreviousDataCapProof);
    }

    function verifyDataCapChunkProof(
        StorageDealType.StorageDeal storage self
    ) external {
        require(
            self.state ==
                StorageDealType.State.PreviousDataCapDataProofSubmitted,
            "Invalid state for verifying data cap chunk proof"
        );

        //TODO:require verify condition
        if (true) {
            //TODO: check previousDataCapIsLastChunk
            if (true) {
                updateState(
                    self,
                    StorageDealType
                        .Event
                        .DataCapChunkProofVerified_And_PreviousDataCapIsLastChunk
                );
            } else {
                updateState(
                    self,
                    StorageDealType
                        .Event
                        .DataCapChunkProofVerified_And_PreviousDataCapIsNotLastChunk
                );
            }
        } else {
            updateState(
                self,
                StorageDealType.Event.DataCapChunkProofVerificationFailed
            );
            //TODO:check PreviousDataCapChunkIsInitailChunk
            if (true) {
                updateState(
                    self,
                    StorageDealType
                        .Event
                        .Failed_PreviousDataCapChunkIsInitailChunk
                );
            } else {
                updateState(
                    self,
                    StorageDealType
                        .Event
                        .Failed_PreviousDataCapChunkIsNotInitailChunk
                );
            }
        }
    }

    function updateState(
        StorageDealType.StorageDeal storage self,
        StorageDealType.Event _event
    ) internal {
        StorageDealType.State currentState = self.state;
        StorageDealType.State newState;

        // Apply the state transition based on the event
        if (_event == StorageDealType.Event.MatchingCompleted) {
            if (currentState == StorageDealType.State.None) {
                newState = StorageDealType.State.DataCapChunkAllocated;
            }
        } else if (
            _event == StorageDealType.Event.SubmitPreviousDataCapProofExpired
        ) {
            if (currentState == StorageDealType.State.DataCapChunkAllocated) {
                newState = StorageDealType
                    .State
                    .SubmitPreviousDataCapProofExpired;
            }
        } else if (_event == StorageDealType.Event.SubmitPreviousDataCapProof) {
            if (currentState == StorageDealType.State.DataCapChunkAllocated) {
                newState = StorageDealType
                    .State
                    .PreviousDataCapDataProofSubmitted;
            }
        } else if (
            _event == StorageDealType.Event.DataCapChunkProofVerificationFailed
        ) {
            if (
                currentState ==
                StorageDealType.State.PreviousDataCapDataProofSubmitted
            ) {
                newState = StorageDealType
                    .State
                    .PreviousDataCapChunkVerificationFailed;
            }
        } else if (
            _event ==
            StorageDealType
                .Event
                .DataCapChunkProofVerified_And_PreviousDataCapIsNotLastChunk
        ) {
            if (
                currentState ==
                StorageDealType.State.PreviousDataCapDataProofSubmitted
            ) {
                newState = StorageDealType.State.DataCapChunkAllocated;
            }
        } else if (
            _event ==
            StorageDealType
                .Event
                .DataCapChunkProofVerified_And_PreviousDataCapIsLastChunk
        ) {
            if (
                currentState ==
                StorageDealType.State.PreviousDataCapDataProofSubmitted
            ) {
                newState = StorageDealType.State.Completed;
            }
        } else if (
            _event ==
            StorageDealType.Event.Failed_PreviousDataCapChunkIsInitailChunk
        ) {
            if (
                currentState ==
                StorageDealType.State.PreviousDataCapChunkVerificationFailed
            ) {
                newState = StorageDealType.State.Failed;
            } else if (
                currentState ==
                StorageDealType.State.SubmitPreviousDataCapProofExpired
            ) {
                newState = StorageDealType.State.Failed;
            }
        } else if (
            _event ==
            StorageDealType.Event.Failed_PreviousDataCapChunkIsNotInitailChunk
        ) {
            if (
                currentState ==
                StorageDealType.State.PreviousDataCapChunkVerificationFailed
            ) {
                newState = StorageDealType.State.PartiallyCompleted;
            } else if (
                currentState ==
                StorageDealType.State.SubmitPreviousDataCapProofExpired
            ) {
                newState = StorageDealType.State.PartiallyCompleted;
            }
        }

        // Update the state if newState is not the same as current state
        if (newState != currentState) {
            self.state = newState;
        }
    }

    function getState(
        StorageDealType.StorageDeal storage self
    ) public view returns (StorageDealType.State) {
        return self.state;
    }
}
