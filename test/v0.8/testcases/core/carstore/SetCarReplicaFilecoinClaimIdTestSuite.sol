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

import {Errors} from "src/v0.8/shared/errors/Errors.sol";
import {SetCarReplicaFilecoinClaimIdAssertionTestSuiteBase} from "test/v0.8/testcases/core/carstore/abstract/CarstoreTestSuiteBase.sol";

import {ICarstore} from "src/v0.8/interfaces/core/ICarstore.sol";
import {ICarstoreAssertion} from "test/v0.8/interfaces/assertions/core/ICarstoreAssertion.sol";
import {RolesType} from "src/v0.8/types/RolesType.sol";

/// @notice set car replica filecoin claim id test case,it should be success
contract SetCarReplicaFilecoinClaimIdTestCaseWithSuccess is
    SetCarReplicaFilecoinClaimIdAssertionTestSuiteBase
{
    constructor(
        ICarstore _carstore,
        ICarstoreAssertion _assertion
    )
        SetCarReplicaFilecoinClaimIdAssertionTestSuiteBase(
            _carstore,
            _assertion
        ) // solhint-disable-next-line
    {}

    function before(
        bytes32 _hash,
        uint64 _datasetId,
        uint64 _size,
        uint64 _matchingId,
        uint64 _claimId
    ) internal virtual override returns (uint64) {
        address admin = carstore.roles().getRoleMember(bytes32(0x00), 0);
        vm.startPrank(admin);
        carstore.roles().grantRole(RolesType.DATASWAP_CONTRACT, address(this));
        vm.stopPrank();
        vm.assume(_datasetId != 0);
        vm.assume(_size != 0);
        vm.assume(_matchingId != 0 && _claimId != 0);
        uint64 _id = carstore.__addCar(_hash, _datasetId, _size, 3);
        carstore.__registCarReplica(_id, _matchingId, 0);
        carstore.__reportCarReplicaMatchingState(_id, _matchingId, true);
        return _id;
    }
}

/// @notice set car replica filecoin claim id test case,it should be reverted due to invalid id.
contract SetCarReplicaFilecoinClaimIdTestCaseWithInvalidId is
    SetCarReplicaFilecoinClaimIdAssertionTestSuiteBase
{
    constructor(
        ICarstore _carstore,
        ICarstoreAssertion _assertion
    )
        SetCarReplicaFilecoinClaimIdAssertionTestSuiteBase(
            _carstore,
            _assertion
        ) // solhint-disable-next-line
    {}

    function before(
        bytes32 _hash,
        uint64 _datasetId,
        uint64 _size,
        uint64 _matchingId,
        uint64 _claimId
    ) internal virtual override returns (uint64) {
        address admin = carstore.roles().getRoleMember(bytes32(0x00), 0);
        vm.startPrank(admin);
        carstore.roles().grantRole(RolesType.DATASWAP_CONTRACT, address(this));
        vm.stopPrank();
        vm.assume(_datasetId != 0);
        vm.assume(_size != 0);
        vm.assume(_matchingId != 0 && _claimId == 0);
        uint64 _id = carstore.__addCar(_hash, _datasetId, _size, 3);
        vm.startPrank(address(0));
        carstore.__registCarReplica(_id, _matchingId, 0);
        carstore.__reportCarReplicaMatchingState(_id, _matchingId, true);
        vm.stopPrank();
        return _id;
    }

    function action(
        uint64 _id,
        uint64 _matchingId,
        uint64 _claimId
    ) internal virtual override {
        vm.expectRevert();
        super.action(_id, _matchingId, _claimId);
    }
}

/// @notice set car replica filecoin claim id test case,it should be reverted due to replica not exsit.
contract SetCarReplicaFilecoinClaimIdTestCaseWithReplicaNotExist is
    SetCarReplicaFilecoinClaimIdAssertionTestSuiteBase
{
    constructor(
        ICarstore _carstore,
        ICarstoreAssertion _assertion
    )
        SetCarReplicaFilecoinClaimIdAssertionTestSuiteBase(
            _carstore,
            _assertion
        ) // solhint-disable-next-line
    {}

    function before(
        bytes32 _hash,
        uint64 _datasetId,
        uint64 _size,
        uint64 _matchingId,
        uint64 _claimId
    ) internal virtual override returns (uint64) {
        address admin = carstore.roles().getRoleMember(bytes32(0x00), 0);
        vm.startPrank(admin);
        carstore.roles().grantRole(RolesType.DATASWAP_CONTRACT, address(this));
        vm.stopPrank();
        vm.assume(_datasetId != 0);
        vm.assume(_size != 0);
        vm.assume(_matchingId != 0 && _claimId != 0);
        uint64 _id = carstore.__addCar(_hash, _datasetId, _size, 3);
        return _id;
    }

    function action(
        uint64 _id,
        uint64 _matchingId,
        uint64 _claimId
    ) internal virtual override {
        vm.expectRevert(
            abi.encodeWithSelector(
                Errors.ReplicaNotExist.selector,
                _id,
                _matchingId
            )
        );
        super.action(_id, _matchingId, _claimId);
    }
}

/// @notice set car replica filecoin claim id test case,it should be reverted due to claim id already exsit.
contract SetCarReplicaFilecoinClaimIdTestCaseWithReplicaFilecoinClaimIdExists is
    SetCarReplicaFilecoinClaimIdAssertionTestSuiteBase
{
    constructor(
        ICarstore _carstore,
        ICarstoreAssertion _assertion
    )
        SetCarReplicaFilecoinClaimIdAssertionTestSuiteBase(
            _carstore,
            _assertion
        ) // solhint-disable-next-line
    {}

    function before(
        bytes32 _hash,
        uint64 _datasetId,
        uint64 _size,
        uint64 _matchingId,
        uint64 _claimId
    ) internal virtual override returns (uint64) {
        address admin = carstore.roles().getRoleMember(bytes32(0x00), 0);
        vm.startPrank(admin);
        carstore.roles().grantRole(RolesType.DATASWAP_CONTRACT, address(this));
        vm.stopPrank();
        vm.assume(_datasetId != 0);
        vm.assume(_size != 0);
        vm.assume(_matchingId != 0 && _claimId != 0);
        uint64 _id = carstore.__addCar(_hash, _datasetId, _size, 3);
        carstore.__registCarReplica(_id, _matchingId, 0);
        carstore.__reportCarReplicaMatchingState(_id, _matchingId, true);
        carstore.__setCarReplicaFilecoinClaimId(_id, _matchingId, _claimId);
        return _id;
    }

    function action(
        uint64 _id,
        uint64 _matchingId,
        uint64 _claimId
    ) internal virtual override {
        vm.expectRevert(
            abi.encodeWithSelector(
                Errors.ReplicaFilecoinClaimIdExists.selector,
                _id,
                _matchingId
            )
        );
        super.action(_id, _matchingId, _claimId);
    }
}
