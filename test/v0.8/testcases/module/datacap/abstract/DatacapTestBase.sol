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

/// @title DatacapTestBase
/// @dev Base contract for datacaps test cases. Datacaps test cases consist of three steps: before, action, and after.
/// The `before` function is used for test case setup, and the `action` function performs the main action of the test case.
/// The `after_` function can be used for cleanup or post-action code.
abstract contract DatacapTestBase is TestCaseBase, Test {
    /// @dev The address of the IDatacaps contract being tested.
    IDatacaps internal datacaps;

    /// @dev The address of the IDatacapsHelpers contract being used for test setup.
    IDatacapsHelpers internal datacapsHelpers;

    /// @dev The address of the IDatacapsAssertion contract containing test assertions.
    IDatacapsAssertion internal datacapsAssertion;

    /// @dev Constructor to initialize the DatacapTestBase with the required contracts.
    /// @param _datacaps The address of the IDatacaps contract.
    /// @param _datacapsHelpers The address of the IDatacapsHelpers contract.
    /// @param _datacapsAssertion The address of the IDatacapsAssertion contract.
    constructor(
        IDatacaps _datacaps,
        IDatacapsHelpers _datacapsHelpers,
        IDatacapsAssertion _datacapsAssertion
    ) {
        datacaps = _datacaps;
        datacapsHelpers = _datacapsHelpers;
        datacapsAssertion = _datacapsAssertion;
    }

    /// @dev Executes the setup code before the main action of the datacaps test case.
    /// This function sets up the test environment and returns a unique identifier.
    /// @return id A unique identifier for the datacaps test case.
    function before() internal virtual override returns (uint64) {
        (, uint64 matchingId) = datacapsHelpers.setup();
        return matchingId;
    }
}
