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
import "test/v0.8/testcases/core/access/TransferOwnershipTestSuite.sol";
import {AccessTestSetup} from "test/v0.8/uinttests/core/access/setup/AccessTestSetup.sol";

contract TransferOwnershipTest is Test, AccessTestSetup {
    /// @notice test case with success
    function testTransferOwnershipWithSuccess(address _account) public {
        setup();
        TransferOwnershipTestCaseWithSuccess testCase = new TransferOwnershipTestCaseWithSuccess(
                roles,
                assertion
            );
        // run testcase
        testCase.run(_account);
    }

    /// @notice test case with unauthorized fail
    function testTransferOwnershipWithUnauthorizedFail(
        address _account
    ) public {
        setup();
        TransferOwnershipTestCaseWithUnauthorizedFail testCase = new TransferOwnershipTestCaseWithUnauthorizedFail(
                roles,
                assertion
            );
        // run testcase
        testCase.run(_account);
    }
}
