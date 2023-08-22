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
/// interface
import {IRoles} from "../../interfaces/core/IRoles.sol";
import {IFilplus} from "../../interfaces/core/IFilplus.sol";
import {IFilecoin} from "../../interfaces/core/IFilecoin.sol";
import {ICarstore} from "../../interfaces/core/ICarstore.sol";
import {IDatasets} from "../../interfaces/module/IDatasets.sol";
import {IMatchings} from "../../interfaces/module/IMatchings.sol";
/// shared
import {MatchingsEvents} from "../../shared/events/MatchingsEvents.sol";
import {MatchingsModifiers} from "../../shared/modifiers/MatchingsModifiers.sol";
/// library
import {MatchingLIB} from "./library/MatchingLIB.sol";
import {MatchingStateMachineLIB} from "./library/MatchingStateMachineLIB.sol";
import {MatchingBidsLIB} from "./library/MatchingBidsLIB.sol";
/// type
import {RolesType} from "../../types/RolesType.sol";
import {DatasetType} from "../../types/DatasetType.sol";
import {MatchingType} from "../../types/MatchingType.sol";

/// @title Matchings Base Contract
/// @notice This contract serves as the base for managing matchings, their states, and associated actions.
/// @dev This contract is intended to be inherited by specific matching-related contracts.
///      TODO: Missing fund proccess,need add later https://github.com/dataswap/core/issues/20
///            1 bidder(when bidding) and initiator(when publish) should transfer FIL to payable function
///            2 proccess the fund after matched
///            3 proccess the fund after matchedsotre,step by step
contract Matchings is IMatchings, MatchingsModifiers {
    /// @notice  Use libraries for different matching functionalities
    using MatchingLIB for MatchingType.Matching;
    using MatchingStateMachineLIB for MatchingType.Matching;
    using MatchingBidsLIB for MatchingType.Matching;

    /// @notice  Declare private variables
    uint64 public matchingsCount;
    mapping(uint64 => MatchingType.Matching) private matchings;

    address private governanceAddress;
    IRoles private roles;
    IFilplus private filplus;
    ICarstore private carstore;
    IDatasets private datasets;

    constructor(
        address _governanceAddress,
        IRoles _roles,
        IFilplus _filplus,
        IFilecoin _filecoin,
        ICarstore _carstore,
        IDatasets _datasets
    )
        MatchingsModifiers(
            _roles,
            _filplus,
            _filecoin,
            _carstore,
            _datasets,
            this
        )
    {
        governanceAddress = _governanceAddress;
        roles = _roles;
        filplus = _filplus;
        carstore = _carstore;
        datasets = _datasets;
    }

    ///@dev update cars info  to carStore before complete
    function _beforeCompleteMatching(uint64 _matchingId) internal {
        bytes32[] memory cars = getMatchingCars(_matchingId);
        for (uint64 i; i < cars.length; i++) {
            carstore.addCarReplica(cars[i], _matchingId);
        }
    }

    /// @notice  Function for bidding on a matching
    function bidding(
        uint64 _matchingId,
        uint256 _amount
    ) external onlyRole(RolesType.STORAGE_PROVIDER) {
        MatchingType.Matching storage matching = matchings[_matchingId];
        matching._matchingBidding(_amount);

        emit MatchingsEvents.MatchingBidPlaced(
            _matchingId,
            msg.sender,
            _amount
        );
        if (
            matching.bidSelectionRule ==
            MatchingType.BidSelectionRule.ImmediateAtLeast ||
            matching.bidSelectionRule ==
            MatchingType.BidSelectionRule.ImmediateAtMost
        ) {
            matching._emitMatchingEvent(MatchingType.Event.Close);
            matching._emitMatchingEvent(MatchingType.Event.HasWinner);
        }
    }

    /// @notice  Function for publishing a new matching
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
        matching.storageCompletionPeriodBlocks = _storageCompletionPeriodBlocks;
        matching.biddingThreshold = _biddingThreshold;
        matching.additionalInfo = _additionalInfo;
        matching.initiator = msg.sender;
        matching.createdBlockNumber = uint64(block.number);

        matching._publishMatching();
        emit MatchingsEvents.MatchingPublished(matchingsCount, msg.sender);
    }

    /// @notice  Function for pausing a matching
    function pauseMatching(
        uint64 _matchingId
    )
        external
        onlyMatchingInitiator(_matchingId)
        onlyMatchingState(_matchingId, MatchingType.State.InProgress)
    {
        MatchingType.Matching storage matching = matchings[_matchingId];
        matching._pauseMatching();
        emit MatchingsEvents.MatchingPaused(_matchingId);
    }

    /// @notice Function for reporting that a matching pause has expired
    function reportMatchingPauseExpired(uint64 _matchingId) external {
        MatchingType.Matching storage matching = matchings[_matchingId];
        matching._reportMatchingPauseExpired();
        emit MatchingsEvents.MatchingPauseExpired(_matchingId);
    }

    /// @notice  Function for resuming a paused matching
    function resumeMatching(
        uint64 _matchingId
    )
        external
        onlyMatchingInitiator(_matchingId)
        onlyMatchingState(_matchingId, MatchingType.State.Paused)
    {
        MatchingType.Matching storage matching = matchings[_matchingId];
        matching._resumeMatching();
        emit MatchingsEvents.MatchingResumed(_matchingId);
    }

    /// @notice  Function for canceling a matching
    function cancelMatching(
        uint64 _matchingId
    ) external onlyMatchingInitiator(_matchingId) {
        MatchingType.Matching storage matching = matchings[_matchingId];
        matching._cancelMatching();
        emit MatchingsEvents.MatchingCancelled(_matchingId);
    }

    /// @notice  Function for closing a matching and choosing a winner
    function closeMatching(
        uint64 _matchingId
    ) external onlyMatchingState(_matchingId, MatchingType.State.InProgress) {
        MatchingType.Matching storage matching = matchings[_matchingId];
        matching._closeMatching();
        address winner = matching._chooseMatchingWinner();
        if (winner != address(0)) {
            _beforeCompleteMatching(_matchingId);
            matching._emitMatchingEvent(MatchingType.Event.HasWinner);
            emit MatchingsEvents.MatchingHasWinner(_matchingId, winner);
        } else {
            matching._emitMatchingEvent(MatchingType.Event.NoWinner);
            emit MatchingsEvents.MatchingNoWinner(_matchingId);
        }
    }

    /// @notice  Function for getting bids in a matching
    function getMatchingBids(
        uint64 _matchingId
    ) public view returns (address[] memory, uint256[] memory) {
        MatchingType.Matching storage matching = matchings[_matchingId];
        return matching._getMatchingBids();
    }

    /// @notice  Function for getting bid amount of a bidder in a matching
    function getMatchingBidAmount(
        uint64 _matchingId,
        address _bidder
    ) public view returns (uint256) {
        MatchingType.Matching storage matching = matchings[_matchingId];
        return matching._getMatchingBidAmount(_bidder);
    }

    /// @notice  Function for getting the count of bids in a matching
    function getMatchingBidsCount(
        uint64 _matchingId
    ) public view returns (uint64) {
        MatchingType.Matching storage matching = matchings[_matchingId];
        return matching._getMatchingBidsCount();
    }

    /// @notice  Function for getting the count of bids in a matching
    function getMatchingCars(
        uint64 _matchingId
    ) public view returns (bytes32[] memory) {
        MatchingType.Matching storage matching = matchings[_matchingId];
        return matching.target.cars;
    }

    /// @notice  Function for getting the total data size of bids in a matching
    function getMatchingSize(uint64 _matchingId) public view returns (uint64) {
        (, , uint64 datasize, , ) = getMatchingTarget(_matchingId);
        return datasize;
    }

    function getMatchingInitiator(
        uint64 _matchingId
    ) external view returns (address) {
        MatchingType.Matching storage matching = matchings[_matchingId];
        return matching.initiator;
    }

    /// @notice  Function for getting the state of a matching
    function getMatchingState(
        uint64 _matchingId
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
        uint64 _matchingId
    )
        public
        view
        returns (
            uint64 datasetID,
            bytes32[] memory cars,
            uint64 size,
            DatasetType.DataType dataType,
            uint64 associatedMappingFilesMatchingID
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
        uint64 _matchingId,
        address _bidder
    ) public view returns (bool) {
        MatchingType.Matching storage matching = matchings[_matchingId];
        return matching._hasMatchingBid(_bidder);
    }

    /// @notice Check if a matching with the given matching ID contains a specific CID.
    /// @param _matchingId The ID of the matching to check.
    /// @param _cid The CID (Content Identifier) to check for.
    /// @return True if the matching contains the specified CID, otherwise false.
    function isMatchingContainsCar(
        uint64 _matchingId,
        bytes32 _cid
    ) public view returns (bool) {
        bytes32[] memory cids = getMatchingCars(_matchingId);
        for (uint64 i = 0; i < cids.length; i++) {
            if (_cid == cids[i]) return true;
        }
        return false;
    }

    /// @notice Check if a matching with the given matching ID contains multiple CIDs.
    /// @param _matchingId The ID of the matching to check.
    /// @param _cids An array of CIDs (Content Identifiers) to check for.
    /// @return True if the matching contains all the specified CIDs, otherwise false.
    function isMatchingContainsCars(
        uint64 _matchingId,
        bytes32[] memory _cids
    ) public view returns (bool) {
        for (uint64 i = 0; i < _cids.length; i++) {
            if (isMatchingContainsCar(_matchingId, _cids[i])) return true;
        }
        return false;
    }

    /// @notice check is matching targe valid
    function isMatchingTargetValid(
        uint64 _datasetId,
        bytes32[] memory _cars,
        uint64 _size,
        DatasetType.DataType _dataType,
        uint64 _associatedMappingFilesMatchingID
    ) public view returns (bool) {
        require(
            datasets.getDatasetState(_datasetId) ==
                DatasetType.State.DatasetApproved,
            "datasetId is not approved!"
        );
        require(
            datasets.isDatasetContainsCars(_datasetId, _cars),
            "Invalid cids!"
        );
        require(_size > 0, "Invalid size!");
        if (_dataType == DatasetType.DataType.Source) {
            (
                uint64 datasetId,
                ,
                ,
                DatasetType.DataType dataType,

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
        uint64 _matchingId
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
        uint64 /*_datasetId*/,
        bytes32[] memory /*_cars*/,
        uint64 /*_size*/,
        DatasetType.DataType /*_dataType*/,
        uint64 /*_associatedMappingFilesMatchingID*/
    ) public pure returns (bool) {
        //TODO https://github.com/dataswap/core/issues/29
        return true;
    }
}
