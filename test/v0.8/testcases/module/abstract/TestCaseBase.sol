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

import {ITestCase} from "test/v0.8/interfaces/testcase/ITestCase.sol";

/// @title TestCaseBase
/// @dev Base contract for test cases. Test cases consist of three steps: before, action, and after.
/// The `run` function orchestrates these steps for each test case.
abstract contract TestCaseBase {
    /// @dev Runs the test case.
    function run() external {
        uint64 id = before();
        action(id);
        after_(id);
    }

    /// @dev Executes the setup code before the main action of the test case.
    /// @return id A unique identifier for the test case.
    function before() internal virtual returns (uint64 id) {}

    /// @dev Executes the main action of the test case.
    /// @param _id The unique identifier for the test case.
    function action(uint64 _id) internal virtual;

    /// @dev Executes any cleanup or post-action code after the test case has run.
    /// @param _id The unique identifier for the test case.
    function after_(uint64 _id) internal virtual {}
}
