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
    /// @notice Retrieves an overview of dataset-related finance statistics.
    /// @param _token The type of token used for the deposit (e.g., FIL, ERC-20).
    /// @return storageClientDatacapCollateralTVL The total value locked (TVL) of storage client datacap collateral.
    /// @return storageClientDataTradingFeeTVL The TVL of storage client data trading fees.
    /// @return storageClientChallengeCommissionTVL The TVL of storage client challenge commissions.
    /// @return datasetPreparerProofAuditCollateralTVL The TVL of dataset preparer proof audit collateral.
    /// @return datasetAuditorChallengeAuditCollateralTVL The TVL of dataset auditor challenge audit collateral.
    /// @return datasetAuditorDisputeAuditCollateralTVL The TVL of dataset auditor dispute audit collateral.
    /// @return datasetPrepareProofDisputePenalty The penalty for dataset preparer proof disputes.
    /// @return datasetAuditorChallengeDisputePenalty The penalty for dataset auditor challenge disputes.
    /// @return datasetAuditorFailureDisputePenalty The penalty for dataset auditor failure disputes.
    /// @return storageClientPaidChallengeCommission The amount of challenge commission paid by storage clients.
    function datasetOverview(
        address _token
    )
        external
        view
        returns (
            uint256 storageClientDatacapCollateralTVL,
            uint256 storageClientDataTradingFeeTVL,
            uint256 storageClientChallengeCommissionTVL,
            uint256 datasetPreparerProofAuditCollateralTVL,
            uint256 datasetAuditorChallengeAuditCollateralTVL,
            uint256 datasetAuditorDisputeAuditCollateralTVL,
            uint256 datasetPrepareProofDisputePenalty,
            uint256 datasetAuditorChallengeDisputePenalty,
            uint256 datasetAuditorFailureDisputePenalty,
            uint256 storageClientPaidChallengeCommission
        );

    /// @notice Retrieves an overview of matching-related finance statistics.
    /// @param _token The type of token used for the deposit (e.g., FIL, ERC-20).
    /// @return storageProviderBidAmountTVL The TVL of storage provider bid amounts.
    /// @return matchedAmount The total amount matched.
    function matchingOverview(
        address _token
    )
        external
        view
        returns (uint256 storageProviderBidAmountTVL, uint256 matchedAmount);

    /// @notice Retrieves an overview of storage-related finance statistics.
    /// @param _token The type of token used for the deposit (e.g., FIL, ERC-20).
    /// @return storageProviderDatacapChunkLandTVL The TVL of storage provider datacap chunk land.
    /// @return storageProviderPaidDataTradingFee The amount of data trading fee paid by storage providers.
    /// @return storageClientPaidDataTradingFee The amount of data trading fee paid by storage clients.
    function storageOverview(
        address _token
    )
        external
        view
        returns (
            uint256 storageProviderDatacapChunkLandTVL,
            uint256 storageProviderPaidDataTradingFee,
            uint256 storageClientPaidDataTradingFee
        );
}
