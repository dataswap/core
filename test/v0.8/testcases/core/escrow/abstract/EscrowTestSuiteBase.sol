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

import {EscrowType} from "src/v0.8/types/EscrowType.sol";

import {IEscrow} from "src/v0.8/interfaces/core/IEscrow.sol";
import {IDatasets} from "src/v0.8/interfaces/module/IDatasets.sol";
import {IEscrowAssertion} from "test/v0.8/interfaces/assertions/core/IEscrowAssertion.sol";

import {EscrowTestBase} from "test/v0.8/testcases/core/escrow/abstract/EscrowTestBase.sol";

/// @title EscrowTestSuiteBase
/// @dev Base contract for test suites related to escrow funds.
abstract contract EscrowTestSuiteBase is EscrowTestBase, Test {
    constructor(
        IDatasets _carstore,
        IEscrow _escrow,
        IEscrowAssertion _assertion
    )
        EscrowTestBase(_carstore, _escrow, _assertion) // solhint-disable-next-line
    {}

    /// @dev Called before running the test to set up the test scenario.
    /// @param _id The business id.
    function before(address payable, uint64 _id) internal virtual {
        vm.assume(_id != 0);
    }

    /// @dev The main action of the test, where the payee deposit funds.
    /// @param _owner The destination address of the funds.
    /// @param _id The business id.
    function action(address payable _owner, uint64 _id) internal virtual;

    /// @dev Called after running the test to perform any necessary cleanup or validation.
    /// @param _owner The destination address of the funds.
    /// @param _id The business id.
    function after_(
        address payable _owner,
        uint64 _id // solhint-disable-next-line
    ) internal virtual {}

    /// @dev Runs the test to add a car to the carstore.
    /// @param _owner The destination address of the funds.
    /// @param _id The business id.
    function run(address payable _owner, uint64 _id) public {
        before(_owner, _id);
        action(_owner, _id);
        after_(_owner, _id);
    }
}
