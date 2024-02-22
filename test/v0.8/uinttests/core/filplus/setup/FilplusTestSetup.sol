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

import {BaseTestSetup} from "test/v0.8/uinttests/helpers/BaseTestSetup.sol";
import {FilplusAssertion} from "test/v0.8/assertions/core/filplus/FilplusAssertion.sol";

/// @title FilplusTestSetup
/// @notice This contract is used for setting up the filplus contract for testing.
contract FilplusTestSetup is BaseTestSetup {
    FilplusAssertion assertion;

    /// @dev Initialize the filplus and assertion contracts.
    function setup() internal {
        enhanceSetup();
        assertion = new FilplusAssertion(filplus());
    }
}
