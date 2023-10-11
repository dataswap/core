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

import {EscrowType} from "src/v0.8/types/EscrowType.sol";

/// @title EscrowLIB
/// @dev This library provides functions for managing the escrow.
/// @notice Library for managing operations related to escrow.
library EscrowLIB {
    function deposit(EscrowType.Escrow storage self, uint256 _total) internal {
        self.owner.total += _total;
    }

    /// @dev Increases the total and collateral balances for the escrow owner and updates the creation block number.
    /// @param self The Escrow object.
    /// @param _amount The collateral funds.
    function collateral(
        EscrowType.Escrow storage self,
        uint256 _amount
    ) internal {
        require(
            self.owner.total >=
                _amount + self.owner.collateral + self.owner.lock,
            "collateral > total"
        );
        self.owner.collateral += _amount;
        self.owner.createdBlockNumber = uint64(block.number);
    }

    /// @dev Calculates and returns the amount available for withdrawal and reduces the total balance accordingly.
    /// @param self The Escrow object.
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
    /// @param self The Escrow object.
    /// @param _amount The collateral funds.
    function updateCollateral(
        EscrowType.Escrow storage self,
        uint256 _amount
    ) internal {
        self.owner.collateral = _amount;
    }

    /// @dev Decreases the total and collateral balances for the escrow owner and increases the burned balance.
    /// @param self The Escrow object.
    /// @param _amount The collateral funds.
    function burn(EscrowType.Escrow storage self, uint256 _amount) internal {
        self.owner.total -= _amount;
        self.owner.collateral -= _amount;
        self.owner.burned += _amount;
    }

    /// @dev Deposits funds into the escrow, locking them for a payment, and updates creation information.
    /// @param self The Escrow object.
    /// @param _amount The collateral funds.
    function paymentCollateral(
        EscrowType.Escrow storage self,
        uint256 _amount
    ) internal {
        require(
            self.owner.total >=
                _amount + self.owner.lock + self.owner.collateral,
            "payment > total"
        );
        self.owner.lock += _amount;
        self.owner.createdBlockNumber = uint64(block.number);
    }

    /// @dev Add beneficiary to payment escrow, and updates creation information.
    /// @param self The Escrow object.
    /// @param _beneficiary The beneficiary address for the payment credited funds.
    /// @param _amount The payment funds.
    function paymentAddbeneficiary(
        EscrowType.Escrow storage self,
        address _beneficiary,
        uint256 _amount
    ) internal {
        if (self.beneficiaries[_beneficiary].createdBlockNumber == 0) {
            self.beneficiariesList.push(_beneficiary);
        }
        require(self.owner.lock >= _amount, "Exceeds the amount of payment");

        self.beneficiaries[_beneficiary].total += _amount;
        self.beneficiaries[_beneficiary].collateral += _amount;
        self.beneficiaries[_beneficiary].createdBlockNumber = uint64(
            block.number
        );
    }

    /// @dev Calculates the amount available for withdrawal by a beneficiary and adjusts balances accordingly.
    /// @param self The Escrow object.
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

    /// @dev Updates the collateral balance for a specific beneficiary in the escrow.
    /// @param self The Escrow object.
    /// @param _beneficiary The beneficiary address for the payment credited funds.
    /// @param _amount The collateral funds.
    function updatePaymentCollateral(
        EscrowType.Escrow storage self,
        address _beneficiary,
        uint256 _amount
    ) internal {
        self.beneficiaries[_beneficiary].collateral = _amount;
    }

    /// @dev Refunds funds to a beneficiary, reducing their total and collateral balances and unlocking the owner's funds.
    /// @param self The Escrow object.
    /// @param _beneficiary The beneficiary address for the payment credited funds.
    /// @param _amount The collateral funds.
    function paymentRefund(
        EscrowType.Escrow storage self,
        address _beneficiary,
        uint256 _amount
    ) internal {
        self.beneficiaries[_beneficiary].total -= _amount;
        self.beneficiaries[_beneficiary].collateral -= _amount;

        self.owner.lock -= _amount;
    }
}
