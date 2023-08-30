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

import {IFilecoinAssertion} from "test/v0.8/interfaces/assertions/core/IFilecoinAssertion.sol";

/// @title MockFilecoinDealTestBase
/// @dev Base contract for filecoin deal test cases with a common constructor.
abstract contract MockFilecoinDealTestBase {
    IFilecoinAssertion internal assertion; // The assertion contract for filecoin deal operations.

    /// @dev Constructor to initialize the mock filecoin and assertion contracts.
    /// @param _assertion The assertion contract for filecoin operations.
    constructor(IFilecoinAssertion _assertion) {
        assertion = _assertion;
    }
}
