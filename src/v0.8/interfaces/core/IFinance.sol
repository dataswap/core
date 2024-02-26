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

import {FinanceType} from "src/v0.8/types/FinanceType.sol";
import {IBusinessFinanceStatistics} from "src/v0.8/interfaces/core/statistics/IBusinessFinanceStatistics.sol";
import {IMemberFinanceStatistics} from "src/v0.8/interfaces/core/statistics/IMemberFinanceStatistics.sol";

/// @title IPayment Interface
/// @notice This interface defines the payment-related functions within the system.
/// @notice instance example,type: mapping(uint256 => mapping(uint256 => mapping(address => mapping(address=>Account))));
///                       explain: mapping(datasetId => mapping(matchingId => mapping(sc/sp/da/dp => mapping(tokentype=>Account))));
///                       If matchingId is set to 0, it indicates the dataset phase.
interface IFinance is IBusinessFinanceStatistics, IMemberFinanceStatistics {
    /// @dev Records the deposited amount for a given dataset and matching ID.
    /// @param _datasetId The ID of the dataset.
    /// @param _matchingId The ID of the matching process.
    /// @param _owner The address of the account owner.
    /// @param _token The type of token used for the deposit (e.g., FIL, ERC-20).
    function deposit(
        uint64 _datasetId,
        uint64 _matchingId,
        address _owner,
        address _token
    ) external payable;

    /// @dev Initiates a withdrawal of funds from the system.
    /// @param _datasetId The ID of the dataset.
    /// @param _matchingId The ID of the matching process.
    /// @param _owner The address of the account owner.
    /// @param _token The type of token for withdrawal (e.g., FIL, ERC-20).
    /// @param _amount The amount to be withdrawn.
    function withdraw(
        uint64 _datasetId,
        uint64 _matchingId,
        address payable _owner,
        address _token,
        uint256 _amount
    ) external;

    /// @dev Initiates an escrow of funds for a given dataset, matching ID, and escrow type.
    /// @param _datasetId The ID of the dataset.
    /// @param _matchingId The ID of the matching process.
    /// @param _token The type of token for escrow (e.g., FIL, ERC-20).
    /// @param _type The type of escrow (e.g., deposit, payment).
    function escrow(
        uint64 _datasetId,
        uint64 _matchingId,
        address _token,
        FinanceType.Type _type
    ) external;

    /// @dev Initiates an escrow of funds for a given dataset, matching ID, and escrow type.
    /// @param _datasetId The ID of the dataset.
    /// @param _matchingId The ID of the matching process.
    /// @param _owner The address of the account owner.
    /// @param _token The type of token for escrow (e.g., FIL, ERC-20).
    /// @param _type The type of escrow (e.g., deposit, payment).
    /// @param _amount The amount to be escrow.
    function __escrow(
        uint64 _datasetId,
        uint64 _matchingId,
        address _owner,
        address _token,
        FinanceType.Type _type,
        uint256 _amount
    ) external;

    /// @dev Handles an escrow, such as claiming or processing it.
    /// @param _datasetId The ID of the dataset.
    /// @param _matchingId The ID of the matching process.
    /// @param _token The type of token for escrow handling (e.g., FIL, ERC-20).
    /// @param _type The type of escrow (e.g., deposit, payment).
    function claimEscrow(
        uint64 _datasetId,
        uint64 _matchingId,
        address _token,
        FinanceType.Type _type
    ) external;

    /// @dev Handles an escrow, move escrow to owner's destination account.
    /// @param _datasetId The ID of the dataset.
    /// @param _destMatchingId The ID of the matching.
    /// @param _token The type of token for escrow handling (e.g., FIL, ERC-20).
    /// @param _type The type of escrow (e.g., deposit, payment).
    function __claimMoveEscrow(
        uint64 _datasetId,
        uint64 _destMatchingId,
        address _token,
        FinanceType.Type _type
    ) external;

    /// @dev Retrieves an account's overview, including deposit, withdraw, burned, balance, lock, escrow.
    /// @param _datasetId The ID of the dataset.
    /// @param _matchingId The ID of the matching process.
    /// @param _token The type of token for the account overview (e.g., FIL, ERC-20).
    /// @param _owner The address of the account owner.
    function getAccountOverview(
        uint64 _datasetId,
        uint64 _matchingId,
        address _owner,
        address _token
    )
        external
        view
        returns (
            uint256 deposited,
            uint256 withdrawn,
            uint256 burned,
            uint256 balance,
            uint256 available,
            uint256 lock,
            uint256 escrow
        );

    /// @dev Retrieves trading income details for an account.
    /// @param _datasetId The ID of the dataset.
    /// @param _matchingId The ID of the matching process.
    /// @param _token The type of token for trading income details (e.g., FIL, ERC-20).
    /// @param _type The type of escrow (e.g., deposit, payment).
    /// @param _owner The address of the account owner.
    function getAccountIncome(
        uint64 _datasetId,
        uint64 _matchingId,
        address _owner,
        address _token,
        FinanceType.Type _type
    ) external view returns (uint256 total, uint256 lock);

    /// @dev Retrieves escrowed amount for an account.
    /// @param _datasetId The ID of the dataset.
    /// @param _matchingId The ID of the matching process.
    /// @param _owner The address of the account owner.
    /// @param _token The type of token for the escrowed amount (e.g., FIL, ERC-20).
    /// @param _type The type of escrow (e.g., deposit, payment).
    function getAccountEscrow(
        uint64 _datasetId,
        uint64 _matchingId,
        address _owner,
        address _token,
        FinanceType.Type _type
    )
        external
        view
        returns (
            uint64 latestHeight,
            uint256 expenditure,
            uint256 current,
            uint256 total
        );

    /// @dev Retrieves the escrow requirement for a specific dataset, matching process, and token type.
    /// @param _datasetId The ID of the dataset.
    /// @param _matchingId The ID of the matching process.
    /// @param _owner The address of the account owner.
    /// @param _token The type of token for the escrow requirement (e.g., FIL, ERC-20).
    /// @return amount The required escrow amount for the specified dataset, matching process, and token type.
    function getEscrowRequirement(
        uint64 _datasetId,
        uint64 _matchingId,
        address _owner,
        address _token,
        FinanceType.Type _type
    ) external view returns (uint256 amount);

    /// @notice Checks if the escrowed funds are sufficient for a given dataset, matching, token, and finance type.
    /// @dev This function returns true if the escrowed funds are enough, otherwise, it returns false.
    /// @param _datasetId The ID of the dataset.
    /// @param _matchingId The ID of the matching associated with the dataset.
    /// @param _owner The address of the account owner.
    /// @param _token The address of the token used for escrow.
    /// @param _type The finance type indicating the purpose of the escrow.
    /// @return A boolean indicating whether the escrowed funds are enough.
    function isEscrowEnough(
        uint64 _datasetId,
        uint64 _matchingId,
        address _owner,
        address _token,
        FinanceType.Type _type
    ) external view returns (bool);
}
