/*******************************************************************************
 *   (c) 2023 DataSwap
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

import {IRoles} from "src/v0.8/interfaces/core/IRoles.sol";
import {CommonModifiers} from "src/v0.8/shared/modifiers/CommonModifiers.sol";

/// @title RolesModifier
contract RolesModifiers is CommonModifiers {
    IRoles private roles;

    // solhint-disable-next-line
    constructor(IRoles _roles) {
        roles = _roles;
    }

    modifier onlyRole(bytes32 _role) {
        // roles.checkRole(_role);
        require(roles.hasRole(_role, msg.sender), "Only allowed role can call");
        _;
    }
}
