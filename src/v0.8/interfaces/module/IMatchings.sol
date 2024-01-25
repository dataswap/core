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
import {IStatistics} from "src/v0.8/interfaces/core/statistics/IStatistics.sol";

/// @title IMatchings
interface IMatchings is IStatistics {
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

    /// @notice Function for getting matchings initiator
    function getMatchingInitiator(
        uint64 _matchingId
    ) external view returns (address);

    /// @notice  Function for getting the state of a matching
    function getMatchingState(
        uint64 _matchingId
    ) external view returns (MatchingType.State);

    /// @notice  Function for getting the metadata of a matching
    /// @param _matchingId The matching id to get meta data of matching.
    /// @return bidSelectionRule The rules for determining the winning bid.
    /// @return biddingDelayBlockCount The number of blocks to delay bidding.
    /// @return biddingPeriodBlockCount The number of blocks for bidding period.
    /// @return storageCompletionPeriodBlocks The number of blocks for storage period.
    /// @return biddingThreshold The threshold for bidding.
    /// @return createdBlockNumber The block height at which matching is created.
    /// @return additionalInfo The additional information about the matching.
    /// @return initiator The initiator of the matching.
    /// @return pausedBlockCount The number of blocks matching is paused.
    function getMatchingMetadata(
        uint64 _matchingId
    )
        external
        view
        returns (
            MatchingType.BidSelectionRule bidSelectionRule,
            uint64 biddingDelayBlockCount,
            uint64 biddingPeriodBlockCount,
            uint64 storageCompletionPeriodBlocks,
            uint256 biddingThreshold,
            uint64 createdBlockNumber,
            string memory additionalInfo,
            address initiator,
            uint64 pausedBlockCount
        );

    /// @notice Function for report publishing a matching
    /// @dev This function is intended for use only by the 'dataswap' contract.
    /// @param _matchingId The matching id to publish cars.
    /// @param _size; The size of the matching target.
    function __reportPublishMatching(uint64 _matchingId, uint64 _size) external;

    /// @notice Function for report canceling a matching
    /// @dev This function is intended for use only by the 'dataswap' contract.
    /// @param _matchingId The matching id.
    /// @param _size; The size of the matching target.
    function __reportCancelMatching(uint64 _matchingId, uint64 _size) external;

    /// @notice Function for report closing a matching
    /// @dev This function is intended for use only by the 'dataswap' contract.
    /// @param _matchingId The matching id.
    function __reportCloseMatching(uint64 _matchingId) external;

    /// @notice Function for report complete with a winner
    /// @dev This function is intended for use only by the 'dataswap' contract.
    /// @param _matchingId The matching id.
    /// @param _size; The size of the matching target.
    /// @param _winner The winner of bids of matching.
    function __reportMatchingHasWinner(
        uint64 _matchingId,
        uint64 _size,
        address _winner
    ) external;

    /// @notice Function for report complete a matching without winner
    /// @dev This function is intended for use only by the 'dataswap' contract.
    /// @param _matchingId The matching id.
    /// @param _size; The size of the matching target.
    function __reportMatchingNoWinner(
        uint64 _matchingId,
        uint64 _size
    ) external;

    // Default getter functions for public variables
    function matchingsCount() external view returns (uint64);
}
