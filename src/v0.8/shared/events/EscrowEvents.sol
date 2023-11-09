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

/// @title EscrowEvents
library EscrowEvents {
    /// @notice Report a collateral event.
    /// @dev This function allows report the collateral event of a specific amount in attoFIL.
    /// @param _type The Escrow type for the credited funds.
    /// @param _owner The destination address for the credited funds.
    /// @param _id The business id associated with the credited funds.
    /// @param _attoFILAmount The amount of attoFIL.
    event Collateral(
        EscrowType.Type _type,
        address indexed _owner,
        uint64 _id,
        uint256 _attoFILAmount
    );

    /// @notice Report a withdrawal event.
    /// @dev This function allows report the withdrawal event of funds.
    /// @param _type The Escrow type for the credited funds.
    /// @param _owner The destination address for the credited funds.
    /// @param _id The business id associated with the credited funds.
    /// @param _attoFILAmount The amount of attoFIL.
    event Withdrawn(
        EscrowType.Type _type,
        address indexed _owner,
        uint64 _id,
        uint256 _attoFILAmount
    );

    /// @notice Report a update collateral event.
    /// @dev This function allows report the update collateral event of funds.
    /// @param _type The Escrow type for the credited funds.
    /// @param _owner The destination address for the credited funds.
    /// @param _id The business id associated with the credited funds.
    /// @param _attoFILAmount The amount of attoFIL.
    event UpdateCollateral(
        EscrowType.Type _type,
        address indexed _owner,
        uint64 _id,
        uint256 _attoFILAmount
    );

    /// @notice Report a burn event.
    /// @dev This function allows report the burn event.
    /// @param _type The Escrow type for the credited funds.
    /// @param _owner The destination address for the credited funds.
    /// @param _id The business id associated with the credited funds.
    /// @param _attoFILAmount The amount of attoFIL.
    event Burn(
        EscrowType.Type _type,
        address indexed _owner,
        uint64 _id,
        uint256 _attoFILAmount
    );

    /// @notice Report a payment event.
    /// @dev This function allows report the payment event of a specific amount in attoFIL.
    /// @param _type The Escrow type for the credited funds.
    /// @param _owner The destination address for the credited funds.
    /// @param _id The business id associated with the credited funds.
    /// @param _attoFILAmount The amount of attoFIL.
    event Payment(
        EscrowType.Type _type,
        address indexed _owner,
        uint64 _id,
        uint256 _attoFILAmount
    );

    /// @notice Report a payment transfer event.
    /// @dev This function allows report the payment transfer event of a specific amount in attoFIL.
    /// @param _type The Escrow type for the credited funds.
    /// @param _owner The destination address for the credited funds.
    /// @param _id The business id associated with the credited funds.
    /// @param _attoFILAmount The amount of attoFIL.
    event PaymentTransfer(
        EscrowType.Type _type,
        address indexed _owner,
        uint64 _id,
        uint256 _attoFILAmount
    );

    /// @notice Report a single beneficiary payment event.
    /// @dev This function allows report the payment event of a specific amount in attoFIL.
    /// @param _type The Escrow type for the credited funds.
    /// @param _owner The destination address for the credited funds.
    /// @param _id The business id associated with the credited funds.
    /// @param _beneficiary The beneficiary address for the payment credited funds.
    /// @param _attoFILAmount The amount of attoFIL.
    event PaymentSingleBeneficiary(
        EscrowType.Type _type,
        address indexed _owner,
        uint64 _id,
        address indexed _beneficiary,
        uint256 _attoFILAmount
    );

    /// @notice Report a PaymentWithdrawn event.
    /// @dev This function allows report the payment withdrawn event of a specific amount in attoFIL.
    /// @param _type The Escrow type for the credited funds.
    /// @param _owner The destination address for the credited funds.
    /// @param _id The business id associated with the credited funds.
    /// @param _beneficiary The beneficiary address for the payment credited funds.
    /// @param _attoFILAmount The amount of attoFIL.
    event PaymentWithdrawn(
        EscrowType.Type _type,
        address indexed _owner,
        uint64 _id,
        address indexed _beneficiary,
        uint256 _attoFILAmount
    );

    /// @notice Report a UpdatePaymentLock made by a _beneficiary.
    /// @dev This function allows report the payment collateral event of a specific amount in attoFIL.
    /// @param _type The Escrow type for the credited funds.
    /// @param _owner The destination address for the credited funds.
    /// @param _id The business id associated with the credited funds.
    /// @param _beneficiary The beneficiary address for the payment credited funds.
    /// @param _attoFILAmount The amount of attoFIL.
    event UpdatePaymentLock(
        EscrowType.Type _type,
        address indexed _owner,
        uint64 _id,
        address indexed _beneficiary,
        uint256 _attoFILAmount
    );

    /// @notice Report a UpdatePaymentSubAccount.
    /// @dev This function allows report the payment collateral event of a specific amount in attoFIL.
    /// @param _type The Escrow type for the credited funds.
    /// @param _owner The destination address for the credited funds.
    /// @param _id The business id associated with the credited funds.
    /// @param _beneficiary The beneficiary address for the payment credited funds.
    /// @param _attoFILAmount The amount of attoFIL.
    event UpdatePaymentSubAccount(
        EscrowType.Type _type,
        address indexed _owner,
        uint64 _id,
        address indexed _beneficiary,
        uint256 _attoFILAmount
    );

    /// @notice Report a UpdatePaymentBeneficiaries.
    /// @dev This function allows report the payment collateral event of a specific amount in attoFIL.
    /// @param _type The Escrow type for the credited funds.
    /// @param _owner The destination address for the credited funds.
    /// @param _id The business id associated with the credited funds.
    /// @param _beneficiary The beneficiary address for the payment credited funds.
    /// @param _attoFILAmount The payment funds.
    event UpdatePaymentBeneficiary(
        EscrowType.Type _type,
        address indexed _owner,
        uint64 _id,
        address _beneficiary,
        uint256 _attoFILAmount
    );

    /// @notice Report a PaymentRefund event.
    /// @dev This function allows report the payment refund event of a specific amount in attoFIL.
    /// @param _type The Escrow type for the credited funds.
    /// @param _owner The destination address for the credited funds.
    /// @param _id The business id associated with the credited funds.
    /// @param _beneficiary The beneficiary address for the payment credited funds.
    /// @param _attoFILAmount The amount of attoFIL.
    event PaymentRefund(
        EscrowType.Type _type,
        address indexed _owner,
        uint64 _id,
        address indexed _beneficiary,
        uint256 _attoFILAmount
    );
}
