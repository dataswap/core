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

import {RolesType} from "src/v0.8/types/RolesType.sol";
import {FinanceType} from "src/v0.8/types/FinanceType.sol";
import {CommonBase} from "test/v0.8/testcases/core/finance/abstract/FinanceTestSuiteBase.sol";

import {IRoles} from "src/v0.8/interfaces/core/IRoles.sol";
import {IFinanceAssertion} from "test/v0.8/interfaces/assertions/core/IFinanceAssertion.sol";

/// @notice __escrow test case with success
contract __EscrowTestCaseWithSuccess is CommonBase {
    constructor(
        IRoles _roles,
        IFinanceAssertion _assertion
    )
        CommonBase(_roles, _assertion) // solhint-disable-next-line
    {}

    function before() internal virtual override {
        vm.deal(address(this), 200 ether);
        assertion.depositAssertion{value: 200 ether}(
            1,
            1,
            address(this),
            FinanceType.FIL
        );

        address admin = roles.getRoleMember(bytes32(0x00), 0);
        vm.startPrank(admin);
        roles.grantRole(RolesType.DATASWAP_CONTRACT, address(assertion));
        vm.stopPrank();
    }

    function action() internal virtual override {
        assertion.__escrowAssertion(
            1,
            1,
            address(this),
            FinanceType.FIL,
            FinanceType.Type.EscrowDataTradingFee,
            100
        );
    }
}

/// @notice __escrow test case with unauthorized fail
contract __EscrowTestCaseWithUnauthorizedFail is CommonBase {
    constructor(
        IRoles _roles,
        IFinanceAssertion _assertion
    )
        CommonBase(_roles, _assertion) // solhint-disable-next-line
    {}

    function before() internal virtual override {
        vm.deal(address(this), 200 ether);
        assertion.depositAssertion{value: 200 ether}(
            1,
            1,
            address(this),
            FinanceType.FIL
        );
    }

    function action() internal virtual override {
        vm.expectRevert();
        assertion.__escrowAssertion(
            1,
            1,
            address(this),
            FinanceType.FIL,
            FinanceType.Type.EscrowDataTradingFee,
            100
        );
    }
}

/// @notice __escrow test case with Insufficient funds fail
contract __EscrowTestCaseWithInsufficientFundsFail is CommonBase {
    constructor(
        IRoles _roles,
        IFinanceAssertion _assertion
    )
        CommonBase(_roles, _assertion) // solhint-disable-next-line
    {}

    function before() internal virtual override {
        address admin = roles.getRoleMember(bytes32(0x00), 0);
        vm.startPrank(admin);
        roles.grantRole(RolesType.DATASWAP_CONTRACT, address(assertion));
        vm.stopPrank();
    }

    function action() internal virtual override {
        vm.expectRevert();
        assertion.__escrowAssertion(
            1,
            1,
            address(this),
            FinanceType.FIL,
            FinanceType.Type.EscrowDataTradingFee,
            100
        );
    }
}
