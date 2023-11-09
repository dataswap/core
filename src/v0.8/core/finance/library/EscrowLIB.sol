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
import {EscrowType} from "src/v0.8/types/EscrowType.sol";

/// @title EscrowLIB
/// @dev This library provides functions for managing the escrow.
/// @notice Library for managing operations related to escrow.
library EscrowLIB {
    /// @dev Deposit funds into the escrow's owner total.
    /// This function increases the total amount owned by the escrow's owner.
    /// @param self The storage reference to the Escrow struct.
    /// @param _total The amount to be deposited.
    function deposit(EscrowType.Escrow storage self, uint256 _total) internal {
        self.owner.total += _total;
    }

    /// @dev Increases the collateral balances for the escrow owner and updates the creation block number.
    /// @param self The storage reference to the Escrow struct.
    /// @param _amount The collateral funds.
    function collateral(
        EscrowType.Escrow storage self,
        uint256 _amount
    ) internal {
        if (
            self.owner.total - self.owner.collateral - self.owner.lock < _amount
        ) {
            revert Errors.ExceedValidCollateralAmount(
                self.owner.total - self.owner.collateral - self.owner.lock,
                _amount
            );
        }

        self.owner.collateral += _amount;
        self.owner.createdBlockNumber = uint64(block.number);
    }

    /// @dev Calculates and returns the amount available for withdrawal and reduces the total balance accordingly.
    /// @param self The storage reference to the Escrow struct.
    function withdraw(
        EscrowType.Escrow storage self
    ) internal returns (uint256) {
        uint256 amount = self.owner.total -
            self.owner.collateral -
            self.owner.lock;

        self.owner.total -= amount;
        return amount;
    }

    /// @dev Updates the collateral balance for the escrow owner.
    /// @param self The storage reference to the Escrow struct.
    /// @param _amount The collateral funds.
    function updateCollateral(
        EscrowType.Escrow storage self,
        uint256 _amount
    ) internal {
        if (self.owner.total - self.owner.lock < _amount) {
            revert Errors.ExceedValidCollateralAmount(
                self.owner.total - self.owner.lock,
                _amount
            );
        }

        self.owner.collateral = _amount;
    }

    /// @dev Decreases the total and collateral balances for the escrow owner and increases the burned balance.
    /// @param self The storage reference to the Escrow struct.
    /// @param _amount The burned funds.
    function burn(EscrowType.Escrow storage self, uint256 _amount) internal {
        if (self.owner.collateral < _amount) {
            revert Errors.ExceedValidBurnAmount(self.owner.collateral, _amount);
        }
        self.owner.total -= _amount;
        self.owner.collateral -= _amount;
        self.owner.burned += _amount;
    }

    /// @dev Deposits funds into the escrow, locking them for a payment, and updates creation information.
    /// @param self The storage reference to the Escrow struct.
    /// @param _amount The payment lock funds.
    function payment(EscrowType.Escrow storage self, uint256 _amount) internal {
        if (
            self.owner.total - self.owner.lock - self.owner.collateral < _amount
        ) {
            revert Errors.ExceedValidPaymentAmount(
                self.owner.total - self.owner.lock - self.owner.collateral,
                _amount
            );
        }

        self.owner.lock += _amount;
        self.owner.createdBlockNumber = uint64(block.number);
    }

    /// @dev Transfer funds from payment lock to unlock.
    /// @param self The storage reference to the Escrow struct.
    /// @param _amount The unlock funds.
    function paymentTransfer(
        EscrowType.Escrow storage self,
        uint256 _amount
    ) internal {
        if (self.owner.lock < _amount) {
            revert Errors.ExceedValidTransferAmount(self.owner.lock, _amount);
        }

        self.owner.lock -= _amount;
    }

    /// @dev Add beneficiary to payment escrow, and updates creation information.
    /// @param self The storage reference to the Escrow struct.
    /// @param _beneficiary The beneficiary address for the payment credited funds.
    /// @param _amount The payment funds.
    function paymentAddbeneficiary(
        EscrowType.Escrow storage self,
        address _beneficiary,
        uint256 _amount
    ) internal {
        if (self.beneficiaries[_beneficiary].createdBlockNumber != 0) {
            revert Errors.BeneficiaryAlreadyExist(_beneficiary);
        }

        if (_amount == 0) return; // Skip

        uint256 usedAmount = 0;
        for (uint i = 0; i < self.beneficiariesList.length; i++) {
            usedAmount += self.beneficiaries[self.beneficiariesList[i]].total;
        }
        if (self.owner.lock - usedAmount < _amount) {
            revert Errors.ExceedValidPaymentAmount(
                self.owner.lock - usedAmount,
                _amount
            );
        }

        self.beneficiariesList.push(_beneficiary);

        self.beneficiaries[_beneficiary].total += _amount;
        self.beneficiaries[_beneficiary].lock += _amount;
        self.beneficiaries[_beneficiary].createdBlockNumber = uint64(
            block.number
        );
    }

    /// @dev Calculates the amount available for withdrawal by a beneficiary and adjusts balances accordingly.
    /// @param self The storage reference to the Escrow struct.
    /// @param _beneficiary The beneficiary address for the payment credited funds.
    /// @return The amount available for withdrawal by the beneficiary.
    function paymentWithdraw(
        EscrowType.Escrow storage self,
        address _beneficiary
    ) internal returns (uint256) {
        uint256 amount = self.beneficiaries[_beneficiary].total -
            self.beneficiaries[_beneficiary].collateral -
            self.beneficiaries[_beneficiary].lock;

        self.beneficiaries[_beneficiary].total -= amount;
        self.owner.total -= amount;
        self.owner.lock -= amount;

        return amount;
    }

    /// @dev Updates the lock balance for a specific beneficiary in the escrow.
    /// @param self The storage reference to the Escrow struct.
    /// @param _beneficiary The beneficiary address for the payment credited funds.
    /// @param _amount The lock funds.
    function updatePaymentLock(
        EscrowType.Escrow storage self,
        address _beneficiary,
        uint256 _amount
    ) internal {
        if (
            self.beneficiaries[_beneficiary].total -
                self.beneficiaries[_beneficiary].collateral <
            _amount
        ) {
            revert Errors.ExceedValidPaymentAmount(
                self.beneficiaries[_beneficiary].total -
                    self.beneficiaries[_beneficiary].collateral,
                _amount
            );
        }

        self.beneficiaries[_beneficiary].lock = _amount;
    }

    /// @dev Refunds funds to a owner, reducing their total and lock balances and unlocking the owner's funds.
    /// @notice Refunds beneficiary all lock funds.
    /// @param self The storage reference to the Escrow struct.
    /// @param _beneficiary The beneficiary address for the payment credited funds.
    function paymentRefund(
        EscrowType.Escrow storage self,
        address _beneficiary
    ) internal returns (uint256) {
        uint256 amount = self.beneficiaries[_beneficiary].lock;

        if (self.beneficiaries[_beneficiary].total < amount) {
            revert Errors.ExceedValidRefundAmount(
                self.beneficiaries[_beneficiary].total,
                amount
            );
        }

        self.beneficiaries[_beneficiary].total -= amount;
        self.owner.lock -= amount;

        self.beneficiaries[_beneficiary].lock -= 0;

        return amount;
    }

    /// @dev Refunds funds to a owner, unlocking all the owner's funds.
    /// @notice Refunds all payment lock funds.
    /// @param self The storage reference to the Escrow struct.
    function paymentRefundWithoutBeneficiary(
        EscrowType.Escrow storage self
    ) internal returns (uint256) {
        uint amount = self.owner.lock;
        self.owner.lock = 0;

        return amount;
    }
}
