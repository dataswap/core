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
import {SetCarReplicaFilecoinDealIdTestCaseWithSuccess} from "test/v0.8/testcases/core/carstore/SetCarReplicaFilecoinDealIdTestSuite.sol";
import {CarstoreTestSetup} from "test/v0.8/uinttests/core/carstore/setup/CarstoreTestSetup.sol";
import {TestHelpers} from "src/v0.8/shared/utils/common/TestHelpers.sol";
import {FilecoinType} from "src/v0.8/types/FilecoinType.sol";

contract SetCarReplicaFilecoinDealIdTest is Test, CarstoreTestSetup {
    /// @dev test case with success when filecoin deal state is storage success
    function testSetCarReplicaFilecoinDealAndStoredWithSuccess(
        bytes32 _cid,
        uint64 _datasetId,
        uint64 _size,
        uint64 _matchingId,
        uint64 _filecoinDealId
    ) public {
        setup();
        SetCarReplicaFilecoinDealIdTestCaseWithSuccess testCase = new SetCarReplicaFilecoinDealIdTestCaseWithSuccess(
                carstore,
                assertion
            );
        // set filecoin store is ok
        carstore.getFilecoin().setMockDealState(FilecoinType.DealState.Stored);
        // run testcase
        testCase.run(_cid, _datasetId, _size, _matchingId, _filecoinDealId);
    }

    /// @dev test case with success when filecoin deal state is storage failed
    function testSetCarReplicaFilecoinDealAndStorageFailedWithSuccess(
        bytes32 _cid,
        uint64 _datasetId,
        uint64 _size,
        uint64 _matchingId,
        uint64 _filecoinDealId
    ) public {
        setup();
        SetCarReplicaFilecoinDealIdTestCaseWithSuccess testCase = new SetCarReplicaFilecoinDealIdTestCaseWithSuccess(
                carstore,
                assertion
            );
        // set filecoin store is ok
        carstore.getFilecoin().setMockDealState(
            FilecoinType.DealState.StorageFailed
        );
        // run testcase
        testCase.run(_cid, _datasetId, _size, _matchingId, _filecoinDealId);
    }
}