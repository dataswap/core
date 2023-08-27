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
import {IDatacaps} from "src/v0.8/interfaces/module/IDatacaps.sol";
import {IDatacapsAssertion} from "test/v0.8/interfaces/assertions/module/IDatacapsAssertion.sol";
import {IDatacapsHelpers} from "test/v0.8/interfaces/helpers/module/IDatacapsHelpers.sol";
import {MatchingType} from "src/v0.8/types/MatchingType.sol";
import {DatasetType} from "src/v0.8/types/DatasetType.sol";

/// @dev design CarstoreTestBase as all test suite must constructor the same parmas
abstract contract DatacapTestBase is TestCaseBase, Test {
    IDatacaps internal datacaps;
    IDatacapsHelpers internal datacapsHelpers;
    IDatacapsAssertion internal datacapsAssertion;

    constructor(
        IDatacaps _datacaps,
        IDatacapsHelpers _datacapsHelpers,
        IDatacapsAssertion _datacapsAssertion
    ) {
        datacaps = _datacaps;
        datacapsHelpers = _datacapsHelpers;
        datacapsAssertion = _datacapsAssertion;
    }

    function before() internal virtual override returns (uint64) {
        (, uint64 matchingId) = datacapsHelpers.setup();
        return matchingId;
    }
}
