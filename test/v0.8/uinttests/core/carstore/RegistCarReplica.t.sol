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
import "test/v0.8/testcases/core/carstore/RegistCarReplicaTestSuite.sol";
import {CarstoreTestSetup} from "test/v0.8/uinttests/core/carstore/setup/CarstoreTestSetup.sol";

contract RegistCarReplicaTest is Test, CarstoreTestSetup {
    /// @notice test case with success
    function testRegistCarReplicaWithSuccess(
        bytes32 _cid,
        uint64 _matchingId,
        uint16 _replicaIndex
    ) public {
        setup();
        RegistCarReplicaTestCaseWithSuccess testCase = new RegistCarReplicaTestCaseWithSuccess(
                carstore,
                assertion
            );
        // run testcase
        testCase.run(_cid, _matchingId, _replicaIndex);
    }

    /// @notice test case with invalid id
    function testRegistCarReplicaWithInvalidId(
        bytes32 _cid,
        uint64 _matchingId,
        uint16 _replicaIndex
    ) public {
        setup();
        RegistCarReplicaTestCaseWithInvalidId testCase = new RegistCarReplicaTestCaseWithInvalidId(
                carstore,
                assertion
            );
        // run testcase
        testCase.run(_cid, _matchingId, _replicaIndex);
    }

    /// @notice test case with car not exsit
    function testRegistCarReplicaWithCarNotExsit(
        bytes32 _cid,
        uint64 _matchingId,
        uint16 _replicaIndex
    ) public {
        setup();
        RegistCarReplicaTestCaseWithCarNotExist testCase = new RegistCarReplicaTestCaseWithCarNotExist(
                carstore,
                assertion
            );
        // run testcase
        testCase.run(_cid, _matchingId, _replicaIndex);
    }

    /// @notice test case with replica alreay exsit
    function testRegistCarReplicaWithReplicaAlreadyExists(
        bytes32 _cid,
        uint64 _matchingId,
        uint16 _replicaIndex
    ) public {
        setup();
        RegistCarReplicaTestCaseWithReplicaAlreadyExists testCase = new RegistCarReplicaTestCaseWithReplicaAlreadyExists(
                carstore,
                assertion
            );
        // run testcase
        testCase.run(_cid, _matchingId, _replicaIndex);
    }
}
