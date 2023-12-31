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

import {AddCarTestSuiteBase} from "test/v0.8/testcases/core/carstore/abstract/CarstoreTestSuiteBase.sol";

import {ICarstore} from "src/v0.8/interfaces/core/ICarstore.sol";
import {ICarstoreAssertion} from "test/v0.8/interfaces/assertions/core/ICarstoreAssertion.sol";
import {RolesType} from "src/v0.8/types/RolesType.sol";

import {Errors} from "src/v0.8/shared/errors/Errors.sol";

/// @notice add car test case,it should be success
contract AddCarTestCaseWithSuccess is AddCarTestSuiteBase {
    constructor(
        ICarstore _carstore,
        ICarstoreAssertion _assertion
    )
        AddCarTestSuiteBase(_carstore, _assertion) // solhint-disable-next-line
    {}

    function before(
        bytes32 /*_cid*/,
        uint64 _datasetId,
        uint64 _size,
        uint16 _replicaCount
    ) internal virtual override {
        address admin = carstore.roles().getRoleMember(bytes32(0x00), 0);
        vm.startPrank(admin);
        carstore.roles().grantRole(RolesType.DATASWAP_CONTRACT, address(this));
        vm.stopPrank();
        vm.assume(_datasetId != 0);
        vm.assume(_size != 0);
        vm.assume(_replicaCount > 0 && _replicaCount < 5);
    }
}

/// @notice add car test case with invalid id,it should be capture revert
contract AddCarTestCaseWithInvalidId is AddCarTestSuiteBase {
    constructor(
        ICarstore _carstore,
        ICarstoreAssertion _assertion
    )
        AddCarTestSuiteBase(_carstore, _assertion) // solhint-disable-next-line
    {}

    function before(
        bytes32 /*_cid*/,
        uint64 _datasetId,
        uint64 _size,
        uint16 _replicaCount
    ) internal virtual override {
        address admin = carstore.roles().getRoleMember(bytes32(0x00), 0);
        vm.startPrank(admin);
        carstore.roles().grantRole(RolesType.DATASWAP_CONTRACT, address(this));
        vm.stopPrank();
        vm.assume(_datasetId == 0 || _size == 0);
        vm.assume(_replicaCount > 0 && _replicaCount < 5);
    }

    function action(
        bytes32 _cid,
        uint64 _datasetId,
        uint64 _size,
        uint16 _replicaCount
    ) internal virtual override {
        vm.expectRevert(bytes("Value must not be zero"));
        super.action(_cid, _datasetId, _size, _replicaCount);
    }
}

/// @notice add car test case with car alreay exsit,it should be capture revert
contract AddCarTestCaseWithCarAlreayExsit is AddCarTestSuiteBase {
    constructor(
        ICarstore _carstore,
        ICarstoreAssertion _assertion
    )
        AddCarTestSuiteBase(_carstore, _assertion) // solhint-disable-next-line
    {}

    function before(
        bytes32 _cid,
        uint64 _datasetId,
        uint64 _size,
        uint16 _replicaCount
    ) internal virtual override {
        address admin = carstore.roles().getRoleMember(bytes32(0x00), 0);
        vm.startPrank(admin);
        carstore.roles().grantRole(RolesType.DATASWAP_CONTRACT, address(this));
        vm.stopPrank();
        vm.assume(_cid[0] != 0);
        vm.assume(_datasetId != 0 && _size != 0);
        vm.assume(_replicaCount > 0 && _replicaCount < 5);
        carstore.__addCar(_cid, _datasetId, _size, _replicaCount);
    }

    function action(
        bytes32 _cid,
        uint64 _datasetId,
        uint64 _size,
        uint16 _replicaCount
    ) internal virtual override {
        uint64 id = carstore.getCarId(_cid);
        vm.expectRevert(
            abi.encodeWithSelector(Errors.CarAlreadyExists.selector, id, _cid)
        );
        super.action(_cid, _datasetId, _size, _replicaCount);
    }
}
