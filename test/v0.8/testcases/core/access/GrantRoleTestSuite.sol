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

/// @notice grant role test case with success
contract GrantRoleTestCaseWithSuccess is RoleManageBase {
    constructor(
        IRoles _roles,
        IRolesAssertion _assertion
    )
        RoleManageBase(_roles, _assertion) // solhint-disable-next-line
    {}

    function before(
        bytes32 _role,
        address _account
    ) internal virtual override {}

    function action(bytes32 _role, address _account) internal virtual override {
        address admin = roles.getRoleMember(bytes32(0x00), 0);
        assertion.grantRoleAssertion(admin, _role, _account);
    }
}

/// @notice grant role test case with unauthorized fail
contract GrantRoleTestCaseWithUnauthorizedFail is RoleManageBase {
    constructor(
        IRoles _roles,
        IRolesAssertion _assertion
    )
        RoleManageBase(_roles, _assertion) // solhint-disable-next-line
    {}

    function before(
        bytes32 _role,
        address _account
    ) internal virtual override {}

    function action(bytes32 _role, address _account) internal virtual override {
        vm.expectRevert(
            bytes(
                "AccessControl: account 0xf62849f9a0b5bf2913b396098f7c7019b51a820a is missing role 0x0000000000000000000000000000000000000000000000000000000000000000"
            )
        );
        roles.grantRole(_role, _account);
    }
}
