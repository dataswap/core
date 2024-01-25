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

/// @title IPayment Interface
/// @notice This interface defines the payment-related functions within the system.
/// @notice instance example,type: mapping(uint256 => mapping(uint256 => mapping(address => mapping(address=>Account))));
///                       explain: mapping(datasetId => mapping(matchingId => mapping(sc/sp/da/dp => mapping(tokentype=>Account))));
///                       If matchingId is set to 0, it indicates the dataset phase.
interface IFinance {
    /// @dev Records the deposited amount for a given dataset and matching ID.
    /// @param _datasetId The ID of the dataset.
    /// @param _matchingId The ID of the matching process.
    /// @param _token The type of token used for the deposit (e.g., FIL, ERC-20).
    /// @param _owner The address of the owner.
    function deposit(
        uint64 _datasetId,
        uint64 _matchingId,
        address _token,
        address _owner
    ) external payable;

    /// @dev Initiates a withdrawal of funds from the system.
    /// @param _datasetId The ID of the dataset.
    /// @param _matchingId The ID of the matching process.
    /// @param _token The type of token for withdrawal (e.g., FIL, ERC-20).
    /// @param _amount The amount to be withdrawn.
    function withdraw(
        uint64 _datasetId,
        uint64 _matchingId,
        address _token,
        uint256 _amount,
        address payable _owner
    ) external;

    /// @dev Initiates an escrow of funds for a given dataset, matching ID, and escrow type.
    /// @param _datasetId The ID of the dataset.
    /// @param _matchingId The ID of the matching process.
    /// @param _token The type of token for escrow (e.g., FIL, ERC-20).
    /// @param _amount The amount to be escrowed.
    /// @param _type The type of escrow (e.g., deposit, payment).
    function escrow(
        uint64 _datasetId,
        uint64 _matchingId,
        address _token,
        uint256 _amount,
        FinanceType.Type _type
    ) external;

    /// @dev Handles an escrow, such as claiming or processing it.
    /// @param _datasetId The ID of the dataset.
    /// @param _matchingId The ID of the matching process.
    /// @param _token The type of token for escrow handling (e.g., FIL, ERC-20).
    /// @param _type The type of escrow (e.g., deposit, payment).
    /// @param _owner The address of the account owner.
    /// @param _payee An array of addresses representing the payees involved in the escrow.
    /// @param _amount An array of uint256 representing the amounts corresponding to each payee.
    function claimEscrow(
        uint64 _datasetId,
        uint64 _matchingId,
        address _token,
        address _owner,
        FinanceType.Type _type,
        address[] memory _payee,
        uint256[] memory _amount
    ) external;

    /// @dev Retrieves an account's overview, including deposit, withdraw, burned, balance, lock, escrow, and collateral.
    /// @param _datasetId The ID of the dataset.
    /// @param _matchingId The ID of the matching process.
    /// @param _token The type of token for the account overview (e.g., FIL, ERC-20).
    /// @param _owner The address of the account owner.
    function getAccountOverview(
        uint64 _datasetId,
        uint64 _matchingId,
        address _token,
        address _owner
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
            uint256 escrow,
            uint256 collateral
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
        address _token,
        FinanceType.Type _type,
        address _owner
    ) external view returns (uint256 total, uint256 lock);

    /// @dev Retrieves escrowed amount for an account.
    /// @param _datasetId The ID of the dataset.
    /// @param _matchingId The ID of the matching process.
    /// @param _token The type of token for the escrowed amount (e.g., FIL, ERC-20).
    /// @param _type The type of escrow (e.g., deposit, payment).
    /// @param _owner The address of the account owner.
    /// @return amount The amount of escrowed funds for the specified account.
    function getAccountEscrow(
        uint64 _datasetId,
        uint64 _matchingId,
        address _token,
        FinanceType.Type _type,
        address _owner
    ) external view returns (uint256 amount);

    /// @dev Retrieves the escrow requirement for a specific dataset, matching process, and token type.
    /// @param _datasetId The ID of the dataset.
    /// @param _matchingId The ID of the matching process.
    /// @param _token The type of token for the escrow requirement (e.g., FIL, ERC-20).
    /// @return amount The required escrow amount for the specified dataset, matching process, and token type.
    /// Note: TypeX_EscrowLibrary needs to include the following methods.
    /// .     function getRequirement(
    ///         uint64 _datasetId,
    ///         uint64 _matchingId,
    ///         address _token
    ///       ) public view returns (uint256 amount);
    function getEscrowRequirement(
        uint64 _datasetId,
        uint64 _matchingId,
        address _token,
        FinanceType.Type _type
    ) external view returns (uint256 amount);

    /// @dev Retrieves payee information for the escrow, including addresses and corresponding amounts.
    /// @param _datasetId The ID of the dataset.
    /// @param _matchingId The ID of the matching process.
    /// @param _token The type of token for the escrowed amount (e.g., FIL, ERC-20).
    /// Note: TypeX_EscrowLibrary needs to include the following methods.
    /// .     function isMetClaimEscrowCondition(
    ///         uint64 _datasetId,
    ///         uint64 _matchingId,
    ///         address _token
    ///       ) external view returns (bool);
    function isMetClaimEscrowCondition(
        uint64 _datasetId,
        uint64 _matchingId,
        address _token,
        FinanceType.Type _type
    ) external view returns (bool);
}
