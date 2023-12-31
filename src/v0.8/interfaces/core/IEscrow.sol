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

/// @title IEscrow Interface
/// @notice This interface defines the escrow-related functions within the system.
interface IEscrow {
    /// @dev Records the sent amount as credit for future withdrawals.
    /// Note Called by the payer to store the sent amount as credit to be pulled.
    /// Funds sent in this way are stored in an intermediate {Escrow} contract, so
    /// there is no danger of them being spent before withdrawal.
    /// @param _type The Escrow type for the credited funds.
    /// @param _owner The destination address for the credited funds.
    /// @param _id The business id associated with the credited funds.
    /// @param _amount The collateral funds.
    /// @notice Emits a {Collateral} event upon successful credit recording.
    function collateral(
        EscrowType.Type _type,
        address _owner,
        uint64 _id,
        uint256 _amount
    ) external payable;

    /// @notice Redeem funds authorized for an address.
    /// Redeem the collateral funds after the collateral expires.
    /// @param _type The Escrow type for the credited funds.
    /// @param _owner The destination address for the credited funds.
    /// @param _id The business id associated with the credited funds.
    /// @notice Emits a {UpdateCollateral} event upon successful credit recording.
    function collateralRedeem(
        EscrowType.Type _type,
        address _owner,
        uint64 _id
    ) external;

    /// @notice Withdraw funds authorized for an address.
    /// @dev This function allows anyone to initiate a withdrawal of authorized funds.
    /// @param _type The Escrow type for the credited funds.
    /// @param _owner The destination address for the credited funds.
    /// @param _id The business id associated with the credited funds.
    /// @notice Emits a {Withdrawn} event upon successful withdrawal.
    function withdraw(
        EscrowType.Type _type,
        address payable _owner,
        uint64 _id
    ) external;

    /// @dev Records the sent amount as credit for future payment withdraw.
    /// Note Called by the payer to store the sent amount as credit to be pulled.
    /// Funds sent in this way are stored in an intermediate {Escrow} contract, so
    /// there is no danger of them being spent before withdrawal.
    /// @param _type The Escrow type for the credited funds.
    /// @param _owner The destination address for the credited funds.
    /// @param _id The business id associated with the credited funds.
    /// @param _amount The collateral funds.
    /// @notice Emits a {Payment} event upon successful credit recording.
    function payment(
        EscrowType.Type _type,
        address _owner,
        uint64 _id,
        uint256 _amount
    ) external payable;

    /// @dev Records the sent amount as credit for future payment withdraw.
    /// Note Called by the payer to store the sent amount as credit to be pulled.
    /// Funds sent in this way are stored in an intermediate {Escrow} contract, so
    /// there is no danger of them being spent before withdrawal.
    /// @param _type The Escrow type for the credited funds.
    /// @param _owner The destination address for the credited funds.
    /// @param _id The business id associated with the credited funds.
    /// @param _beneficiary The beneficiary address for the payment credited funds.
    /// @param _amount The collateral funds.
    /// @notice Emits a {PaymentSingleBeneficiary} event upon successful credit recording.
    function paymentSingleBeneficiary(
        EscrowType.Type _type,
        address _owner,
        uint64 _id,
        address _beneficiary,
        uint256 _amount
    ) external payable;

    /// @notice Payment withdraw funds authorized for an address.
    /// @dev This function allows anyone to initiate a withdrawal of authorized funds.
    /// @param _type The Escrow type for the credited funds.
    /// @param _owner The destination address for the credited funds.
    /// @param _id The business id associated with the credited funds.
    /// @param _beneficiary The beneficiary address for the payment credited funds.
    /// @notice Emits a {PaymentWithdrawn} event upon successful credit recording.
    function paymentWithdraw(
        EscrowType.Type _type,
        address _owner,
        uint64 _id,
        address _beneficiary
    ) external;

    /// @notice Payment transfer funds from locked to unlocked.Only total data prepare fee allowed.
    /// @param _type The Escrow type for the credited funds.
    /// @param _owner The destination address for the credited funds.
    /// @param _id The business id associated with the credited funds.
    /// @param _amount The payment transfer credited funds.
    /// @notice Emits a {PaymentTransfer} event upon successful credit recording.
    function paymentTransfer(
        EscrowType.Type _type,
        address _owner,
        uint64 _id,
        uint256 _amount
    ) external;

    /// @notice Refund funds authorized for an address.
    /// @param _type The Escrow type for the credited funds.
    /// @param _owner The destination address for the credited funds.
    /// @param _id The business id associated with the credited funds.
    /// @notice Emits a {PaymentRefund} event upon successful credit recording.
    function paymentRefund(
        EscrowType.Type _type,
        address _owner,
        uint64 _id
    ) external;

    /// @notice Post an update event for collateral type. Called by internal contract.
    /// @param _type The Escrow type for the credited funds.
    /// @param _owner The destination address for the credited funds.
    /// @param _id The business id associated with the credited funds.
    function __emitCollateralUpdate(
        EscrowType.Type _type,
        address _owner,
        uint64 _id,
        EscrowType.CollateralEvent _event
    ) external;

    /// @notice Post an event for payment type. Called by internal contract
    /// @param _type The Escrow type for the credited funds.
    /// @param _owner The destination address for the credited funds.
    /// @param _id The business id associated with the credited funds.
    /// @param _beneficiary The beneficiary address for the payment credited funds.
    function __emitPaymentUpdate(
        EscrowType.Type _type,
        address _owner,
        uint64 _id,
        address _beneficiary,
        EscrowType.PaymentEvent _event
    ) external;

    /// @notice Get beneficiariesList.
    /// @param _type The Escrow type for the credited funds.
    /// @param _owner The destination address for the credited funds.
    /// @param _id The business id associated with the credited funds.
    function getBeneficiariesList(
        EscrowType.Type _type,
        address _owner,
        uint64 _id
    ) external view returns (address[] memory);

    /// @notice Get beneficiary fund.
    /// @param _type The Escrow type for the credited funds.
    /// @param _owner The destination address for the credited funds.
    /// @param _id The business id associated with the credited funds.
    /// @param _beneficiary The beneficiary address for the payment credited funds.
    function getBeneficiaryFund(
        EscrowType.Type _type,
        address _owner,
        uint64 _id,
        address _beneficiary
    )
        external
        view
        returns (
            uint256 total, // Total amount in fund account
            uint256 lock, // Lock amount in fund account for payment beneficiaries
            uint256 collateral, // Collateral amount in fund account for withdraw and punishment
            uint256 burned, // burned amount in fund account
            uint64 createdBlockNumber // Fund account created block number
        );

    /// @notice Get owner fund.
    /// @param _type The Escrow type for the credited funds.
    /// @param _owner The destination address for the credited funds.
    /// @param _id The business id associated with the credited funds.
    function getOwnerFund(
        EscrowType.Type _type,
        address _owner,
        uint64 _id
    )
        external
        view
        returns (
            uint256 total, // Total amount in fund account
            uint256 lock, // Lock amount in fund account for payment beneficiaries
            uint256 collateral, // Collateral amount in fund account for withdraw and punishment
            uint256 burned, // burned amount in fund account
            uint64 createdBlockNumber // Fund account created block number
        );
}
