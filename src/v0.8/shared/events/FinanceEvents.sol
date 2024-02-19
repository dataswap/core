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

import {FinanceType} from "src/v0.8/types/FinanceType.sol";

/// @title FinanceEvents
library FinanceEvents {
    /// @notice Event emitted when a deposit occurs.
    /// @dev This function allows reporting the collateral event of a specific amount in attoFIL.
    /// @param _datasetId The ID of the dataset.
    /// @param _matchingId The ID of the matching process.
    /// @param _owner The destination address for the credited funds.
    /// @param _token The type of token associated with the event.
    /// @param _attoFILAmount The amount of attoFIL involved in the event.
    event Deposit(
        uint64 _datasetId,
        uint64 _matchingId,
        address _owner,
        address _token,
        uint256 _attoFILAmount
    );

    /// @notice Event emitted when a withdrawal occurs.
    /// @dev This function allows reporting the withdrawal event of funds.
    /// @param _datasetId The ID of the dataset.
    /// @param _matchingId The ID of the matching process.
    /// @param _owner The destination address for the credited funds.
    /// @param _token The type of token associated with the event.
    /// @param _attoFILAmount The amount of attoFIL involved in the event.
    event Withdraw(
        uint64 _datasetId,
        uint64 _matchingId,
        address _owner,
        address _token,
        uint256 _attoFILAmount
    );

    /// @notice Event emitted when a collateral event occurs.
    /// @dev This function allows reporting the collateral event of a specific amount in attoFIL.
    /// @param _datasetId The ID of the dataset.
    /// @param _matchingId The ID of the matching process.
    /// @param _owner The destination address for the credited funds.
    /// @param _token The type of token associated with the event.
    /// @param _type The Escrow type for the credited funds.
    /// @param _attoFILAmount The amount of attoFIL involved in the event.
    event Escrow(
        uint64 _datasetId,
        uint64 _matchingId,
        address _owner,
        address _token,
        FinanceType.Type _type,
        uint256 _attoFILAmount
    );

    /// @notice Event emitted when a burn event occurs.
    /// @dev This function allows reporting the burn event.
    /// @param _datasetId The ID of the dataset.
    /// @param _matchingId The ID of the matching process.
    /// @param _owner The destination address for the credited funds.
    /// @param _token The type of token associated with the event.
    /// @param _type The Escrow type for the credited funds.
    /// @param _attoFILAmount The amount of attoFIL involved in the event.
    event Burn(
        uint64 _datasetId,
        uint64 _matchingId,
        address _owner,
        address _token,
        FinanceType.Type _type,
        uint256 _attoFILAmount
    );

    /// @notice Event emitted when a payment event occurs.
    /// @dev This function allows reporting the payment event.
    /// @param _datasetId The ID of the dataset.
    /// @param _matchingId The ID of the matching process.
    /// @param _owner The destination address for the credited funds.
    /// @param _token The type of token associated with the event.
    /// @param _type The Escrow type for the credited funds.
    /// @param _attoFILAmount The amount of attoFIL involved in the event.
    event Payment(
        uint64 _datasetId,
        uint64 _matchingId,
        address _owner,
        address _token,
        FinanceType.Type _type,
        uint256 _attoFILAmount
    );

    /// @notice Event emitted when an income event occurs.
    /// @dev This function allows reporting the income event.
    /// @param _datasetId The ID of the dataset.
    /// @param _matchingId The ID of the matching process.
    /// @param _owner The destination address for the credited funds.
    /// @param _token The type of token associated with the event.
    /// @param _type The Escrow type for the credited funds.
    /// @param _attoFILAmount The amount of attoFIL involved in the event.
    event Income(
        uint64 _datasetId,
        uint64 _matchingId,
        address _owner,
        address _token,
        FinanceType.Type _type,
        uint256 _attoFILAmount
    );
}
