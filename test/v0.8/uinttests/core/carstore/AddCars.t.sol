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
import {AddCarsTestCaseWithSuccess, AddCarsTestCaseWithInvalidPrams} from "test/v0.8/testcases/core/carstore/AddCarsTestSuite.sol";
import {CarstoreTestSetup} from "test/v0.8/uinttests/core/carstore/setup/CarstoreTestSetup.sol";
import {CommonHelpers} from "test/v0.8/helpers/utils/CommonHelpers.sol";

contract AddCarsTest is Test, CarstoreTestSetup {
    /// @notice test case with success
    function testAddCarsWithSuccess(
        uint64 _datasetId,
        uint16 _replicaCount
    ) public {
        setup();
        AddCarsTestCaseWithSuccess testCase = new AddCarsTestCaseWithSuccess(
            carstore(),
            assertion
        );
        // make sure the cids is different
        uint64 carsCount = 100;
        bytes32[] memory cids = new bytes32[](carsCount);
        uint64[] memory sizes = new uint64[](carsCount);
        for (uint64 i = 0; i < carsCount; i++) {
            sizes[i] = i + 1;
            cids[i] = CommonHelpers.convertUint64ToBytes32(i);
        }
        // run testcase
        testCase.run(cids, _datasetId, sizes, _replicaCount);
    }

    /// @notice test case with invalid params
    function testAddCarsWithInvalidParams(
        bytes32[] memory _cids,
        uint64 _datasetId,
        uint64[] memory _sizes,
        uint16 _replicaCount
    ) public {
        setup();
        AddCarsTestCaseWithInvalidPrams testCase = new AddCarsTestCaseWithInvalidPrams(
                carstore(),
                assertion
            );
        // run testcase
        testCase.run(_cids, _datasetId, _sizes, _replicaCount);
    }
}
