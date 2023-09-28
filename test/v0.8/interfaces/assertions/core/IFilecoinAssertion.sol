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

import {FilecoinType} from "src/v0.8/types/FilecoinType.sol";

// Interface for asserting Filecoin actions
/// @dev All methods that do not change the state must be tested by methods that will change the state to ensure test coverage.
interface IFilecoinAssertion {
    /// @notice Asserts the mock Filecoin deal state for a replica.
    /// @param _cid The CID (Content Identifier) of the replica.
    /// @param _claimId The ID of the Filecoin storage deal.
    /// @param _expectState The expected state of the Filecoin storage deal.
    function getReplicaDealStateAssertion(
        bytes32 _cid,
        uint64 _claimId,
        FilecoinType.DealState _expectState
    ) external;

    /// @dev This function does nothing and is for testing purposes only.
    /// @param _cid The CID of the replica.
    /// @param _claimId The ID of the Filecoin storage deal.
    /// @param _state The state to set for mock purposes.
    function setMockDealStateAssertion(
        bytes32 _cid,
        uint64 _claimId,
        FilecoinType.DealState _state
    ) external;
}
