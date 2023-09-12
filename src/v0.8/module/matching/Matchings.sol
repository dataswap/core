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
/// interface
import {IRoles} from "src/v0.8/interfaces/core/IRoles.sol";
import {IFilplus} from "src/v0.8/interfaces/core/IFilplus.sol";
import {ICarstore} from "src/v0.8/interfaces/core/ICarstore.sol";
import {IDatasets} from "src/v0.8/interfaces/module/IDatasets.sol";
import {IMatchings} from "src/v0.8/interfaces/module/IMatchings.sol";
/// shared
import {MatchingsEvents} from "src/v0.8/shared/events/MatchingsEvents.sol";
import {MatchingsModifiers} from "src/v0.8/shared/modifiers/MatchingsModifiers.sol";
/// library
import {MatchingLIB} from "src/v0.8/module/matching/library/MatchingLIB.sol";
import {MatchingStateMachineLIB} from "src/v0.8/module/matching/library/MatchingStateMachineLIB.sol";
import {MatchingBidsLIB} from "src/v0.8/module/matching/library/MatchingBidsLIB.sol";
/// type
import {RolesType} from "src/v0.8/types/RolesType.sol";
import {DatasetType} from "src/v0.8/types/DatasetType.sol";
import {MatchingType} from "src/v0.8/types/MatchingType.sol";

import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {UUPSUpgradeable} from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

/// @title Matchings Base Contract
/// @notice This contract serves as the base for managing matchings, their states, and associated actions.
/// @dev This contract is intended to be inherited by specific matching-related contracts.
///      TODO: Missing fund proccess,need add later https://github.com/dataswap/core/issues/20
///            1 bidder(when bidding) and initiator(when publish) should transfer FIL to payable function
///            2 proccess the fund after matched
///            3 proccess the fund after matchedsotre,step by step
contract Matchings is
    Initializable,
    UUPSUpgradeable,
    IMatchings,
    MatchingsModifiers
{
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
    IDatasets public datasets;
    /// @dev This empty reserved space is put in place to allow future versions to add new
    uint256[32] private __gap;

    /// @notice initialize function to initialize the contract and grant the default admin role to the deployer.
    // solhint-disable-next-line
    function initialize(
        address _governanceAddress,
        address _roles,
        address _filplus,
        address _filecoin,
        address _carstore,
        address _datasets
    ) public initializer {
        MatchingsModifiers.matchingsModifiersInitialize(
            _roles,
            _filplus,
            _filecoin,
            _carstore,
            _datasets,
            address(this)
        );
        governanceAddress = _governanceAddress;
        roles = IRoles(_roles);
        filplus = IFilplus(_filplus);
        carstore = ICarstore(_carstore);
        datasets = IDatasets(_datasets);
        __UUPSUpgradeable_init();
    }

    /// @notice UUPS Upgradeable function to update the roles implementation
    /// @dev Only triggered by contract admin
    function _authorizeUpgrade(
        address newImplementation
    )
        internal
        override
        onlyRole(RolesType.DEFAULT_ADMIN_ROLE) // solhint-disable-next-line
    {}

    /// @notice Returns the implementation contract
    function getImplementation() external view returns (address) {
        return _getImplementation();
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
            closeMatching(_matchingId);
        }
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
    ) external onlyRole(RolesType.DATASET_PROVIDER) returns (uint64) {
        matchingsCount++;
        MatchingType.Matching storage matching = matchings[matchingsCount];
        matching.target = MatchingType.Target({
            datasetId: _datasetId,
            cars: new bytes32[](0),
            size: 0,
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
        return matchingsCount;
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
    ) external onlyRole(RolesType.DATASET_PROVIDER) {
        MatchingType.Matching storage matching = matchings[_matchingId];
        uint64 _size = carstore.getCarsSize(_cars);
        require(matching.initiator == msg.sender, "invalid sender");
        (uint64 datasetId, , , , ) = getMatchingTarget(_matchingId);
        require(datasetId == _datasetId, "invalid dataset id");
        require(
            isMatchingTargetMeetsFilPlusRequirements(
                _datasetId,
                _cars,
                _size,
                matching.target.dataType,
                matching.target.associatedMappingFilesMatchingID
            ),
            "Target invalid"
        );

        matching._updateTargetCars(_cars, _size);

        if (complete) {
            matching._publishMatching();
            emit MatchingsEvents.MatchingPublished(_matchingId, msg.sender);
        }
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
        require(matching.pausedBlockCount == 0, "only can paused one time");
        require(
            uint8(block.number) <
                matching.createdBlockNumber + matching.biddingDelayBlockCount,
            "alreay bidding,can't pause."
        );
        matching._pauseMatching();
        emit MatchingsEvents.MatchingPaused(_matchingId);
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
    ) public onlyMatchingState(_matchingId, MatchingType.State.InProgress) {
        MatchingType.Matching storage matching = matchings[_matchingId];
        if (
            matching.bidSelectionRule ==
            MatchingType.BidSelectionRule.ImmediateAtLeast ||
            matching.bidSelectionRule ==
            MatchingType.BidSelectionRule.ImmediateAtMost
        ) {
            require(
                block.number >=
                    matching.createdBlockNumber +
                        matching.biddingDelayBlockCount +
                        matching.pausedBlockCount,
                "Bidding too early"
            );
        } else {
            require(
                block.number >=
                    matching.createdBlockNumber +
                        matching.biddingDelayBlockCount +
                        matching.biddingPeriodBlockCount +
                        matching.pausedBlockCount,
                "Bidding period not expired"
            );
        }
        matching._closeMatching();
        address winner = matching._chooseMatchingWinner();
        if (winner != address(0)) {
            _beforeCompleteMatching(_matchingId);
            matching.winner = winner;
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

    /// @notice Get the cars of a matching.
    /// @param _matchingId The ID of the matching.
    /// @return cars An array of CIDs representing the cars in the matching.
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

    /// @notice  Function for getting winner of a matching
    function getMatchingWinner(
        uint64 _matchingId
    ) public view returns (address) {
        MatchingType.Matching storage matching = matchings[_matchingId];
        return matching.winner;
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

        // Source data needs to ensure that the associated mapping files data has been stored
        if (_dataType == DatasetType.DataType.Source) {
            (, , , DatasetType.DataType dataType, ) = getMatchingTarget(
                _associatedMappingFilesMatchingID
            );

            require(
                dataType == DatasetType.DataType.MappingFiles,
                "Need a associated matching"
            );
            require(
                getMatchingState(_associatedMappingFilesMatchingID) ==
                    MatchingType.State.Completed,
                "datasetId is not completed!"
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
