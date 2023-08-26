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

// NOTE: view asserton functions must all be tested by the functions that will change state
interface IMatchingAssertion {
    function biddingAssertion(uint64 _matchingId, uint256 _amount) external;

    function publishMatchingAssertion(
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

    function pauseMatchingAssertion(uint64 _matchingId) external;

    function resumeMatchingAssertion(uint64 _matchingId) external;

    function cancelMatchingAssertion(uint64 _matchingId) external;

    function closeMatchingAssertion(
        uint64 _matchingId,
        address _winner
    ) external;

    function getMatchingBidsAssertion(
        uint64 _matchingId,
        address[] memory _expectBidders,
        uint256[] memory _expectAmounts
    ) external;

    function getMatchingBidAmountAssertion(
        uint64 _matchingId,
        address _bidder,
        uint256 _expectAmount
    ) external;

    function getMatchingBidsCountAssertion(
        uint64 _matchingId,
        uint64 _expectCount
    ) external;

    function getMatchingCarsAssertion(
        uint64 _matchingId,
        bytes32[] memory _expectCars
    ) external;

    function getMatchingSizeAssertion(
        uint64 _matchingId,
        uint64 _expectSize
    ) external;

    function getMatchingInitiatorAssertion(
        uint64 _matchingId,
        address _expectInitiator
    ) external;

    function getMatchingStateAssertion(
        uint64 _matchingId,
        MatchingType.State _expectState
    ) external;

    function getMatchingTargetAssertion(
        uint64 _matchingId,
        uint64 _expectDatasetID,
        bytes32[] memory _expectCars,
        uint64 _expectSize,
        DatasetType.DataType _expectDataType,
        uint64 _expectAssociatedMappingFilesMatchingID
    ) external;

    function getMatchingWinnerAssertion(
        uint64 _matchingId,
        address _expectWinner
    ) external;

    function hasMatchingBidAssertion(
        uint64 _matchingId,
        address _bidder,
        bool _expectHasMatchingBid
    ) external;

    function isMatchingContainsCarAssertion(
        uint64 _matchingId,
        bytes32 _cid,
        bool _expectIsMatchingContainsCars
    ) external;

    function isMatchingContainsCarsAssertion(
        uint64 _matchingId,
        bytes32[] memory _cids,
        bool _expectIsMatchingContainsCars
    ) external;

    function isMatchingTargetValidAssertion(
        uint64 _datasetId,
        bytes32[] memory _cars,
        uint64 _size,
        DatasetType.DataType _dataType,
        uint64 _associatedMappingFilesMatchingID,
        bool _expectIsMatchingTargetValid
    ) external;

    function isMatchingTargetMeetsFilPlusRequirementsAssertion(
        uint64 _matchingId,
        bool _expectIsMatchingTargetMeetsFilPlusRequirements
    ) external;

    function isMatchingTargetMeetsFilPlusRequirementsAssertion(
        uint64 _datasetId,
        bytes32[] memory _cars,
        uint64 _size,
        DatasetType.DataType _dataType,
        uint64 _associatedMappingFilesMatchingID,
        bool _expectIsMatchingTargetMeetsFilPlusRequirements
    ) external;

    function matchingsCountAssertion(uint64 _expectCount) external;
}
