/*******************************************************************************
 *   (c) 2023 DataSwap
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

// Import required external contracts and interfaces
import {Test} from "forge-std/Test.sol";
import {MockFilecoin} from "../../../../../../src/v0.8/mocks/core/filecoin/MockFilecoin.sol";
import {FilecoinType} from "../../../../../../src/v0.8/types/FilecoinType.sol";

// Contract definition for test helper functions
contract MockFilecoinTest is Test {
    MockFilecoin public filecoin;

    // Setting up the test environment
    function setUp() public {
        filecoin = new MockFilecoin();
    }

    //test function for setMockDealState
    function testSetMockDealState(
        uint8 _state,
        bytes32 _cid,
        uint64 _filecoinDealId
    ) external {
        vm.assume(_state <= uint8(FilecoinType.DealState.Expired));
        filecoin.setMockDealState(FilecoinType.DealState(_state));
        assertEq(
            _state,
            uint8(filecoin.getReplicaDealState(_cid, _filecoinDealId))
        );
    }
}
