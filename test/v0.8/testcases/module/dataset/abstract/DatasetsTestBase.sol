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
import {IDatasets} from "src/v0.8/interfaces/module/IDatasets.sol";
import {IDatasetsRequirement} from "src/v0.8/interfaces/module/IDatasetsRequirement.sol";
import {IDatasetsProof} from "src/v0.8/interfaces/module/IDatasetsProof.sol";
import {IDatasetsChallenge} from "src/v0.8/interfaces/module/IDatasetsChallenge.sol";
import {IDatasetsAssertion} from "test/v0.8/interfaces/assertions/module/IDatasetsAssertion.sol";
import {IDatasetsHelpers} from "test/v0.8/interfaces/helpers/module/IDatasetsHelpers.sol";
import {TestCaseBase} from "test/v0.8/testcases/module/abstract/TestCaseBase.sol";

/// @title DatasetsTestBase
/// @dev Base contract for datasets test cases. Datasets test cases consist of three steps: before, action, and after.
/// The `before` function is used for test case setup, and the `action` function performs the main action of the test case.
/// The `after_` function can be used for cleanup or post-action code.
abstract contract DatasetsTestBase is TestCaseBase, Test {
    /// @dev The address of the IDatasets contract being tested.
    IDatasets internal datasets;
    IDatasetsRequirement internal datasetsRequirement;
    IDatasetsProof internal datasetsProof;
    IDatasetsChallenge internal datasetsChallenge;

    /// @dev The address of the IDatasetsHelpers contract being used for test setup.
    IDatasetsHelpers internal datasetsHelpers;

    /// @dev The address of the IDatasetsAssertion contract containing test assertions.
    IDatasetsAssertion internal datasetsAssertion;

    /// @dev Constructor to initialize the DatasetsTestBase with the required contracts.
    /// @param _datasets The address of the IDatasets contract.
    /// @param _datasetsHelpers The address of the IDatasetsHelpers contract.
    /// @param _datasetsAssertion The address of the IDatasetsAssertion contract.
    constructor(
        IDatasets _datasets,
        IDatasetsRequirement _datasetsRequirement,
        IDatasetsProof _datasetsProof,
        IDatasetsChallenge _datasetsChallenge,
        IDatasetsHelpers _datasetsHelpers,
        IDatasetsAssertion _datasetsAssertion
    ) {
        datasets = _datasets;
        datasetsRequirement = _datasetsRequirement;
        datasetsProof = _datasetsProof;
        datasetsChallenge = _datasetsChallenge;
        datasetsHelpers = _datasetsHelpers;
        datasetsAssertion = _datasetsAssertion;
    }
}
