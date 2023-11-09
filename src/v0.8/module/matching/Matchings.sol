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
    MatchingsModifiers
{
    /// @notice  Use libraries for different matching functionalities
    using MatchingLIB for MatchingType.Matching;
    using MatchingStateMachineLIB for MatchingType.Matching;
    using ArrayAddressLIB for address[];

    /// @notice  Declare private variables
    uint64 public matchingsCount;
    mapping(uint64 => MatchingType.Matching) private matchings;

    address private governanceAddress;
    IRoles private roles;
    IDatasetsRequirement public datasetsRequirement;
    IMatchingsTarget public matchingsTarget;
    IMatchingsBids public matchingsBids;
    /// @dev This empty reserved space is put in place to allow future versions to add new
    uint256[32] private __gap;

    /// @notice initialize function to initialize the contract and grant the default admin role to the deployer.
    // solhint-disable-next-line
    function initialize(
        address _governanceAddress,
        address _roles,
        address _datasetsRequirement
    ) public initializer {
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

    function initDependencies(
        address _matchingsTarget,
        address _matchingsBids
    ) external onlyRole(roles, RolesType.DEFAULT_ADMIN_ROLE) {
        matchingsTarget = IMatchingsTarget(_matchingsTarget);
        matchingsBids = IMatchingsBids(_matchingsBids);
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
        matchingsCount++;
        MatchingType.Matching storage matching = matchings[matchingsCount];
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
        return matchingsCount;
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

    /// @notice Function for publishing a matching
    /// @param _matchingId The matching id to publish cars.
    function reportPublishMatching(
        uint64 _matchingId
    ) external onlyMatchingsTarget(matchingsTarget, _matchingId) {
        MatchingType.Matching storage matching = matchings[_matchingId];
        matching._publishMatching();
    }

    /// @notice Function for report canceling a matching
    function reportCancelMatching(
        uint64 _matchingId
    ) external onlyMatchingsBids(matchingsBids, _matchingId) {
        MatchingType.Matching storage matching = matchings[_matchingId];
        matching._cancelMatching();
        emit MatchingsEvents.MatchingCancelled(_matchingId);
    }

    /// @notice Function for closing a matching
    function reportCloseMatching(
        uint64 _matchingId
    ) external onlyMatchingsBids(matchingsBids, _matchingId) {
        MatchingType.Matching storage matching = matchings[_matchingId];
        matching._closeMatching();
        emit MatchingsEvents.MatchingClosed(_matchingId);
    }

    /// @notice Function for report complete a matching with a winner
    function reportMatchingHasWinner(
        uint64 _matchingId,
        address _winner
    ) external onlyMatchingsBids(matchingsBids, _matchingId) {
        MatchingType.Matching storage matching = matchings[_matchingId];
        matching._reportMatchingHasWinner();
        emit MatchingsEvents.MatchingHasWinner(_matchingId, _winner);
    }

    /// @notice Function for report complete a matching without winner.
    function reportMatchingNoWinner(
        uint64 _matchingId
    ) external onlyMatchingsBids(matchingsBids, _matchingId) {
        MatchingType.Matching storage matching = matchings[_matchingId];
        matching._reportMatchingNoWinner();
        emit MatchingsEvents.MatchingNoWinner(_matchingId);
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

    /// @notice Function for getting the selection rule of a matching
    function getBidSelectionRule(
        uint64 _matchingId
    ) public view returns (MatchingType.BidSelectionRule) {
        MatchingType.Matching storage matching = matchings[_matchingId];
        return matching.bidSelectionRule;
    }

    /// @notice Function for getting the threshold of a matching
    function getBiddingThreshold(
        uint64 _matchingId
    ) public view returns (uint256) {
        MatchingType.Matching storage matching = matchings[_matchingId];
        return matching.biddingThreshold;
    }

    /// @notice Function for getting the start height of a matching
    function getBiddingStartHeight(
        uint64 _matchingId
    ) public view returns (uint64) {
        MatchingType.Matching storage matching = matchings[_matchingId];
        return matching.createdBlockNumber + matching.biddingDelayBlockCount;
    }

    /// @notice Function for getting the after pause height of a matching
    function getBiddingAfterPauseHeight(
        uint64 _matchingId
    ) public view returns (uint64) {
        MatchingType.Matching storage matching = matchings[_matchingId];
        return
            matching.createdBlockNumber +
            matching.biddingDelayBlockCount +
            matching.pausedBlockCount;
    }

    /// @notice Function for getting the end height of a matching
    function getBiddingEndHeight(
        uint64 _matchingId
    ) public view returns (uint64) {
        MatchingType.Matching storage matching = matchings[_matchingId];
        return
            matching.createdBlockNumber +
            matching.biddingDelayBlockCount +
            matching.biddingPeriodBlockCount +
            matching.pausedBlockCount;
    }

    /// @notice  Function for getting the storage completion period blocks in a matching
    function getMatchingStorageCompletionHeight(
        uint64 _matchingId
    ) public view returns (uint64) {
        MatchingType.Matching storage matching = matchings[_matchingId];
        return matching.storageCompletionPeriodBlocks;
    }

    /// @notice  Function for getting the matching creation block number
    function getMatchingCreatedHeight(
        uint64 _matchingId
    ) public view returns (uint64) {
        MatchingType.Matching storage matching = matchings[_matchingId];
        return matching.createdBlockNumber;
    }
}
