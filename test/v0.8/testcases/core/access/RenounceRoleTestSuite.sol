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

import {RoleManageBase} from "test/v0.8/testcases/core/access/abstract/AccessTestSuiteBase.sol";
import {IRoles} from "src/v0.8/interfaces/core/IRoles.sol";
import {IRolesAssertion} from "test/v0.8/interfaces/assertions/core/IRolesAssertion.sol";

/// @notice renounce role test case with success
contract RenounceRoleTestCaseWithSuccess is RoleManageBase {
    constructor(
        IRoles _roles,
        IRolesAssertion _assertion
    )
        RoleManageBase(_roles, _assertion) // solhint-disable-next-line
    {}

    function before(bytes32 _role, address _account) internal virtual override {
        address admin = roles.getRoleMember(bytes32(0x00), 0);
        vm.prank(admin);
        roles.grantRole(_role, _account);
    }

    function action(bytes32 _role, address _account) internal virtual override {
        assertion.renounceRoleAssertion(_account, _role, _account);
    }
}

/// @notice renounce role test case with unauthorized fail
contract RenounceRoleTestCaseWithUnauthorizedFail is RoleManageBase {
    constructor(
        IRoles _roles,
        IRolesAssertion _assertion
    )
        RoleManageBase(_roles, _assertion) // solhint-disable-next-line
    {}

    function before(bytes32 _role, address _account) internal virtual override {
        address admin = roles.getRoleMember(bytes32(0x00), 0);
        vm.prank(admin);
        roles.grantRole(_role, _account);
    }

    function action(bytes32 _role, address _account) internal virtual override {
        vm.expectRevert(
            bytes("AccessControl: can only renounce roles for self")
        );
        roles.renounceRole(_role, _account);
    }
}
