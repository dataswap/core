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

// Importing Solidity libraries and contracts
import {DSTest} from "ds-test/test.sol";
import {Test} from "forge-std/Test.sol";

import {FinanceType} from "src/v0.8/types/FinanceType.sol";
import {FinanceTestType} from "test/v0.8/types/FinanceTestType.sol";

import {IFinance} from "src/v0.8/interfaces/core/IFinance.sol";
import {IFinanceAssertion} from "test/v0.8/interfaces/assertions/core/IFinanceAssertion.sol";

/// @notice This contract defines assertion functions for testing an IFinance contract.
/// @dev NOTE: All methods that do not change the state must be tested by methods that will change the state to ensure test coverage.
/// @dev NOTE: claimEscrow and __claimMoveEscrow Depend on the business environment and put it into business testing.

contract FinanceAssertion is DSTest, Test, IFinanceAssertion {
    IFinance public finance;

    constructor(IFinance _finance) {
        finance = _finance;
    }

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
    ) public {
        FinanceTestType.OverviewInfo memory overview;
        (
            overview.deposited,
            overview.withdrawn,
            overview.burned,
            overview.balance,
            overview.available,
            overview.lock,
            overview.escrow
        ) = finance.getAccountOverview(_datasetId, _matchingId, _owner, _token);
        assertEq(overview.deposited, _expectOverview.deposited);
        assertEq(overview.withdrawn, _expectOverview.withdrawn);
        assertEq(overview.burned, _expectOverview.burned);
        assertEq(overview.balance, _expectOverview.balance);
        assertEq(overview.available, _expectOverview.available);
        assertEq(overview.lock, _expectOverview.lock);
        assertEq(overview.escrow, _expectOverview.escrow);
    }

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
    ) public {
        (uint256 total, uint256 lock) = finance.getAccountIncome(
            _datasetId,
            _matchingId,
            _owner,
            _token,
            _type
        );
        assertEq(total, _expectTotal);
        assertEq(lock, _expectLock);
    }

    /// @dev Assertion for getting the account escrow details.
    /// @param _datasetId The ID of the dataset.
    /// @param _matchingId The ID of the matching process.
    /// @param _owner The address of the account owner.
    /// @param _token The type of token for the escrowed amount (e.g., FIL, ERC-20).
    /// @param _type The type of escrow (e.g., deposit, payment).
    /// @param _expectExpenditure The expected escrowed expenditure amount.
    /// @param _expectCurrent The expected current escrowed amount.
    /// @param _expectTotal The expected total escrowed amount.
    function getAccountEscrowAssertion(
        uint64 _datasetId,
        uint64 _matchingId,
        address _owner,
        address _token,
        FinanceType.Type _type,
        uint64 /*_expectLatestHeight*/,
        uint256 _expectExpenditure,
        uint256 _expectCurrent,
        uint256 _expectTotal
    ) public {
        (
            /*uint64 latestHeight*/,
            uint256 expenditure,
            uint256 current,
            uint256 total
        ) = finance.getAccountEscrow(
                _datasetId,
                _matchingId,
                _owner,
                _token,
                _type
            );
        // assertEq(latestHeight, _expectLatestHeight);
        assertEq(expenditure, _expectExpenditure);
        assertEq(current, _expectCurrent);
        assertEq(total, _expectTotal);
    }

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
    ) public {
        uint256 amount = finance.getEscrowRequirement(
            _datasetId,
            _matchingId,
            _owner,
            _token,
            _type
        );
        assertEq(amount, _expectAmount);
    }

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
    ) public {
        assertEq(
            finance.isEscrowEnough(
                _datasetId,
                _matchingId,
                _owner,
                _token,
                _type
            ),
            _expectValue
        );
    }

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
    ) external payable {
        FinanceTestType.OverviewInfo memory overview;
        (
            overview.deposited,
            overview.withdrawn,
            overview.burned,
            overview.balance,
            overview.available,
            overview.lock,
            overview.escrow
        ) = finance.getAccountOverview(_datasetId, _matchingId, _owner, _token);

        finance.deposit{value: msg.value}(
            _datasetId,
            _matchingId,
            _owner,
            _token
        );

        overview.deposited += msg.value;
        overview.balance += msg.value;
        overview.available += msg.value;

        getAccountOverviewAssertion(
            _datasetId,
            _matchingId,
            _owner,
            _token,
            overview
        );
    }

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
    ) external {
        FinanceTestType.OverviewInfo memory overview;
        (
            overview.deposited,
            overview.withdrawn,
            overview.burned,
            overview.balance,
            overview.available,
            overview.lock,
            overview.escrow
        ) = finance.getAccountOverview(_datasetId, _matchingId, _owner, _token);

        finance.withdraw(_datasetId, _matchingId, _owner, _token, _amount);

        overview.withdrawn += _amount;
        overview.balance -= _amount;
        getAccountOverviewAssertion(
            _datasetId,
            _matchingId,
            _owner,
            _token,
            overview
        );
    }

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
    ) external {
        (
            uint64 latestHeight,
            uint256 expenditure,
            uint256 current,
            uint256 total
        ) = finance.getAccountEscrow(
                _datasetId,
                _matchingId,
                _owner,
                _token,
                _type
            );

        isEscrowEnoughAssertion(
            _datasetId,
            _matchingId,
            _owner,
            _token,
            _type,
            false
        );

        finance.escrow(_datasetId, _matchingId, _token, _type);

        isEscrowEnoughAssertion(
            _datasetId,
            _matchingId,
            _owner,
            _token,
            _type,
            true
        );

        uint256 amount = finance.getEscrowRequirement(
            _datasetId,
            _matchingId,
            _owner,
            _token,
            _type
        );

        getEscrowRequirementAssertion(
            _datasetId,
            _matchingId,
            _owner,
            _token,
            _type,
            amount
        );

        getAccountEscrowAssertion(
            _datasetId,
            _matchingId,
            _owner,
            _token,
            _type,
            latestHeight,
            expenditure,
            current + amount,
            total + amount
        );
    }

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
    ) external {
        (
            uint64 latestHeight,
            uint256 expenditure,
            uint256 current,
            uint256 total
        ) = finance.getAccountEscrow(
                _datasetId,
                _matchingId,
                msg.sender,
                _token,
                _type
            );

        finance.__escrow(
            _datasetId,
            _matchingId,
            _owner,
            _token,
            _type,
            _amount
        );
        getAccountEscrowAssertion(
            _datasetId,
            _matchingId,
            msg.sender,
            _token,
            _type,
            latestHeight,
            expenditure,
            current + _amount,
            total + _amount
        );
    }
}
