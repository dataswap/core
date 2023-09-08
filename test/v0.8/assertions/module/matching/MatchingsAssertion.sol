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
import {IMatchingsAssertion} from "test/v0.8/interfaces/assertions/module/IMatchingsAssertion.sol";

/// @title MatchingsAssertion Contract
/// @notice This contract provides assertion functions to test the functionality of the IMatchings contract.
contract MatchingsAssertion is DSTest, Test, IMatchingsAssertion {
    IMatchings public matchings;
    ICarstore public carstore;

    /// @notice Constructor to set the IMatchings contract address.
    /// @param _matchings The address of the IMatchings contract to test.
    /// @param _carstore The address of the ICarstore contract to test.
    constructor(IMatchings _matchings, ICarstore _carstore) {
        matchings = _matchings;
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
        (address[] memory bidders, uint256[] memory amounts) = matchings
            .getMatchingBids(_matchingId);
        uint64 oldBidsCount = matchings.getMatchingBidsCount(_matchingId);

        // Perform the action
        vm.prank(caller);
        matchings.bidding(_matchingId, _amount);

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
    /// @param _dataType The data type of the matching.
    /// @param _associatedMappingFilesMatchingID The associated mapping files matching ID.
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
        DatasetType.DataType _dataType,
        uint64 _associatedMappingFilesMatchingID,
        MatchingType.BidSelectionRule _bidSelectionRule,
        uint64 _biddingDelayBlockCount,
        uint64 _biddingPeriodBlockCount,
        uint64 _storageCompletionPeriodBlocks,
        uint256 _biddingThreshold,
        uint16 _replicaIndex,
        string memory _additionalInfo
    ) external {
        // Before the action, get the current number of matchings.
        uint64 oldMatchingsCount = matchings.matchingsCount();
        // Perform the action
        vm.prank(caller);
        uint64 _matchingId = matchings.createMatching(
            _datasetId,
            _dataType,
            _associatedMappingFilesMatchingID,
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

        // Check the details of the published matching.
        getMatchingTargetAssertion(
            _matchingId,
            _datasetId,
            new bytes32[](0),
            0,
            _dataType,
            _associatedMappingFilesMatchingID
        );
        getMatchingReplicaIndexAssertion(_matchingId, _replicaIndex);
        getMatchingCarsAssertion(_matchingId, new bytes32[](0));
        getMatchingSizeAssertion(_matchingId, 0);
        getMatchingInitiatorAssertion(_matchingId, caller);
    }

    /// @notice Assertion function to test the 'publishMatching' function of IMatchings contract.
    /// @param caller The address of the caller.
    /// @param _matchingId The ID of the dataset.
    /// @param _datasetId The ID of the dataset.
    /// @param _cars An array of car IDs.
    /// @param complete If the publish is complete.
    function publishMatchingAssertion(
        address caller,
        uint64 _matchingId,
        uint64 _datasetId,
        bytes32[] memory _cars,
        bool complete
    ) external {
        uint64 _size = carstore.getCarsSize(_cars);

        (
            ,
            ,
            ,
            DatasetType.DataType _dataType,
            uint64 _associatedMappingFilesMatchingID
        ) = matchings.getMatchingTarget(_matchingId);

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
        matchings.publishMatching(_matchingId, _datasetId, _cars, complete);

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
    ) external {
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
    ) external {
        /// @dev TODO: should limit cancel state:https://github.com/dataswap/core/issues/51
        // Perform the action
        vm.prank(caller);
        matchings.cancelMatching(_matchingId);

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
    ) external {
        // Before the action, check the state of the matching.
        getMatchingStateAssertion(_matchingId, MatchingType.State.InProgress);

        // Perform the action
        vm.prank(caller);
        matchings.closeMatching(_matchingId);

        // After the action, check the state and winner of the matching.
        address winner = matchings.getMatchingWinner(_matchingId);
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
        (address[] memory bidders, uint256[] memory amounts) = matchings
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
            matchings.getMatchingBidAmount(_matchingId, _bidder),
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
        assertEq(matchings.getMatchingBidsCount(_matchingId), _expectCount);
    }

    /// @notice Assertion function to test the 'getMatchingCars' function of IMatchings contract.
    /// @param _matchingId The ID of the matching.
    /// @param _expectCars The expected array of car IDs.
    function getMatchingCarsAssertion(
        uint64 _matchingId,
        bytes32[] memory _expectCars
    ) public {
        bytes32[] memory cars = matchings.getMatchingCars(_matchingId);
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
        assertEq(matchings.getMatchingReplicaIndex(_matchingId), _expectIndex);
    }

    /// @notice Assertion function to test the 'getMatchingSize' function of IMatchings contract.
    /// @param _matchingId The ID of the matching.
    /// @param _expectSize The expected matching size.
    function getMatchingSizeAssertion(
        uint64 _matchingId,
        uint64 _expectSize
    ) public {
        assertEq(matchings.getMatchingSize(_matchingId), _expectSize);
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
        bytes32[] memory _expectCars,
        uint64 _expectSize,
        DatasetType.DataType _expectDataType,
        uint64 _expectAssociatedMappingFilesMatchingID
    ) public {
        (
            uint64 datasetID,
            bytes32[] memory cars,
            uint64 size,
            DatasetType.DataType dataType,
            uint64 associatedMappingFilesMatchingID
        ) = matchings.getMatchingTarget(_matchingId);
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
        assertEq(matchings.getMatchingWinner(_matchingId), _expectWinner);
    }

    /// @notice Assertion function to test the 'getMatchingWinners' function of IMatchings contract.
    /// @param _matchingIds The IDs of the matchings.
    /// @param _expectWinners The expected winners address.
    function getMatchingWinnersAssertion(
        uint64[] memory _matchingIds,
        address[] memory _expectWinners
    ) public {
        assertEq(_matchingIds.length, _expectWinners.length);
        address[] memory winners = matchings.getMatchingWinners(_matchingIds);
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
            matchings.hasMatchingBid(_matchingId, _bidder),
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
        assertEq(
            matchings.isMatchingContainsCar(_matchingId, _cid),
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
        assertEq(
            matchings.isMatchingContainsCars(_matchingId, _cids),
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
        assertEq(
            matchings.isMatchingTargetValid(
                _datasetId,
                _cars,
                _size,
                _dataType,
                _associatedMappingFilesMatchingID
            ),
            _expectIsMatchingTargetValid
        );
    }

    /// @notice Assertion function to test the count of matchings in the IMatchings contract.
    /// @param _expectCount The expected count of matchings.
    function matchingsCountAssertion(uint64 _expectCount) public {
        assertEq(matchings.matchingsCount(), _expectCount);
    }
}
