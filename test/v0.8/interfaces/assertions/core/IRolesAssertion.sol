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

// assert carstore action
// NOTE: view asserton functions must all be tested by the functions that will change state
interface IRolesAssertion {
    /// @dev transfer ownership assertion
    function transferOwnershipAssertion(address _newOwner) external;

    /// @dev accept ownership assertion
    function acceptOwnershipAssertion() external;

    /// @dev renounce ownership assertion
    function renounceOwnershipAssertion() external;

    /// @dev grant role assertion
    function grantRoleAssertion(bytes32 _role, address _account) external;

    /// @dev revoke role assertion
    function revokeRoleAssertion(bytes32 _role, address _account) external;

    /// @dev renounce role assertion
    function renounceRoleAssertion(bytes32 _role, address _account) external;

    /// @dev check role assertion, check the msg.sender is owner
    function checkRoleAssertion() external view;

    /// @dev owner assertion
    function ownerAssertion(address _expectOwner) external;

    /// @dev pending owner assertion
    function pendingOwnerAssertion(address _expectPendingOwner) external;

    /// @dev get role member assertion
    function getRoleMemberAssertion(
        bytes32 _role,
        uint256 _index,
        address _expectAddress
    ) external;

    /// @dev get role member count assertion
    function getRoleMemberCountAssertion(
        bytes32 _role,
        uint256 _expectCount
    ) external;

    /// @dev has role assertion
    function hasRoleAssertion(
        bytes32 _role,
        address _account,
        bool _expectExsit
    ) external;

    /// @dev get role admin assertion
    function getRoleAdminAssertion(bytes32 _role, bytes32 _expectRole) external;
}
