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
import {TestCaseBase} from "test/v0.8/testcases/module/abstract/TestCaseBase.sol";
import {IMatchings} from "src/v0.8/interfaces/module/IMatchings.sol";
import {IMatchingsTarget} from "src/v0.8/interfaces/module/IMatchingsTarget.sol";
import {IMatchingsBids} from "src/v0.8/interfaces/module/IMatchingsBids.sol";
import {IMatchingsAssertion} from "test/v0.8/interfaces/assertions/module/IMatchingsAssertion.sol";
import {IMatchingsHelpers} from "test/v0.8/interfaces/helpers/module/IMatchingsHelpers.sol";

/// @title MatchingsTestBase
/// @dev Base contract for matchings test suites. Matchings test suites consist of three steps: before, action, and after.
/// The `before` function is used for test case setup, and the `action` function performs the main action of the test case.
/// The `after_` function can be used for cleanup or post-action code.
abstract contract MatchingsTestBase is TestCaseBase, Test {
    IMatchings internal matchings;
    IMatchingsTarget internal matchingsTarget;
    IMatchingsBids internal matchingsBids;
    IMatchingsHelpers internal matchingsHelpers;
    IMatchingsAssertion internal matchingsAssertion;

    /// @dev Constructor to initialize the MatchingsTestBase with the required contracts.
    /// @param _matchings The address of the IMatchings contract.
    /// @param _matchingsHelpers The address of the IMatchingsHelpers contract.
    /// @param _matchingsAssertion The address of the IMatchingsAssertion contract.
    constructor(
        IMatchings _matchings,
        IMatchingsTarget _matchingsTarget,
        IMatchingsBids _matchingsBids,
        IMatchingsHelpers _matchingsHelpers,
        IMatchingsAssertion _matchingsAssertion
    ) {
        matchings = _matchings;
        matchingsTarget = _matchingsTarget;
        matchingsBids = _matchingsBids;
        matchingsHelpers = _matchingsHelpers;
        matchingsAssertion = _matchingsAssertion;
    }
}
