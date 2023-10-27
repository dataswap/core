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
import "test/v0.8/testcases/module/storage/SubmitStorageClaimIdTestSuite.sol";
import {StorageTestSetup} from "test/v0.8/uinttests/module/storage/setup/StorageTestSetup.sol";

contract SubmitStorageClaimIdTest is Test, StorageTestSetup {
    /// @notice test case with success
    function testSubmitStorageClaimIdWithSuccess() public {
        setup();
        SubmitStorageClaimIdTestCaseWithSuccess testCase = new SubmitStorageClaimIdTestCaseWithSuccess(
                carstore,
                storages,
                generator,
                helpers,
                assertion,
                filecoin
            );
        testCase.run();
    }

    /// @notice test case with invalid address
    function testSubmitStorageClaimIdWithInvalidAddress() public {
        setup();
        SubmitStorageClaimIdTestCaseWithInvalidAddress testCase = new SubmitStorageClaimIdTestCaseWithInvalidAddress(
                carstore,
                storages,
                generator,
                helpers,
                assertion,
                filecoin
            );
        testCase.run();
    }

    /// @notice test case with invalid cid
    function testSubmitStorageClaimIdWithInvalidCid() public {
        setup();
        SubmitStorageClaimIdTestCaseWithInvalidCid testCase = new SubmitStorageClaimIdTestCaseWithInvalidCid(
                carstore,
                storages,
                generator,
                helpers,
                assertion,
                filecoin
            );
        testCase.run();
    }

    /// @notice test case with duplicate cid
    function testSubmitStorageClaimIdWithDuplicateCid() public {
        setup();
        SubmitStorageClaimIdTestCaseWithDuplicateCid testCase = new SubmitStorageClaimIdTestCaseWithDuplicateCid(
                carstore,
                storages,
                generator,
                helpers,
                assertion,
                filecoin
            );
        testCase.run();
    }
}
