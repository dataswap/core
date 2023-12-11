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
import {IDatasets} from "src/v0.8/interfaces/module/IDatasets.sol";
import {IMatchings} from "src/v0.8/interfaces/module/IMatchings.sol";
import {IMatchingsBids} from "src/v0.8/interfaces/module/IMatchingsBids.sol";
import {IEscrowAssertion} from "test/v0.8/interfaces/assertions/core/IEscrowAssertion.sol";
import {IStoragesHelpers} from "test/v0.8/interfaces/helpers/module/IStoragesHelpers.sol";

import {EscrowTestSuiteBase} from "test/v0.8/testcases/core/escrow/abstract/EscrowTestSuiteBase.sol";

/// @notice PaymentWithdraw test case,it should be success
contract PaymentWithdrawTestCaseWithSuccess is EscrowTestSuiteBase {
    IStoragesHelpers internal storagesHelpers;
    IMatchings matchings;
    IMatchingsBids matchingsBids;

    constructor(
        IDatasets _datasets,
        IEscrow _escrow,
        IEscrowAssertion _assertion,
        IStoragesHelpers _storagesHelpers,
        IMatchings _matchings,
        IMatchingsBids _matchingsBids
    )
        EscrowTestSuiteBase(_datasets, _escrow, _assertion) // solhint-disable-next-line
    {
        storagesHelpers = _storagesHelpers;
        matchings = _matchings;
        matchingsBids = _matchingsBids;
    }

    /// @dev The main action of the test, where the owner payment withdraw funds.
    function action(address payable, uint64) internal virtual override {
        (, uint64 matchingId) = storagesHelpers.setup();

        address owner = matchingsBids.getMatchingWinner(matchingId);
        address beneficiary = matchings.getMatchingInitiator(matchingId);
        address[] memory beneficiaries = new address[](1);
        beneficiaries[0] = beneficiary;

        assertion.getBeneficiaryFundAssertion(
            EscrowType.Type.DataPrepareFeeByProvider,
            owner,
            matchingId,
            beneficiary,
            200,
            200,
            0,
            0,
            201
        );
        assertion.getBeneficiariesListAssertion(
            EscrowType.Type.DataPrepareFeeByProvider,
            owner,
            matchingId,
            beneficiaries
        );

        escrow.__emitPaymentUpdate(
            EscrowType.Type.DataPrepareFeeByProvider,
            owner,
            matchingId,
            beneficiary,
            EscrowType.PaymentEvent.SyncPaymentLock
        );
        /// NOTE: filecoin paymentWithdraw does not support testing,following test code is reserved for backup
        // escrow.paymentWithdraw(
        //     EscrowType.Type.DataPrepareFeeByProvider,
        //     owner,
        //     matchingId,
        //     beneficiary
        // );

        // assertion.getBeneficiaryFundAssertion(
        //     EscrowType.Type.DataPrepareFeeByProvider,
        //     owner,
        //     matchingId,
        //     beneficiary,
        //     0,
        //     0,
        //     0,
        //     0,
        //     100
        // );
    }
}

/// @notice PaymentWithdraw test case,it should be fail
contract PaymentWithdrawTestCaseWithFail is EscrowTestSuiteBase {
    constructor(
        IDatasets _datasets,
        IEscrow _escrow,
        IEscrowAssertion _assertion
    )
        EscrowTestSuiteBase(_datasets, _escrow, _assertion) // solhint-disable-next-line
    {}

    /// @dev The main action of the test, where the owner payment withdraw funds.
    /// @param _owner The destination address of the funds.
    /// @param _id The business id.
    function action(
        address payable _owner,
        uint64 _id
    ) internal virtual override {
        address beneficiary = address(100);
        vm.expectRevert();
        escrow.paymentWithdraw(
            EscrowType.Type.DatasetAuditFee,
            _owner,
            _id,
            beneficiary
        );
    }
}
