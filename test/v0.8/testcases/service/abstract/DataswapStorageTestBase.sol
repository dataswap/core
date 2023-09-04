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
import {IDataswapStorage} from "src/v0.8/interfaces/service/IDataswapStorage.sol";
import {IDataswapStorageHelpers} from "test/v0.8/interfaces/helpers/service/IDataswapStorageHelpers.sol";
import {IDataswapStorageAssertion} from "test/v0.8/interfaces/assertions/service/IDataswapStorageAssertion.sol";

abstract contract DataswapStorageTestBase is TestCaseBase, Test {
    IDataswapStorage internal dataswapStorage;

    IDataswapStorageHelpers internal dataswapStorageHelpers;

    /// @dev The address of the IDataswapStorageAssertion contract containing test assertions.
    IDataswapStorageAssertion internal assertion;

    constructor(
        IDataswapStorage _dataswapStorage,
        IDataswapStorageHelpers _dataswapStorageHelpers,
        IDataswapStorageAssertion _assertion
    ) {
        dataswapStorage = _dataswapStorage;
        dataswapStorageHelpers = _dataswapStorageHelpers;
        assertion = _assertion;
    }
}
