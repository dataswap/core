/*******************************************************************************
 *   (c) 2023 DataSwap
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

import {DatasetType} from "../../types/DatasetType.sol";
import {MatchingType} from "../../types/MatchingType.sol";

/// @title IMatchings
interface IMatchings {
    /// @notice  Function for bidding on a matching
    function bidding(uint256 _matchingId, uint256 _amount) external;

    function publishMatching(
        uint256 _datasetId,
        bytes32[] memory _cars,
        uint64 _size,
        MatchingType.DataType _dataType,
        uint256 _associatedMappingFilesMatchingID,
        MatchingType.BidSelectionRule _bidSelectionRule,
        uint64 _biddingDelayBlockCount,
        uint64 _biddingPeriodBlockCount,
        uint64 _storagePeriodBlockCount,
        uint256 _biddingThreshold,
        string memory _additionalInfo
    ) external;

    /// @notice  Function for pausing a matching
    function pauseMatching(uint256 _matchingId) external;

    /// @notice Function for reporting that a matching pause has expired
    function reportMatchingPauseExpired(uint256 _matchingId) external;

    /// @notice  Function for resuming a paused matching
    function resumeMatching(uint256 _matchingId) external;

    /// @notice  Function for canceling a matching
    function cancelMatching(uint256 _matchingId) external;

    /// @notice  Function for closing a matching and choosing a winner
    function closeMatching(uint256 _matchingId) external;

    /// @notice  Function for getting bids in a matching
    function getMatchingBids(
        uint256 _matchingId
    ) external view returns (address[] memory, uint256[] memory);

    /// @notice  Function for getting bid amount of a bidder in a matching
    function getMatchingBidAmount(
        uint256 _matchingId,
        address _bidder
    ) external view returns (uint256);

    /// @notice  Function for getting the count of bids in a matching
    function getMatchingBidsCount(
        uint256 _matchingId
    ) external view returns (uint256);

    /// @notice  Function for getting the count of bids in a matching
    function getMatchingCars(
        uint256 _matchingId
    ) external view returns (bytes32[] memory);

    function getMatchingDataSize(
        uint256 _matchingId
    ) external view returns (uint256);

    /// @notice  Function for getting the state of a matching
    function getMatchingState(
        uint256 _matchingId
    ) external view returns (MatchingType.State);

    /// @notice Get the target information of a matching.
    /// @param _matchingId The ID of the matching.
    /// @return datasetID The ID of the associated dataset.
    /// @return cars An array of CIDs representing the cars in the matching.
    /// @return size The size of the matching.
    /// @return dataType The data type of the matching.
    /// @return associatedMappingFilesMatchingID The ID of the associated mapping files matching.
    function getMatchingTarget(
        uint256 _matchingId
    )
        external
        view
        returns (
            uint256 datasetID,
            bytes32[] memory cars,
            uint256 size,
            MatchingType.DataType dataType,
            uint256 associatedMappingFilesMatchingID
        );

    /// @notice  Function for checking if a bidder has a bid in a matching
    function hasMatchingBid(
        uint256 _matchingId,
        address _bidder
    ) external view returns (bool);

    /// @notice Check if a matching with the given matching ID contains a specific CID.
    /// @param _matchingId The ID of the matching to check.
    /// @param _cid The CID (Content Identifier) to check for.
    /// @return True if the matching contains the specified CID, otherwise false.
    function isMatchingContainsCar(
        uint256 _matchingId,
        bytes32 _cid
    ) external view returns (bool);

    /// @notice Check if a matching with the given matching ID contains multiple CIDs.
    /// @param _matchingId The ID of the matching to check.
    /// @param _cids An array of CIDs (Content Identifiers) to check for.
    /// @return True if the matching contains all the specified CIDs, otherwise false.
    function isMatchingContainsCars(
        uint256 _matchingId,
        bytes32[] memory _cids
    ) external view returns (bool);

    /// @notice check is matching targe valid
    function isMatchingTargetValid(
        uint256 _datasetId,
        bytes32[] memory _cars,
        uint256 _size,
        MatchingType.DataType _dataType,
        uint256 _associatedMappingFilesMatchingID
    ) external view returns (bool);

    /// @notice Check if a matching meets the requirements of Fil+.
    function isMatchingTargetMeetsFilPlusRequirements(
        uint256 _matchingId
    ) external view returns (bool);

    /// @notice Check if a matching meets the requirements of Fil+.
    function isMatchingTargetMeetsFilPlusRequirements(
        uint256 _datasetId,
        bytes32[] memory _cars,
        uint256 _size,
        MatchingType.DataType _dataType,
        uint256 _associatedMappingFilesMatchingID
    ) external view returns (bool);

    // Default getter functions for public variables
    function matchingsCount() external view returns (uint256);
}
