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

/// @title IStatisticsBaseAssertion Interface
/// @notice Interface for asserting count and size overviews in statistics.
interface IStatisticsBaseAssertion {
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
    ) external;

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
    ) external;
}
