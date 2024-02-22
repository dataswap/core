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
import {FinanceTestType} from "test/v0.8/types/FinanceTestType.sol";

/// @title IFinanceAssertion
/// @dev This interface defines assertion methods for testing finance-related functionality.
/// All methods that do not change the state must be tested by methods that will change the state to ensure test coverage.
interface IFinanceAssertion {
    /// @dev Assertion for depositing funds.
    /// @param _datasetId The ID of the dataset.
    /// @param _matchingId The ID of the matching process.
    /// @param _owner The address of the account owner.
    /// @param _token The type of token used for the deposit (e.g., FIL, ERC-20).
    function depositAssertion(
        uint64 _datasetId,
        uint64 _matchingId,
        address _owner,
        address _token
    ) external payable;

    /// @dev Assertion for withdrawing funds.
    /// @param _datasetId The ID of the dataset.
    /// @param _matchingId The ID of the matching process.
    /// @param _owner The address of the account owner.
    /// @param _token The type of token for withdrawal (e.g., FIL, ERC-20).
    /// @param _amount The amount to be withdrawn.
    function withdrawAssertion(
        uint64 _datasetId,
        uint64 _matchingId,
        address payable _owner,
        address _token,
        uint256 _amount
    ) external;

    /// @dev Assertion for escrowing funds.
    /// @param _datasetId The ID of the dataset.
    /// @param _matchingId The ID of the matching process.
    /// @param _owner The address of the account owner.
    /// @param _token The type of token for escrow (e.g., FIL, ERC-20).
    /// @param _type The type of escrow (e.g., deposit, payment).
    function escrowAssertion(
        uint64 _datasetId,
        uint64 _matchingId,
        address _owner,
        address _token,
        FinanceType.Type _type
    ) external;

    /// @dev Assertion for escrowing funds with a specified amount.
    /// @param _datasetId The ID of the dataset.
    /// @param _matchingId The ID of the matching process.
    /// @param _owner The address of the account owner.
    /// @param _token The type of token for escrow (e.g., FIL, ERC-20).
    /// @param _type The type of escrow (e.g., deposit, payment).
    /// @param _amount The amount to be escrowed.
    function __escrowAssertion(
        uint64 _datasetId,
        uint64 _matchingId,
        address _owner,
        address _token,
        FinanceType.Type _type,
        uint256 _amount
    ) external;

    /// @dev Assertion for getting the account overview.
    /// @param _datasetId The ID of the dataset.
    /// @param _matchingId The ID of the matching process.
    /// @param _owner The address of the account owner.
    /// @param _token The type of token for the account overview (e.g., FIL, ERC-20).
    /// @param _expectOverview The expected overview info.
    function getAccountOverviewAssertion(
        uint64 _datasetId,
        uint64 _matchingId,
        address _owner,
        address _token,
        FinanceTestType.OverviewInfo memory _expectOverview
    ) external;

    /// @dev Assertion for getting the account income details.
    /// @param _datasetId The ID of the dataset.
    /// @param _matchingId The ID of the matching process.
    /// @param _owner The address of the account owner.
    /// @param _token The type of token for trading income details (e.g., FIL, ERC-20).
    /// @param _type The type of escrow (e.g., deposit, payment).
    /// @param _expectTotal The expected total income amount in the account.
    /// @param _expectLock The expected locked income amount in the account.
    function getAccountIncomeAssertion(
        uint64 _datasetId,
        uint64 _matchingId,
        address _owner,
        address _token,
        FinanceType.Type _type,
        uint256 _expectTotal,
        uint256 _expectLock
    ) external;

    /// @dev Assertion for getting the account escrow details.
    /// @param _datasetId The ID of the dataset.
    /// @param _matchingId The ID of the matching process.
    /// @param _owner The address of the account owner.
    /// @param _token The type of token for the escrowed amount (e.g., FIL, ERC-20).
    /// @param _type The type of escrow (e.g., deposit, payment).
    /// @param _expectLatestHeight The expected latest height of the escrow.
    /// @param _expectExpenditure The expected escrowed expenditure amount.
    /// @param _expectCurrent The expected current escrowed amount.
    /// @param _expectTotal The expected total escrowed amount.
    function getAccountEscrowAssertion(
        uint64 _datasetId,
        uint64 _matchingId,
        address _token,
        address _owner,
        FinanceType.Type _type,
        uint64 _expectLatestHeight,
        uint256 _expectExpenditure,
        uint256 _expectCurrent,
        uint256 _expectTotal
    ) external;

    /// @dev Assertion for getting the escrow requirement.
    /// @param _datasetId The ID of the dataset.
    /// @param _matchingId The ID of the matching process.
    /// @param _owner The address of the account owner.
    /// @param _token The type of token for the escrow requirement (e.g., FIL, ERC-20).
    /// @param _type The type of escrow (e.g., deposit, payment).
    /// @param _expectAmount The required escrow amount for the specified dataset, matching process, and token type.
    function getEscrowRequirementAssertion(
        uint64 _datasetId,
        uint64 _matchingId,
        address _owner,
        address _token,
        FinanceType.Type _type,
        uint256 _expectAmount
    ) external;

    /// @dev Assertion for checking if the escrowed funds are enough.
    /// @param _datasetId The ID of the dataset.
    /// @param _matchingId The ID of the matching associated with the dataset.
    /// @param _owner The address of the account owner.
    /// @param _token The address of the token used for escrow.
    /// @param _type The finance type indicating the purpose of the escrow.
    /// @param _expectValue A boolean indicating the expected result for the escrowed funds (enough or not enough).
    function isEscrowEnoughAssertion(
        uint64 _datasetId,
        uint64 _matchingId,
        address _owner,
        address _token,
        FinanceType.Type _type,
        bool _expectValue
    ) external;
}
