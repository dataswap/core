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
import {IRoles} from "src/v0.8/interfaces/core/IRoles.sol";
import {IFilplus} from "src/v0.8/interfaces/core/IFilplus.sol";
import {IFilecoin} from "src/v0.8/interfaces/core/IFilecoin.sol";
import {ICarstore} from "src/v0.8/interfaces/core/ICarstore.sol";
import {IDatasets} from "src/v0.8/interfaces/module/IDatasets.sol";
import {IMatchings} from "src/v0.8/interfaces/module/IMatchings.sol";
///shared
import {DatasetsModifiers} from "src/v0.8/shared/modifiers/DatasetsModifiers.sol";
import {Errors} from "src/v0.8/shared/errors/Errors.sol";
///types
import {MatchingType} from "src/v0.8/types/MatchingType.sol";

/// @title storages
/// @dev Manages the storage of matched data after successful matching with Filecoin storage deals.
contract MatchingsModifiers is DatasetsModifiers {
    IRoles private roles;
    IFilplus private filplus;
    IFilecoin private filecoin;
    ICarstore private carstore;
    IDatasets private datasets;
    IMatchings private matchings;

    // solhint-disable-next-line
    constructor(
        IRoles _roles,
        IFilplus _filplus,
        IFilecoin _filecoin,
        ICarstore _carstore,
        IDatasets _datasets,
        IMatchings _matchings
    ) DatasetsModifiers(_roles, _filplus, _filecoin, _carstore, _datasets) {
        roles = _roles;
        filplus = _filplus;
        carstore = _carstore;
        datasets = _datasets;
        matchings = _matchings;
    }

    /// @notice Modifier to restrict access to the matching initiator
    modifier onlyMatchingContainsCar(uint64 _matchingId, bytes32 _cid) {
        if (!matchings.isMatchingContainsCar(_matchingId, _cid)) {
            revert Errors.ReplicaNotExist(_cid, _matchingId);
        }
        _;
    }

    /// @notice Modifier to restrict access to the matching initiator
    modifier onlyMatchingInitiator(uint64 _matchingId) {
        address initiator = matchings.getMatchingInitiator(_matchingId);
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
    modifier onlyMatchingState(uint64 _matchingId, MatchingType.State _state) {
        MatchingType.State matchingState = matchings.getMatchingState(
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
}
