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
import {DatacapTestSetup} from "test/v0.8/uinttests/module/storage/setup/DatacapTestSetup.sol";
import "test/v0.8/testcases/module/storage/RequestAllocateTestSuite.sol";

contract RequestAllocateDatacapTest is Test, DatacapTestSetup {
    /// @dev test case with success
    function testRequestAllocateDatacapWithSuccess() public {
        setup();
        RequestAllocateTestCaseWithSuccess testCase = new RequestAllocateTestCaseWithSuccess(
                storages,
                helpers,
                assertion
            );
        testCase.run();
    }

    /// @dev test case with invalid matching id
    function testRequestAllocateTestSuiteWithInvalidMatchingId() public {
        setup();
        RequestAllocateTestSuiteWithInvalidMatchingId testCase = new RequestAllocateTestSuiteWithInvalidMatchingId(
                storages,
                helpers,
                assertion
            );
        testCase.run();
    }

    /// @dev test case with invalid caller
    function testRequestAllocateTestSuiteWithInvalidCaller() public {
        setup();
        RequestAllocateTestSuiteWithInvalidCaller testCase = new RequestAllocateTestSuiteWithInvalidCaller(
                storages,
                helpers,
                assertion
            );
        testCase.run();
    }

    /// @dev test case with invalid next request
    function testRequestAllocateTestSuiteWithInvalidNextRequest() public {
        setup();
        RequestAllocateTestSuiteWithInvalidNextRequest testCase = new RequestAllocateTestSuiteWithInvalidNextRequest(
                storages,
                helpers,
                assertion
            );
        testCase.run();
    }
}
