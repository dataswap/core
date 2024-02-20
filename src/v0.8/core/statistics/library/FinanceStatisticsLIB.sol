/*******************************************************************************
 *   (c) 2024 dataswap
 *
 *  Licensed under either the MIT License (the "MIT License") or the Apache License, Version 2.0
 *  (the "Apache License"). You may not use this file except in compliance with one of these
 *  licenses. You may obtain a copy of the MIT License at
 *
 *      https://opensource.org/licenses/MIT
 *
 *  Or the Apache License, Version 2.0 at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the MIT License or the Apache License for the specific language governing permissions and
 *  limitations under the respective licenses.
 ********************************************************************************/

// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.21;

import {StatisticsType} from "src/v0.8/types/StatisticsType.sol";

library FinanceStatisticsLIB {
    /// @notice Adds an amount to the total balance.
    function addTotal(
        StatisticsType.FinanceStatistics storage self,
        uint256 size
    ) internal {}

    /// @notice Subtracts an amount from the total balance.
    function subTotal(
        StatisticsType.FinanceStatistics storage self,
        uint256 size
    ) internal {}

    /// @notice Sets the escrow balance.
    function setEscrow(
        StatisticsType.FinanceStatistics storage self,
        uint256 size
    ) internal {}

    /// @notice Sets the locked balance.
    function setLocked(
        StatisticsType.FinanceStatistics storage self,
        uint256 size
    ) internal {}

    /// @notice Retrieves an overview of the finance statistics.
    function getOverview(
        StatisticsType.FinanceStatistics storage self
    )
        internal
        view
        returns (
            uint256 total,
            uint256 available,
            uint256 escrow,
            uint256 locked
        )
    {}
}

library BasicFinanceStatisticsLIB {
    /// @notice Adds an amount to the balance.
    function add(uint256 balance, uint256 size) internal {}

    /// @notice Subtracts an amount from the balance.
    function sub(uint256 balance, uint256 size) internal {}

    /// @notice Returns an overview of the balance.
    function get() internal returns (uint256) {}
}
