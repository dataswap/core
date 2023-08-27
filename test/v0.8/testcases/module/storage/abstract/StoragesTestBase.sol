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
import {IStorages} from "src/v0.8/interfaces/module/IStorages.sol";
import {IStoragesAssertion} from "test/v0.8/interfaces/assertions/module/IStoragesAssertion.sol";
import {IStoragesHelpers} from "test/v0.8/interfaces/helpers/module/IStoragesHelpers.sol";

/// @dev design CarstoreTestBase as all test suite must constructor the same parmas
abstract contract StoragesTestBase is TestCaseBase, Test {
    IStorages internal storages;
    IStoragesHelpers internal storagesHelpers;
    IStoragesAssertion internal storagesAssertion;

    constructor(
        IStorages _storages,
        IStoragesHelpers _storagesHelpers,
        IStoragesAssertion _storagesAssertion
    ) {
        storages = _storages;
        storagesHelpers = _storagesHelpers;
        storagesAssertion = _storagesAssertion;
    }
}
