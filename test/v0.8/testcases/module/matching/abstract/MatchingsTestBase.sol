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

import {IMatchings} from "src/v0.8/interfaces/module/IMatchings.sol";
import {IMatchingsAssertion} from "test/v0.8/interfaces/assertions/module/IMatchingsAssertion.sol";
import {IMatchingsHelpers} from "test/v0.8/interfaces/helpers/module/IMatchingsHelpers.sol";

/// @dev design CarstoreTestBase as all test suite must constructor the same parmas
abstract contract MatchingsTestBase {
    IMatchings internal matchings;
    IMatchingsHelpers internal matchingsHelpers;
    IMatchingsAssertion internal matchingsAssertion;

    constructor(
        IMatchings _matchings,
        IMatchingsHelpers _matchingsHelpers,
        IMatchingsAssertion _matchingsAssertion
    ) {
        matchings = _matchings;
        matchingsHelpers = _matchingsHelpers;
        matchingsAssertion = _matchingsAssertion;
    }
}
