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

import {DatasetType} from "src/v0.8/types/DatasetType.sol";
import {MatchingType} from "src/v0.8/types/MatchingType.sol";

/// @title IMatchings
interface IMatchings {
    /// @notice  Function for init matchings instance.
    function initMatchings(
        address _matchingsTarget,
        address _matchingsBids
    ) external;

    /// @notice Function for create a new matching.
    /// @param _datasetId The dataset id to create matching.
    /// @param _bidSelectionRule The rules for determining the winning bid.
    /// @param _biddingDelayBlockCount The number of blocks to delay bidding.
    /// @param _biddingPeriodBlockCount The number of blocks for bidding period.
    /// @param _storageCompletionPeriodBlocks The number of blocks for storage period.
    /// @param _biddingThreshold The threshold for bidding.
    /// @param _replicaIndex The index of the replica in dataset.
    /// @param _additionalInfo The additional information about the matching.
    /// @return The matchingId.
    function createMatching(
        uint64 _datasetId,
        MatchingType.BidSelectionRule _bidSelectionRule,
        uint64 _biddingDelayBlockCount,
        uint64 _biddingPeriodBlockCount,
        uint64 _storageCompletionPeriodBlocks,
        uint256 _biddingThreshold,
        uint16 _replicaIndex,
        string memory _additionalInfo
    ) external returns (uint64);

    /// @notice Function for pausing a matching
    /// @param _matchingId The matching id.
    function pauseMatching(uint64 _matchingId) external;

    /// @notice Function for resuming a paused matching
    /// @param _matchingId The matching id.
    function resumeMatching(uint64 _matchingId) external;

    /// @notice Function for report publishing a matching
    /// @param _matchingId The matching id to publish cars.
    function reportPublishMatching(uint64 _matchingId) external;

    /// @notice Function for report canceling a matching
    /// @param _matchingId The matching id.
    function reportCancelMatching(uint64 _matchingId) external;

    /// @notice Function for report closing a matching
    /// @param _matchingId The matching id.
    function reportCloseMatching(uint64 _matchingId) external;

    /// @notice Function for report complete with a winner
    /// @param _matchingId The matching id.
    /// @param _winner The winner of bids of matching.
    function reportMatchingHasWinner(
        uint64 _matchingId,
        address _winner
    ) external;

    /// @notice Function for report complete a matching without winner
    /// @param _matchingId The matching id.
    function reportMatchingNoWinner(uint64 _matchingId) external;

    /// @notice Function for getting matchings initiator
    function getMatchingInitiator(
        uint64 _matchingId
    ) external view returns (address);

    /// @notice  Function for getting the state of a matching
    function getMatchingState(
        uint64 _matchingId
    ) external view returns (MatchingType.State);

    /// @notice  Function for getting the bid selection rule of a matching
    function getBidSelectionRule(
        uint64 _matchingId
    ) external view returns (MatchingType.BidSelectionRule);

    /// @notice  Function for getting the bid threshold of a matching
    function getBiddingThreshold(
        uint64 _matchingId
    ) external view returns (uint256);

    /// @notice  Function for getting the start height of a matching
    function getBiddingStartHeight(
        uint64 _matchingId
    ) external view returns (uint64);

    /// @notice  Function for getting the after pause height of a matching
    function getBiddingAfterPauseHeight(
        uint64 _matchingId
    ) external view returns (uint64);

    /// @notice  Function for getting the end height of a matching
    function getBiddingEndHeight(
        uint64 _matchingId
    ) external view returns (uint64);

    // Default getter functions for public variables
    function matchingsCount() external view returns (uint64);
}
