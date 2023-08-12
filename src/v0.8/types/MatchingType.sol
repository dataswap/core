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

import "./DatasetType.sol";

/// @title MatchingType Library
/// @author waynewyang
/// @notice This library defines data structures and enums related to dataset matching and their states.
library MatchingType {
    /// @notice Enum representing the possible states of a dataset matching.
    enum State {
        None,
        Published, // Matching is published and open for bids
        InProgress, // Matching is currently in progress
        Paused, // Matching is paused
        Closed, // Matching is closed and no longer accepting bids
        Completed, // Matching is completed
        Cancelled, // Matching is cancelled
        Failed // Matching has failed
    }

    /// @notice Enum representing the events associated with dataset matching.
    enum Event {
        Publish, // Matching is published
        FilPlusCheckSuccessed, // Fil+ check succeeded
        FilPlusCheckFailed, // Fil+ check failed
        Pause, // Matching is paused
        PauseExpired, // Pause period expired
        Resume, // Matching is resumed
        Cancel, // Matching is cancelled
        Close, // Matching is closed
        HasWinner, // Matching has a winner
        NoWinner // No winner in the matching
    }

    /// @notice Enum representing the rules for determining the winner bid.
    enum BidSelectionRule {
        HighestBid, //Note:it is Auction, Winner is determined by the highest bid
        LowestBid // Note: it is Tender, Winner is determined by the lowest bid
    }

    /// @notice Enum representing the type of data associated with a matching.
    enum DataType {
        MappingFiles, // Matching is associated with mapping files
        Dataset // Matching is associated with a dataset
    }

    /// @notice Struct representing the target of a matching.
    struct Target {
        uint256 datasetId; // ID of the dataset associated with the matching
        bytes32[] cars; // Array of car IDs associated with the matching
        uint256 size; // Size of the matching target，Note:total datacap size that this matching need allocate
        DataType dataType; // Type of data associated with the matching
        uint256 associatedMappingFilesMatchingID; // ID of the matching associated with mapping files
    }

    /// @notice Struct representing a bid in a matching.
    struct Bid {
        address bidder; // Address of the bidder
        uint256 bid; // Bid amount
    }

    /// @notice Struct representing a dataset matching.
    struct Matching {
        Target target; // Matching target details
        BidSelectionRule bidSelectionRule;
        uint256 biddingDelayBlockCount; // Number of blocks to delay bidding
        uint256 biddingPeriodBlockCount; // Number of blocks for bidding period
        uint256 storagePeriodBlockCount; // Number of blocks for storage period
        uint256 biddingThreshold; // Threshold for bidding
        string additionalInfo; // Additional information about the matching
        address initiator; // Address of the initiator of the matching
        uint256 createdBlockNumber; // Block number at which the matching was created
        State state; // Current state of the matching
        Bid[] bids; // Array of bids in the matching
        address winner; // Address of the winner in the matching
    }
}
