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

import {DSTest} from "ds-test/test.sol";
import {Test} from "forge-std/Test.sol";
import {IRoles} from "src/v0.8/interfaces/core/IRoles.sol";
import {IRolesAssertion} from "test/v0.8/interfaces/assertions/core/IRolesAssertion.sol";

// assert carstore action
// NOTE: view asserton functions must all be tested by the functions that will change state
contract RolesAssertion is DSTest, Test, IRolesAssertion {
    IRoles public roles;
    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    constructor(IRoles _roles) {
        roles = _roles;
    }

    /// @dev transfer ownership assertion
    function transferOwnershipAssertion(
        address caller,
        address _newOwner
    ) external {
        // before action
        ownerAssertion(caller);

        // action
        vm.prank(caller);
        roles.transferOwnership(_newOwner);

        // after action
        ownerAssertion(caller);
        pendingOwnerAssertion(_newOwner);
    }

    /// @dev accept ownership assertion
    function acceptOwnershipAssertion(address caller) external {
        // berfore
        pendingOwnerAssertion(caller);

        // action
        vm.prank(caller);
        roles.acceptOwnership();

        // after action
        ownerAssertion(caller);
    }

    /// @dev renounce ownership assertion
    function renounceOwnershipAssertion(address caller) external {
        // before action
        ownerAssertion(caller);

        // action
        vm.prank(caller);
        roles.renounceOwnership();

        // after action
        if (caller != address(0)) {
            assertNotEq(caller, roles.owner());
        } else {
            ownerAssertion(caller);
        }
    }

    /// @dev grant role assertion
    function grantRoleAssertion(
        address caller,
        bytes32 _role,
        address _account
    ) external {
        // before action
        hasRoleAssertion(_role, _account, false);
        uint256 beforRoleMemberCount = roles.getRoleMemberCount(_role);

        // action
        vm.prank(caller);
        roles.grantRole(_role, _account);

        // after action
        hasRoleAssertion(_role, _account, true);
        getRoleMemberCountAssertion(_role, beforRoleMemberCount + 1);
        getRoleMemberAssertion(_role, beforRoleMemberCount, _account);
        getRoleAdminAssertion(_role, DEFAULT_ADMIN_ROLE);
    }

    /// @dev revoke role assertion
    function revokeRoleAssertion(
        address caller,
        bytes32 _role,
        address _account
    ) external {
        // before action
        hasRoleAssertion(_role, _account, true);

        // action
        vm.prank(caller);
        roles.revokeRole(_role, _account);

        //after action
        hasRoleAssertion(_role, _account, false);
    }

    /// @dev renounce role assertion
    function renounceRoleAssertion(
        address caller,
        bytes32 _role,
        address _account
    ) external {
        // before action
        hasRoleAssertion(_role, _account, true);

        // action
        vm.prank(caller);
        roles.renounceRole(_role, _account);

        //after action
        hasRoleAssertion(_role, _account, false);
    }

    /// @dev check role assertion, check the msg.sender is owner
    function checkRoleAssertion(address caller) public {
        vm.prank(caller);
        roles.checkRole(DEFAULT_ADMIN_ROLE);
    }

    /// @dev owner assertion
    function ownerAssertion(address _expectOwner) public {
        assertEq(roles.owner(), _expectOwner, "owner not matched");
    }

    /// @dev pending owner assertion
    function pendingOwnerAssertion(address _expectPendingOwner) public {
        assertEq(
            roles.pendingOwner(),
            _expectPendingOwner,
            "pending owner not matched"
        );
    }

    /// @dev get role member assertion
    function getRoleMemberAssertion(
        bytes32 _role,
        uint256 _index,
        address _expectAddress
    ) public {
        assertEq(
            roles.getRoleMember(_role, _index),
            _expectAddress,
            "role member not matched"
        );
    }

    /// @dev get role member count assertion
    function getRoleMemberCountAssertion(
        bytes32 _role,
        uint256 _expectCount
    ) public {
        assertEq(
            roles.getRoleMemberCount(_role),
            _expectCount,
            "count not matched"
        );
    }

    /// @dev has role assertion
    function hasRoleAssertion(
        bytes32 _role,
        address _account,
        bool _expectExsit
    ) public {
        assertEq(
            roles.hasRole(_role, _account),
            _expectExsit,
            "has role not matched"
        );
    }

    /// @dev get role admin assertion
    function getRoleAdminAssertion(bytes32 _role, bytes32 _expectRole) public {
        assertEq(roles.getRoleAdmin(_role), _expectRole, "role not matched");
    }
}
