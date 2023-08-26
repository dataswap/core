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
import {AddCarTestCaseWithSuccess, AddCarTestCaseWithInvalidId, AddCarTestCaseWithCarAlreayExsit} from "test/v0.8/testcases/core/carstore/AddCarTestSuite.sol";
import {CarstoreTestSetup} from "test/v0.8/uinttests/core/carstore/setup/CarstoreTestSetup.sol";

contract AddCarTest is Test, CarstoreTestSetup {
    /// @dev test case with success
    function testAddCarWithSuccess(
        bytes32 _cid,
        uint64 _datasetId,
        uint64 _size
    ) public {
        setup();
        AddCarTestCaseWithSuccess testCase = new AddCarTestCaseWithSuccess(
            carstore,
            assertion
        );
        testCase.run(_cid, _datasetId, _size);
    }

    /// @dev test case with invalid id
    function testAdWithdCarInvalidId(
        bytes32 _cid,
        uint64 _datasetId,
        uint64 _size
    ) public {
        setup();
        AddCarTestCaseWithInvalidId testCase = new AddCarTestCaseWithInvalidId(
            carstore,
            assertion
        );
        testCase.run(_cid, _datasetId, _size);
    }

    /// @dev test case with car already exsit
    function testAddCarWithrCarAlreadyExsit(
        bytes32 _cid,
        uint64 _datasetId,
        uint64 _size
    ) public {
        setup();
        AddCarTestCaseWithCarAlreayExsit testCase = new AddCarTestCaseWithCarAlreayExsit(
                carstore,
                assertion
            );
        testCase.run(_cid, _datasetId, _size);
    }
}
