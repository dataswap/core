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

import {TransferOwnershipBase} from "test/v0.8/testcases/core/access/abstract/AccessTestSuiteBase.sol";
import {IRoles} from "src/v0.8/interfaces/core/IRoles.sol";
import {IRolesAssertion} from "test/v0.8/interfaces/assertions/core/IRolesAssertion.sol";

/// @dev transfer Ownership test case with success
contract TransferOwnershipTestCaseWithSuccess is TransferOwnershipBase {
    constructor(
        IRoles _roles,
        IRolesAssertion _assertion
    )
        TransferOwnershipBase(_roles, _assertion) // solhint-disable-next-line
    {}

    function before(address _account) internal virtual override {}

    function action(address _account) internal virtual override {
        address admin = roles.getRoleMember(bytes32(0x00), 0);
        assertion.transferOwnershipAssertion(admin, _account);
    }
}
