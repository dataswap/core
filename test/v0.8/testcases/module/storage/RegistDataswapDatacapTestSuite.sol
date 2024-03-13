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

import {TestCaseBase} from "test/v0.8/testcases/module/abstract/TestCaseBase.sol";
import {IStoragesAssertion} from "test/v0.8/interfaces/assertions/module/IStoragesAssertion.sol";

///@notice regist dataswap datacap test case with success
contract RegistDataswapDatacapWithSuccess is TestCaseBase {
    IStoragesAssertion storagesAssertion;
    constructor(IStoragesAssertion _storagesAssertion) TestCaseBase() {
        storagesAssertion = _storagesAssertion;
    }

    function action(uint64 /*_matchingId*/) internal virtual override {
        storagesAssertion.registDataswapDatacapAssertion(address(0), 1024);
    }
}
