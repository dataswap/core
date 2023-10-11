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
import "test/v0.8/testcases/core/escrow/WithdrawTestSuite.sol";
import {EscrowTestSetup} from "test/v0.8/uinttests/core/escrow/setup/EscrowTestSetup.sol";

contract WithdrawTest is Test, EscrowTestSetup {
    /// @notice test case with success
    function testWithdrawWithSuccess(
        address payable _owner,
        uint64 _id
    ) public {
        setup();
        WithdrawTestCaseWithSuccess testCase = new WithdrawTestCaseWithSuccess(
            datasets,
            escrow,
            assertion
        );
        testCase.run(_owner, _id);
    }

    /// @notice test case with fail
    function testWithdrawWithFail(address payable _owner, uint64 _id) public {
        setup();
        WithdrawTestCaseWithFail testCase = new WithdrawTestCaseWithFail(
            datasets,
            escrow,
            assertion
        );
        testCase.run(_owner, _id);
    }
}
