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
    /// @notice Retrieves all members registered in the system.
    /// @return _members An array containing the addresses of all registered members.
    function getAllAccounts() external view returns (address[] memory _members);

    /// @notice Retrieves the overview of an member's financial state.
    /// @param _member The address of the member to retrieve the overview for.
    /// @param _token The type of token used for the deposit (e.g., FIL, ERC-20).
    /// @return total The total balance of the member.
    /// @return available The available balance of the member.
    /// @return escrow The escrow balance of the member.
    /// @return locked The locked balance of the member.
    function getAccountOverview(
        address _member,
        address _token
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
