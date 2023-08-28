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

import {Test} from "forge-std/Test.sol";
import {AccessTestBase} from "test/v0.8/testcases/core/access/abstract/AccessTestBase.sol";

import {IRoles} from "src/v0.8/interfaces/core/IRoles.sol";
import {IRolesAssertion} from "test/v0.8/interfaces/assertions/core/IRolesAssertion.sol";

/// @title Abstract contract for testing role management.
abstract contract RoleManageBase is AccessTestBase, Test {
    constructor(
        IRoles _roles,
        IRolesAssertion _assertion
    ) AccessTestBase(_roles, _assertion) {}

    /// @dev Called before the role management action.
    /// @param _role The role to be managed.
    /// @param _account The account for which the role is managed.
    function before(bytes32 _role, address _account) internal virtual;

    /// @dev The role management action.
    /// @param _role The role to be managed.
    /// @param _account The account for which the role is managed.
    function action(bytes32 _role, address _account) internal virtual;

    /// @dev Called after the role management action.
    /// @param _role The role to be managed.
    /// @param _account The account for which the role is managed.
    function after_(bytes32 _role, address _account) internal virtual {}

    /// @dev Runs the role management test case.
    /// @param _role The role to be managed.
    /// @param _account The account for which the role is managed.
    function run(bytes32 _role, address _account) public {
        before(_role, _account);
        action(_role, _account);
        after_(_role, _account);
    }
}

abstract contract TransferOwnershipBase is AccessTestBase, Test {
    constructor(
        IRoles _roles,
        IRolesAssertion _assertion
    ) AccessTestBase(_roles, _assertion) {}

    /// @dev Called before the transfer ownership action.
    /// @param _account The account to which ownership is transferred.
    function before(address _account) internal virtual;

    /// @dev The transfer ownership action.
    /// @param _account The account to which ownership is transferred.
    function action(address _account) internal virtual;

    /// @dev Called after the transfer ownership action.
    /// @param _account The account to which ownership is transferred.
    function after_(address _account) internal virtual {}

    /// @dev Runs the transfer ownership test case.
    /// @param _account The account to which ownership is transferred.
    function run(address _account) public {
        before(_account);
        action(_account);
        after_(_account);
    }
}

abstract contract CommonBase is AccessTestBase, Test {
    constructor(
        IRoles _roles,
        IRolesAssertion _assertion
    ) AccessTestBase(_roles, _assertion) {}

    /// @dev Called before the common action.
    function before() internal virtual;

    /// @dev The common action.
    function action() internal virtual;

    /// @dev Called after the common action.
    function after_() internal virtual {}

    /// @dev Runs the common test case.
    function run() public {
        before();
        action();
        after_();
    }
}
