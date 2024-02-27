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

import {StatisticsType} from "src/v0.8/types/StatisticsType.sol";

interface IBusinessFinanceStatistics {
    /// @notice Provides an overview of escrow statistics related to a dataset.
    /// @param _token The token address.
    /// @return storageClientEscrowDatacapCollateral The total escrowed amount for storage client datacap collateral.
    /// @return storageClientEscrowDataTradingFee The total escrowed amount for storage client data trading fee.
    /// @return storageClientEscrowChallengeCommission The total escrowed amount for storage client challenge commission.
    /// @return datasetPreparerEscrowProofAuditCollateral The total escrowed amount for dataset preparer proof audit collateral.
    /// @return datasetAuditorEscrowChallengeAuditCollateral The total escrowed amount for dataset auditor challenge audit collateral.
    /// @return datasetAuditorEscrowDisputeAuditCollateral The total escrowed amount for dataset auditor dispute audit collateral.
    /// @return datasetPrepareProofDisputePenalty The total escrowed amount for dataset prepare proof dispute penalty.
    /// @return datasetAuditorChallengeDisputePenalty The total escrowed amount for dataset auditor challenge dispute penalty.
    /// @return datasetAuditorFailureDisputePenalty The total escrowed amount for dataset auditor failure dispute penalty.
    /// @return storageClientPaidChallengeCommission The total paid commission for storage client challenge.
    function datasetOverview(
        address _token
    )
        external
        view
        returns (
            uint256 storageClientEscrowDatacapCollateral,
            uint256 storageClientEscrowDataTradingFee,
            uint256 storageClientEscrowChallengeCommission,
            uint256 datasetPreparerEscrowProofAuditCollateral,
            uint256 datasetAuditorEscrowChallengeAuditCollateral,
            uint256 datasetAuditorEscrowDisputeAuditCollateral,
            uint256 datasetPrepareProofDisputePenalty,
            uint256 datasetAuditorChallengeDisputePenalty,
            uint256 datasetAuditorFailureDisputePenalty,
            uint256 storageClientPaidChallengeCommission
        );

    /// @notice Provides an overview of escrow statistics related to matching.
    /// @param _token The token address.
    /// @return storageProviderEscrowDataTradingFee The total escrowed amount for storage provider data trading fee.
    /// @return matchedAmount The total matched amount.
    function matchingOverview(
        address _token
    )
        external
        view
        returns (
            uint256 storageProviderEscrowDataTradingFee,
            uint256 matchedAmount
        );

    /// @notice Provides an overview of escrow statistics related to storage.
    /// @param _token The token address.
    /// @return storageProviderEscrowDatacapChunkLand The total escrowed amount for storage provider datacap chunk land.
    /// @return storageProviderPaidDataTradingFee The total escrowed amount for storage provider data trading fee.
    /// @return storageClientPaidDataTradingFee The total escrowed amount for storage client data trading fee.
    function storageOverview(
        address _token
    )
        external
        view
        returns (
            uint256 storageProviderEscrowDatacapChunkLand,
            uint256 storageProviderPaidDataTradingFee,
            uint256 storageClientPaidDataTradingFee
        );
}
