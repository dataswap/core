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

import "../../types/RolesType.sol";
import "../../types/DatasetType.sol";
import "../dataset/Datasets.sol";
import "../../types/MatchingType.sol";
import "./library/MatchingLIB.sol";
import "./library/MatchingStateMachineLIB.sol";
import "./library/MatchingBidsLIB.sol";
import "./IMatchings.sol";

/// @title Matchings Base Contract
/// @notice This contract serves as the base for managing matchings, their states, and associated actions.
/// @dev This contract is intended to be inherited by specific matching-related contracts.
abstract contract Matchings is Ownable2Step, Datasets, IMatchings {
    /// @notice  Declare private variables
    uint256 private matchingsCount;
    mapping(uint256 => MatchingType.Matching) private matchings;

    /// @notice  Use libraries for different matching functionalities
    using MatchingLIB for MatchingType.Matching;
    using MatchingStateMachineLIB for MatchingType.Matching;
    using MatchingBidsLIB for MatchingType.Matching;

    /// @notice  Declare events for external monitoring
    event MatchingPublished(
        uint256 indexed matchingId,
        address indexed initiator
    );
    event MatchingPaused(uint256 indexed _matchingId);
    event MatchingPauseExpired(uint256 indexed _matchingId);
    event MatchingResumed(uint256 indexed _matchingId);
    event MatchingCancelled(uint256 indexed _matchingId);
    event MatchingHasWinner(
        uint256 indexed _matchingId,
        address indexed _winner
    );
    event MatchingNoWinner(uint256 indexed _matchingId);
    event MatchingBidPlaced(
        uint256 indexed _matchingId,
        address _bidder,
        uint256 _amount
    );

    /// @notice  Modifier to restrict access to the matching initiator
    modifier onlyMatchingContainsCid(uint256 _matchingId, bytes32 _cid) {
        require(
            isMatchingContainsCid(_matchingId, _cid),
            "You are not the initiator of this matching"
        );
        _;
    }

    /// @notice  Modifier to restrict access to the matching initiator
    modifier onlyMatchingInitiator(uint256 _matchingId) {
        require(
            matchings[_matchingId].initiator == msg.sender,
            "You are not the initiator of this matching"
        );
        _;
    }

    /// @notice  Modifier to restrict access based on matching state
    modifier onlyMatchingState(uint256 _matchingId, MatchingType.State _state) {
        require(
            matchings[_matchingId].state == _state,
            "Matching is not in the expected state"
        );
        _;
    }

    ///@dev update cars info  to carStore before complete
    function _beforeCompleteMatching(uint256 _matchingId) internal virtual;

    /// @notice  Function for bidding on a matching
    function matchingBidding(
        uint256 _matchingId,
        uint256 _amount
    ) external onlyRole(RolesType.STORAGE_PROVIDER) {
        MatchingType.Matching storage matching = matchings[_matchingId];
        matching._matchingBidding(_amount);

        emit MatchingBidPlaced(_matchingId, msg.sender, _amount);
    }

    /// @notice  Function for publishing a new matching
    /// TODO:pls see MatchingLIB _publishMatching
    function publishMatching(
        uint256 _datasetId,
        bytes32[] memory _cars,
        uint256 _size,
        MatchingType.DataType _dataType,
        uint256 _associatedMappingFilesMatchingID,
        MatchingType.BidSelectionRule _bidSelectionRule,
        uint256 _biddingDelayBlockCount,
        uint256 _biddingPeriodBlockCount,
        uint256 _storagePeriodBlockCount,
        uint256 _biddingThreshold,
        string memory _additionalInfo
    ) external onlyRole(RolesType.DATASET_PROVIDER) {
        require(
            isMatchingTargetMeetsFilPlusRequirements(
                _datasetId,
                _cars,
                _size,
                _dataType,
                _associatedMappingFilesMatchingID
            ),
            "target not meets filplus requirements"
        );
        matchingsCount++;
        MatchingType.Matching storage matching = matchings[matchingsCount];
        matching.target = MatchingType.Target({
            datasetId: _datasetId,
            cars: _cars,
            size: _size,
            dataType: _dataType,
            associatedMappingFilesMatchingID: _associatedMappingFilesMatchingID
        });
        matching.bidSelectionRule = _bidSelectionRule;
        matching.biddingDelayBlockCount = _biddingDelayBlockCount;
        matching.biddingPeriodBlockCount = _biddingPeriodBlockCount;
        matching.storagePeriodBlockCount = _storagePeriodBlockCount;
        matching.biddingThreshold = _biddingThreshold;
        matching.additionalInfo = _additionalInfo;
        matching.initiator = msg.sender;
        matching.createdBlockNumber = block.number;

        matching._publishMatching();
        emit MatchingPublished(matchingsCount, msg.sender);
    }

    /// @notice  Function for pausing a matching
    function pauseMatching(
        uint256 _matchingId
    )
        external
        onlyMatchingInitiator(_matchingId)
        onlyMatchingState(_matchingId, MatchingType.State.InProgress)
    {
        MatchingType.Matching storage matching = matchings[_matchingId];
        matching._pauseMatching();
        emit MatchingPaused(_matchingId);
    }

    /// @notice Function for reporting that a matching pause has expired
    function reportMatchingPauseExpired(uint256 _matchingId) external {
        MatchingType.Matching storage matching = matchings[_matchingId];
        matching._reportMatchingPauseExpired();
        emit MatchingPauseExpired(_matchingId);
    }

    /// @notice  Function for resuming a paused matching
    function resumeMatching(
        uint256 _matchingId
    )
        external
        onlyMatchingInitiator(_matchingId)
        onlyMatchingState(_matchingId, MatchingType.State.Paused)
    {
        MatchingType.Matching storage matching = matchings[_matchingId];
        matching._resumeMatching();
        emit MatchingResumed(_matchingId);
    }

    /// @notice  Function for canceling a matching
    function cancelMatching(
        uint256 _matchingId
    ) external onlyMatchingInitiator(_matchingId) {
        MatchingType.Matching storage matching = matchings[_matchingId];
        matching._cancelMatching();
        emit MatchingCancelled(_matchingId);
    }

    /// @notice  Function for closing a matching and choosing a winner
    function closeMatching(
        uint256 _matchingId
    ) external onlyMatchingState(_matchingId, MatchingType.State.InProgress) {
        MatchingType.Matching storage matching = matchings[_matchingId];
        matching._closeMatching();
        address winner = matching._chooseMatchingWinner();
        if (winner != address(0)) {
            _beforeCompleteMatching(_matchingId);
            matching._emitMatchingEvent(MatchingType.Event.HasWinner);
            emit MatchingHasWinner(_matchingId, winner);
        } else {
            matching._emitMatchingEvent(MatchingType.Event.NoWinner);
            emit MatchingNoWinner(_matchingId);
        }
    }

    /// @notice  Function for getting bids in a matching
    function getMatchingBids(
        uint256 _matchingId
    ) public view returns (address[] memory, uint256[] memory) {
        MatchingType.Matching storage matching = matchings[_matchingId];
        return matching._getMatchingBids();
    }

    /// @notice  Function for getting bid amount of a bidder in a matching
    function getMatchingBidAmount(
        uint256 _matchingId,
        address _bidder
    ) public view returns (uint256) {
        MatchingType.Matching storage matching = matchings[_matchingId];
        return matching._getMatchingBidAmount(_bidder);
    }

    /// @notice  Function for getting the count of bids in a matching
    function getMatchingBidsCount(
        uint256 _matchingId
    ) public view returns (uint256) {
        MatchingType.Matching storage matching = matchings[_matchingId];
        return matching._getMatchingBidsCount();
    }

    /// @notice  Function for getting the count of bids in a matching
    function getMatchingCids(
        uint256 _matchingId
    ) public view returns (bytes32[] memory) {
        MatchingType.Matching storage matching = matchings[_matchingId];
        return matching.target.cars;
    }

    /// @notice  Function for getting the total data size of bids in a matching
    function getMatchingDataSize(
        uint256 _matchingId
    ) public view returns (uint256) {
        (, , uint256 datasize, , ) = getMatchingTarget(_matchingId);
        return datasize;
    }

    /// @notice  Function for getting the state of a matching
    function getMatchingState(
        uint256 _matchingId
    ) public view returns (MatchingType.State) {
        MatchingType.Matching storage matching = matchings[_matchingId];
        return matching._getMatchingState();
    }

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
        public
        view
        returns (
            uint256 datasetID,
            bytes32[] memory cars,
            uint256 size,
            MatchingType.DataType dataType,
            uint256 associatedMappingFilesMatchingID
        )
    {
        // Access the matching with the specified ID and retrieve the target information
        MatchingType.Matching storage matching = matchings[_matchingId];
        return (
            matching.target.datasetId,
            matching.target.cars,
            matching.target.size,
            matching.target.dataType,
            matching.target.associatedMappingFilesMatchingID
        );
    }

    /// @notice  Function for checking if a bidder has a bid in a matching
    function hasMatchingBid(
        uint256 _matchingId,
        address _bidder
    ) public view returns (bool) {
        MatchingType.Matching storage matching = matchings[_matchingId];
        return matching._hasMatchingBid(_bidder);
    }

    /// @notice Check if a matching with the given matching ID contains a specific CID.
    /// @param _matchingId The ID of the matching to check.
    /// @param _cid The CID (Content Identifier) to check for.
    /// @return True if the matching contains the specified CID, otherwise false.
    function isMatchingContainsCid(
        uint256 _matchingId,
        bytes32 _cid
    ) public view returns (bool) {
        bytes32[] memory cids = getMatchingCids(_matchingId);
        for (uint256 i = 0; i < cids.length; i++) {
            if (_cid == cids[i]) return true;
        }
        return false;
    }

    /// @notice Check if a matching with the given matching ID contains multiple CIDs.
    /// @param _matchingId The ID of the matching to check.
    /// @param _cids An array of CIDs (Content Identifiers) to check for.
    /// @return True if the matching contains all the specified CIDs, otherwise false.
    function isMatchingContainsCids(
        uint256 _matchingId,
        bytes32[] memory _cids
    ) public view returns (bool) {
        for (uint256 i = 0; i < _cids.length; i++) {
            if (isMatchingContainsCid(_matchingId, _cids[i])) return true;
        }
        return false;
    }

    /// @notice check is matching targe valid
    function isMatchingTargetValid(
        uint256 _datasetId,
        bytes32[] memory _cars,
        uint256 _size,
        MatchingType.DataType _dataType,
        uint256 _associatedMappingFilesMatchingID
    ) public view returns (bool) {
        require(
            getDatasetState(_datasetId) == DatasetType.State.DatasetApproved,
            "datasetId is not approved!"
        );
        require(isDatasetContainsCids(_datasetId, _cars), "Invalid cids!");
        require(_size > 0, "Invalid size!");
        if (_dataType == MatchingType.DataType.Dataset) {
            (
                uint256 datasetId,
                ,
                ,
                MatchingType.DataType dataType,

            ) = getMatchingTarget(_associatedMappingFilesMatchingID);

            require(
                datasetId == _datasetId && dataType == _dataType,
                "Need has a associated MappingFiles matching id"
            );
            require(
                isMatchingTargetMeetsFilPlusRequirements(
                    _datasetId,
                    _cars,
                    _size,
                    _dataType,
                    _associatedMappingFilesMatchingID
                ),
                "Not meets filplus requirements"
            );
        }
        return true;
    }

    /// @notice Check if a matching meets the requirements of Fil+.
    function isMatchingTargetMeetsFilPlusRequirements(
        uint256 _matchingId
    ) public view returns (bool) {
        MatchingType.Matching storage matching = matchings[_matchingId];
        return
            isMatchingTargetMeetsFilPlusRequirements(
                matching.target.datasetId,
                matching.target.cars,
                matching.target.size,
                matching.target.dataType,
                matching.target.associatedMappingFilesMatchingID
            );
    }

    /// @notice Check if a matching meets the requirements of Fil+.
    function isMatchingTargetMeetsFilPlusRequirements(
        uint256 _datasetId,
        bytes32[] memory _cars,
        uint256 _size,
        MatchingType.DataType _dataType,
        uint256 _associatedMappingFilesMatchingID
    ) public view virtual returns (bool);
}
