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

// assert carstore action
// NOTE: view asserton functions must all be tested by the functions that will change state
contract FilecoinAssertion is DSTest, Test {
    IFilecoin public filecoin;
    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    constructor(IFilecoin _filecoin) {
        filecoin = _filecoin;
    }

    /// @dev get mock filecin deal state assertion
    function getReplicaDealStateAssertion(
        bytes32 _cid,
        uint64 _filecoinDealId,
        FilecoinType.DealState _state
    ) public {
        assertEq(
            uint8(filecoin.getReplicaDealState(_cid, _filecoinDealId)),
            uint8(_state)
        );
    }

    /// @dev set mock filecin deal state assertion
    function setMockDealStateAssertion(
        bytes32 _cid,
        uint64 _filecoinDealId,
        FilecoinType.DealState _state
    ) external {
        //action
        filecoin.setMockDealState(_state);

        //before action
        getReplicaDealStateAssertion(_cid, _filecoinDealId, _state);
    }
}
