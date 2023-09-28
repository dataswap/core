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
import {ReportCarReplicaExpiredTestCaseWithSuccess, ReportCarReplicaExpiredTestCaseWithInvalidDealState, ReportCarReplicaExpiredTestCaseWithInvalidId} from "test/v0.8/testcases/core/carstore/ReportCarReplicaExpiredTestSuite.sol";
import {CarstoreTestSetup} from "test/v0.8/uinttests/core/carstore/setup/CarstoreTestSetup.sol";

contract ReportCarReplicaExpiredTest is Test, CarstoreTestSetup {
    /// @notice test case with success
    function testReportCarReplicaExpiredWithSuccess(
        bytes32 _cid,
        uint64 _datasetId,
        uint64 _size,
        uint64 _matchingId,
        uint64 _claimId
    ) public {
        setup();
        ReportCarReplicaExpiredTestCaseWithSuccess testCase = new ReportCarReplicaExpiredTestCaseWithSuccess(
                carstore,
                assertion
            );
        // run testcase
        testCase.run(_cid, _datasetId, _size, _matchingId, _claimId);
    }

    /// @notice test case with invalid deal state
    function testReportCarReplicaExpiredWithInvalidDealState(
        bytes32 _cid,
        uint64 _datasetId,
        uint64 _size,
        uint64 _matchingId,
        uint64 _claimId
    ) public {
        setup();
        ReportCarReplicaExpiredTestCaseWithInvalidDealState testCase = new ReportCarReplicaExpiredTestCaseWithInvalidDealState(
                carstore,
                assertion
            );
        // run testcase
        testCase.run(_cid, _datasetId, _size, _matchingId, _claimId);
    }

    /// @notice test case with invalid id
    function testReportCarReplicaExpiredWithInvalidId(
        bytes32 _cid,
        uint64 _datasetId,
        uint64 _size,
        uint64 _matchingId,
        uint64 _claimId
    ) public {
        setup();
        ReportCarReplicaExpiredTestCaseWithInvalidId testCase = new ReportCarReplicaExpiredTestCaseWithInvalidId(
                carstore,
                assertion
            );
        // run testcase
        testCase.run(_cid, _datasetId, _size, _matchingId, _claimId);
    }
}
