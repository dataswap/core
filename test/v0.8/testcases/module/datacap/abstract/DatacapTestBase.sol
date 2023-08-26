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

import {IDatacaps} from "src/v0.8/interfaces/module/IDatacaps.sol";
import {IDatacapAssertion} from "test/v0.8/interfaces/assertions/module/IDatacapAssertion.sol";
import {IDatacapsSetupHelpers} from "test/v0.8/interfaces/helpers/setup/IDatacapsSetupHelpers.sol";

/// @dev design CarstoreTestBase as all test suite must constructor the same parmas
abstract contract DatacapTestBase {
    IDatacaps internal datacaps;
    IDatacapsSetupHelpers internal datacapsSetupHelpers;
    IDatacapAssertion internal datacapAssertion;

    constructor(
        IDatacaps _datacaps,
        IDatacapsSetupHelpers _datacapsSetupHelpers,
        IDatacapAssertion _datacapAssertion
    ) {
        datacaps = _datacaps;
        datacapsSetupHelpers = _datacapsSetupHelpers;
        datacapAssertion = _datacapAssertion;
    }
}
