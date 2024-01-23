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

import {Errors} from "src/v0.8/shared/errors/Errors.sol";
import {FinanceType} from "src/v0.8/types/FinanceType.sol";

/// @title FinanceLIB
/// @dev This library provides functions for managing the finance operations.
/// @notice Library for managing operations related to finance.
library FinanceLIB {
    /// @dev Deposits funds into the account.
    /// @param self The storage reference to the account.
    /// @param _amount The amount to deposit.
    function _deposit(
        FinanceType.Account storage self,
        uint256 _amount
    ) internal {
        self.statistics.deposited += _amount;
        self.total += _amount;
    }

    /// @dev Withdraws funds from the account.
    /// @param self The account to withdraw funds from.
    /// @param _amount The amount of funds to withdraw.
    function _withdraw(
        FinanceType.Account storage self,
        uint256 _amount
    ) internal {
        uint256 available = self.total -
            _getValidEscrows(self) -
            _getLocks(self);
        if (_amount > available) {
            revert Errors.ExceedValidWithdrawAmount(available, _amount);
        }
        self.statistics.withdrawn += _amount;
        self.total -= _amount;
    }

    /// @dev Escrows funds in the account.
    /// @param self The account to escrow funds in.
    /// @param _amount The amount of funds to escrow.
    function _escrow(
        FinanceType.Account storage self,
        FinanceType.Type _type,
        uint256 _amount
    ) internal {
        uint256 available = self.total -
            _getValidEscrows(self) -
            _getLocks(self);
        if (_amount > available) {
            revert Errors.ExceedValidEscrowAmount(available, _amount);
        }
        self.escrow[_type].total += _amount;
        self.escrow[_type].latestHeight = uint64(block.number);
    }

    /// @dev Income funds in the account.
    /// @param self The account to income funds in.
    /// @param _amount The amount of funds to income.
    function _income(
        FinanceType.Account storage self,
        FinanceType.Type _type,
        uint256 _amount
    ) internal {
        self.income[_type].push(
            FinanceType.IncomePaymentUnit(uint64(block.number), _amount)
        );
        self.total += _amount;
    }

    /// @dev payment funds in the account.
    /// @param self The account to payment funds in.
    /// @param _amount The amount of funds to payment.
    function _payment(
        FinanceType.Account storage self,
        FinanceType.Type _type,
        uint256 _amount
    ) internal {
        uint256 available = _getValidEscrow(self, _type);
        if (_amount > available) {
            revert Errors.ExceedValidPaymentAmount(available, _amount);
        }
        self.escrow[_type].expenditure += _amount;
        self.total -= _amount;
    }

    /// @dev Income funds in the account.
    /// @param self The account to income funds in.
    /// @param _amount The amount of funds to income.
    function _burn(
        FinanceType.Account storage self,
        FinanceType.Type _type,
        uint256 _amount
    ) internal {
        uint256 available = _getValidEscrow(self, _type);
        if (_amount > available) {
            revert Errors.ExceedValidBurnAmount(available, _amount);
        }
        self.escrow[_type].expenditure += _amount;
        self.statistics.burned += _amount;
        self.total -= _amount;
    }

    /// @dev Gets the escrowed amount for a specific type.
    /// @param self The account to retrieve escrowed amount from.
    /// @param _type The type of escrow (e.g., deposit, payment).
    /// @return amount The total escrowed amount for the specified type.
    function _getValidEscrow(
        FinanceType.Account storage self,
        FinanceType.Type _type
    ) internal view returns (uint256 amount) {
        amount = self.escrow[_type].total - self.escrow[_type].expenditure;
    }

    /// @dev Retrieves the last height of the escrow in the account.
    /// @param self The finance account to retrieve escrow information from.
    /// @return height The last recorded height of the escrow.
    function _getEscrowLastHeight(
        FinanceType.Account storage self,
        FinanceType.Type _type
    ) internal view returns (uint64 latestHeight) {
        latestHeight = self.escrow[_type].latestHeight;
    }

    /// @dev Gets the total escrowed amount for all types.
    /// @param self The account to retrieve escrowed amount from.
    /// @return amount The total escrowed amount for all types.
    function _getValidEscrows(
        FinanceType.Account storage self
    ) internal view returns (uint256 amount) {
        for (uint256 i = 0; i < uint256(FinanceType.Type.End); i++) {
            amount += _getValidEscrow(self, FinanceType.Type(i));
        }
    }

    /// @dev Gets the locked amount in the account.
    /// @param self The account to retrieve locked amount from.
    /// @return amount The locked amount in the account.
    function _getSingleLock(
        FinanceType.Account storage self,
        FinanceType.Type _type,
        uint64 _index
    ) internal view returns (uint256 amount) {
        amount = 0; //TODO: Release mechanism to be updated
    }

    /// @dev Gets the locked amount in the account.
    /// @param self The account to retrieve locked amount from.
    /// @return amount The locked amount in the account.
    function _getLock(
        FinanceType.Account storage self,
        FinanceType.Type _type
    ) internal view returns (uint256 amount) {
        amount = 0; //TODO: Release mechanism to be updated
    }

    /// @dev Gets all the locked amount in the account.
    /// @param self The account to retrieve locked amount from.
    /// @return amount The locked amount in the account.
    function _getLocks(
        FinanceType.Account storage self
    ) internal view returns (uint256 amount) {
        amount = 0; //TODO: Release mechanism to be updated
    }

    /// @dev Retrieves trading income details for an account.
    /// @param _datasetId The ID of the dataset.
    /// @param _matchingId The ID of the matching process.
    /// @param _token The type of token for trading income details (e.g., FIL, ERC-20).
    /// @param _type The type of escrow (e.g., deposit, payment).
    /// @param _owner The address of the account owner.
    function _getAccountIncome(
        FinanceType.Account storage self,
        FinanceType.Type _type
    )
        internal
        view
        returns (
            uint64[] memory height,
            uint256[] memory amount,
            uint256[] memory lock
        )
    {
        uint256 length = self.income[_type].length;
        height = new uint64[](length);
        amount = new uint256[](length);
        lock = new uint256[](length);
        for (uint256 i = 0; i < length; i++) {
            height[i] = self.income[_type].height[i];
            amount[i] = self.income[_type].amount[i];
            lock[i] = self._getSingleLock(_type, i);
        }
    }

    /// @dev Retrieves escrowed amount for an account.
    /// @param self The account to retrieve locked amount from.
    /// @return amount The amount of escrowed funds for the specified account.
    function _getAccountEscrow(
        FinanceType.Account storage self,
        FinanceType.Type _type
    )
        external
        view
        returns (uint64 latestHeight, uint256 expenditure, uint256 total)
    {
        latestHeight = self.escrow[_type].latestHeight;
        expenditure = self.escrow[_type].expenditure;
        total = self.escrow[_type].total;
    }
}
