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
import {Generator} from "test/v0.8/helpers/utils/Generator.sol";
import {IStorages} from "src/v0.8/interfaces/module/IStorages.sol";
import {IStoragesAssertion} from "test/v0.8/interfaces/assertions/module/IStoragesAssertion.sol";
import {IStoragesHelpers} from "test/v0.8/interfaces/helpers/module/IStoragesHelpers.sol";

/// @title StoragesTestBase
/// @dev Base contract for storages test suites. Storages test suites consist of three steps: before, action, and after.
/// The `before` function is used for test case setup, and the `action` function performs the main action of the test case.
/// The `after_` function can be used for cleanup or post-action code.
abstract contract StoragesTestBase is TestCaseBase, Test {
    Generator internal generator;

    IStorages internal storages;
    IStoragesHelpers internal storagesHelpers;
    IStoragesAssertion internal storagesAssertion;

    /// @dev Constructor to initialize the StoragesTestBase with the required contracts.
    /// @param _storages The address of the IStorages contract.
    /// @param _generator The random generator contract.
    /// @param _storagesHelpers The address of the IStoragesHelpers contract.
    /// @param _storagesAssertion The address of the IStoragesAssertion contract.
    constructor(
        IStorages _storages,
        Generator _generator,
        IStoragesHelpers _storagesHelpers,
        IStoragesAssertion _storagesAssertion
    ) {
        storages = _storages;
        generator = _generator;
        storagesHelpers = _storagesHelpers;
        storagesAssertion = _storagesAssertion;
    }
}
