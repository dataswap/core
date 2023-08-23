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

// Import required external contracts and interfaces
import {Test} from "forge-std/Test.sol";
import {Roles} from "src/v0.8/core/access/Roles.sol";

// Contract definition for test helper functions
contract RolesTest is Test {
    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;
    Roles public roles;

    // Setting up the test environment
    function setUp() public {
        roles = new Roles();
    }

    /**
     * @dev Test function to grant a role to an account.
     *
     * It grants the specified `_role` to the given `_account`.
     * After granting the role, the function asserts that the account has the role,
     * the role member count is 1, and the role admin is the DEFAULT_ADMIN_ROLE.
     * Lastly, it checks if the message sender is the DEFAULT_ADMIN_ROLE.
     */
    function testGrantRole(bytes32 _role, address _account) external {
        vm.roll(1);
        roles.grantRole(_role, _account);

        vm.roll(2);
        if (_role != DEFAULT_ADMIN_ROLE) {
            assertEq(1, roles.getRoleMemberCount(_role));
            assertEq(_account, roles.getRoleMember(_role, 0));
        } else {
            assertEq(2, roles.getRoleMemberCount(_role));
            assertEq(_account, roles.getRoleMember(_role, 1));
        }

        assertEq(true, roles.hasRole(_role, _account));
        assertEq(DEFAULT_ADMIN_ROLE, roles.getRoleAdmin(_role));
        roles.checkRole(DEFAULT_ADMIN_ROLE); // Check if msg.sender is DEFAULT_ADMIN_ROLE
    }

    /**
     * @dev Test function to revoke a role from an account.
     *
     * It first grants the specified `_role` to the given `_account`, then revokes the role from that account.
     * After revoking the role, the function asserts that the account no longer has the role.
     */
    function testRevokeRole(bytes32 _role, address _account) external {
        vm.roll(1);
        roles.grantRole(_role, _account);
        assertEq(true, roles.hasRole(_role, _account));

        vm.roll(2);
        roles.revokeRole(_role, _account);
        assertEq(false, roles.hasRole(_role, _account));
    }

    /**
     * @dev Test function to renounce a role by an account.
     *
     * It first grants the specified `_role` to the given `_account`, then simulates `_account` renouncing the role.
     * After renouncing the role, the function asserts that the account no longer has the role.
     */
    function testRenounceRole(bytes32 _role, address _account) external {
        vm.roll(1);
        roles.grantRole(_role, _account);
        assertEq(true, roles.hasRole(_role, _account));

        vm.roll(2);
        vm.prank(_account);
        roles.renounceRole(_role, _account);
        assertEq(false, roles.hasRole(_role, _account));
    }

    /**
     * @dev Test function to transfer ownership of the Roles contract.
     *
     * It transfers the ownership of the contract to `_newOwner` and then asserts that the pending owner is set to `_newOwner`.
     * After that, it simulates `_newOwner` accepting the ownership, which will set the owner to `_newOwner`.
     * Lastly, it simulates `_newOwner` renouncing the ownership, and the function asserts that the owner is no longer `_newOwner`.
     */
    function testTransferOwnership(address _newOwner) external {
        assertEq(address(this), roles.owner());

        vm.roll(1);
        roles.transferOwnership(_newOwner);

        vm.roll(2);
        assertEq(_newOwner, roles.pendingOwner());

        vm.roll(3);
        vm.prank(_newOwner);
        roles.acceptOwnership();
        assertEq(_newOwner, roles.owner());

        vm.roll(4);
        vm.startPrank(_newOwner);
        roles.renounceOwnership();
        vm.stopPrank();
        if (_newOwner != address(0)) {
            assertNotEq(_newOwner, roles.owner());
        }
        if (address(this) != address(0)) {
            assertNotEq(address(this), roles.owner());
        } else {
            assertEq(address(this), roles.owner());
        }
    }
}
