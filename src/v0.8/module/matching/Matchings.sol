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
import {IDatasetsRequirement} from "src/v0.8/interfaces/module/IDatasetsRequirement.sol";
import {IMatchings} from "src/v0.8/interfaces/module/IMatchings.sol";
import {IMatchingsBids} from "src/v0.8/interfaces/module/IMatchingsBids.sol";
import {IMatchingsTarget} from "src/v0.8/interfaces/module/IMatchingsTarget.sol";

/// shared
import {MatchingsEvents} from "src/v0.8/shared/events/MatchingsEvents.sol";
import {MatchingsModifiers} from "src/v0.8/shared/modifiers/MatchingsModifiers.sol";
import {Errors} from "src/v0.8/shared/errors/Errors.sol";
import {StatisticsBase} from "src/v0.8/core/statistics/StatisticsBase.sol";

/// library
import {MatchingLIB} from "src/v0.8/module/matching/library/MatchingLIB.sol";
import {MatchingStateMachineLIB} from "src/v0.8/module/matching/library/MatchingStateMachineLIB.sol";
import "src/v0.8/shared/utils/array/ArrayLIB.sol";

/// type
import {RolesType} from "src/v0.8/types/RolesType.sol";
import {DatasetType} from "src/v0.8/types/DatasetType.sol";
import {MatchingType} from "src/v0.8/types/MatchingType.sol";

import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {UUPSUpgradeable} from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

/// @title Matchings Base Contract
/// @notice This contract serves as the base for managing matchings, their states, and associated actions.
/// @dev This contract is intended to be inherited by specific matching-related contracts.
contract Matchings is
    Initializable,
    UUPSUpgradeable,
    IMatchings,
    StatisticsBase,
    MatchingsModifiers
{
    /// @notice  Use libraries for different matching functionalities
    using MatchingLIB for MatchingType.Matching;
    using MatchingStateMachineLIB for MatchingType.Matching;
    using ArrayAddressLIB for address[];

    /// @notice  Declare private variables
    mapping(uint64 => MatchingType.Matching) private matchings;

    address private governanceAddress;
    IRoles private roles;
    IDatasetsRequirement public datasetsRequirement;
    /// @dev This empty reserved space is put in place to allow future versions to add new
    uint256[32] private __gap;

    /// @notice initialize function to initialize the contract and grant the default admin role to the deployer.
    // solhint-disable-next-line
    function initialize(
        address _governanceAddress,
        address _roles,
        address _datasetsRequirement
    ) public initializer {
        StatisticsBase.statisticsBaseInitialize();
        governanceAddress = _governanceAddress;
        roles = IRoles(_roles);
        datasetsRequirement = IDatasetsRequirement(_datasetsRequirement);
        __UUPSUpgradeable_init();
    }

    /// @notice UUPS Upgradeable function to update the roles implementation
    /// @dev Only triggered by contract admin
    function _authorizeUpgrade(
        address newImplementation
    )
        internal
        override
        onlyRole(roles, RolesType.DEFAULT_ADMIN_ROLE) // solhint-disable-next-line
    {}

    /// @notice Returns the implementation contract
    function getImplementation() external view returns (address) {
        return _getImplementation();
    }

    /// @notice Function for create a new matching.
    /// @param _datasetId The dataset id to create matching.
    /// @param _bidSelectionRule The rules for determining the winning bid.
    /// @param _biddingDelayBlockCount The number of blocks to delay bidding.
    /// @param _biddingPeriodBlockCount The number of blocks for bidding period.
    /// @param _storageCompletionPeriodBlocks The number of blocks for storage period.
    /// @param _biddingThreshold The threshold for bidding.
    /// @param _replicaIndex The index of the replica in dataset.
    /// @param _additionalInfo The additional information about the matching.
    /// @return The matchingId.
    function createMatching(
        uint64 _datasetId,
        MatchingType.BidSelectionRule _bidSelectionRule,
        uint64 _biddingDelayBlockCount,
        uint64 _biddingPeriodBlockCount,
        uint64 _storageCompletionPeriodBlocks,
        uint256 _biddingThreshold,
        uint16 _replicaIndex,
        string memory _additionalInfo
    ) external onlyRole(roles, RolesType.DATASET_PROVIDER) returns (uint64) {
        _addCountTotal(1);
        MatchingType.Matching storage matching = matchings[matchingsCount()];
        require(
            _replicaIndex <
                datasetsRequirement.getDatasetReplicasCount(_datasetId),
            "Invalid matching replica"
        );

        ///TODO: the dp must by client or submit proof
        (address[] memory dp, , , , ) = datasetsRequirement
            .getDatasetReplicaRequirement(_datasetId, _replicaIndex);

        if (dp.length > 0) {
            require(dp.isContains(msg.sender), "Invalid DP submitter");
        }

        matching.bidSelectionRule = _bidSelectionRule;
        matching.biddingDelayBlockCount = _biddingDelayBlockCount;
        matching.biddingPeriodBlockCount = _biddingPeriodBlockCount;
        matching.storageCompletionPeriodBlocks = _storageCompletionPeriodBlocks;
        matching.biddingThreshold = _biddingThreshold;
        matching.additionalInfo = _additionalInfo;
        matching.initiator = msg.sender;
        matching.createdBlockNumber = uint64(block.number);
        emit MatchingsEvents.MatchingCreated(matchingsCount(), msg.sender);
        return matchingsCount();
    }

    /// @notice Function for pausing a matching
    function pauseMatching(
        uint64 _matchingId
    ) external onlyMatchingInitiator(this, _matchingId) {
        MatchingType.Matching storage matching = matchings[_matchingId];
        matching._pauseMatching();
        emit MatchingsEvents.MatchingPaused(_matchingId);
    }

    /// @notice Function for resuming a paused matching
    function resumeMatching(
        uint64 _matchingId
    ) external onlyMatchingInitiator(this, _matchingId) {
        MatchingType.Matching storage matching = matchings[_matchingId];
        matching._resumeMatching();
        emit MatchingsEvents.MatchingResumed(_matchingId);
    }

    /// @notice Function for getting the initiator of a matching
    function getMatchingInitiator(
        uint64 _matchingId
    ) public view returns (address) {
        MatchingType.Matching storage matching = matchings[_matchingId];
        return matching.initiator;
    }

    /// @notice Function for getting the state of a matching
    function getMatchingState(
        uint64 _matchingId
    ) public view returns (MatchingType.State) {
        MatchingType.Matching storage matching = matchings[_matchingId];
        return matching._getMatchingState();
    }

    /// @notice Function for getting the meta data of a matching.
    /// @param _matchingId The matching id to get meta data of matching.
    /// @return bidSelectionRule The rules for determining the winning bid.
    /// @return biddingDelayBlockCount The number of blocks to delay bidding.
    /// @return biddingPeriodBlockCount The number of blocks for bidding period.
    /// @return storageCompletionPeriodBlocks The number of blocks for storage period.
    /// @return biddingThreshold The threshold for bidding.
    /// @return createdBlockNumber The block height at which matching is created.
    /// @return additionalInfo The additional information about the matching.
    /// @return initiator The initiator of the matching.
    /// @return pausedBlockCount The number of blocks matching is paused.
    function getMatchingMetadata(
        uint64 _matchingId
    )
        public
        view
        returns (
            MatchingType.BidSelectionRule bidSelectionRule,
            uint64 biddingDelayBlockCount,
            uint64 biddingPeriodBlockCount,
            uint64 storageCompletionPeriodBlocks,
            uint256 biddingThreshold,
            uint64 createdBlockNumber,
            string memory additionalInfo,
            address initiator,
            uint64 pausedBlockCount
        )
    {
        MatchingType.Matching storage matching = matchings[_matchingId];
        return (
            matching.bidSelectionRule,
            matching.biddingDelayBlockCount,
            matching.biddingPeriodBlockCount,
            matching.storageCompletionPeriodBlocks,
            matching.biddingThreshold,
            matching.createdBlockNumber,
            matching.additionalInfo,
            matching.initiator,
            matching.pausedBlockCount
        );
    }

    /// @notice Function for publishing a matching
    /// @dev This function is intended for use only by the 'dataswap' contract.
    /// @param _matchingId The matching id to publish cars.
    function __reportPublishMatching(
        uint64 _matchingId,
        uint64 _size
    ) external onlyRole(roles, RolesType.DATASWAP_CONTRACT) {
        MatchingType.Matching storage matching = matchings[_matchingId];
        _addSizeTotal(_size);
        matching._publishMatching();
    }

    /// @notice Function for report canceling a matching
    /// @dev This function is intended for use only by the 'dataswap' contract.
    function __reportCancelMatching(
        uint64 _matchingId,
        uint64 _size
    ) external onlyRole(roles, RolesType.DATASWAP_CONTRACT) {
        MatchingType.Matching storage matching = matchings[_matchingId];
        matching._cancelMatching();
        _addCountFailed(1);
        _addSizeFailed(_size);
        emit MatchingsEvents.MatchingCancelled(_matchingId);
    }

    /// @notice Function for closing a matching
    /// @dev This function is intended for use only by the 'dataswap' contract.
    function __reportCloseMatching(
        uint64 _matchingId
    ) external onlyRole(roles, RolesType.DATASWAP_CONTRACT) {
        MatchingType.Matching storage matching = matchings[_matchingId];
        matching._closeMatching();
        emit MatchingsEvents.MatchingClosed(_matchingId);
    }

    /// @notice Function for report complete a matching with a winner
    /// @dev This function is intended for use only by the 'dataswap' contract.
    function __reportMatchingHasWinner(
        uint64 _matchingId,
        uint64 _size,
        address _winner
    ) external onlyRole(roles, RolesType.DATASWAP_CONTRACT) {
        MatchingType.Matching storage matching = matchings[_matchingId];
        matching._reportMatchingHasWinner();
        _addCountSuccess(1);
        _addSizeSuccess(_size);
        emit MatchingsEvents.MatchingHasWinner(_matchingId, _winner);
    }

    /// @notice Function for report complete a matching without winner.
    /// @dev This function is intended for use only by the 'dataswap' contract.
    function __reportMatchingNoWinner(
        uint64 _matchingId,
        uint64 _size
    ) external onlyRole(roles, RolesType.DATASWAP_CONTRACT) {
        MatchingType.Matching storage matching = matchings[_matchingId];
        matching._reportMatchingNoWinner();
        _addCountFailed(1);
        _addSizeFailed(_size);
        emit MatchingsEvents.MatchingNoWinner(_matchingId);
    }

    /// @notice Returns the count of matchings.
    /// @return The total count of matchings.
    function matchingsCount() public view returns (uint64) {
        // Calls the internal function to get the total count of matchings.
        return uint64(_totalCount());
    }
}
