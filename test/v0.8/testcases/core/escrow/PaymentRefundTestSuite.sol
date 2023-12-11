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

import {EscrowType} from "src/v0.8/types/EscrowType.sol";
import {IEscrow} from "src/v0.8/interfaces/core/IEscrow.sol";
import {ICarstore} from "src/v0.8/interfaces/core/ICarstore.sol";
import {IStorages} from "src/v0.8/interfaces/module/IStorages.sol";

import {IFilecoin} from "src/v0.8/interfaces/core/IFilecoin.sol";
import {IDatasets} from "src/v0.8/interfaces/module/IDatasets.sol";
import {IEscrowAssertion} from "test/v0.8/interfaces/assertions/core/IEscrowAssertion.sol";

import {IStoragesHelpers} from "test/v0.8/interfaces/helpers/module/IStoragesHelpers.sol";
import {IMatchingsHelpers} from "test/v0.8/interfaces/helpers/module/IMatchingsHelpers.sol";
import {EscrowTestSuiteBase} from "test/v0.8/testcases/core/escrow/abstract/EscrowTestSuiteBase.sol";

import {CidUtils} from "src/v0.8/shared/utils/cid/CidUtils.sol";

/// @notice PaymentRefund test case,it should be success
contract PaymentRefundTestCaseWithSuccess is EscrowTestSuiteBase {
    ICarstore carstore;
    IStorages internal storages;
    IStoragesHelpers internal storagesHelpers;
    IFilecoin internal filecoin;

    constructor(
        IDatasets _datasets,
        IEscrow _escrow,
        IEscrowAssertion _assertion,
        IStoragesHelpers _storagesHelpers,
        ICarstore _carstore,
        IStorages _storages,
        IFilecoin _filecoin
    )
        EscrowTestSuiteBase(_datasets, _escrow, _assertion) // solhint-disable-next-line
    {
        storagesHelpers = _storagesHelpers;
        carstore = _carstore;
        storages = _storages;
        filecoin = _filecoin;
    }

    /// @dev The main action of the test, where the owner payment funds.
    /// @param _owner The destination address of the funds.
    function action(address payable _owner, uint64) internal virtual override {
        (uint64 datasetId, uint64 matchingId) = storagesHelpers.setup();

        uint64[] memory cars = storages.matchingsTarget().getMatchingCars(
            matchingId
        );

        uint64[] memory claimIds = storagesHelpers.generateFilecoinClaimIds(
            uint64(cars.length)
        );

        for (uint64 i = 0; i < cars.length; i++) {
            bytes memory dataCid = CidUtils.hashToCID(
                carstore.getCarHash(cars[i])
            );
            filecoin.setMockClaimData(claimIds[i], dataCid);
        }
        vm.deal(address(this), 10 ether);
        vm.roll(10);
        escrow.payment{value: 1 ether}(
            EscrowType.Type.DataPrepareFeeByProvider,
            _owner,
            matchingId,
            1000000000000000000
        );
        escrow.payment{value: 1 ether}(
            EscrowType.Type.TotalDataPrepareFeeByClient,
            _owner,
            datasetId,
            1000000000000000000
        );
        assertion.getOwnerFundAssertion(
            EscrowType.Type.DataPrepareFeeByProvider,
            _owner,
            matchingId,
            1000000000000000000,
            1000000000000000000,
            0,
            0,
            10
        );
        assertion.getOwnerFundAssertion(
            EscrowType.Type.TotalDataPrepareFeeByClient,
            _owner,
            datasetId,
            1000000000000000000,
            1000000000000000000,
            0,
            0,
            10
        );

        escrow.__emitPaymentUpdate(
            EscrowType.Type.TotalDataPrepareFeeByClient,
            _owner,
            matchingId,
            storages.matchings().getMatchingInitiator(matchingId),
            EscrowType.PaymentEvent.AddPaymentSubAccount
        );
        (uint256 amount, , , , ) = escrow.getOwnerFund(
            EscrowType.Type.TotalDataPrepareFeeByClient,
            _owner,
            datasetId
        );

        assertion.getOwnerFundAssertion(
            EscrowType.Type.TotalDataPrepareFeeByClient,
            _owner,
            datasetId,
            amount,
            amount,
            0,
            0,
            10
        );
        assertion.getOwnerFundAssertion(
            EscrowType.Type.DataPrepareFeeByClient,
            _owner,
            matchingId,
            1000000000000000000 - amount,
            1000000000000000000 - amount,
            0,
            0,
            10
        );

        vm.roll(100000);
        escrow.paymentRefund(
            EscrowType.Type.DataPrepareFeeByProvider,
            _owner,
            matchingId
        );

        assertion.getOwnerFundAssertion(
            EscrowType.Type.DataPrepareFeeByProvider,
            _owner,
            matchingId,
            1000000000000000000,
            0,
            0,
            0,
            10
        );

        escrow.paymentRefund(
            EscrowType.Type.DataPrepareFeeByClient,
            _owner,
            matchingId
        );

        assertion.getOwnerFundAssertion(
            EscrowType.Type.DataPrepareFeeByClient,
            _owner,
            matchingId,
            1000000000000000000 - amount,
            0,
            0,
            0,
            10
        );
    }
}

/// @notice PaymentRefund test case,it should be fail
contract PaymentRefundTestCaseWithFail is EscrowTestSuiteBase {
    IMatchingsHelpers internal matchingsHelpers;

    constructor(
        IDatasets _datasets,
        IEscrow _escrow,
        IEscrowAssertion _assertion,
        IMatchingsHelpers _matchingsHelpers
    )
        EscrowTestSuiteBase(_datasets, _escrow, _assertion) // solhint-disable-next-line
    {
        matchingsHelpers = _matchingsHelpers;
    }

    /// @dev The main action of the test, where the owner payment funds.
    /// @param _owner The destination address of the funds.
    function action(address payable _owner, uint64) internal virtual override {
        (uint64 datasetId, uint64 matchingId) = matchingsHelpers
            .completeMatchingWorkflow();

        vm.deal(address(this), 10 ether);
        escrow.payment{value: 1}(
            EscrowType.Type.DataPrepareFeeByProvider,
            _owner,
            datasetId,
            1
        );
        escrow.__emitPaymentUpdate(
            EscrowType.Type.TotalDataPrepareFeeByClient,
            _owner,
            matchingId,
            matchingsHelpers.matchings().getMatchingInitiator(matchingId),
            EscrowType.PaymentEvent.AddPaymentSubAccount
        );

        vm.expectRevert();
        escrow.paymentRefund(
            EscrowType.Type.DataPrepareFeeByClient,
            _owner,
            matchingId
        );
    }
}
