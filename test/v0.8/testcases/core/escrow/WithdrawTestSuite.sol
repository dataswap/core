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
import {IEscrowAssertion} from "test/v0.8/interfaces/assertions/core/IEscrowAssertion.sol";

import {EscrowTestSuiteBase} from "test/v0.8/testcases/core/escrow/abstract/EscrowTestSuiteBase.sol";

/// @notice Withdraw test case,it should be success
contract WithdrawTestCaseWithSuccess is EscrowTestSuiteBase {
    constructor(
        IDatasets _datasets,
        IEscrow _escrow,
        IEscrowAssertion _assertion
    )
        EscrowTestSuiteBase(_datasets, _escrow, _assertion) // solhint-disable-next-line
    {}

    /// @dev The main action of the test, where the payee deposit funds.
    /// @param _owner The destination address of the funds.
    /// @param _id The business id.
    function action(
        address payable _owner,
        uint64 _id
    ) internal virtual override {
        vm.deal(address(this), 10 ether);
        vm.roll(100);
        escrow.collateral{value: 1}(
            EscrowType.Type.DatacapCollateral,
            _owner,
            _id,
            1
        );

        assertion.getOwnerFundAssertion(
            EscrowType.Type.DatacapCollateral,
            _owner,
            _id,
            1,
            0,
            1,
            0,
            100
        );
        vm.roll(100 + 2880 * 365 + 100);
        escrow.collateralRedeem(EscrowType.Type.DatacapCollateral, _owner, _id);
        assertion.getOwnerFundAssertion(
            EscrowType.Type.DatacapCollateral,
            _owner,
            _id,
            1,
            0,
            0,
            0,
            100
        );
        /// NOTE: filecoin paymentWithdraw does not support testing,following test code is reserved for backup
        // escrow.withdraw(EscrowType.Type.DatacapCollateral, _owner, _id);

        // assertion.getOwnerFundAssertion(
        //     EscrowType.Type.DatacapCollateral,
        //     _owner,
        //     _id,
        //     0,
        //     0,
        //     0,
        //     0,
        //     100 + 2880 * 365 + 100
        // );
    }
}

/// @notice Withdraw test case,it should be fail
contract WithdrawTestCaseWithFail is EscrowTestSuiteBase {
    constructor(
        IDatasets _datasets,
        IEscrow _escrow,
        IEscrowAssertion _assertion
    )
        EscrowTestSuiteBase(_datasets, _escrow, _assertion) // solhint-disable-next-line
    {}

    /// @dev The main action of the test, where the payee deposit funds.
    /// @param _owner The destination address of the funds.
    /// @param _id The business id.
    function action(
        address payable _owner,
        uint64 _id
    ) internal virtual override {
        vm.expectRevert();
        escrow.withdraw(EscrowType.Type.DatacapCollateral, _owner, _id);
    }
}
