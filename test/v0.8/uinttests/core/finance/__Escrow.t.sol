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
import {FinanceTestSetup} from "test/v0.8/uinttests/core/finance/setup/FinanceTestSetup.sol";

import {__EscrowTestCaseWithSuccess, __EscrowTestCaseWithUnauthorizedFail, __EscrowTestCaseWithInsufficientFundsFail} from "test/v0.8/testcases/core/finance/__EscrowTestSuite.sol";

contract __EscrowTest is Test, FinanceTestSetup {
    /// @notice test case with success
    function test__EscrowTestCaseWithSuccess() public {
        setup();

        __EscrowTestCaseWithSuccess testCase = new __EscrowTestCaseWithSuccess(
            role(),
            assertion 
        );
        testCase.run();
    }

    /// @notice test case with fail
    function test__EscrowTestCaseWithUnauthorizedFail() public {
        setup();
        __EscrowTestCaseWithUnauthorizedFail testCase = new __EscrowTestCaseWithUnauthorizedFail(
            role(),
            assertion 
        );
        testCase.run();
    }

        /// @notice test case with fail
    function test__EscrowTestCaseWithInsufficientFundsFail() public {
        setup();
        __EscrowTestCaseWithInsufficientFundsFail testCase = new __EscrowTestCaseWithInsufficientFundsFail(
            role(),
            assertion 
        );
        testCase.run();
    }
}
