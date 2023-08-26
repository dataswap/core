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
interface IMatchingsHelpers {
    function publishMatching(
        uint64 _datasetId,
        bytes32[] memory _cars,
        uint64 _size,
        DatasetType.DataType _dataType,
        uint64 _associatedMappingFilesMatchingID,
        MatchingType.BidSelectionRule _bidSelectionRule,
        uint64 _biddingDelayBlockCount,
        uint64 _biddingPeriodBlockCount,
        uint64 _storageCompletionPeriodBlocks,
        uint256 _biddingThreshold
    ) external returns (uint64 matchingId);

    /// @notice  Function for bidding on a matching
    function bidding(
        uint64 _matchingId,
        address _bidder,
        uint256 _amount,
        uint64 _blocknumber
    ) external;

    /// @notice  Function for pausing a matching
    function pauseMatching(uint64 _matchingId) external;

    /// @notice  Function for resuming a paused matching
    function resumeMatching(uint64 _matchingId) external;

    /// @notice  Function for canceling a matching
    function cancelMatching(uint64 _matchingId) external;

    /// @notice  Function for closing a matching and choosing a winner
    function closeMatching(uint64 _matchingId) external;

    function completeMatchingWorkflow(
        uint64 _datasetId,
        bytes32[] memory _cars,
        uint64 _size,
        DatasetType.DataType _dataType,
        uint64 _associatedMappingFilesMatchingID,
        MatchingType.BidSelectionRule _bidSelectionRule,
        uint64 _biddingDelayBlockCount,
        uint64 _biddingPeriodBlockCount,
        uint64 _storageCompletionPeriodBlocks,
        uint256 _biddingThreshold
    ) external returns (uint64 matchingId);
}
