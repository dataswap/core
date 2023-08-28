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

/// @title IRolesAssertion
/// @dev This interface defines assertion methods for testing role-related functionality.
/// All methods that do not change the state must be tested by methods that will change the state to ensure test coverage.
interface IRolesAssertion {
    /// @notice Asserts the transfer of ownership.
    /// @param caller The caller's address.
    /// @param _newOwner The expected new owner's address.
    function transferOwnershipAssertion(
        address caller,
        address _newOwner
    ) external;

    /// @notice Asserts the acceptance of ownership.
    /// @param caller The caller's address.
    function acceptOwnershipAssertion(address caller) external;

    /// @notice Asserts the renouncement of ownership.
    /// @param caller The caller's address.
    function renounceOwnershipAssertion(address caller) external;

    /// @notice Asserts the granting of a role.
    /// @param caller The caller's address.
    /// @param _role The role being granted.
    /// @param _account The account to which the role is being granted.
    function grantRoleAssertion(
        address caller,
        bytes32 _role,
        address _account
    ) external;

    /// @notice Asserts the revocation of a role.
    /// @param caller The caller's address.
    /// @param _role The role being revoked.
    /// @param _account The account from which the role is being revoked.
    function revokeRoleAssertion(
        address caller,
        bytes32 _role,
        address _account
    ) external;

    /// @notice Asserts the renunciation of a role.
    /// @param caller The caller's address.
    /// @param _role The role being renounced.
    /// @param _account The account from which the role is being renounced.
    function renounceRoleAssertion(
        address caller,
        bytes32 _role,
        address _account
    ) external;

    /// @notice Asserts the check for a specific role.
    /// @param caller The caller's address.
    function checkRoleAssertion(address caller) external;

    /// @notice Asserts the owner of a contract.
    /// @param _expectOwner The expected owner's address.
    function ownerAssertion(address _expectOwner) external;

    /// @notice Asserts the pending owner of a contract.
    /// @param _expectPendingOwner The expected pending owner's address.
    function pendingOwnerAssertion(address _expectPendingOwner) external;

    /// @notice Asserts the member of a role at a specific index.
    /// @param _role The role being checked.
    /// @param _index The index of the member.
    /// @param _expectAddress The expected address of the member.
    function getRoleMemberAssertion(
        bytes32 _role,
        uint256 _index,
        address _expectAddress
    ) external;

    /// @notice Asserts the count of members in a role.
    /// @param _role The role being checked.
    /// @param _expectCount The expected count of members.
    function getRoleMemberCountAssertion(
        bytes32 _role,
        uint256 _expectCount
    ) external;

    /// @notice Asserts whether an account has a specific role.
    /// @param _role The role being checked.
    /// @param _account The account being checked.
    /// @param _expectExsit The expected existence of the role for the account.
    function hasRoleAssertion(
        bytes32 _role,
        address _account,
        bool _expectExsit
    ) external;

    /// @notice Asserts the admin role of a specific role.
    /// @param _role The role being checked.
    /// @param _expectRole The expected admin role.
    function getRoleAdminAssertion(bytes32 _role, bytes32 _expectRole) external;
}
