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

import {DSTest} from "ds-test/test.sol";
import {Test} from "forge-std/Test.sol";
import {DatasetType} from "src/v0.8/types/DatasetType.sol";
import {MatchingType} from "src/v0.8/types/MatchingType.sol";
import {ICarstore} from "src/v0.8/interfaces/core/ICarstore.sol";
import {IMatchings} from "src/v0.8/interfaces/module/IMatchings.sol";
import {IMatchingsBids} from "src/v0.8/interfaces/module/IMatchingsBids.sol";
import {IMatchingsTarget} from "src/v0.8/interfaces/module/IMatchingsTarget.sol";
import {IMatchingsAssertion} from "test/v0.8/interfaces/assertions/module/IMatchingsAssertion.sol";

/// @title MatchingsAssertion Contract
/// @notice This contract provides assertion functions to test the functionality of the IMatchings contract.
contract MatchingsAssertion is DSTest, Test, IMatchingsAssertion {
    IMatchings public matchings;
    IMatchingsTarget public matchingsTarget;
    IMatchingsBids public matchingsBids;
    ICarstore public carstore;

    /// @notice Constructor to set the IMatchings contract address.
    /// @param _matchings The address of the IMatchings contract to test.
    /// @param _carstore The address of the ICarstore contract to test.
    constructor(
        IMatchings _matchings,
        IMatchingsTarget _matchingsTarget,
        IMatchingsBids _matchingsBids,
        ICarstore _carstore
    ) {
        matchings = _matchings;
        matchingsTarget = _matchingsTarget;
        matchingsBids = _matchingsBids;
        carstore = _carstore;
    }

    /// @notice Assertion function to test the 'bidding' function of IMatchings contract.
    /// @param caller The address of the caller.
    /// @param _matchingId The ID of the matching.
    /// @param _amount The bidding amount.
    function biddingAssertion(
        address caller,
        uint64 _matchingId,
        uint256 _amount
    ) external {
        // Before the action, get the existing bids and count.
        (address[] memory bidders, uint256[] memory amounts) = matchingsBids
            .getMatchingBids(_matchingId);
        uint64 oldBidsCount = matchingsBids.getMatchingBidsCount(_matchingId);

        // Perform the action
        vm.prank(caller);
        matchingsBids.bidding(_matchingId, _amount);

        // After the bidding action:
        // 1. Check the new bids and count.
        address[] memory newBidders = new address[](bidders.length + 1);
        for (uint64 i = 0; i < newBidders.length - 1; i++) {
            newBidders[i] = bidders[i];
        }
        newBidders[newBidders.length - 1] = caller;

        uint256[] memory newAmounts = new uint256[](amounts.length + 1);
        for (uint64 i = 0; i < newAmounts.length - 1; i++) {
            newAmounts[i] = amounts[i];
        }
        newAmounts[newAmounts.length - 1] = _amount;

        // 2. Perform assertions to check if the bid was successful.
        getMatchingBidsAssertion(_matchingId, newBidders, newAmounts);
        getMatchingBidAmountAssertion(_matchingId, caller, _amount);
        getMatchingBidsCountAssertion(_matchingId, oldBidsCount + 1);
        hasMatchingBidAssertion(_matchingId, caller, true);
    }

    /// @notice Assertion function to test the 'createMatching' function of IMatchings contract.
    /// @param caller The address of the caller.
    /// @param _datasetId The ID of the dataset.
    /// @param _bidSelectionRule The bid selection rule.
    /// @param _biddingDelayBlockCount The bidding delay block count.
    /// @param _biddingPeriodBlockCount The bidding period block count.
    /// @param _storageCompletionPeriodBlocks The storage completion period in blocks.
    /// @param _biddingThreshold The bidding threshold.
    /// @param _replicaIndex The index of the replica in dataset.
    /// @param _additionalInfo Additional information about the matching.
    function createMatchingAssertion(
        address caller,
        uint64 _datasetId,
        MatchingType.BidSelectionRule _bidSelectionRule,
        uint64 _biddingDelayBlockCount,
        uint64 _biddingPeriodBlockCount,
        uint64 _storageCompletionPeriodBlocks,
        uint256 _biddingThreshold,
        uint16 _replicaIndex,
        string memory _additionalInfo
    ) public {
        // Before the action, get the current number of matchings.
        uint64 oldMatchingsCount = matchings.matchingsCount();
        // Perform the action
        vm.prank(caller);
        uint64 _matchingId = matchings.createMatching(
            _datasetId,
            _bidSelectionRule,
            _biddingDelayBlockCount,
            _biddingPeriodBlockCount,
            _storageCompletionPeriodBlocks,
            _biddingThreshold,
            _replicaIndex,
            _additionalInfo
        );

        // After the action:
        // Check if the number of matchings has increased.
        matchingsCountAssertion(oldMatchingsCount + 1);

        getMatchingReplicaIndexAssertion(_matchingId, _replicaIndex);
        getMatchingCarsAssertion(_matchingId, new uint64[](0));
        getMatchingSizeAssertion(_matchingId, 0);
        getMatchingInitiatorAssertion(_matchingId, caller);
        getBidSelectionRuleAssertion(_matchingId, _bidSelectionRule);
        getBiddingThresholdAssertion(_matchingId, _biddingThreshold);
        getBiddingStartHeightAssertion(
            _matchingId,
            uint64(block.number) + _biddingDelayBlockCount
        );
        getBiddingAfterPauseHeightAssertion(
            _matchingId,
            uint64(block.number) + _biddingDelayBlockCount
        );
        getBiddingEndHeightAssertion(
            _matchingId,
            uint64(block.number) +
                _biddingDelayBlockCount +
                _biddingPeriodBlockCount
        );
    }

    /// @notice Function for create a new matching target.
    /// @param caller The address of the caller.
    /// @param _matchingId The matching id to publish cars.
    /// @param _datasetId The dataset id to create matching.
    /// @param _dataType Identify the data type of "cars", which can be either "Source" or "MappingFiles".
    /// @param _associatedMappingFilesMatchingID The matching ID that associated with mapping files of dataset of _datasetId
    /// @param _replicaIndex The index of the replica in dataset.
    function createTargetAssertion(
        address caller,
        uint64 _matchingId,
        uint64 _datasetId,
        DatasetType.DataType _dataType,
        uint64 _associatedMappingFilesMatchingID,
        uint16 _replicaIndex
    ) public {
        // Perform the action
        vm.prank(caller);
        matchingsTarget.createTarget(
            _matchingId,
            _datasetId,
            _dataType,
            _associatedMappingFilesMatchingID,
            _replicaIndex
        );

        // Check the details of the published matching.
        getMatchingTargetAssertion(
            _matchingId,
            _datasetId,
            new uint64[](0),
            0,
            _dataType,
            _associatedMappingFilesMatchingID
        );
    }

    /// @notice  Function for parse cars from indexes.
    /// @param _starts The starts of cars to publish.
    /// @param _ends The ends of cars to publish.
    /// @param _expectCars The expected cars of the parsed.
    function parseCarsAssertion(
        uint64[] memory _starts,
        uint64[] memory _ends,
        uint64[] memory _expectCars
    ) public {
        uint64[] memory cars = matchingsTarget.parseCars(_starts, _ends);
        assertEq(cars.length, _expectCars.length);
        for (uint64 i = 0; i < cars.length; i++) {
            assertEq(cars[i], _expectCars[i]);
        }
    }

    /// @notice Assertion function to test the 'publishMatching' function of IMatchings contract.
    /// @param caller The address of the caller.
    /// @param _matchingId The matching id to publish cars.
    /// @param _datasetId The dataset id of matching.
    /// @param _carsStarts The cars to publish.
    /// @param _carsEnds The cars to publish.
    /// @param complete If the publish is complete.
    function publishMatchingAssertion(
        address caller,
        uint64 _matchingId,
        uint64 _datasetId,
        uint64[] memory _carsStarts,
        uint64[] memory _carsEnds,
        bool complete
    ) public {
        uint64[] memory _cars = matchingsTarget.parseCars(
            _carsStarts,
            _carsEnds
        );
        uint64 _size = carstore.getCarsSize(_cars);

        (
            ,
            ,
            ,
            DatasetType.DataType _dataType,
            uint64 _associatedMappingFilesMatchingID
        ) = matchingsTarget.getMatchingTarget(_matchingId);

        // Check if the matching target is valid.
        isMatchingTargetValidAssertion(
            _datasetId,
            _cars,
            _size,
            _dataType,
            _associatedMappingFilesMatchingID,
            true
        );

        // Check if the matching already contains the cars.
        isMatchingContainsCarsAssertion(_matchingId, _cars, false);
        // Perform the action
        vm.prank(caller);
        matchingsTarget.publishMatching(
            _matchingId,
            _datasetId,
            _carsStarts,
            _carsEnds,
            complete
        );

        // After the action:
        // Check the details of the published matching.
        getMatchingTargetAssertion(
            _matchingId,
            _datasetId,
            _cars,
            _size,
            _dataType,
            _associatedMappingFilesMatchingID
        );
        getMatchingCarsAssertion(_matchingId, _cars);
        getMatchingSizeAssertion(_matchingId, _size);
        getMatchingInitiatorAssertion(_matchingId, caller);
        isMatchingContainsCarAssertion(_matchingId, _cars[0], true);
        isMatchingContainsCarsAssertion(_matchingId, _cars, true);
    }

    /// @notice Assertion function to test the 'pauseMatching' function of IMatchings contract.
    /// @param caller The address of the caller.
    /// @param _matchingId The ID of the matching to pause.
    function pauseMatchingAssertion(
        address caller,
        uint64 _matchingId
    ) external {
        // Before the action, check the state of the matching.
        getMatchingStateAssertion(_matchingId, MatchingType.State.InProgress);

        // Perform the action
        vm.prank(caller);
        matchings.pauseMatching(_matchingId);

        // After the action, check if the matching is paused.
        getMatchingStateAssertion(_matchingId, MatchingType.State.Paused);
    }

    /// @notice Assertion function to test the 'resumeMatching' function of IMatchings contract.
    /// @param caller The address of the caller.
    /// @param _matchingId The ID of the matching to resume.
    function resumeMatchingAssertion(
        address caller,
        uint64 _matchingId
    ) public {
        // Before the action, check the state of the matching.
        getMatchingStateAssertion(_matchingId, MatchingType.State.Paused);

        // Perform the action
        vm.prank(caller);
        matchings.resumeMatching(_matchingId);

        // After the action, check if the matching is resumed.
        getMatchingStateAssertion(_matchingId, MatchingType.State.InProgress);
    }

    /// @notice Assertion function to test the 'cancelMatching' function of IMatchings contract.
    /// @param caller The address of the caller.
    /// @param _matchingId The ID of the matching to cancel.
    function cancelMatchingAssertion(
        address caller,
        uint64 _matchingId
    ) public {
        /// @dev TODO: should limit cancel state:https://github.com/dataswap/core/issues/51
        // Perform the action
        vm.prank(caller);
        matchingsBids.cancelMatching(_matchingId);

        // After the action, check if the matching is cancelled.
        getMatchingStateAssertion(_matchingId, MatchingType.State.Cancelled);
    }

    /// @notice Assertion function to test the 'closeMatching' function of IMatchings contract.
    /// @param caller The address of the caller.
    /// @param _matchingId The ID of the matching to close.
    /// @param _winner The address of the winner.
    function closeMatchingAssertion(
        address caller,
        uint64 _matchingId,
        address _winner
    ) public {
        // Before the action, check the state of the matching.
        getMatchingStateAssertion(_matchingId, MatchingType.State.InProgress);

        // Perform the action
        vm.prank(caller);
        matchingsBids.closeMatching(_matchingId);

        // After the action, check the state and winner of the matching.
        address winner = matchingsBids.getMatchingWinner(_matchingId);
        if (winner == address(0)) {
            getMatchingStateAssertion(_matchingId, MatchingType.State.Failed);
        } else {
            getMatchingStateAssertion(
                _matchingId,
                MatchingType.State.Completed
            );
            getMatchingWinnerAssertion(_matchingId, _winner);
            uint64[] memory matchingIds = new uint64[](1);
            matchingIds[0] = _matchingId;
            address[] memory winners = new address[](1);
            winners[0] = winner;
            getMatchingWinnersAssertion(matchingIds, winners);
        }
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
        (address[] memory bidders, uint256[] memory amounts) = matchingsBids
            .getMatchingBids(_matchingId);
        assertEq(bidders.length, _expectBidders.length);
        assertEq(amounts.length, _expectAmounts.length);
        for (uint64 i; i < bidders.length; i++) {
            assertEq(bidders[i], _expectBidders[i]);
        }
        for (uint64 i; i < amounts.length; i++) {
            assertEq(amounts[i], _expectAmounts[i]);
        }
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
        assertEq(
            matchingsBids.getMatchingBidAmount(_matchingId, _bidder),
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
        assertEq(matchingsBids.getMatchingBidsCount(_matchingId), _expectCount);
    }

    /// @notice Assertion function to test the 'getMatchingCars' function of IMatchings contract.
    /// @param _matchingId The ID of the matching.
    /// @param _expectCars The expected array of car IDs.
    function getMatchingCarsAssertion(
        uint64 _matchingId,
        uint64[] memory _expectCars
    ) public {
        uint64[] memory cars = matchingsTarget.getMatchingCars(_matchingId);
        assertEq(cars.length, _expectCars.length);
        for (uint64 i = 0; i < cars.length; i++) {
            assertEq(cars[i], _expectCars[i]);
        }
    }

    /// @notice Get the index of matching's replica.
    /// @param _matchingId The ID of the matching.
    /// @param _expectIndex The expected index of replica.
    function getMatchingReplicaIndexAssertion(
        uint64 _matchingId,
        uint16 _expectIndex
    ) public {
        assertEq(
            matchingsTarget.getMatchingReplicaIndex(_matchingId),
            _expectIndex
        );
    }

    /// @notice Assertion function to test the 'getMatchingSize' function of IMatchings contract.
    /// @param _matchingId The ID of the matching.
    /// @param _expectSize The expected matching size.
    function getMatchingSizeAssertion(
        uint64 _matchingId,
        uint64 _expectSize
    ) public {
        assertEq(matchingsTarget.getMatchingSize(_matchingId), _expectSize);
    }

    /// @notice Assertion function to test the 'getMatchingInitiator' function of IMatchings contract.
    /// @param _matchingId The ID of the matching.
    /// @param _expectInitiator The expected initiator address.
    function getMatchingInitiatorAssertion(
        uint64 _matchingId,
        address _expectInitiator
    ) public {
        assertEq(matchings.getMatchingInitiator(_matchingId), _expectInitiator);
    }

    /// @notice Assertion function to test the 'getMatchingState' function of IMatchings contract.
    /// @param _matchingId The ID of the matching.
    /// @param _expectState The expected state of the matching.
    function getMatchingStateAssertion(
        uint64 _matchingId,
        MatchingType.State _expectState
    ) public {
        assertEq(
            uint8(matchings.getMatchingState(_matchingId)),
            uint8(_expectState)
        );
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
        uint64[] memory _expectCars,
        uint64 _expectSize,
        DatasetType.DataType _expectDataType,
        uint64 _expectAssociatedMappingFilesMatchingID
    ) public {
        (
            uint64 datasetID,
            uint64[] memory cars,
            uint64 size,
            DatasetType.DataType dataType,
            uint64 associatedMappingFilesMatchingID
        ) = matchingsTarget.getMatchingTarget(_matchingId);
        assertEq(datasetID, _expectDatasetID);
        assertEq(cars.length, _expectCars.length);
        assertEq(size, _expectSize);
        assertEq(uint8(dataType), uint8(_expectDataType));
        assertEq(
            associatedMappingFilesMatchingID,
            _expectAssociatedMappingFilesMatchingID
        );
        for (uint64 i = 0; i < cars.length; i++) {
            assertEq(cars[i], _expectCars[i]);
        }
    }

    /// @notice Assertion function to test the 'getMatchingWinner' function of IMatchings contract.
    /// @param _matchingId The ID of the matching.
    /// @param _expectWinner The expected winner address.
    function getMatchingWinnerAssertion(
        uint64 _matchingId,
        address _expectWinner
    ) public {
        assertEq(matchingsBids.getMatchingWinner(_matchingId), _expectWinner);
    }

    /// @notice Assertion function to test the 'getMatchingWinners' function of IMatchings contract.
    /// @param _matchingIds The IDs of the matchings.
    /// @param _expectWinners The expected winners address.
    function getMatchingWinnersAssertion(
        uint64[] memory _matchingIds,
        address[] memory _expectWinners
    ) public {
        assertEq(_matchingIds.length, _expectWinners.length);
        address[] memory winners = matchingsBids.getMatchingWinners(
            _matchingIds
        );
        for (uint256 i = 0; i < _matchingIds.length; i++) {
            assertEq(winners[i], _expectWinners[i]);
        }
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
        assertEq(
            matchingsBids.hasMatchingBid(_matchingId, _bidder),
            _expectHasMatchingBid
        );
    }

    /// @notice Assertion function to test the 'isMatchingContainsCar' function of IMatchings contract.
    /// @param _matchingId The ID of the matching.
    /// @param _cid The car ID to check.
    /// @param _expectIsMatchingContainsCars The expected result of whether the matching contains the car.
    function isMatchingContainsCarAssertion(
        uint64 _matchingId,
        uint64 _cid,
        bool _expectIsMatchingContainsCars
    ) public {
        assertEq(
            matchingsTarget.isMatchingContainsCar(_matchingId, _cid),
            _expectIsMatchingContainsCars
        );
    }

    /// @notice Assertion function to test the 'isMatchingContainsCars' function of IMatchings contract.
    /// @param _matchingId The ID of the matching.
    /// @param _cids The array of car IDs to check.
    /// @param _expectIsMatchingContainsCars The expected result of whether the matching contains all the cars.
    function isMatchingContainsCarsAssertion(
        uint64 _matchingId,
        uint64[] memory _cids,
        bool _expectIsMatchingContainsCars
    ) public {
        assertEq(
            matchingsTarget.isMatchingContainsCars(_matchingId, _cids),
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
        uint64[] memory _cars,
        uint64 _size,
        DatasetType.DataType _dataType,
        uint64 _associatedMappingFilesMatchingID,
        bool _expectIsMatchingTargetValid
    ) public {
        assertEq(
            matchingsTarget.isMatchingTargetValid(
                _datasetId,
                _cars,
                _size,
                _dataType,
                _associatedMappingFilesMatchingID
            ),
            _expectIsMatchingTargetValid
        );
    }

    /// @notice Function for getting the selection rule of a matching.
    /// @param _matchingId The ID of the matching.
    /// @param _expectBidSelectionRule The expected rule of bid selection of matching.
    function getBidSelectionRuleAssertion(
        uint64 _matchingId,
        MatchingType.BidSelectionRule _expectBidSelectionRule
    ) public {
        MatchingType.BidSelectionRule _bidSelectionRule = matchings
            .getBidSelectionRule(_matchingId);
        assertEq(uint256(_bidSelectionRule), uint256(_expectBidSelectionRule));
    }

    /// @notice Function for getting the threshold of a matching
    /// @param _matchingId The ID of the matching.
    /// @param _expectBiddingThreshold The expected threshold of bid of matching.
    function getBiddingThresholdAssertion(
        uint64 _matchingId,
        uint256 _expectBiddingThreshold
    ) public {
        assertEq(
            matchings.getBiddingThreshold(_matchingId),
            _expectBiddingThreshold
        );
    }

    /// @notice Function for getting the start height of a matching
    /// @param _matchingId The ID of the matching.
    /// @param _expectStartHeight The expected start height of matching.
    function getBiddingStartHeightAssertion(
        uint64 _matchingId,
        uint64 _expectStartHeight
    ) public {
        assertEq(
            matchings.getBiddingStartHeight(_matchingId),
            _expectStartHeight
        );
    }

    /// @notice Function for getting the after pause height of a matching
    /// @param _matchingId The ID of the matching.
    /// @param _expectAfterPauseHeight The expected after pause height of matching.
    function getBiddingAfterPauseHeightAssertion(
        uint64 _matchingId,
        uint64 _expectAfterPauseHeight
    ) public {
        assertEq(
            matchings.getBiddingAfterPauseHeight(_matchingId),
            _expectAfterPauseHeight
        );
    }

    /// @notice Function for getting the end height of a matching
    /// @param _matchingId The ID of the matching.
    /// @param _expectEndHeight The expected end height of matching.
    function getBiddingEndHeightAssertion(
        uint64 _matchingId,
        uint64 _expectEndHeight
    ) public {
        assertEq(matchings.getBiddingEndHeight(_matchingId), _expectEndHeight);
    }

    /// @notice Assertion function to test the count of matchings in the IMatchings contract.
    /// @param _expectCount The expected count of matchings.
    function matchingsCountAssertion(uint64 _expectCount) public {
        assertEq(matchings.matchingsCount(), _expectCount);
    }
}
