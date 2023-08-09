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

import "../../../types/StorageDealType.sol";
import "../../../types/CarReplicaType.sol";
import "../../../core/carsStorage/abstract/CarsStorageBase.sol";

/// @title StorageDeal Library
/// @notice A library containing functions related to storage deals and their processing.
library StorageDealLIB {
    /// @notice Submit a MatchingCompleted event to signal the completion of a matching
    /// @param self The StorageDeal storage instance
    function submitMatchingCompletedEvent(
        StorageDealType.StorageDeal storage self
    ) external {
        require(
            self.state == StorageDealType.State.None,
            "Invalid state for submitMatchingCompletedEvent"
        );
        postEvent(self, StorageDealType.Event.MatchingCompleted);
    }

    /// @notice Report the expiration of submitting previous data cap proof
    /// @param self The StorageDeal storage instance
    function reportSubmitPreviousDataCapProofExpired(
        StorageDealType.StorageDeal storage self
    ) external {
        require(
            self.state == StorageDealType.State.DataCapChunkAllocated,
            "Invalid state for report SubmitPreviousDataCapProofExpired"
        );
        //TODO:require expired condition
        postEvent(
            self,
            StorageDealType.Event.SubmitPreviousDataCapProofExpired
        );
        if (isPreviousDataCapChunkIsInitailChunk(self)) {
            postEvent(
                self,
                StorageDealType.Event.Failed_PreviousDataCapChunkIsInitailChunk
            );
        } else {
            postEvent(
                self,
                StorageDealType
                    .Event
                    .Failed_PreviousDataCapChunkIsNotInitailChunk
            );
        }
    }

    /// @notice Submit proof of previous data cap for storage deals
    /// @param self The StorageDeal storage instance
    /// @param _proofs Array of CarProof structures containing the proofs of previous data cap
    /// @param _carsStorageContractAddress The address of the CarsStorage contract
    function submitPreviousDataCapProof(
        StorageDealType.StorageDeal storage self,
        StorageDealType.CarProof[] memory _proofs,
        address _carsStorageContractAddress
    ) external {
        require(
            self.state == StorageDealType.State.DataCapChunkAllocated,
            "Invalid state for submitting previous data cap proof"
        );
        postEvent(self, StorageDealType.Event.SubmitPreviousDataCapProof);
        verifyDataCapChunkProof(self, _proofs, _carsStorageContractAddress);
    }

    /// @notice Verify the submitted data cap chunk proof
    /// @param self The StorageDeal storage instance
    /// @param _proofs Array of CarProof structures containing the proofs to be verified
    /// @param _carsStorageContractAddress The address of the CarsStorage contract
    function verifyDataCapChunkProof(
        StorageDealType.StorageDeal storage self,
        StorageDealType.CarProof[] memory _proofs,
        address _carsStorageContractAddress
    ) internal {
        require(
            self.state ==
                StorageDealType.State.PreviousDataCapDataProofSubmitted,
            "Invalid state for verifying data cap chunk proof"
        );

        //TODO:require verify condition
        if (true) {
            self.storedCarsCount += _proofs.length;
            postCarVerifiedAction(self, _proofs, _carsStorageContractAddress);
            if (isPreviousDataCapIsLastChunk(self)) {
                postEvent(
                    self,
                    StorageDealType
                        .Event
                        .DataCapChunkProofVerified_And_PreviousDataCapIsLastChunk
                );
            } else {
                postEvent(
                    self,
                    StorageDealType
                        .Event
                        .DataCapChunkProofVerified_And_PreviousDataCapIsNotLastChunk
                );
            }
        } else {
            postEvent(
                self,
                StorageDealType.Event.DataCapChunkProofVerificationFailed
            );
            if (isPreviousDataCapChunkIsInitailChunk(self)) {
                postEvent(
                    self,
                    StorageDealType
                        .Event
                        .Failed_PreviousDataCapChunkIsInitailChunk
                );
            } else {
                postEvent(
                    self,
                    StorageDealType
                        .Event
                        .Failed_PreviousDataCapChunkIsNotInitailChunk
                );
            }
        }
    }

    /// @notice Post an event and update the matching's state
    /// @param self The StorageDeal storage instance
    /// @param _event The event to be posted
    function postEvent(
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

    /// @notice Get the current state of the StorageDeal instance.
    /// @param self The StorageDeal storage instance
    /// @return The current state of the StorageDeal.
    function getState(
        StorageDealType.StorageDeal storage self
    ) public view returns (StorageDealType.State) {
        return self.state;
    }

    /// @notice Perform actions after successful verification of CarProofs.
    /// @param self The StorageDeal storage instance
    /// @param _proofs Array of CarProof structures containing the proofs that were verified
    /// @param _carsStorageContractAddress The address of the CarsStorage contract
    function postCarVerifiedAction(
        StorageDealType.StorageDeal storage self,
        StorageDealType.CarProof[] memory _proofs,
        address _carsStorageContractAddress
    ) internal {
        CarsStorageBase cars = CarsStorageBase(_carsStorageContractAddress);
        //TODO: require: cars of proofs should included in matching and in carsStorage
        for (uint256 i = 0; i < _proofs.length; i++) {
            cars.setReplicaFilecoinDealId(
                _proofs[i].car,
                self.matchingId,
                _proofs[i].filcoinDealId
            );
        }
    }

    /// @notice Check if the previous data cap chunk is the initial chunk.
    /// @param self The StorageDeal storage instance
    /// @return True if the previous data cap chunk is the initial chunk, otherwise false.
    function isPreviousDataCapChunkIsInitailChunk(
        StorageDealType.StorageDeal storage self
    ) internal view returns (bool) {
        return self.storedCarsCount == 0;
    }

    /// @notice Check if the previous data cap is the last chunk.
    /// @param self The StorageDeal storage instance
    /// @return True if the previous data cap is the last chunk, otherwise false.
    function isPreviousDataCapIsLastChunk(
        StorageDealType.StorageDeal storage self
    ) internal view returns (bool) {
        //TODO:call matching contract,checkout cids[] length
        return self.storedCarsCount > 0;
    }
}
