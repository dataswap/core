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
import {IFinanceAssertion} from "test/v0.8/interfaces/assertions/core/IFinanceAssertion.sol";

/// @title FinanceTestBase
/// @dev Base contract for finance test cases.
abstract contract FinanceTestBase {
    IRoles internal roles;
    IFinanceAssertion internal assertion;

    /// @dev Constructor to initialize the finance and assertion contracts.
    /// @param _roles The finance contract.
    /// @param _assertion The assertion contract.
    constructor(IRoles _roles, IFinanceAssertion _assertion) {
        roles = _roles;
        assertion = _assertion;
    }
}
