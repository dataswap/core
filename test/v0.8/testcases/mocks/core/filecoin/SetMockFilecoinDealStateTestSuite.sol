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
import {IFilecoinAssertion} from "test/v0.8/interfaces/assertions/core/IFilecoinAssertion.sol";
import {MockFilecoinDealTestSuiteBase} from "test/v0.8/testcases/mocks/core/filecoin/abstract/MockFilecoinDealTestSuiteBase.sol";

///@notice Set mock filecoin deal state test with success.
contract SetMockFilecoinDealStateTestCaseWithSuccess is
    MockFilecoinDealTestSuiteBase
{
    constructor(
        IFilecoinAssertion _assertion
    )
        MockFilecoinDealTestSuiteBase(_assertion) // solhint-disable-next-line
    {}
}
