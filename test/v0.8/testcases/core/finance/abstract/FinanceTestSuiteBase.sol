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
import {FinanceTestBase} from "test/v0.8/testcases/core/finance/abstract/FinanceTestBase.sol";

import {IRoles} from "src/v0.8/interfaces/core/IRoles.sol";
import {IFinanceAssertion} from "test/v0.8/interfaces/assertions/core/IFinanceAssertion.sol";

abstract contract CommonBase is FinanceTestBase, Test {
    constructor(
        IRoles _roles,
        IFinanceAssertion _assertion
    ) FinanceTestBase(_roles, _assertion) {}

    /// @dev Called before the common action.
    function before() internal virtual {}

    /// @dev The common action.
    function action() internal virtual {}

    /// @dev Called after the common action.
    function after_() internal virtual {}

    /// @dev Runs the common test case.
    function run() public {
        before();
        action();
        after_();
    }
}
