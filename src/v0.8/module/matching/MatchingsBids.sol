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
import {IDatasetsProof} from "src/v0.8/interfaces/module/IDatasetsProof.sol";
import {IDatasets} from "src/v0.8/interfaces/module/IDatasets.sol";
import {IMatchings} from "src/v0.8/interfaces/module/IMatchings.sol";
import {IMatchingsBids} from "src/v0.8/interfaces/module/IMatchingsBids.sol";
import {IMatchingsTarget} from "src/v0.8/interfaces/module/IMatchingsTarget.sol";

/// shared
import {MatchingsEvents} from "src/v0.8/shared/events/MatchingsEvents.sol";
import {MatchingsModifiers} from "src/v0.8/shared/modifiers/MatchingsModifiers.sol";
import {Errors} from "src/v0.8/shared/errors/Errors.sol";

/// library
import {MatchingBidsLIB} from "src/v0.8/module/matching/library/MatchingBidsLIB.sol";
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
///      TODO: Missing fund proccess,need add later https://github.com/dataswap/core/issues/20
///            1 bidder(when bidding) and initiator(when publish) should transfer FIL to payable function
///            2 proccess the fund after matched
///            3 proccess the fund after matchedsotre,step by step
contract MatchingsBids is
    Initializable,
    UUPSUpgradeable,
    IMatchingsBids,
    MatchingsModifiers
{
    /// @notice  Use libraries for different matching functionalities
    using MatchingBidsLIB for MatchingType.MatchingBids;
    using ArrayAddressLIB for address[];
    using ArrayUint64LIB for uint64[];

    /// @notice  Declare private variables
    mapping(uint64 => MatchingType.MatchingBids) private matchingBids;

    address private governanceAddress;
    IRoles private roles;
    IFilplus private filplus;
    ICarstore private carstore;
    IDatasets public datasets;
    IDatasetsRequirement public datasetsRequirement;
    IDatasetsProof public datasetsProof;
    IMatchings public matchings;
    IMatchingsTarget public matchingsTarget;
    /// @dev This empty reserved space is put in place to allow future versions to add new
    uint256[32] private __gap;

    /// @notice initialize function to initialize the contract and grant the default admin role to the deployer.
    // solhint-disable-next-line
    function initialize(
        address _governanceAddress,
        address _roles,
        address _filplus,
        address _carstore,
        address _datasets,
        address _datasetsRequirement,
        address _datasetsProof
    ) public initializer {
        governanceAddress = _governanceAddress;
        roles = IRoles(_roles);
        filplus = IFilplus(_filplus);
        carstore = ICarstore(_carstore);
        datasets = IDatasets(_datasets);
        datasetsRequirement = IDatasetsRequirement(_datasetsRequirement);
        datasetsProof = IDatasetsProof(_datasetsProof);
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

    function initMatchings(
        address _matchings,
        address _matchingsTarget
    ) external onlyRole(roles, RolesType.DEFAULT_ADMIN_ROLE) {
        matchings = IMatchings(_matchings);
        matchingsTarget = IMatchingsTarget(_matchingsTarget);
    }

    /// @notice Function for bidding on a matching
    function bidding(
        uint64 _matchingId,
        uint256 _amount
    )
        external
        onlyRole(roles, RolesType.STORAGE_PROVIDER)
        onlyMatchingState(matchings, _matchingId, MatchingType.State.InProgress)
    {
        MatchingType.MatchingBids storage bids = matchingBids[_matchingId];
        MatchingType.BidSelectionRule bidSelectionRule = matchings
            .getBidSelectionRule(_matchingId);
        bids._matchingBidding(
            bidSelectionRule,
            matchings.getBiddingThreshold(_matchingId),
            matchings.getBiddingAfterPauseHeight(_matchingId),
            matchings.getBiddingEndHeight(_matchingId),
            _amount
        );
        (, address[] memory sp, , , ) = datasetsRequirement
            .getDatasetReplicaRequirement(
                matchingsTarget.getMatchingDatasetId(_matchingId),
                matchingsTarget.getMatchingReplicaIndex(_matchingId)
            );

        if (sp.length > 0) {
            require(sp.isContains(msg.sender), "Invalid SP submitter");
        }

        emit MatchingsEvents.MatchingBidPlaced(
            _matchingId,
            msg.sender,
            _amount
        );
        if (
            bidSelectionRule ==
            MatchingType.BidSelectionRule.ImmediateAtLeast ||
            bidSelectionRule == MatchingType.BidSelectionRule.ImmediateAtMost
        ) {
            closeMatching(_matchingId);
        }
    }

    ///@dev update cars info to carStore after matching failed
    function _afterMatchingFailed(uint64 _matchingId) internal {
        uint64[] memory cars = matchingsTarget.getMatchingCars(_matchingId);
        for (uint64 i; i < cars.length; i++) {
            carstore.reportCarReplicaMatchingState(cars[i], _matchingId, false);
        }
    }

    ///@dev update cars info to carStore before matching complete
    function _beforeMatchingCompleted(uint64 _matchingId) internal {
        uint64[] memory cars = matchingsTarget.getMatchingCars(_matchingId);
        for (uint64 i; i < cars.length; i++) {
            carstore.reportCarReplicaMatchingState(cars[i], _matchingId, true);
        }
    }

    /// @notice Function for canceling a matching
    /// @param _matchingId The ID of the matching.
    function cancelMatching(
        uint64 _matchingId
    ) external onlyMatchingInitiator(matchings, _matchingId) {
        _afterMatchingFailed(_matchingId);
        try matchings.reportCancelMatching(_matchingId) {} catch Error(
            string memory err
        ) {
            revert(err);
        } catch {
            revert("report cancel matching failed");
        }
    }

    /// @notice Function for closing a matching and choosing a winner
    function closeMatching(uint64 _matchingId) public {
        if (
            matchings.getMatchingState(_matchingId) ==
            MatchingType.State.InProgress
        ) {
            try matchings.reportCloseMatching(_matchingId) {} catch {
                revert("close matching failed");
            }
        }

        require(
            matchings.getMatchingState(_matchingId) ==
                MatchingType.State.Closed,
            "Invalid state"
        );

        MatchingType.MatchingBids storage bids = matchingBids[_matchingId];
        address winner = bids._chooseMatchingWinner(
            matchings.getBidSelectionRule(_matchingId),
            matchings.getBiddingThreshold(_matchingId),
            matchings.getBiddingAfterPauseHeight(_matchingId),
            matchings.getBiddingEndHeight(_matchingId)
        );

        if (winner != address(0)) {
            if (
                !matchingsTarget.isMatchingTargetMeetsFilPlusRequirements(
                    _matchingId,
                    winner
                )
            ) {
                bids._setMatchingBidderNotComplyFilplusRule(winner);
                revert Errors
                    .NotCompliantRuleMatchingTargetMeetsFilPlusRequirements(
                        _matchingId,
                        winner
                    );
            }

            _beforeMatchingCompleted(_matchingId);
            bids.winner = winner;
            matchings.reportMatchingHasWinner(_matchingId, winner);
        } else {
            _afterMatchingFailed(_matchingId);
            matchings.reportMatchingNoWinner(_matchingId);
        }
    }

    /// @notice Function for getting bids in a matching
    function getMatchingBids(
        uint64 _matchingId
    ) public view returns (address[] memory, uint256[] memory) {
        MatchingType.MatchingBids storage bids = matchingBids[_matchingId];
        return bids._getMatchingBids();
    }

    /// @notice Function for getting bid amount of a bidder in a matching
    function getMatchingBidAmount(
        uint64 _matchingId,
        address _bidder
    ) public view returns (uint256) {
        MatchingType.MatchingBids storage bids = matchingBids[_matchingId];
        return bids._getMatchingBidAmount(_bidder);
    }

    /// @notice Function for getting the count of bids in a matching
    function getMatchingBidsCount(
        uint64 _matchingId
    ) public view returns (uint64) {
        MatchingType.MatchingBids storage bids = matchingBids[_matchingId];
        return bids._getMatchingBidsCount();
    }

    /// @notice Function for getting winner of a matching
    function getMatchingWinner(
        uint64 _matchingId
    ) public view returns (address) {
        MatchingType.MatchingBids storage bids = matchingBids[_matchingId];
        return bids.winner;
    }

    /// @notice Function for getting winners of a matchings
    function getMatchingWinners(
        uint64[] memory _matchingIds
    ) public view returns (address[] memory) {
        (uint256 count, uint64[] memory matchingIds) = _matchingIds
            .removeElement(0);
        address[] memory winners = new address[](count);
        for (uint64 i = 0; i < count; i++) {
            winners[i] = getMatchingWinner(matchingIds[i]);
        }
        return winners;
    }

    /// @notice Function for checking if a bidder has a bid in a matching
    function hasMatchingBid(
        uint64 _matchingId,
        address _bidder
    ) public view returns (bool) {
        MatchingType.MatchingBids storage bids = matchingBids[_matchingId];
        return bids._hasMatchingBid(_bidder);
    }
}