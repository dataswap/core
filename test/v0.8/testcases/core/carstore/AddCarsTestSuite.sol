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

import {AddCarsTestSuiteBase} from "test/v0.8/testcases/core/carstore/abstract/CarstoreTestSuiteBase.sol";

import {ICarstore} from "src/v0.8/interfaces/core/ICarstore.sol";
import {ICarstoreAssertion} from "test/v0.8/interfaces/assertions/core/ICarstoreAssertion.sol";
import {RolesType} from "src/v0.8/types/RolesType.sol";

/// @notice add cars test case,it should be success
contract AddCarsTestCaseWithSuccess is AddCarsTestSuiteBase {
    constructor(
        ICarstore _carstore,
        ICarstoreAssertion _assertion
    )
        AddCarsTestSuiteBase(_carstore, _assertion) // solhint-disable-next-line
    {}

    function before(
        bytes32[] memory _cids,
        uint64 _datasetId,
        uint64[] memory _sizes,
        uint16 _replicaCount
    ) internal virtual override {
        address admin = carstore.roles().getRoleMember(bytes32(0x00), 0);
        vm.startPrank(admin);
        carstore.roles().grantRole(RolesType.DATASWAP_CONTRACT, address(this));
        vm.stopPrank();
        vm.assume(_datasetId != 0);
        vm.assume(_cids.length == _sizes.length);
        vm.assume(_replicaCount > 0 && _replicaCount < 5);
        for (uint64 i = 0; i < _sizes.length; i++) {
            vm.assume(_sizes[i] != 0);
        }
    }
}

/// @notice add cars test case with invalid prams,it should can capture revert
contract AddCarsTestCaseWithInvalidPrams is AddCarsTestSuiteBase {
    constructor(
        ICarstore _carstore,
        ICarstoreAssertion _assertion
    )
        AddCarsTestSuiteBase(_carstore, _assertion) // solhint-disable-next-line
    {}

    function before(
        bytes32[] memory _cids,
        uint64 _datasetId,
        uint64[] memory _sizes,
        uint16 _replicaCount
    ) internal virtual override {
        address admin = carstore.roles().getRoleMember(bytes32(0x00), 0);
        vm.startPrank(admin);
        carstore.roles().grantRole(RolesType.DATASWAP_CONTRACT, address(this));
        vm.stopPrank();
        vm.assume(_datasetId != 0 && _cids.length != _sizes.length);
        vm.assume(_replicaCount > 0 && _replicaCount < 5);
    }

    function action(
        bytes32[] memory _cids,
        uint64 _datasetId,
        uint64[] memory _sizes,
        uint16 _replicaCount
    ) internal virtual override {
        vm.expectRevert(bytes("Invalid params"));
        super.action(_cids, _datasetId, _sizes, _replicaCount);
    }
}
