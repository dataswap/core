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

import {ReportCarReplicaExpiredTestSuiteBase} from "test/v0.8/testcases/core/carstore/abstract/CarstoreTestSuiteBase.sol";
import {FilecoinType} from "src/v0.8/types/FilecoinType.sol";

import {Errors} from "src/v0.8/shared/errors/Errors.sol";
import {ICarstore} from "src/v0.8/interfaces/core/ICarstore.sol";
import {ICarstoreAssertion} from "test/v0.8/interfaces/assertions/core/ICarstoreAssertion.sol";

/// @notice report car replica filecoin deal id  expired test case,it should be success
contract ReportCarReplicaExpiredTestCaseWithSuccess is
    ReportCarReplicaExpiredTestSuiteBase
{
    constructor(
        ICarstore _carstore,
        ICarstoreAssertion _assertion
    )
        ReportCarReplicaExpiredTestSuiteBase(_carstore, _assertion) // solhint-disable-next-line
    {}

    function before(
        bytes32 _cid,
        uint64 _datasetId,
        uint64 _size,
        uint64 _matchingId,
        uint64 _filecoinDealId
    ) internal virtual override {
        vm.assume(_datasetId != 0);
        vm.assume(_size != 0);
        vm.assume(_matchingId != 0 && _filecoinDealId != 0);
        carstore.addCar(_cid, _datasetId, _size);
        carstore.addCarReplica(_cid, _matchingId);
        carstore.setCarReplicaFilecoinDealId(
            _cid,
            _matchingId,
            _filecoinDealId
        );
        carstore.filecoin().setMockDealState(FilecoinType.DealState.Expired);
    }
}

/// @notice report car replica filecoin deal id  expired test case,it should be reverted due to invalid state
contract ReportCarReplicaExpiredTestCaseWithInvalidDealState is
    ReportCarReplicaExpiredTestSuiteBase
{
    constructor(
        ICarstore _carstore,
        ICarstoreAssertion _assertion
    )
        ReportCarReplicaExpiredTestSuiteBase(_carstore, _assertion) // solhint-disable-next-line
    {}

    function before(
        bytes32 _cid,
        uint64 _datasetId,
        uint64 _size,
        uint64 _matchingId,
        uint64 _filecoinDealId
    ) internal virtual override {
        vm.assume(_datasetId != 0);
        vm.assume(_size != 0);
        vm.assume(_matchingId != 0 && _filecoinDealId != 0);
        carstore.addCar(_cid, _datasetId, _size);
        carstore.addCarReplica(_cid, _matchingId);
        carstore.setCarReplicaFilecoinDealId(
            _cid,
            _matchingId,
            _filecoinDealId
        );
        carstore.filecoin().setMockDealState(FilecoinType.DealState.Stored);
    }

    function action(
        bytes32 _cid,
        uint64 _matchingId,
        uint64 _filecoinDealId
    ) internal virtual override {
        vm.expectRevert(
            abi.encodeWithSelector(
                Errors.InvalidReplicaFilecoinDealState.selector,
                _cid,
                _filecoinDealId
            )
        );
        super.action(_cid, _matchingId, _filecoinDealId);
    }
}

/// @notice report car replica filecoin deal id  expired test case,it should be reverted due to invalid id
contract ReportCarReplicaExpiredTestCaseWithInvalidId is
    ReportCarReplicaExpiredTestSuiteBase
{
    constructor(
        ICarstore _carstore,
        ICarstoreAssertion _assertion
    )
        ReportCarReplicaExpiredTestSuiteBase(_carstore, _assertion) // solhint-disable-next-line
    {}

    function before(
        bytes32 /*_cid*/,
        uint64 _datasetId,
        uint64 _size,
        uint64 _matchingId,
        uint64 _filecoinDealId
    ) internal virtual override {
        vm.assume(_datasetId != 0);
        vm.assume(_size != 0);
        vm.assume(_matchingId == 0 || _filecoinDealId == 0);
    }

    function action(
        bytes32 _cid,
        uint64 _matchingId,
        uint64 _filecoinDealId
    ) internal virtual override {
        vm.expectRevert();
        super.action(_cid, _matchingId, _filecoinDealId);
    }
}
