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

interface IMemberFinanceStatistics {
    /// @notice Adds funds to the total balance of an account.
    function addAccountTotal(address _account, uint256 size) external;

    /// @notice Subtracts funds from the total balance of an account.
    function subAccountTotal(address _account, uint256 size) external;

    /// @notice Sets the escrow balance of an account.
    function setAccountEscrow(address _account, uint256 size) external;

    /// @notice Sets the locked balance of an account.
    function setAccountLocked(address _account, uint256 size) external;

    /// @notice Retrieves all accounts.
    function getAllAccounts() external returns (address[] memory _accounts);

    /// @notice Retrieves an overview of the finance statistics for a specific account.
    function getAccountOverview(
        address _account
    )
        external
        view
        returns (
            uint256 total,
            uint256 available,
            uint256 escrow,
            uint256 locked
        );
}
