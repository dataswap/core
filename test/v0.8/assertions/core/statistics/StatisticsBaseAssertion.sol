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

// Importing Solidity libraries and contracts
import {DSTest} from "ds-test/test.sol";
import {Test} from "forge-std/Test.sol";
import {IStatistics} from "src/v0.8/interfaces/core/statistics/IStatistics.sol";
import {IStatisticsBaseAssertion} from "test/v0.8/interfaces/assertions/core/IStatisticsBaseAssertion.sol";

/// @notice This contract defines assertion functions for testing an IFilplus contract.
/// @dev NOTE: All methods that do not change the state must be tested by methods that will change the state to ensure test coverage.
abstract contract StatisticsBaseAssertion is
    DSTest,
    Test,
    IStatisticsBaseAssertion
{
    IStatistics public statistics;
    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    /// @notice Constructor function to initialize the contract with the provided statistics instance.
    /// @param _statistics Instance of the IStatistics contract to be used.
    constructor(IStatistics _statistics) {
        statistics = _statistics;
    }

    /// @notice External function to assert the count overview in statistics.
    /// @param expectTotal Expected total count.
    /// @param expectSuccess Expected success count.
    /// @param expectOngoing Expected ongoing count.
    /// @param expectFailed Expected failed count.
    function getCountOverviewAssertion(
        uint256 expectTotal,
        uint256 expectSuccess,
        uint256 expectOngoing,
        uint256 expectFailed
    ) external {
        (
            uint256 total,
            uint256 success,
            uint256 ongoing,
            uint256 failed
        ) = statistics.getCountOverview();
        assertEq(total, expectTotal);
        assertEq(success, expectSuccess);
        assertEq(ongoing, expectOngoing);
        assertEq(failed, expectFailed);
    }

    /// @notice External function to assert the size overview in statistics.
    /// @param expectTotal Expected total size.
    /// @param expectSuccess Expected success size.
    /// @param expectOngoing Expected ongoing size.
    /// @param expectFailed Expected failed size.
    function getSizeOverviewAssersion(
        uint256 expectTotal,
        uint256 expectSuccess,
        uint256 expectOngoing,
        uint256 expectFailed
    ) external {
        (
            uint256 total,
            uint256 success,
            uint256 ongoing,
            uint256 failed
        ) = statistics.getSizeOverview();
        assertEq(total, expectTotal);
        assertEq(success, expectSuccess);
        assertEq(ongoing, expectOngoing);
        assertEq(failed, expectFailed);
    }
}
