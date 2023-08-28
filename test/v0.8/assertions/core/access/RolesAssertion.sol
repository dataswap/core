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

// Importing Solidity libraries and contracts
import {DSTest} from "ds-test/test.sol";
import {Test} from "forge-std/Test.sol";
import {IRoles} from "src/v0.8/interfaces/core/IRoles.sol";
import {IRolesAssertion} from "test/v0.8/interfaces/assertions/core/IRolesAssertion.sol";

/// @notice This contract defines assertion functions for testing an IRoles contract.
/// @dev NOTE: All methods that do not change the state must be tested by methods that will change the state to ensure test coverage.

contract RolesAssertion is DSTest, Test, IRolesAssertion {
    // Storage for the address of the IRoles contract
    IRoles public roles;

    // Constant for the default admin role
    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    /// @notice Constructor that takes the address of the IRoles contract as a parameter.
    /// @param _roles The address of the IRoles contract.
    constructor(IRoles _roles) {
        roles = _roles;
    }

    /// @notice Assertion function for transferring ownership.
    /// @param caller The address of the caller.
    /// @param _newOwner The address of the new owner.
    function transferOwnershipAssertion(
        address caller,
        address _newOwner
    ) external {
        // Before the action, assert ownership.
        ownerAssertion(caller);

        // Perform the action.
        vm.prank(caller);
        roles.transferOwnership(_newOwner);

        // After the action, assert ownership and pending owner.
        ownerAssertion(caller);
        pendingOwnerAssertion(_newOwner);
    }

    /// @notice Assertion function for accepting ownership.
    /// @param caller The address of the caller.
    function acceptOwnershipAssertion(address caller) external {
        // Before the action, assert pending ownership.
        pendingOwnerAssertion(caller);

        // Perform the action.
        vm.prank(caller);
        roles.acceptOwnership();

        // After the action, assert ownership.
        ownerAssertion(caller);
    }

    /// @notice Assertion function for renouncing ownership.
    /// @param caller The address of the caller.
    function renounceOwnershipAssertion(address caller) external {
        // Before the action, assert ownership.
        ownerAssertion(caller);

        // Perform the action.
        vm.prank(caller);
        roles.renounceOwnership();

        // After the action, check if ownership has changed.
        if (caller != address(0)) {
            assertNotEq(caller, roles.owner());
        } else {
            ownerAssertion(caller);
        }
    }

    /// @notice Assertion function for granting a role.
    /// @param caller The address of the caller.
    /// @param _role The role being granted.
    /// @param _account The address of the account receiving the role.
    function grantRoleAssertion(
        address caller,
        bytes32 _role,
        address _account
    ) external {
        // Before the action, assert that the account does not have the role.
        hasRoleAssertion(_role, _account, false);
        uint256 beforeRoleMemberCount = roles.getRoleMemberCount(_role);

        // Perform the action.
        vm.prank(caller);
        roles.grantRole(_role, _account);

        // After the action, assert that the account now has the role.
        hasRoleAssertion(_role, _account, true);
        getRoleMemberCountAssertion(_role, beforeRoleMemberCount + 1);
        getRoleMemberAssertion(_role, beforeRoleMemberCount, _account);
        getRoleAdminAssertion(_role, DEFAULT_ADMIN_ROLE);
    }

    /// @notice Assertion function for revoking a role.
    /// @param caller The address of the caller.
    /// @param _role The role being revoked.
    /// @param _account The address of the account having the role revoked.
    function revokeRoleAssertion(
        address caller,
        bytes32 _role,
        address _account
    ) external {
        // Before the action, assert that the account has the role.
        hasRoleAssertion(_role, _account, true);

        // Perform the action.
        vm.prank(caller);
        roles.revokeRole(_role, _account);

        // After the action, assert that the account no longer has the role.
        hasRoleAssertion(_role, _account, false);
    }

    /// @notice Assertion function for renouncing a role.
    /// @param caller The address of the caller.
    /// @param _role The role being renounced.
    /// @param _account The address of the account renouncing the role.
    function renounceRoleAssertion(
        address caller,
        bytes32 _role,
        address _account
    ) external {
        // Before the action, assert that the account has the role.
        hasRoleAssertion(_role, _account, true);

        // Perform the action.
        vm.prank(caller);
        roles.renounceRole(_role, _account);

        // After the action, assert that the account no longer has the role.
        hasRoleAssertion(_role, _account, false);
    }

    /// @notice Assertion function to check if the caller has a specific role (admin role).
    /// @param caller The address of the caller.
    function checkRoleAssertion(address caller) public {
        vm.prank(caller);
        roles.checkRole(DEFAULT_ADMIN_ROLE);
    }

    /// @notice Assertion function for owner.
    /// @param _expectOwner The expected owner's address.
    function ownerAssertion(address _expectOwner) public {
        assertEq(roles.owner(), _expectOwner, "Owner not matched");
    }

    /// @notice Assertion function for pending owner.
    /// @param _expectPendingOwner The expected pending owner's address.
    function pendingOwnerAssertion(address _expectPendingOwner) public {
        assertEq(
            roles.pendingOwner(),
            _expectPendingOwner,
            "Pending owner not matched"
        );
    }

    /// @notice Assertion function for getting a role member.
    /// @param _role The role being queried.
    /// @param _index The index of the role member to retrieve.
    /// @param _expectAddress The expected address of the role member.
    function getRoleMemberAssertion(
        bytes32 _role,
        uint256 _index,
        address _expectAddress
    ) public {
        assertEq(
            roles.getRoleMember(_role, _index),
            _expectAddress,
            "Role member not matched"
        );
    }

    /// @notice Assertion function for getting the role member count.
    /// @param _role The role being queried.
    /// @param _expectCount The expected role member count.
    function getRoleMemberCountAssertion(
        bytes32 _role,
        uint256 _expectCount
    ) public {
        assertEq(
            roles.getRoleMemberCount(_role),
            _expectCount,
            "Count not matched"
        );
    }

    /// @notice Assertion function for checking if an account has a specific role.
    /// @param _role The role being checked.
    /// @param _account The address of the account being checked.
    /// @param _expectExist The expected existence status of the role for the account.
    function hasRoleAssertion(
        bytes32 _role,
        address _account,
        bool _expectExist
    ) public {
        assertEq(
            roles.hasRole(_role, _account),
            _expectExist,
            "Has role not matched"
        );
    }

    /// @notice Assertion function for getting the role admin.
    /// @param _role The role being queried.
    /// @param _expectRole The expected admin role.
    function getRoleAdminAssertion(bytes32 _role, bytes32 _expectRole) public {
        assertEq(roles.getRoleAdmin(_role), _expectRole, "Role not matched");
    }
}
