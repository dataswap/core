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

/// @title FinanceAccountLIB
/// @dev This library provides functions for managing the finance operations.
/// @notice Library for managing operations related to finance.
library FinanceAccountLIB {
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
    ) internal notExceedValidAmount(self, _amount) {
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
    ) internal notExceedValidAmount(self, _amount) {
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
    ) internal notExceedValidEscrowAmount(self, _type, _amount) {
        self.escrow[_type].expenditure += _amount;
        self.total -= _amount;
    }

    /// @dev Burn funds in the account. only for counting.
    /// @param self The account to burn funds in.
    /// @param _amount The amount of funds to burn.
    function _burn(FinanceType.Account storage self, uint256 _amount) internal {
        self.statistics.burned += _amount;
    }

    /// @dev Retrieves an account's overview, including deposit, withdraw, burned, balance, lock, escrow.
    /// @param self The account to overview.
    function _getAccountOverview(
        FinanceType.Account storage self
    )
        internal
        view
        returns (
            uint256 deposited,
            uint256 withdrawn,
            uint256 burned,
            uint256 balance,
            uint256 available,
            uint256 locks,
            uint256 escrows
        )
    {
        deposited = self.statistics.deposited;
        withdrawn = self.statistics.withdrawn;
        burned = self.statistics.burned;
        balance = self.total;
        available = self.total - _getValidEscrows(self) - _getLocks(self);
        locks = _getLocks(self);
        escrows = _getValidEscrows(self);
    }

    /// @dev Retrieves trading income details for an account.
    /// @param _type The type of escrow (e.g., deposit, payment).
    function _getAccountIncome(
        FinanceType.Account storage self,
        FinanceType.Type _type
    ) internal view returns (uint256 total, uint256 lock) {
        for (uint256 i = 0; i < self.income[_type].length; i++) {
            total += self.income[_type][i].amount;
            lock += _getSingleLock(self, _type, i);
        }
    }

    /// @dev Retrieves escrowed amount for an account.
    /// @param self The account to retrieve locked amount from.
    function _getAccountEscrow(
        FinanceType.Account storage self,
        FinanceType.Type _type
    )
        internal
        view
        returns (
            uint64 latestHeight,
            uint256 expenditure,
            uint256 current,
            uint256 total
        )
    {
        latestHeight = self.escrow[_type].latestHeight;
        expenditure = self.escrow[_type].expenditure;
        total = self.escrow[_type].total;
        current = total - expenditure;
    }

    /// @dev Retrieves the last height of the escrow in the account.
    /// @param self The finance account to retrieve escrow information from.
    /// @return latestHeight The last recorded height of the escrow.
    function _getEscrowLastHeight(
        FinanceType.Account storage self,
        FinanceType.Type _type
    ) internal view returns (uint64 latestHeight) {
        latestHeight = self.escrow[_type].latestHeight;
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

    /// @dev Gets the single income lock amount in the account.
    /// @return amount The locked amount in the account.
    function _getSingleLock(
        FinanceType.Account storage /*self*/,
        FinanceType.Type /*_type*/,
        uint256 /*_index*/
    ) internal pure returns (uint256 amount) {
        amount = 0; //TODO: Release mechanism to be updated
    }

    /// @dev Gets the locked amount in the account.
    /// @return amount The locked amount in the account.
    function _getLock(
        FinanceType.Account storage /*self*/,
        FinanceType.Type /*_type*/
    ) internal pure returns (uint256 amount) {
        amount = 0; //TODO: Release mechanism to be updated
    }

    /// @dev Gets all the locked amount in the account.
    /// @return amount The locked amount in the account.
    function _getLocks(
        FinanceType.Account storage /*self*/
    ) internal pure returns (uint256 amount) {
        amount = 0; //TODO: Release mechanism to be updated
    }

    /// @dev Modifier that checks if the given amount does not exceed the valid available amount.
    /// @param self The storage reference to the FinanceType.Account.
    /// @param _amount The amount to check against the available amount.
    modifier notExceedValidAmount(
        FinanceType.Account storage self,
        uint256 _amount
    ) {
        uint256 available = self.total -
            _getValidEscrows(self) -
            _getLocks(self);
        if (_amount > available) {
            revert Errors.ExceedValidAmount(available, _amount);
        }
        _;
    }

    /// @dev Modifier that checks if the given amount does not exceed the valid escrow amount for a specific type.
    /// @param self The storage reference to the FinanceType.Account.
    /// @param _type The FinanceType.Type specifying the escrow type.
    /// @param _amount The amount to check against the available escrow amount.
    modifier notExceedValidEscrowAmount(
        FinanceType.Account storage self,
        FinanceType.Type _type,
        uint256 _amount
    ) {
        uint256 available = _getValidEscrow(self, _type);
        if (_amount > available) {
            revert Errors.ExceedValidEscrowAmount(available, _amount);
        }
        _;
    }
}
