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

/// @title EscrowType Library
/// @notice This library defines escrow type within the system.
library EscrowType {
    /// @notice Enum escrow object types.
    enum Type {
        DatacapCollateral, // The storage client collateral.
        DatacapChunkCollateral, // The storage provider collateral.
        DataAuditCollateral, // The dataset auditor collateral, for dispute
        DataPrepareCollateral, // The data preparer collateral,for dispute
        DatasetAuditFee, // The dataset auditor calculate fees.
        TotalDataPrepareFeeByClient, // The data preparer calculate fees of dataset paid by storage client.
        DataPrepareFeeByClient, // The data preparer calculate fees of matching paid by storage client.
        DataPrepareFeeByProvider // The data preparer calculate fees paid by storage provider.
    }

    /// @notice Enum representing the events related to collateral management.Triggered by business contract
    enum CollateralEvent {
        SyncBurn, // Escrow synchronize collateral burn amount.
        SyncCollateral // Escrow synchronize collateral amount.
    }

    /// @notice Enum representing the events related to payment management.Triggered by business contract
    enum PaymentEvent {
        SyncPaymentLock, // Escrow synchronize allow payment amount.
        SyncPaymentBeneficiary, // Escrow synchronize payment beneficiaries list.
        AddPaymentSubAccount // Escrow synchronize sub payment account.
    }

    /// @notice Struct the beneficiary of escrow
    struct Fund {
        uint256 total; // Total amount in fund account
        uint256 lock; // Lock amount in fund account for payment beneficiaries
        uint256 collateral; // Collateral amount in fund account for withdraw and punishment
        uint256 burned; // burned amount in fund account
        uint64 createdBlockNumber; // Fund account created block number
    }

    /// @notice Struct the escrow
    struct Escrow {
        Fund owner; // fund owner
        address[] beneficiariesList; // Retrieves beneficiaries list
        mapping(address beneficiary => Fund) beneficiaries; // Beneficiaries information
    }
}
