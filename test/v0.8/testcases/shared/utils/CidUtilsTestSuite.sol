/*******************************************************************************
 *   (c) 2023 DataSwap
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

// Import required external contracts and interfaces
import {Test} from "forge-std/Test.sol";
import {CidUtils} from "src/v0.8/shared/utils/cid/CidUtils.sol";
import {TestCaseBase} from "test/v0.8/testcases/module/abstract/TestCaseBase.sol";

///@notice cid utils test with success.
contract CidUtilsTestCaseWithSuccess is TestCaseBase, Test {
    function action(uint64) internal virtual override {
        bytes32 hash = 0x03b2ed13af20471b3eea52c329c29bba17568ecf0190f50c9e675cf5a453b813;

        assertEq(
            CidUtils.hashToCID(hash),
            hex"0181e20392202003b2ed13af20471b3eea52c329c29bba17568ecf0190f50c9e675cf5a453b813"
        );
    }
}
