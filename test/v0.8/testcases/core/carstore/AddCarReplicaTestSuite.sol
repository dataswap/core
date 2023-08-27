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

import {AddCarReplicaTestSuiteBase} from "test/v0.8/testcases/core/carstore/abstract/CarstoreTestSuiteBase.sol";
import {FilecoinType} from "src/v0.8/types/FilecoinType.sol";

import {ICarstore} from "src/v0.8/interfaces/core/ICarstore.sol";
import {ICarstoreAssertion} from "test/v0.8/interfaces/assertions/core/ICarstoreAssertion.sol";
import {Errors} from "src/v0.8/shared/errors/Errors.sol";

/// @dev set car replica filecoin deal id test case,it should be success
contract AddCarReplicaTestCaseWithSuccess is AddCarReplicaTestSuiteBase {
    constructor(
        ICarstore _carstore,
        ICarstoreAssertion _assertion
    )
        AddCarReplicaTestSuiteBase(_carstore, _assertion) // solhint-disable-next-line
    {}

    function before(
        bytes32 _cid,
        uint64 _matchingId
    ) internal virtual override {
        vm.assume(_matchingId != 0);
        carstore.addCar(_cid, 1, 32 * 1024 * 1024 * 1024);
    }
}

contract AddCarReplicaTestCaseWithInvalidId is AddCarReplicaTestSuiteBase {
    constructor(
        ICarstore _carstore,
        ICarstoreAssertion _assertion
    )
        AddCarReplicaTestSuiteBase(_carstore, _assertion) // solhint-disable-next-line
    {}

    function before(
        bytes32 _cid,
        uint64 _matchingId
    ) internal virtual override {
        vm.assume(_matchingId == 0);
        carstore.addCar(_cid, 1, 32 * 1024 * 1024 * 1024);
    }

    function action(
        bytes32 _cid,
        uint64 _matchingId
    ) internal virtual override {
        vm.expectRevert();
        super.action(_cid, _matchingId);
    }
}

contract AddCarReplicaTestCaseWithCarNotExist is AddCarReplicaTestSuiteBase {
    constructor(
        ICarstore _carstore,
        ICarstoreAssertion _assertion
    )
        AddCarReplicaTestSuiteBase(_carstore, _assertion) // solhint-disable-next-line
    {}

    function before(
        bytes32 /*_cid*/,
        uint64 _matchingId
    ) internal virtual override {
        vm.assume(_matchingId != 0);
    }

    function action(
        bytes32 _cid,
        uint64 _matchingId
    ) internal virtual override {
        vm.expectRevert(
            abi.encodeWithSelector(Errors.CarNotExist.selector, _cid)
        );
        super.action(_cid, _matchingId);
    }
}

contract AddCarReplicaTestCaseWithReplicaAlreadyExists is
    AddCarReplicaTestSuiteBase
{
    constructor(
        ICarstore _carstore,
        ICarstoreAssertion _assertion
    )
        AddCarReplicaTestSuiteBase(_carstore, _assertion) // solhint-disable-next-line
    {}

    function before(
        bytes32 _cid,
        uint64 _matchingId
    ) internal virtual override {
        vm.assume(_matchingId != 0);
        carstore.addCar(_cid, 1, 32 * 1024 * 1024 * 1024);
        carstore.addCarReplica(_cid, _matchingId);
    }

    function action(
        bytes32 _cid,
        uint64 _matchingId
    ) internal virtual override {
        vm.expectRevert(
            abi.encodeWithSelector(
                Errors.ReplicaAlreadyExists.selector,
                _cid,
                _matchingId
            )
        );
        super.action(_cid, _matchingId);
    }
}
