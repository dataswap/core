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

import {Test} from "forge-std/Test.sol";
import {FilecoinType} from "src/v0.8/types/FilecoinType.sol";

import {MockFilecoinSetup} from "test/v0.8/uinttests/mocks/core/filecoin/setup/MockFilecoinSetup.sol";
import {SetMockFilecoinDealStateTestCaseWithSuccess} from "test/v0.8/testcases/mocks/core/filecoin/SetMockFilecoinDealStateTestSuite.sol";

contract MockFilecoinTest is Test, MockFilecoinSetup {
    /// @notice test case with success
    function testMockFilecoinTestCaseWithSuccess(
        bytes32 _cid,
        uint64 _filecoinDealId,
        uint8 _state
    ) public {
        setup();
        vm.assume(_state <= uint8(FilecoinType.DealState.Expired));
        SetMockFilecoinDealStateTestCaseWithSuccess testCase = new SetMockFilecoinDealStateTestCaseWithSuccess(
                assertion
            );
        testCase.run(_cid, _filecoinDealId, FilecoinType.DealState(_state));
    }
}
