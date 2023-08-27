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
import {IMatchings} from "src/v0.8/interfaces/module/IMatchings.sol";
import {IMatchingsAssertion} from "test/v0.8/interfaces/assertions/module/IMatchingsAssertion.sol";

// assert carstore action
// NOTE: view asserton functions must all be tested by the functions that will change state
contract MatchingsAssertion is DSTest, Test, IMatchingsAssertion {
    IMatchings public matchings;

    constructor(IMatchings _matchings) {
        matchings = _matchings;
    }

    function biddingAssertion(
        address caller,
        uint64 _matchingId,
        uint256 _amount
    ) external {
        //before
        (address[] memory bidders, uint256[] memory amounts) = matchings
            .getMatchingBids(_matchingId);
        uint64 oldbidsCount = matchings.getMatchingBidsCount(_matchingId);

        // action
        vm.prank(caller);
        matchings.bidding(_matchingId, _amount);

        //after bidding
        // assert bids
        address[] memory newBidders = new address[](bidders.length + 1);
        for (uint64 i = 0; i < newBidders.length - 1; i++) {
            newBidders[i] = bidders[i];
        }
        newBidders[newBidders.length - 1] = msg.sender;
        uint256[] memory newAmounts = new uint256[](amounts.length + 1);
        for (uint64 i = 0; i < newAmounts.length - 1; i++) {
            newAmounts[i] = amounts[i];
        }
        newAmounts[newAmounts.length - 1] = _amount;
        getMatchingBidsAssertion(_matchingId, newBidders, newAmounts);
        // assert new bid amount
        getMatchingBidAmountAssertion(_matchingId, msg.sender, _amount);
        // assert bids count
        getMatchingBidsCountAssertion(_matchingId, oldbidsCount + 1);
        // assert bidder has bid
        hasMatchingBidAssertion(_matchingId, msg.sender, true);
    }

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
        //before action
        uint64 oldMatchingsCount = matchings.matchingsCount();
        isMatchingTargetValidAssertion(
            _datasetId,
            _cars,
            _size,
            _dataType,
            _associatedMappingFilesMatchingID,
            true
        );
        isMatchingTargetMeetsFilPlusRequirementsAssertion(
            _datasetId,
            _cars,
            _size,
            _dataType,
            _associatedMappingFilesMatchingID,
            true
        );
        isMatchingContainsCarsAssertion(oldMatchingsCount + 1, _cars, false);

        //action
        vm.prank(caller);
        matchings.publishMatching(
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

        //after action
        matchingsCountAssertion(oldMatchingsCount + 1);

        getMatchingTargetAssertion(
            oldMatchingsCount + 1,
            _datasetId,
            _cars,
            _size,
            _dataType,
            _associatedMappingFilesMatchingID
        );
        getMatchingCarsAssertion(oldMatchingsCount + 1, _cars);
        getMatchingSizeAssertion(oldMatchingsCount + 1, _size);
        getMatchingInitiatorAssertion(oldMatchingsCount + 1, msg.sender);
        isMatchingContainsCarAssertion(oldMatchingsCount + 1, _cars[0], true);
        isMatchingContainsCarsAssertion(oldMatchingsCount + 1, _cars, true);
    }

    function pauseMatchingAssertion(
        address caller,
        uint64 _matchingId
    ) external {
        //before action
        getMatchingStateAssertion(_matchingId, MatchingType.State.InProgress);

        //action
        vm.prank(caller);
        matchings.pauseMatching(_matchingId);

        //after action
        getMatchingStateAssertion(_matchingId, MatchingType.State.Paused);
    }

    function resumeMatchingAssertion(
        address caller,
        uint64 _matchingId
    ) external {
        //before action
        getMatchingStateAssertion(_matchingId, MatchingType.State.Paused);

        //action
        vm.prank(caller);
        matchings.resumeMatching(_matchingId);

        //after action
        getMatchingStateAssertion(_matchingId, MatchingType.State.InProgress);
    }

    function cancelMatchingAssertion(
        address caller,
        uint64 _matchingId
    ) external {
        // before action
        // TODO: should limit cancel state

        // action
        vm.prank(caller);
        matchings.cancelMatching(_matchingId);

        // after action
        getMatchingStateAssertion(_matchingId, MatchingType.State.Cancelled);
    }

    function closeMatchingAssertion(
        address caller,
        uint64 _matchingId,
        address _winner
    ) external {
        // before action
        getMatchingStateAssertion(_matchingId, MatchingType.State.InProgress);

        // action
        vm.prank(caller);
        matchings.closeMatching(_matchingId);

        // after action
        address winner = matchings.getMatchingWinner(_matchingId);
        if (winner == address(0)) {
            getMatchingStateAssertion(_matchingId, MatchingType.State.Failed);
        } else {
            getMatchingStateAssertion(
                _matchingId,
                MatchingType.State.Completed
            );
            getMatchingWinnerAssertion(_matchingId, _winner);
        }
    }

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

    function getMatchingBidsCountAssertion(
        uint64 _matchingId,
        uint64 _expectCount
    ) public {
        assertEq(matchings.getMatchingBidsCount(_matchingId), _expectCount);
    }

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

    function getMatchingSizeAssertion(
        uint64 _matchingId,
        uint64 _expectSize
    ) public {
        assertEq(matchings.getMatchingSize(_matchingId), _expectSize);
    }

    function getMatchingInitiatorAssertion(
        uint64 _matchingId,
        address _expectInitiator
    ) public {
        assertEq(matchings.getMatchingInitiator(_matchingId), _expectInitiator);
    }

    function getMatchingStateAssertion(
        uint64 _matchingId,
        MatchingType.State _expectState
    ) public {
        assertEq(
            uint8(matchings.getMatchingState(_matchingId)),
            uint8(_expectState)
        );
    }

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

    function getMatchingWinnerAssertion(
        uint64 _matchingId,
        address _expectWinner
    ) public {
        assertEq(matchings.getMatchingWinner(_matchingId), _expectWinner);
    }

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

    function isMatchingTargetMeetsFilPlusRequirementsAssertion(
        uint64 _matchingId,
        bool _expectIsMatchingTargetMeetsFilPlusRequirements
    ) public {
        assertEq(
            matchings.isMatchingTargetMeetsFilPlusRequirements(_matchingId),
            _expectIsMatchingTargetMeetsFilPlusRequirements
        );
    }

    function isMatchingTargetMeetsFilPlusRequirementsAssertion(
        uint64 _datasetId,
        bytes32[] memory _cars,
        uint64 _size,
        DatasetType.DataType _dataType,
        uint64 _associatedMappingFilesMatchingID,
        bool _expectIsMatchingTargetMeetsFilPlusRequirements
    ) public {
        assertEq(
            matchings.isMatchingTargetMeetsFilPlusRequirements(
                _datasetId,
                _cars,
                _size,
                _dataType,
                _associatedMappingFilesMatchingID
            ),
            _expectIsMatchingTargetMeetsFilPlusRequirements
        );
    }

    function matchingsCountAssertion(uint64 _expectCount) public {
        assertEq(matchings.matchingsCount(), _expectCount);
    }
}
