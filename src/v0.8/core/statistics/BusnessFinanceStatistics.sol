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
import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {IBusinessFinanceStatistics} from "src/v0.8/interfaces/core/statistics/IBusinessFinanceStatistics.sol";
import {StatisticsType} from "src/v0.8/types/StatisticsType.sol";
import {BasicFinanceStatisticsLIB} from "src/v0.8/core/statistics/library/FinanceStatisticsLIB.sol";
import {IRoles} from "src/v0.8/interfaces/core/IRoles.sol";
import {RolesModifiers} from "src/v0.8/shared/modifiers/RolesModifiers.sol";

contract BusinessFinanceStatistics is
    Initializable,
    IBusinessFinanceStatistics,
    RolesModifiers
{
    using BasicFinanceStatisticsLIB for uint256;

    mapping(StatisticsType.BusinessFinanceStatisticsType => uint256)
        private amounts;

    IRoles public roles;

    /// @dev This empty reserved space is put in place to allow future versions to add new
    uint256[32] private __gap;

    function businessFinanceStatisticsInitialize(
        address _roles
    ) public virtual onlyInitializing {
        roles = IRoles(_roles);
    }

    /// @notice Adds funds of a specific type to the balance.
    /// @param _type The type of finance statistics to add funds to.
    /// @param _size The amount of funds to add.
    function add(
        StatisticsType.BusinessFinanceStatisticsType _type,
        uint256 _size
    ) external {
        //TODO: impl
    }

    /// @notice Subtracts funds of a specific type from the balance.
    /// @param _type The type of finance statistics to subtract funds from.
    /// @param _size The amount of funds to subtract.
    function sub(
        StatisticsType.BusinessFinanceStatisticsType _type,
        uint256 _size
    ) external {
        //TODO: impl
    }

    /// @notice Retrieves an overview of dataset-related finance statistics.
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
    function datasetOverview()
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
        )
    {
        //TODO: impl
    }

    /// @notice Retrieves an overview of matching-related finance statistics.
    /// @return storageProviderBidAmountTVL The TVL of storage provider bid amounts.
    /// @return matchedAmount The total amount matched.
    function matchingOverview()
        external
        view
        returns (uint256 storageProviderBidAmountTVL, uint256 matchedAmount)
    {
        //TODO: impl
    }

    /// @notice Retrieves an overview of storage-related finance statistics.
    /// @return storageProviderDatacapChunkLandTVL The TVL of storage provider datacap chunk land.
    /// @return storageProviderPaidDataTradingFee The amount of data trading fee paid by storage providers.
    /// @return storageClientPaidDataTradingFee The amount of data trading fee paid by storage clients.
    function storageOverview()
        external
        view
        returns (
            uint256 storageProviderDatacapChunkLandTVL,
            uint256 storageProviderPaidDataTradingFee,
            uint256 storageClientPaidDataTradingFee
        )
    {
        //TODO: impl
    }
}
