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

import "test/v0.8/testcases/core/carstore/abstract/CarstoreTestSuiteBase.sol";
import {FilecoinType} from "src/v0.8/types/FilecoinType.sol";

import {Errors} from "src/v0.8/shared/errors/Errors.sol";
import {ICarstore} from "src/v0.8/interfaces/core/ICarstore.sol";
import {ICarstoreAssertion} from "test/v0.8/interfaces/assertions/core/ICarstoreAssertion.sol";
import {RolesType} from "src/v0.8/types/RolesType.sol";

/// @notice report car replica matching state test case,it should be success
contract ReportCarReplicaMatchingStateTestCaseWithSuccess is
    ReportCarReplicaMatchingStateTestSuiteBase
{
    constructor(
        ICarstore _carstore,
        ICarstoreAssertion _assertion
    )
        ReportCarReplicaMatchingStateTestSuiteBase(_carstore, _assertion) // solhint-disable-next-line
    {}

    function before(
        bytes32 _hash,
        uint64 _datasetId,
        uint64 _size,
        uint64 _matchingId,
        uint16 _replicaIndex
    ) internal virtual override returns (uint64) {
        address admin = carstore.roles().getRoleMember(bytes32(0x00), 0);
        vm.startPrank(admin);
        carstore.roles().grantRole(RolesType.DATASWAP_CONTRACT, address(this));
        vm.stopPrank();
        vm.assume(_datasetId != 0);
        vm.assume(_size != 0);
        vm.assume(_matchingId != 0);
        uint64 _id = carstore.__addCar(_hash, _datasetId, _size, 10);
        vm.assume(_replicaIndex < 10);
        carstore.__registCarReplica(_id, _matchingId, _replicaIndex);
        return _id;
    }

    function action(
        uint64 _id,
        uint64 _matchingId,
        bool _matchingState
    ) internal virtual override {
        super.action(_id, _matchingId, _matchingState);
    }
}
