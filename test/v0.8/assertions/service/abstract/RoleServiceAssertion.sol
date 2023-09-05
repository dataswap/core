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
import {ServiceAssertionBase} from "test/v0.8/assertions/service/abstract/base/ServiceAssertionBase.sol";

/// @title RoleServiceAssertion
abstract contract RoleServiceAssertion is ServiceAssertionBase {
    /// @notice Assertion function for transferring ownership.
    /// @param caller The address of the caller.
    /// @param _newOwner The address of the new owner.
    function transferOwnershipAssertion(
        address caller,
        address _newOwner
    ) external {
        rolesAssertion.transferOwnershipAssertion(caller, _newOwner);
    }

    /// @notice Assertion function for accepting ownership.
    /// @param caller The address of the caller.
    function acceptOwnershipAssertion(address caller) external {
        rolesAssertion.acceptOwnershipAssertion(caller);
    }

    /// @notice Assertion function for renouncing ownership.
    /// @param caller The address of the caller.
    function renounceOwnershipAssertion(address caller) external {
        rolesAssertion.renounceOwnershipAssertion(caller);
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
        rolesAssertion.grantRoleAssertion(caller, _role, _account);
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
        rolesAssertion.revokeRoleAssertion(caller, _role, _account);
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
        rolesAssertion.renounceRoleAssertion(caller, _role, _account);
    }

    /// @notice Assertion function to check if the caller has a specific role (admin role).
    /// @param caller The address of the caller.
    function checkRoleAssertion(address caller) public {
        rolesAssertion.checkRoleAssertion(caller);
    }

    /// @notice Assertion function for owner.
    /// @param _expectOwner The expected owner's address.
    function ownerAssertion(address _expectOwner) public {
        rolesAssertion.ownerAssertion(_expectOwner);
    }

    /// @notice Assertion function for pending owner.
    /// @param _expectPendingOwner The expected pending owner's address.
    function pendingOwnerAssertion(address _expectPendingOwner) public {
        rolesAssertion.pendingOwnerAssertion(_expectPendingOwner);
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
        rolesAssertion.getRoleMemberAssertion(_role, _index, _expectAddress);
    }

    /// @notice Assertion function for getting the role member count.
    /// @param _role The role being queried.
    /// @param _expectCount The expected role member count.
    function getRoleMemberCountAssertion(
        bytes32 _role,
        uint256 _expectCount
    ) public {
        rolesAssertion.getRoleMemberCountAssertion(_role, _expectCount);
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
        rolesAssertion.hasRoleAssertion(_role, _account, _expectExist);
    }

    /// @notice Assertion function for getting the role admin.
    /// @param _role The role being queried.
    /// @param _expectRole The expected admin role.
    function getRoleAdminAssertion(bytes32 _role, bytes32 _expectRole) public {
        rolesAssertion.getRoleAdminAssertion(_role, _expectRole);
    }
}
