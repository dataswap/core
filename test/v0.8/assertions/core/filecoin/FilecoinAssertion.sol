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

import {DSTest} from "ds-test/test.sol";
import {Test} from "forge-std/Test.sol";
import {IFilecoin} from "src/v0.8/interfaces/core/IFilecoin.sol";
import {FilecoinType} from "src/v0.8/types/FilecoinType.sol";
import {IFilecoinAssertion} from "test/v0.8/interfaces/assertions/core/IFilecoinAssertion.sol";

/// @title FilecoinAssertion
/// @notice This contract provides assertion methods for Filecoin operations.
/// @dev All methods that do not change the state must be tested by methods that will change the state to ensure test coverage.
contract FilecoinAssertion is DSTest, Test, IFilecoinAssertion {
    IFilecoin public filecoin;
    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    constructor(IFilecoin _filecoin) {
        filecoin = _filecoin;
    }

    /// @notice Assertion function to get the mock Filecoin deal state for a given CID and Filecoin deal ID.
    /// @param _cid The CID (Content Identifier) of the data.
    /// @param _filecoinDealId The ID of the Filecoin deal.
    /// @param _state The expected Filecoin deal state to compare with.
    function getReplicaDealStateAssertion(
        bytes32 _cid,
        uint64 _filecoinDealId,
        FilecoinType.DealState _state
    ) public {
        // Ensure that the returned Filecoin deal state matches the expected state.
        assertEq(
            uint8(filecoin.getReplicaDealState(_cid, _filecoinDealId)),
            uint8(_state)
        );
    }

    /// @notice Assertion function to set the mock Filecoin deal state for a given CID and Filecoin deal ID.
    /// @param _cid The CID (Content Identifier) of the data.
    /// @param _filecoinDealId The ID of the Filecoin deal.
    /// @param _state The new Filecoin deal state to set.
    function setMockDealStateAssertion(
        bytes32 _cid,
        uint64 _filecoinDealId,
        FilecoinType.DealState _state
    ) external {
        // Perform the action: set the mock Filecoin deal state.
        filecoin.setMockDealState(_state);

        // Before and after the action, verify that the deal state is as expected.
        getReplicaDealStateAssertion(_cid, _filecoinDealId, _state);
    }
}
