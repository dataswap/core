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

/// @title IMatchingsAssertion
/// @dev This interface defines assertion methods for testing matching-related functionality.
/// All methods that do not change the state must be tested by methods that will change the state to ensure test coverage.
interface IMatchingsAssertion {
    /// @notice Asserts a bidding action.
    /// @param caller The caller's address.
    /// @param _matchingId The ID of the matching for which bidding is done.
    /// @param _amount The bid amount.
    function biddingAssertion(
        address caller,
        uint64 _matchingId,
        uint256 _amount
    ) external;

    /// @notice Asserts the publishing of a matching.
    /// @param caller The caller's address.
    /// @param _datasetId The ID of the dataset associated with the matching.
    /// @param _cars The CIDs of the cars associated with the matching.
    /// @param _size The size of the matching.
    /// @param _dataType The data type of the matching.
    /// @param _associatedMappingFilesMatchingID The associated mapping files matching ID.
    /// @param _bidSelectionRule The bid selection rule for the matching.
    /// @param _biddingDelayBlockCount The bidding delay block count.
    /// @param _biddingPeriodBlockCount The bidding period block count.
    /// @param _storageCompletionPeriodBlocks The storage completion period blocks.
    /// @param _biddingThreshold The bidding threshold amount.
    /// @param _additionalInfo Additional information about the matching.
    function publishMatchingAssertion(
        address caller,
        uint64 _datasetId,
        bytes32[] memory _cars,
        uint64 _size,
        DatasetType.DataType _dataType,
        uint64 _associatedMappingFilesMatchingID,
        MatchingType.BidSelectionRule _bidSelectionRule,
        uint64 _biddingDelayBlockCount,
        uint64 _biddingPeriodBlockCount,
        uint64 _storageCompletionPeriodBlocks,
        uint256 _biddingThreshold,
        string memory _additionalInfo
    ) external;

    /// @notice Asserts the pausing of a matching.
    /// @param caller The caller's address.
    /// @param _matchingId The ID of the matching to be paused.
    function pauseMatchingAssertion(
        address caller,
        uint64 _matchingId
    ) external;

    /// @notice Asserts the resuming of a matching.
    /// @param caller The caller's address.
    /// @param _matchingId The ID of the matching to be resumed.
    function resumeMatchingAssertion(
        address caller,
        uint64 _matchingId
    ) external;

    /// @notice Asserts the cancellation of a matching.
    /// @param caller The caller's address.
    /// @param _matchingId The ID of the matching to be canceled.
    function cancelMatchingAssertion(
        address caller,
        uint64 _matchingId
    ) external;

    /// @notice Asserts the closing of a matching and declares a winner.
    /// @param caller The caller's address.
    /// @param _matchingId The ID of the matching to be closed.
    /// @param _winner The address of the winning bidder.
    function closeMatchingAssertion(
        address caller,
        uint64 _matchingId,
        address _winner
    ) external;

    /// @notice Asserts the retrieval of bids for a matching.
    /// @param _matchingId The ID of the matching.
    /// @param _expectBidders The expected array of bidder addresses.
    /// @param _expectAmounts The expected array of bid amounts.
    function getMatchingBidsAssertion(
        uint64 _matchingId,
        address[] memory _expectBidders,
        uint256[] memory _expectAmounts
    ) external;

    /// @notice Asserts the retrieval of the bid amount for a specific bidder in a matching.
    /// @param _matchingId The ID of the matching.
    /// @param _bidder The address of the bidder.
    /// @param _expectAmount The expected bid amount.
    function getMatchingBidAmountAssertion(
        uint64 _matchingId,
        address _bidder,
        uint256 _expectAmount
    ) external;

    /// @notice Asserts the count of bids for a matching.
    /// @param _matchingId The ID of the matching.
    /// @param _expectCount The expected count of bids.
    function getMatchingBidsCountAssertion(
        uint64 _matchingId,
        uint64 _expectCount
    ) external;

    /// @notice Asserts the retrieval of cars associated with a matching.
    /// @param _matchingId The ID of the matching.
    /// @param _expectCars The expected array of car CIDs.
    function getMatchingCarsAssertion(
        uint64 _matchingId,
        bytes32[] memory _expectCars
    ) external;

    /// @notice Asserts the retrieval of the size of a matching.
    /// @param _matchingId The ID of the matching.
    /// @param _expectSize The expected size of the matching.
    function getMatchingSizeAssertion(
        uint64 _matchingId,
        uint64 _expectSize
    ) external;

    /// @notice Asserts the retrieval of the initiator's address for a matching.
    /// @param _matchingId The ID of the matching.
    /// @param _expectInitiator The expected address of the initiator.
    function getMatchingInitiatorAssertion(
        uint64 _matchingId,
        address _expectInitiator
    ) external;

    /// @notice Asserts the retrieval of the state of a matching.
    /// @param _matchingId The ID of the matching.
    /// @param _expectState The expected state of the matching.
    function getMatchingStateAssertion(
        uint64 _matchingId,
        MatchingType.State _expectState
    ) external;

    /// @notice Asserts the retrieval of the target information for a matching.
    /// @param _matchingId The ID of the matching.
    /// @param _expectDatasetID The expected dataset ID associated with the matching.
    /// @param _expectCars The expected array of car CIDs associated with the matching.
    /// @param _expectSize The expected size of the matching.
    /// @param _expectDataType The expected data type of the matching.
    /// @param _expectAssociatedMappingFilesMatchingID The expected associated mapping files matching ID.
    function getMatchingTargetAssertion(
        uint64 _matchingId,
        uint64 _expectDatasetID,
        bytes32[] memory _expectCars,
        uint64 _expectSize,
        DatasetType.DataType _expectDataType,
        uint64 _expectAssociatedMappingFilesMatchingID
    ) external;

    /// @notice Asserts the retrieval of the winner's address for a closed matching.
    /// @param _matchingId The ID of the closed matching.
    /// @param _expectWinner The expected address of the winner.
    function getMatchingWinnerAssertion(
        uint64 _matchingId,
        address _expectWinner
    ) external;

    /// @notice Asserts whether a matching has a bid from a specific bidder.
    /// @param _matchingId The ID of the matching.
    /// @param _bidder The address of the bidder.
    /// @param _expectHasMatchingBid The expected result indicating whether the matching has a bid from the specified bidder.
    function hasMatchingBidAssertion(
        uint64 _matchingId,
        address _bidder,
        bool _expectHasMatchingBid
    ) external;

    /// @notice Asserts whether a matching contains a specific car CID.
    /// @param _matchingId The ID of the matching.
    /// @param _cid The car CID to check.
    /// @param _expectIsMatchingContainsCars The expected result indicating whether the matching contains the specified car CID.
    function isMatchingContainsCarAssertion(
        uint64 _matchingId,
        bytes32 _cid,
        bool _expectIsMatchingContainsCars
    ) external;

    /// @notice Asserts whether a matching contains a list of specific car CIDs.
    /// @param _matchingId The ID of the matching.
    /// @param _cids The array of car CIDs to check.
    /// @param _expectIsMatchingContainsCars The expected result indicating whether the matching contains all the specified car CIDs.
    function isMatchingContainsCarsAssertion(
        uint64 _matchingId,
        bytes32[] memory _cids,
        bool _expectIsMatchingContainsCars
    ) external;

    /// @notice Asserts whether a target for a matching is valid.
    /// @param _datasetId The dataset ID associated with the target.
    /// @param _cars The array of car CIDs associated with the target.
    /// @param _size The size of the target.
    /// @param _dataType The data type of the target.
    /// @param _associatedMappingFilesMatchingID The associated mapping files matching ID for the target.
    /// @param _expectIsMatchingTargetValid The expected result indicating whether the target is valid for a matching.
    function isMatchingTargetValidAssertion(
        uint64 _datasetId,
        bytes32[] memory _cars,
        uint64 _size,
        DatasetType.DataType _dataType,
        uint64 _associatedMappingFilesMatchingID,
        bool _expectIsMatchingTargetValid
    ) external;

    /// @notice Asserts whether a target for a matching meets FilPlus requirements.
    /// @param _matchingId The ID of the matching.
    /// @param _expectIsMatchingTargetMeetsFilPlusRequirements The expected result indicating whether the target meets FilPlus requirements.
    function isMatchingTargetMeetsFilPlusRequirementsAssertion(
        uint64 _matchingId,
        bool _expectIsMatchingTargetMeetsFilPlusRequirements
    ) external;

    /// @notice Asserts whether a target for a matching meets FilPlus requirements.
    /// @param _datasetId The dataset ID associated with the target.
    /// @param _cars The array of car CIDs associated with the target.
    /// @param _size The size of the target.
    /// @param _dataType The data type of the target.
    /// @param _associatedMappingFilesMatchingID The associated mapping files matching ID for the target.
    /// @param _expectIsMatchingTargetMeetsFilPlusRequirements The expected result indicating whether the target meets FilPlus requirements.
    function isMatchingTargetMeetsFilPlusRequirementsAssertion(
        uint64 _datasetId,
        bytes32[] memory _cars,
        uint64 _size,
        DatasetType.DataType _dataType,
        uint64 _associatedMappingFilesMatchingID,
        bool _expectIsMatchingTargetMeetsFilPlusRequirements
    ) external;

    /// @notice Asserts the count of matchings.
    /// @param _expectCount The expected count of matchings.
    function matchingsCountAssertion(uint64 _expectCount) external;
}
