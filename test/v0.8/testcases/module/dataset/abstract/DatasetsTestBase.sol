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
import {IDatasetsAssertion} from "test/v0.8/interfaces/assertions/module/IDatasetsAssertion.sol";
import {IDatasetsHelpers} from "test/v0.8/interfaces/helpers/module/IDatasetsHelpers.sol";
import {TestCaseBase} from "test/v0.8/testcases/module/abstract/TestCaseBase.sol";

/// @dev design CarstoreTestBase as all test suite must constructor the same parmas
abstract contract DatasetsTestBase is TestCaseBase, Test {
    IDatasets internal datasets;
    IDatasetsHelpers internal datasetsHelpers;
    IDatasetsAssertion internal datasetsAssertion;

    constructor(
        IDatasets _datasets,
        IDatasetsHelpers _datasetsHelpers,
        IDatasetsAssertion _datasetsAssertion
    ) {
        datasets = _datasets;
        datasetsHelpers = _datasetsHelpers;
        datasetsAssertion = _datasetsAssertion;
    }
}