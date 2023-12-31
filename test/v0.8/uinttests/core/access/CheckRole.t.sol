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
import "test/v0.8/testcases/core/access/CheckRoleTestSuite.sol";
import {AccessTestSetup} from "test/v0.8/uinttests/core/access/setup/AccessTestSetup.sol";

contract CheckRoleTest is Test, AccessTestSetup {
    /// @notice test case with success
    function testCheckRoleWithSuccess() public {
        setup();
        CheckRoleTestCaseWithSuccess testCase = new CheckRoleTestCaseWithSuccess(
                roles,
                assertion
            );
        // run testcase
        testCase.run();
    }

    /// @notice test case with unauthorized fail
    function testCheckRoleWithUnauthorizedFail() public {
        setup();
        CheckRoleTestCaseWithUnauthorizedFail testCase = new CheckRoleTestCaseWithUnauthorizedFail(
                roles,
                assertion
            );
        // run testcase
        testCase.run();
    }
}
