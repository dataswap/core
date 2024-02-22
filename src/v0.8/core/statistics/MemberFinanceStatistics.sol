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
import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {IMemberFinanceStatistics} from "src/v0.8/interfaces/core/statistics/IMemberFinanceStatistics.sol";
import {StatisticsType} from "src/v0.8/types/StatisticsType.sol";
import {IRoles} from "src/v0.8/interfaces/core/IRoles.sol";
import {RolesModifiers} from "src/v0.8/shared/modifiers/RolesModifiers.sol";

abstract contract MemberFinanceStatistics is
    Initializable,
    IMemberFinanceStatistics,
    RolesModifiers
{
    mapping(address => StatisticsType.FinanceStatistics)
        private membersStatistics;

    address[] private members;
    IRoles roles;
    /// @dev This empty reserved space is put in place to allow future versions to add new
    uint256[32] private __gap;

    function memberFinanceStatisticsInitialize(
        address _roles
    ) public virtual onlyInitializing {
        roles = IRoles(_roles);
    }

    /// @notice Inserts a member into the system.
    /// @param _datasetId The ID of the dataset.
    /// @param _matchingId The ID of the matching process.
    /// @param _token The type of token for the account overview (e.g., FIL, ERC-20).
    /// @param _member The address of the member to insert.
    function _insertMemberAcount(
        uint64 _datasetId,
        uint64 _matchingId,
        address _token,
        address _member
    ) internal {
        StatisticsType.FinanceStatistics
            storage memberStatistics = membersStatistics[_member];
        if (!memberStatistics.records[_datasetId][_matchingId][_token]) {
            memberStatistics.records[_datasetId][_matchingId][_token] = true;
            memberStatistics.statistics.push(
                StatisticsType.MemberFinanceStatistics(
                    _datasetId,
                    _matchingId,
                    _token
                )
            );
        }
    }

    /// @notice Retrieves all members registered in the system.
    /// @return _members An array containing the addresses of all registered members.
    function getAllAccounts()
        external
        view
        returns (address[] memory _members)
    {
        return members;
    }

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
        )
    {
        for (
            uint64 i = 0;
            i < membersStatistics[_member].statistics.length;
            i++
        ) {
            (
                ,
                ,
                ,
                uint256 _balance,
                uint256 _available,
                uint256 _locks,
                uint256 _escrows
            ) = roles.finance().getAccountOverview(
                    membersStatistics[_member].statistics[i].datasetId,
                    membersStatistics[_member].statistics[i].matchingId,
                    _member,
                    _token
                );
            total += _balance;
            available += _available;
            escrow += _escrows;
            locked += _locks;
        }
    }
}
