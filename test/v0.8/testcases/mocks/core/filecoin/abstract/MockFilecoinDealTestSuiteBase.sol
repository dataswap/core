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
import {FilecoinType} from "src/v0.8/types/FilecoinType.sol";
import {IFilecoinAssertion} from "test/v0.8/interfaces/assertions/core/IFilecoinAssertion.sol";
import {MockFilecoinDealTestBase} from "test/v0.8/testcases/mocks/core/filecoin/abstract/MockFilecoinDealTestBase.sol";

/// @title MockFilecoinDealTestSuiteBase
/// @dev Base contract for test suites related to mock filecoin deal process.
abstract contract MockFilecoinDealTestSuiteBase is
    MockFilecoinDealTestBase,
    Test
{
    constructor(
        IFilecoinAssertion _assertion
    )
        MockFilecoinDealTestBase(_assertion) // solhint-disable-next-line
    {}

    /// @dev Called before running the test to set up the test scenario.
    /// @param _cid The CID (Content Identifier) of the replica.
    /// @param _filecoinDealId The filecoin Deal ID.
    /// @param _state The filecoin Deal ID state.
    function before(
        bytes32 _cid,
        uint64 _filecoinDealId,
        FilecoinType.DealState _state // solhint-disable-next-line
    ) internal virtual {}

    /// @dev The main action of the test, the mock Filecoin deal state for a replica.
    /// @param _cid The CID (Content Identifier) of the replica.
    /// @param _filecoinDealId The filecoin Deal ID.
    /// @param _state The filecoin Deal ID state.
    function action(
        bytes32 _cid,
        uint64 _filecoinDealId,
        FilecoinType.DealState _state
    ) internal virtual {
        assertion.setMockDealStateAssertion(_cid, _filecoinDealId, _state);
    }

    /// @dev Called after running the test to perform any necessary cleanup or validation.
    /// @param _cid The CID (Content Identifier) of the replica.
    /// @param _filecoinDealId The filecoin Deal ID.
    /// @param _state The filecoin Deal ID state.
    function after_(
        bytes32 _cid,
        uint64 _filecoinDealId,
        FilecoinType.DealState _state // solhint-disable-next-line
    ) internal virtual {}

    /// @dev Runs the test to add a car to the carstore.
    /// @param _cid The CID (Content Identifier) of the replica.
    /// @param _filecoinDealId The filecoin Deal ID.
    /// @param _state The filecoin Deal ID state.
    function run(
        bytes32 _cid,
        uint64 _filecoinDealId,
        FilecoinType.DealState _state
    ) public {
        before(_cid, _filecoinDealId, _state);
        action(_cid, _filecoinDealId, _state);
        after_(_cid, _filecoinDealId, _state);
    }
}
