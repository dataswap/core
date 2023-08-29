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

import {IDatasets} from "src/v0.8/interfaces/module/IDatasets.sol";
import {DatasetType} from "src/v0.8/types/DatasetType.sol";
import {MatchingType} from "src/v0.8/types/MatchingType.sol";
import {DataswapStorageServiceBase} from "src/v0.8/service/dataswapstorage/abstract/base/DataswapStorageServiceBase.sol";

/// @title MatchingsService
abstract contract MatchingsService is DataswapStorageServiceBase {
    /// @notice  Function for bidding on a matching
    function bidding(uint64 _matchingId, uint256 _amount) external {
        matchingsInstance.bidding(_matchingId, _amount);
    }

    /// @notice Function for create a new matching.
    /// @param _datasetId The dataset id to create matching.
    /// @param _dataType Identify the data type of "cars", which can be either "Source" or "MappingFiles".
    /// @param _associatedMappingFilesMatchingID The matching ID that associated with mapping files of dataset of _datasetId
    /// @param _bidSelectionRule The rules for determining the winning bid.
    /// @param _biddingDelayBlockCount The number of blocks to delay bidding.
    /// @param _biddingPeriodBlockCount The number of blocks for bidding period.
    /// @param _storageCompletionPeriodBlocks The number of blocks for storage period.
    /// @param _biddingThreshold The threshold for bidding.
    /// @param _additionalInfo The additional information about the matching.
    /// @return The matchingId.
    function createMatching(
        uint64 _datasetId,
        DatasetType.DataType _dataType,
        uint64 _associatedMappingFilesMatchingID,
        MatchingType.BidSelectionRule _bidSelectionRule,
        uint64 _biddingDelayBlockCount,
        uint64 _biddingPeriodBlockCount,
        uint64 _storageCompletionPeriodBlocks,
        uint256 _biddingThreshold,
        string memory _additionalInfo
    ) external returns (uint64) {
        return
            matchingsInstance.createMatching(
                _datasetId,
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

    /// @notice  Function for publishing a matching
    /// @param _matchingId The matching id to publish cars.
    /// @param _datasetId The dataset id of matching.
    /// @param _cars The cars to publish.
    /// @param complete If the publish is complete.
    function publishMatching(
        uint64 _matchingId,
        uint64 _datasetId,
        bytes32[] memory _cars,
        bool complete
    ) external {
        matchingsInstance.publishMatching(
            _matchingId,
            _datasetId,
            _cars,
            complete
        );
    }

    /// @notice  Function for pausing a matching
    function pauseMatching(uint64 _matchingId) external {
        matchingsInstance.pauseMatching(_matchingId);
    }

    /// @notice  Function for resuming a paused matching
    function resumeMatching(uint64 _matchingId) external {
        matchingsInstance.resumeMatching(_matchingId);
    }

    /// @notice  Function for canceling a matching
    function cancelMatching(uint64 _matchingId) external {
        matchingsInstance.cancelMatching(_matchingId);
    }

    /// @notice  Function for closing a matching and choosing a winner
    function closeMatching(uint64 _matchingId) external {
        matchingsInstance.closeMatching(_matchingId);
    }

    /// @notice  Function for getting bids in a matching
    function getMatchingBids(
        uint64 _matchingId
    ) external view returns (address[] memory, uint256[] memory) {
        return matchingsInstance.getMatchingBids(_matchingId);
    }

    /// @notice  Function for getting bid amount of a bidder in a matching
    function getMatchingBidAmount(
        uint64 _matchingId,
        address _bidder
    ) external view returns (uint256) {
        return matchingsInstance.getMatchingBidAmount(_matchingId, _bidder);
    }

    /// @notice  Function for getting the count of bids in a matching
    function getMatchingBidsCount(
        uint64 _matchingId
    ) external view returns (uint64) {
        return matchingsInstance.getMatchingBidsCount(_matchingId);
    }

    /// @notice  Function for getting the count of bids in a matching
    function getMatchingCars(
        uint64 _matchingId
    ) external view returns (bytes32[] memory) {
        return matchingsInstance.getMatchingCars(_matchingId);
    }

    /// @notice get matching size
    function getMatchingSize(
        uint64 _matchingId
    ) external view returns (uint64) {
        return matchingsInstance.getMatchingSize(_matchingId);
    }

    /// @notice get matching initiator
    function getMatchingInitiator(
        uint64 _matchingId
    ) external view returns (address) {
        return matchingsInstance.getMatchingInitiator(_matchingId);
    }

    /// @notice  Function for getting the state of a matching
    function getMatchingState(
        uint64 _matchingId
    ) external view returns (MatchingType.State) {
        return matchingsInstance.getMatchingState(_matchingId);
    }

    /// @notice Get the target information of a matching.
    /// @param _matchingId The ID of the matching.
    /// @return datasetID The ID of the associated dataset.
    /// @return cars An array of CIDs representing the cars in the matching.
    /// @return size The size of the matching.
    /// @return dataType The data type of the matching.
    /// @return associatedMappingFilesMatchingID The ID of the associated mapping files matching.
    function getMatchingTarget(
        uint64 _matchingId
    )
        external
        view
        returns (
            uint64 datasetID,
            bytes32[] memory cars,
            uint64 size,
            DatasetType.DataType dataType,
            uint64 associatedMappingFilesMatchingID
        )
    {
        return matchingsInstance.getMatchingTarget(_matchingId);
    }

    /// @notice  Function for getting winner of a matching
    function getMatchingWinner(
        uint64 _matchingId
    ) external view returns (address) {
        return matchingsInstance.getMatchingWinner(_matchingId);
    }

    /// @notice  Function for checking if a bidder has a bid in a matching
    function hasMatchingBid(
        uint64 _matchingId,
        address _bidder
    ) external view returns (bool) {
        return matchingsInstance.hasMatchingBid(_matchingId, _bidder);
    }

    /// @notice Check if a matching with the given matching ID contains a specific CID.
    /// @param _matchingId The ID of the matching to check.
    /// @param _cid The CID (Content Identifier) to check for.
    /// @return True if the matching contains the specified CID, otherwise false.
    function isMatchingContainsCar(
        uint64 _matchingId,
        bytes32 _cid
    ) external view returns (bool) {
        return matchingsInstance.isMatchingContainsCar(_matchingId, _cid);
    }

    /// @notice Check if a matching with the given matching ID contains multiple CIDs.
    /// @param _matchingId The ID of the matching to check.
    /// @param _cids An array of CIDs (Content Identifiers) to check for.
    /// @return True if the matching contains all the specified CIDs, otherwise false.
    function isMatchingContainsCars(
        uint64 _matchingId,
        bytes32[] memory _cids
    ) external view returns (bool) {
        return matchingsInstance.isMatchingContainsCars(_matchingId, _cids);
    }

    /// @notice check is matching targe valid
    function isMatchingTargetValid(
        uint64 _datasetId,
        bytes32[] memory _cars,
        uint64 _size,
        DatasetType.DataType _dataType,
        uint64 _associatedMappingFilesMatchingID
    ) external view returns (bool) {
        return
            matchingsInstance.isMatchingTargetValid(
                _datasetId,
                _cars,
                _size,
                _dataType,
                _associatedMappingFilesMatchingID
            );
    }

    /// @notice Check if a matching meets the requirements of Fil+.
    function isMatchingTargetMeetsFilPlusRequirements(
        uint64 _matchingId
    ) external view returns (bool) {
        return
            matchingsInstance.isMatchingTargetMeetsFilPlusRequirements(
                _matchingId
            );
    }

    /// @notice Check if a matching meets the requirements of Fil+.
    function isMatchingTargetMeetsFilPlusRequirements(
        uint64 _datasetId,
        bytes32[] memory _cars,
        uint64 _size,
        DatasetType.DataType _dataType,
        uint64 _associatedMappingFilesMatchingID
    ) external view returns (bool) {
        return
            matchingsInstance.isMatchingTargetMeetsFilPlusRequirements(
                _datasetId,
                _cars,
                _size,
                _dataType,
                _associatedMappingFilesMatchingID
            );
    }

    /// @notice Default getter functions for public variables
    function matchingsCount() external view returns (uint64) {
        return matchingsInstance.matchingsCount();
    }

    /// @notice get datasets instance
    function datasets() external view returns (IDatasets) {
        return matchingsInstance.datasets();
    }
}
