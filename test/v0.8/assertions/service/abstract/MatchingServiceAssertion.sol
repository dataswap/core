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
import {ServiceAssertionBase} from "test/v0.8/assertions/service/abstract/base/ServiceAssertionBase.sol";

/// @title MatchingServiceAssertion
abstract contract MatchingServiceAssertion is ServiceAssertionBase {
    /// @notice Assertion function to test the 'bidding' function of IMatchings contract.
    /// @param caller The address of the caller.
    /// @param _matchingId The ID of the matching.
    /// @param _amount The bidding amount.
    function biddingAssertion(
        address caller,
        uint64 _matchingId,
        uint256 _amount
    ) external {
        matchingsAssertion.biddingAssertion(caller, _matchingId, _amount);
    }

    /// @notice Assertion function to test the 'publishMatching' function of IMatchings contract.
    /// @param caller The address of the caller.
    /// @param _datasetId The ID of the dataset.
    /// @param _cars An array of car IDs.
    /// @param _size The size of the matching.
    /// @param _dataType The data type of the matching.
    /// @param _associatedMappingFilesMatchingID The associated mapping files matching ID.
    /// @param _bidSelectionRule The bid selection rule.
    /// @param _biddingDelayBlockCount The bidding delay block count.
    /// @param _biddingPeriodBlockCount The bidding period block count.
    /// @param _storageCompletionPeriodBlocks The storage completion period in blocks.
    /// @param _biddingThreshold The bidding threshold.
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
    ) external {
        matchingsAssertion.publishMatchingAssertion(
            caller,
            _datasetId,
            _cars,
            _size,
            _dataType,
            _associatedMappingFilesMatchingID,
            _bidSelectionRule,
            _biddingDelayBlockCount,
            _biddingPeriodBlockCount,
            _storageCompletionPeriodBlocks,
            _biddingThreshold,
            _additionalInfo
        );
    }

    /// @notice Assertion function to test the 'pauseMatching' function of IMatchings contract.
    /// @param caller The address of the caller.
    /// @param _matchingId The ID of the matching to pause.
    function pauseMatchingAssertion(
        address caller,
        uint64 _matchingId
    ) external {
        matchingsAssertion.pauseMatchingAssertion(caller, _matchingId);
    }

    /// @notice Assertion function to test the 'resumeMatching' function of IMatchings contract.
    /// @param caller The address of the caller.
    /// @param _matchingId The ID of the matching to resume.
    function resumeMatchingAssertion(
        address caller,
        uint64 _matchingId
    ) external {
        matchingsAssertion.resumeMatchingAssertion(caller, _matchingId);
    }

    /// @notice Assertion function to test the 'cancelMatching' function of IMatchings contract.
    /// @param caller The address of the caller.
    /// @param _matchingId The ID of the matching to cancel.
    function cancelMatchingAssertion(
        address caller,
        uint64 _matchingId
    ) external {
        matchingsAssertion.cancelMatchingAssertion(caller, _matchingId);
    }

    /// @notice Assertion function to test the 'closeMatching' function of IMatchings contract.
    /// @param caller The address of the caller.
    /// @param _matchingId The ID of the matching to close.
    /// @param _winner The address of the winner.
    function closeMatchingAssertion(
        address caller,
        uint64 _matchingId,
        address _winner
    ) external {
        matchingsAssertion.closeMatchingAssertion(caller, _matchingId, _winner);
    }

    /// @notice Assertion function to test the 'getMatchingBids' function of IMatchings contract.
    /// @param _matchingId The ID of the matching.
    /// @param _expectBidders The expected array of bidders.
    /// @param _expectAmounts The expected array of bid amounts.
    function getMatchingBidsAssertion(
        uint64 _matchingId,
        address[] memory _expectBidders,
        uint256[] memory _expectAmounts
    ) public {
        matchingsAssertion.getMatchingBidsAssertion(
            _matchingId,
            _expectBidders,
            _expectAmounts
        );
    }

    /// @notice Assertion function to test the 'getMatchingBidAmount' function of IMatchings contract.
    /// @param _matchingId The ID of the matching.
    /// @param _bidder The address of the bidder.
    /// @param _expectAmount The expected bid amount.
    function getMatchingBidAmountAssertion(
        uint64 _matchingId,
        address _bidder,
        uint256 _expectAmount
    ) public {
        matchingsAssertion.getMatchingBidAmountAssertion(
            _matchingId,
            _bidder,
            _expectAmount
        );
    }

    /// @notice Assertion function to test the 'getMatchingBidsCount' function of IMatchings contract.
    /// @param _matchingId The ID of the matching.
    /// @param _expectCount The expected count of bids.
    function getMatchingBidsCountAssertion(
        uint64 _matchingId,
        uint64 _expectCount
    ) public {
        matchingsAssertion.getMatchingBidsCountAssertion(
            _matchingId,
            _expectCount
        );
    }

    /// @notice Assertion function to test the 'getMatchingCars' function of IMatchings contract.
    /// @param _matchingId The ID of the matching.
    /// @param _expectCars The expected array of car IDs.
    function getMatchingCarsAssertion(
        uint64 _matchingId,
        bytes32[] memory _expectCars
    ) public {
        matchingsAssertion.getMatchingCarsAssertion(_matchingId, _expectCars);
    }

    /// @notice Assertion function to test the 'getMatchingSize' function of IMatchings contract.
    /// @param _matchingId The ID of the matching.
    /// @param _expectSize The expected matching size.
    function getMatchingSizeAssertion(
        uint64 _matchingId,
        uint64 _expectSize
    ) public {
        matchingsAssertion.getMatchingSizeAssertion(_matchingId, _expectSize);
    }

    /// @notice Assertion function to test the 'getMatchingInitiator' function of IMatchings contract.
    /// @param _matchingId The ID of the matching.
    /// @param _expectInitiator The expected initiator address.
    function getMatchingInitiatorAssertion(
        uint64 _matchingId,
        address _expectInitiator
    ) public {
        matchingsAssertion.getMatchingInitiatorAssertion(
            _matchingId,
            _expectInitiator
        );
    }

    /// @notice Assertion function to test the 'getMatchingState' function of IMatchings contract.
    /// @param _matchingId The ID of the matching.
    /// @param _expectState The expected state of the matching.
    function getMatchingStateAssertion(
        uint64 _matchingId,
        MatchingType.State _expectState
    ) public {
        matchingsAssertion.getMatchingStateAssertion(_matchingId, _expectState);
    }

    /// @notice Assertion function to test the 'getMatchingTarget' function of IMatchings contract.
    /// @param _matchingId The ID of the matching.
    /// @param _expectDatasetID The expected dataset ID.
    /// @param _expectCars The expected array of car IDs.
    /// @param _expectSize The expected matching size.
    /// @param _expectDataType The expected data type of the matching.
    /// @param _expectAssociatedMappingFilesMatchingID The expected associated mapping files matching ID.
    function getMatchingTargetAssertion(
        uint64 _matchingId,
        uint64 _expectDatasetID,
        bytes32[] memory _expectCars,
        uint64 _expectSize,
        DatasetType.DataType _expectDataType,
        uint64 _expectAssociatedMappingFilesMatchingID
    ) public {
        matchingsAssertion.getMatchingTargetAssertion(
            _matchingId,
            _expectDatasetID,
            _expectCars,
            _expectSize,
            _expectDataType,
            _expectAssociatedMappingFilesMatchingID
        );
    }

    /// @notice Assertion function to test the 'getMatchingWinner' function of IMatchings contract.
    /// @param _matchingId The ID of the matching.
    /// @param _expectWinner The expected winner address.
    function getMatchingWinnerAssertion(
        uint64 _matchingId,
        address _expectWinner
    ) public {
        matchingsAssertion.getMatchingWinnerAssertion(
            _matchingId,
            _expectWinner
        );
    }

    /// @notice Assertion function to test the 'hasMatchingBid' function of IMatchings contract.
    /// @param _matchingId The ID of the matching.
    /// @param _bidder The address of the bidder.
    /// @param _expectHasMatchingBid The expected result of whether the bidder has a matching bid.
    function hasMatchingBidAssertion(
        uint64 _matchingId,
        address _bidder,
        bool _expectHasMatchingBid
    ) public {
        matchingsAssertion.hasMatchingBidAssertion(
            _matchingId,
            _bidder,
            _expectHasMatchingBid
        );
    }

    /// @notice Assertion function to test the 'isMatchingContainsCar' function of IMatchings contract.
    /// @param _matchingId The ID of the matching.
    /// @param _cid The car ID to check.
    /// @param _expectIsMatchingContainsCars The expected result of whether the matching contains the car.
    function isMatchingContainsCarAssertion(
        uint64 _matchingId,
        bytes32 _cid,
        bool _expectIsMatchingContainsCars
    ) public {
        matchingsAssertion.isMatchingContainsCarAssertion(
            _matchingId,
            _cid,
            _expectIsMatchingContainsCars
        );
    }

    /// @notice Assertion function to test the 'isMatchingContainsCars' function of IMatchings contract.
    /// @param _matchingId The ID of the matching.
    /// @param _cids The array of car IDs to check.
    /// @param _expectIsMatchingContainsCars The expected result of whether the matching contains all the cars.
    function isMatchingContainsCarsAssertion(
        uint64 _matchingId,
        bytes32[] memory _cids,
        bool _expectIsMatchingContainsCars
    ) public {
        matchingsAssertion.isMatchingContainsCarsAssertion(
            _matchingId,
            _cids,
            _expectIsMatchingContainsCars
        );
    }

    /// @notice Assertion function to test the 'isMatchingTargetValid' function of IMatchings contract.
    /// @param _datasetId The ID of the dataset.
    /// @param _cars The array of car IDs.
    /// @param _size The matching size.
    /// @param _dataType The data type of the dataset.
    /// @param _associatedMappingFilesMatchingID The associated mapping files matching ID.
    /// @param _expectIsMatchingTargetValid The expected result of whether the matching target is valid.
    function isMatchingTargetValidAssertion(
        uint64 _datasetId,
        bytes32[] memory _cars,
        uint64 _size,
        DatasetType.DataType _dataType,
        uint64 _associatedMappingFilesMatchingID,
        bool _expectIsMatchingTargetValid
    ) public {
        matchingsAssertion.isMatchingTargetValidAssertion(
            _datasetId,
            _cars,
            _size,
            _dataType,
            _associatedMappingFilesMatchingID,
            _expectIsMatchingTargetValid
        );
    }

    /// @notice Assertion function to test the 'isMatchingTargetMeetsFilPlusRequirements' function of IMatchings contract.
    /// @param _matchingId The ID of the matching.
    /// @param _expectIsMatchingTargetMeetsFilPlusRequirements The expected result of whether the matching target meets FIL+ requirements.
    function isMatchingTargetMeetsFilPlusRequirementsAssertion(
        uint64 _matchingId,
        bool _expectIsMatchingTargetMeetsFilPlusRequirements
    ) public {
        matchingsAssertion.isMatchingTargetMeetsFilPlusRequirementsAssertion(
            _matchingId,
            _expectIsMatchingTargetMeetsFilPlusRequirements
        );
    }

    /// @notice Assertion function to test the 'isMatchingTargetMeetsFilPlusRequirements' function of IMatchings contract.
    /// @param _datasetId The ID of the dataset.
    /// @param _cars The array of car IDs.
    /// @param _size The matching size.
    /// @param _dataType The data type of the dataset.
    /// @param _associatedMappingFilesMatchingID The associated mapping files matching ID.
    /// @param _expectIsMatchingTargetMeetsFilPlusRequirements The expected result of whether the matching target meets FIL+ requirements.
    function isMatchingTargetMeetsFilPlusRequirementsAssertion(
        uint64 _datasetId,
        bytes32[] memory _cars,
        uint64 _size,
        DatasetType.DataType _dataType,
        uint64 _associatedMappingFilesMatchingID,
        bool _expectIsMatchingTargetMeetsFilPlusRequirements
    ) public {
        matchingsAssertion.isMatchingTargetMeetsFilPlusRequirementsAssertion(
            _datasetId,
            _cars,
            _size,
            _dataType,
            _associatedMappingFilesMatchingID,
            _expectIsMatchingTargetMeetsFilPlusRequirements
        );
    }

    /// @notice Assertion function to test the count of matchings in the IMatchings contract.
    /// @param _expectCount The expected count of matchings.
    function matchingsCountAssertion(uint64 _expectCount) public {
        matchingsAssertion.matchingsCountAssertion(_expectCount);
    }
}
