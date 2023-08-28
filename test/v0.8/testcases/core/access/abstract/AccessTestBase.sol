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

import {IRoles} from "src/v0.8/interfaces/core/IRoles.sol";
import {IRolesAssertion} from "test/v0.8/interfaces/assertions/core/IRolesAssertion.sol";

/// @title AccessTestBase
/// @dev Base contract for access control test cases.
abstract contract AccessTestBase {
    IRoles internal roles; // The roles contract for managing access control.
    IRolesAssertion internal assertion; // The assertion contract for verifying access control.

    /// @dev Constructor to initialize the roles and assertion contracts.
    /// @param _roles The roles contract for managing access control.
    /// @param _assertion The assertion contract for verifying access control.
    constructor(IRoles _roles, IRolesAssertion _assertion) {
        roles = _roles;
        assertion = _assertion;
    }
}
