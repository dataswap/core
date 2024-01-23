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

/// @title FinanceType Library
/// @notice This library defines finance type within the system.
/// @notice mapping(address => uint256) representing  (TokenType=>Amount).
library FinanceType {
    /// @notice Escrow types.
    enum Type {
        //1,Commission
        ChallengeCommission,
        DataTradingCommission,
        //2,TradingFee
        DataTradingFee,
        //3,Collateral
        DatacapCollateral,
        DatacapChunkLandCollateral,
        ProofAuditCollateral,
        ChallengeAuditCollateral,
        DisputeAuditCollateral,
        // End for traverse
        End
    }

    /// @notice enum representing the ReleaseType details.
    enum ReleaseType {
        Linear
    }

    /// @notice Struct representing the ReleaseRule details.
    struct ReleaseRule {
        ReleaseType releaseType;
        uint64 delayBlocks;
        uint64 durationBlocks;
    }

    /// @notice Struct representing the IncomePaymentUnit details.
    struct IncomePaymentUnit {
        uint64 height;
        uint256 amount;
    }

    /// @notice Struct representing the EscrowPaymentUnit details.
    struct EscrowPaymentUnit {
        uint64 latestHeight;
        uint256 expenditure;
        uint256 total;
    }

    /// @notice Struct representing the Statistics details.
    struct Statistics {
        uint256 deposited; // Total Deposit, from deposit.
        uint256 withdrawn; // Total Withdrawal
        uint256 burned; // Total Burned(only from collateral)
    }

    /// @notice Struct representing the account details.
    struct Account {
        uint256 total; // Total balance =  escrow + lock + available; from deposit + income. to withdraw + escrowPayment + escrowBurn
        mapping(Type => IncomePaymentUnit[]) income; // getLock from income (Receiving funds from another account)
        mapping(Type => EscrowPaymentUnit) escrow; //Preparing to make a payment to another account; from escrow. to escrowPayment + escrowBurn
        Statistics statistics;
    }
}
