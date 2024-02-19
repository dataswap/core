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
import {IMatchingsBids} from "src/v0.8/interfaces/module/IMatchingsBids.sol";

/// shared
import {MatchingsEvents} from "src/v0.8/shared/events/MatchingsEvents.sol";
import {MatchingsModifiers} from "src/v0.8/shared/modifiers/MatchingsModifiers.sol";
import {Errors} from "src/v0.8/shared/errors/Errors.sol";

/// library
import {MatchingBidsLIB} from "src/v0.8/module/matching/library/MatchingBidsLIB.sol";
import {ArrayAddressLIB, ArrayUint64LIB} from "src/v0.8/shared/utils/array/ArrayLIB.sol";

/// type
import {RolesType} from "src/v0.8/types/RolesType.sol";
import {DatasetType} from "src/v0.8/types/DatasetType.sol";
import {MatchingType} from "src/v0.8/types/MatchingType.sol";
import {FinanceType} from "src/v0.8/types/FinanceType.sol";

import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {UUPSUpgradeable} from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

/// @title Matchings Base Contract
/// @notice This contract serves as the base for managing matchings, their states, and associated actions.
/// @dev This contract is intended to be inherited by specific matching-related contracts.
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
    IRoles public roles;
    /// @dev This empty reserved space is put in place to allow future versions to add new
    uint256[32] private __gap;

    /// @notice initialize function to initialize the contract and grant the default admin role to the deployer.
    // solhint-disable-next-line
    function initialize(
        address _governanceAddress,
        address _roles
    ) public initializer {
        governanceAddress = _governanceAddress;
        roles = IRoles(_roles);
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

    /// @notice Function for bidding on a matching
    function bidding(
        uint64 _matchingId,
        uint256 _amount
    )
        external
        payable
        onlyMatchingState(
            roles.matchings(),
            _matchingId,
            MatchingType.State.InProgress
        )
    {
        MatchingType.BidSelectionRule bidSelectionRule = _bidding(
            _matchingId,
            _amount
        );

        (uint64 datasetId, , , , , uint16 replicaIndex, ) = roles
            .matchingsTarget()
            .getMatchingTarget(_matchingId);

        (, address[] memory sp, , , ) = roles
            .datasetsRequirement()
            .getDatasetReplicaRequirement(datasetId, replicaIndex);

        if (sp.length > 0) {
            require(sp.isContains(msg.sender), "Invalid SP submitter");
        }

        roles.grantDataswapRole(RolesType.STORAGE_PROVIDER, msg.sender);
        // Add bidding escrow
        // roles.finance().escrow(/// TODO: https://github.com/dataswap/core/issues/245
        //     datasetId,
        //     _matchingId,
        //     FinanceType.FIL,
        //     FinanceType.Type.EscrowDataTradingFee
        // );

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

    /// @notice Internal Function for bidding on a matching
    function _bidding(
        uint64 _matchingId,
        uint256 _amount
    ) internal returns (MatchingType.BidSelectionRule) {
        MatchingType.MatchingBids storage bids = matchingBids[_matchingId];
        (
            MatchingType.BidSelectionRule bidSelectionRule,
            uint64 biddingDelayBlockCount,
            uint64 biddingPeriodBlockCount,
            ,
            uint256 biddingThreshold,
            uint64 createdBlockNumber,
            ,
            ,
            uint64 pausedBlockCount
        ) = roles.matchings().getMatchingMetadata(_matchingId);

        bids._matchingBidding(
            bidSelectionRule,
            biddingThreshold,
            createdBlockNumber + biddingDelayBlockCount + pausedBlockCount,
            createdBlockNumber +
                biddingDelayBlockCount +
                biddingPeriodBlockCount +
                pausedBlockCount,
            _amount
        );
        return bidSelectionRule;
    }

    ///@dev update cars info to carStore after matching failed
    function _afterMatchingFailed(
        uint64 _matchingId
    ) internal returns (uint64) {
        (, uint64[] memory cars, uint64 _size, , , , ) = roles
            .matchingsTarget()
            .getMatchingTarget(_matchingId);
        for (uint64 i; i < cars.length; i++) {
            roles.carstore().__reportCarReplicaMatchingState(
                cars[i],
                _matchingId,
                false
            );
        }
        return _size;
    }

    ///@dev update cars info to carStore before matching complete
    function _beforeMatchingCompleted(
        uint64 _matchingId
    )
        internal
        returns (
            uint64 /*_datasetId*/,
            uint16 /*_replicaIndex*/,
            uint64 /*_size*/
        )
    {
        (
            uint64 _datasetId,
            uint64[] memory cars,
            uint64 _size,
            ,
            ,
            uint16 _replicaIndex,

        ) = roles.matchingsTarget().getMatchingTarget(_matchingId);
        for (uint64 i; i < cars.length; i++) {
            roles.carstore().__reportCarReplicaMatchingState(
                cars[i],
                _matchingId,
                true
            );
        }
        return (_datasetId, _replicaIndex, _size);
    }

    /// @notice Function for canceling a matching
    /// @param _matchingId The ID of the matching.
    function cancelMatching(
        uint64 _matchingId
    ) external onlyMatchingInitiator(roles.matchings(), _matchingId) {
        uint64 _size = _afterMatchingFailed(_matchingId);
        try
            roles.matchings().__reportCancelMatching(_matchingId, _size)
        // solhint-disable-next-line
        {

        } catch Error(string memory err) {
            revert(err);
        } catch {
            revert("report cancel matching failed");
        }
    }

    /// @notice justify is has a winner for a closed matching.
    /// @dev This internal function is used to choose a winner for a closed matching based on the specified rule.
    function _chooseMatchingWinner(
        uint64 _matchingId
    ) internal view returns (address) {
        MatchingType.MatchingBids storage bids = matchingBids[_matchingId];
        (
            MatchingType.BidSelectionRule bidSelectionRule,
            uint64 biddingDelayBlockCount,
            uint64 biddingPeriodBlockCount,
            ,
            uint256 biddingThreshold,
            uint64 createdBlockNumber,
            ,
            ,
            uint64 pausedBlockCount
        ) = roles.matchings().getMatchingMetadata(_matchingId);

        address winner = bids._chooseMatchingWinner(
            bidSelectionRule,
            biddingThreshold,
            createdBlockNumber + biddingDelayBlockCount + pausedBlockCount,
            createdBlockNumber +
                biddingDelayBlockCount +
                biddingPeriodBlockCount +
                pausedBlockCount
        );
        return winner;
    }

    /// @notice Function for closing a matching and choosing a winner
    function closeMatching(uint64 _matchingId) public {
        if (
            roles.matchings().getMatchingState(_matchingId) ==
            MatchingType.State.InProgress
        ) {
            // solhint-disable-next-line
            try roles.matchings().__reportCloseMatching(_matchingId) {} catch {
                revert("close matching failed");
            }
        }

        require(
            roles.matchings().getMatchingState(_matchingId) ==
                MatchingType.State.Closed,
            "Invalid state"
        );

        address winner = _chooseMatchingWinner(_matchingId);

        if (winner != address(0)) {
            MatchingType.MatchingBids storage bids = matchingBids[_matchingId];
            if (
                !roles
                    .matchingsTarget()
                    .isMatchingTargetMeetsFilPlusRequirements(
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

            (
                uint64 _datasetId,
                uint16 _replicaIndex,
                uint64 _size
            ) = _beforeMatchingCompleted(_matchingId);
            bids.winner = winner;

            roles.matchings().__reportMatchingHasWinner(
                _matchingId,
                _datasetId,
                _replicaIndex,
                _size,
                winner
            );
            // Refund bidding escrow for no winner
            // roles.finance().claimEscrow(/// TODO: https://github.com/dataswap/core/issues/245
            //     _datasetId,
            //     _matchingId,
            //     FinanceType.FIL,
            //     FinanceType.Type.EscrowDataTradingFee
            // );
        } else {
            uint64 _size = _afterMatchingFailed(_matchingId);
            roles.matchings().__reportMatchingNoWinner(_matchingId, _size);
        }
    }

    /// @notice Function for getting bids in a matching.
    /// @param _matchingId The matching id to get bids of matching.
    /// @return bidders The addresses of bidders who have placed bids in the current matching.
    /// @return amounts The highest bid placed by any bidder in the current matching.
    /// @return complyFilplusRules Whether the bidders who have placed bids in the current matching comply with Filplus rules.
    /// @return winner The winner of the current matching.
    function getMatchingBids(
        uint64 _matchingId
    )
        public
        view
        returns (
            address[] memory bidders,
            uint256[] memory amounts,
            bool[] memory complyFilplusRules,
            address winner
        )
    {
        MatchingType.MatchingBids storage bids = matchingBids[_matchingId];
        (bidders, amounts, complyFilplusRules) = bids._getMatchingBids();

        return (bidders, amounts, complyFilplusRules, bids.winner);
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
