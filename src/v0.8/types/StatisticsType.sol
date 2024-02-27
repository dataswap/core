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

/// @title StaticsType Library
/// @notice Library for handling statistical data with total, success, and failed counts
library StatisticsType {
    /// @notice Struct to hold statistical data
    struct Statistics {
        uint256 total; // Total count
        uint256 success; // Success count
        uint256 failed; // Failed count
    }

    /// @title StorageStatistics Structure
    /// @notice Struct for holding data related to storage, including total, storage provider count, completed storage, allocated datacap, and canceled datacap
    struct StorageStatistics {
        uint256 total; // Total matched storage or total datacap for matching
        uint256 completed; // Completed storage
        uint256 allocatedDatacap; // Allocated datacap
        uint256 canceled; // Canceled datacap
    }

    /// @title StorageProviderStatistics Structure
    /// @notice Struct for holding statistics related to storage providers, including an array of storage providers and sizes associated with each storage provider
    struct StorageProvidersStatistics {
        uint64[] storageProviders; // Array of storage providers
        mapping(uint64 => uint256) storageProviderInfos; // Mapping of sizes associated with storage providers (storageProviderId => size)
    }

    /// @title Enum defining types of business finance statistics.
    enum BusinessFinanceStatisticsType {
        // Dataset Escrow
        StorageClientEscrowDatacapCollateral,
        StorageClientEscrowDataTradingFee,
        StorageClientEscrowChallengeCommission,
        DatasetPreparerEscrowProofAuditCollateral,
        DatasetAuditorEscrowChallengeAuditCollateral,
        DatasetAuditorEscrowDisputeAuditCollateral,
        // Dataset Penalty
        DatasetPrepareProofDisputePenalty,
        DatasetAuditorChallengeDisputePenalty,
        DatasetAuditorFailureDisputePenalty,
        // Dataset Payment
        StorageClientPaidChallengeCommission,
        // Matching Escrow
        StorageProviderEscrowDataTradingFee,
        // Matching Matched Amount
        MatchedAmount,
        // Storages Escrow
        StorageProviderEscrowDatacapChunkLand,
        // Storage Data Trading Fee
        StorageProviderPaidDataTradingFee,
        StorageClientPaidDataTradingFee,
        None
    }

    /// @notice Struct representing the PaymentType details.
    enum PaymentType {
        Refund, // Retund funds
        Burn, // Burn funds
        Payment // payment funds
    }
}
