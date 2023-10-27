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

///interface
import {IMatchings} from "src/v0.8/interfaces/module/IMatchings.sol";
import {IMatchingsTarget} from "src/v0.8/interfaces/module/IMatchingsTarget.sol";
import {IMatchingsBids} from "src/v0.8/interfaces/module/IMatchingsBids.sol";
///shared
import {CarstoreModifiers} from "src/v0.8/shared/modifiers/CarstoreModifiers.sol";
import {Errors} from "src/v0.8/shared/errors/Errors.sol";
///types
import {MatchingType} from "src/v0.8/types/MatchingType.sol";

/// @title storages
/// @dev Manages the storage of matched data after successful matching with Filecoin storage deals.
contract MatchingsModifiers is CarstoreModifiers {
    /// @notice Modifier to restrict access to the matching initiator
    modifier onlyMatchingInitiator(IMatchings _matchings, uint64 _matchingId) {
        address initiator = _matchings.getMatchingInitiator(_matchingId);
        if (initiator != msg.sender) {
            revert Errors.NotMatchingInitiator(
                _matchingId,
                initiator,
                msg.sender
            );
        }
        _;
    }

    /// @notice Modifier to restrict access based on matching state
    modifier onlyMatchingState(
        IMatchings _matchings,
        uint64 _matchingId,
        MatchingType.State _state
    ) {
        MatchingType.State matchingState = _matchings.getMatchingState(
            _matchingId
        );
        if (matchingState != _state) {
            revert Errors.InvalidMatchingState(
                _matchingId,
                _state,
                matchingState
            );
        }
        _;
    }

    /// @notice Modifier to restrict access to the matching target
    modifier onlyMatchingsTarget(
        IMatchingsTarget _matchingsTarget,
        uint64 _matchingId
    ) {
        if (address(_matchingsTarget) != msg.sender) {
            revert Errors.NotMatchingsTarget(_matchingId, msg.sender);
        }
        _;
    }
    /// @notice Modifier to restrict access to the matching target
    modifier onlyMatchingsBids(
        IMatchingsBids _matchingsBids,
        uint64 _matchingId
    ) {
        if (address(_matchingsBids) != msg.sender) {
            revert Errors.NotMatchingsTarget(_matchingId, msg.sender);
        }
        _;
    }

    /// @notice Modifier to restrict access to the matching initiator
    modifier onlyMatchingContainsCar(
        IMatchingsTarget _matchingsTarget,
        uint64 _matchingId,
        uint64 _id
    ) {
        if (!_matchingsTarget.isMatchingContainsCar(_matchingId, _id)) {
            revert Errors.ReplicaNotExist(_id, _matchingId);
        }
        _;
    }
}
