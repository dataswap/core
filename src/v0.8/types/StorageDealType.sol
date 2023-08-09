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

/// @title StorageDealType Library
/// @notice This library defines enums and structs related to storage deals and their states.
library StorageDealType {
    /// @notice Enum representing the possible states of a storage deal.
    enum State {
        None, // No state
        DataCapChunkAllocated, // DataCap chunk has been allocated
        SubmitPreviousDataCapProofExpired, // Submitting previous DataCap proof has expired
        PreviousDataCapDataProofSubmitted, // Proof for previous DataCap data has been submitted
        PreviousDataCapChunkVerificationFailed, // Verification of previous DataCap chunk failed
        Failed, // Storage deal has failed
        PartiallyCompleted, // Storage deal is partially completed
        Completed // Storage deal is completed
    }

    /// @notice Enum representing the events associated with storage deals.
    enum Event {
        MatchingCompleted, // Matching for a storage deal has been completed
        SubmitPreviousDataCapProofExpired, // Submitting previous DataCap proof has expired
        SubmitPreviousDataCapProof, // Submitting proof for previous DataCap
        DataCapChunkProofVerificationFailed, // Verification of DataCap chunk proof failed
        DataCapChunkProofVerified_And_PreviousDataCapIsNotLastChunk, // DataCap chunk proof verified and previous DataCap is not the last chunk
        DataCapChunkProofVerified_And_PreviousDataCapIsLastChunk, // DataCap chunk proof verified and previous DataCap is the last chunk
        Failed_PreviousDataCapChunkIsInitailChunk, // Storage deal failed as previous DataCap chunk is the initial chunk
        Failed_PreviousDataCapChunkIsNotInitailChunk // Storage deal failed as previous DataCap chunk is not the initial chunk
    }

    /// @notice Struct representing proof of a car's inclusion in a storage deal.
    struct CarProof {
        bytes32 car; // Content ID (CID) of the car
        uint256 filcoinDealId; // ID of the Filecoin deal associated with the car's storage
    }

    /// @notice Struct representing a storage deal.
    struct StorageDeal {
        uint256 matchingId; // ID of the matching associated with the storage deal
        uint256 storedCarsCount; // Number of cars stored in the deal
        State state; // Current state of the storage deal
    }
}
