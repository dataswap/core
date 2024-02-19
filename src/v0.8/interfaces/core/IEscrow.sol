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

/// @title IEscrow
/// @dev This IEscrow provides Escrow-related interface.
interface IEscrow {
    /// @dev Retrieves payee information for EscrowDataTradingFee.
    /// @param _datasetId The ID of the dataset.
    /// @param _matchingId The ID of the matching process.
    /// @param _token The type of token for escrow handling (e.g., FIL, ERC-20).
    /// @return paymentsInfo An array containing the payees's address.
    function getPayeeInfo(
        uint64 _datasetId,
        uint64 _matchingId,
        address _token
    ) external view returns (FinanceType.PaymentInfo[] memory paymentsInfo);

    /// @notice Get dataset pre-conditional collateral requirement.
    /// @param _datasetId The ID of the dataset.
    /// @param _matchingId The ID of the matching associated with the dataset.
    /// @param _owner An array containing the addresses of the dataset and matching process owners.
    /// @param _token The address of the token used for escrow.
    /// @return amount The collateral requirement amount.
    function getRequirement(
        uint64 _datasetId,
        uint64 _matchingId,
        address _owner,
        address _token
    ) external view returns (uint256 amount);
}
