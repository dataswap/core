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
import {FinanceType} from "src/v0.8/types/FinanceType.sol";
import {MatchingType} from "src/v0.8/types/MatchingType.sol";
import {IRoles} from "src/v0.8/interfaces/core/IRoles.sol";

contract BusinessFinanceStatistics is
    Initializable,
    IBusinessFinanceStatistics
{
    mapping(StatisticsType.BusinessFinanceStatisticsType => mapping(address => uint256))
        private amounts;

    /// @dev This empty reserved space is put in place to allow future versions to add new
    uint256[32] private __gap;

    function businessFinanceStatisticsInitialize()
        public
        virtual
        onlyInitializing
    {}

    /// @notice Adds funds of a specific type to the balance.
    /// @dev The function is only intended for internal use within the dataswap contract and for intercontract calls.
    /// @param _type The type of finance statistics to add funds to.
    /// @param _token The type of token used for the deposit (e.g., FIL, ERC-20).
    /// @param _size The amount of funds to add.
    function _add(
        StatisticsType.BusinessFinanceStatisticsType _type,
        address _token,
        uint256 _size
    ) internal {
        if (_type == StatisticsType.BusinessFinanceStatisticsType.None) {
            return;
        }
        amounts[_type][_token] += _size;
    }

    /// @notice Subtracts funds of a specific type from the balance.
    /// @dev The function is only intended for internal use within the dataswap contract and for intercontract calls.
    /// @param _type The type of finance statistics to subtract funds from.
    /// @param _token The type of token used for the deposit (e.g., FIL, ERC-20).
    /// @param _size The amount of funds to subtract.
    function _sub(
        StatisticsType.BusinessFinanceStatisticsType _type,
        address _token,
        uint256 _size
    ) internal {
        if (_type == StatisticsType.BusinessFinanceStatisticsType.None) {
            return;
        }
        require(amounts[_type][_token] >= _size, "invalid subtrahend");
        amounts[_type][_token] -= _size;
    }

    /// @notice Determines the escrow option for a given dataset and matching ID.
    /// @param _matchingId The ID of the matching.
    /// @param _type The finance type.
    /// @return businessFinanceStatisticsType The type of business finance statistics.
    function _getEscrowStatisticsType(
        uint64 _matchingId,
        FinanceType.Type _type
    )
        internal
        pure
        returns (
            StatisticsType.BusinessFinanceStatisticsType businessFinanceStatisticsType
        )
    {
        if (_type == FinanceType.Type.EscrowDatacapCollateral) {
            businessFinanceStatisticsType = StatisticsType
                .BusinessFinanceStatisticsType
                .StorageClientEscrowDatacapCollateral;
        } else if (_type == FinanceType.Type.EscrowDataTradingFee) {
            if (_matchingId == 0) {
                businessFinanceStatisticsType = StatisticsType
                    .BusinessFinanceStatisticsType
                    .StorageClientEscrowDataTradingFee;
            } else {
                businessFinanceStatisticsType = StatisticsType
                    .BusinessFinanceStatisticsType
                    .StorageProviderEscrowDataTradingFee;
            }
        } else if (_type == FinanceType.Type.EscrowChallengeCommission) {
            businessFinanceStatisticsType = StatisticsType
                .BusinessFinanceStatisticsType
                .StorageClientEscrowChallengeCommission;
        } else if (_type == FinanceType.Type.EscrowDataTradingCommission) {
            //TODO: platform commission
            businessFinanceStatisticsType = StatisticsType
                .BusinessFinanceStatisticsType
                .None;
        } else if (_type == FinanceType.Type.EscrowDatacapChunkLandCollateral) {
            businessFinanceStatisticsType = StatisticsType
                .BusinessFinanceStatisticsType
                .StorageProviderEscrowDatacapChunkLand;
        } else if (_type == FinanceType.Type.EscrowProofAuditCollateral) {
            businessFinanceStatisticsType = StatisticsType
                .BusinessFinanceStatisticsType
                .DatasetPreparerEscrowProofAuditCollateral;
        } else if (_type == FinanceType.Type.EscrowChallengeAuditCollateral) {
            businessFinanceStatisticsType = StatisticsType
                .BusinessFinanceStatisticsType
                .DatasetAuditorEscrowChallengeAuditCollateral;
        } else if (_type == FinanceType.Type.EscrowDisputeAuditCollateral) {
            businessFinanceStatisticsType = StatisticsType
                .BusinessFinanceStatisticsType
                .DatasetAuditorEscrowDisputeAuditCollateral;
        }
    }

    /// @notice Internal function to determine the statistics type for the payer based on the dataset ID, finance type, payer address, and roles.
    /// @param _datasetId The ID of the dataset.
    /// @param _type The finance type.
    /// @param _payer The address of the payer.
    /// @param _roles The roles contract.
    /// @return businessFinanceStatisticsType The business finance statistics type.
    function _getPayerStatisticsType(
        uint64 _datasetId,
        FinanceType.Type _type,
        address _payer,
        IRoles _roles
    )
        internal
        view
        returns (
            StatisticsType.BusinessFinanceStatisticsType businessFinanceStatisticsType
        )
    {
        if (_type == FinanceType.Type.EscrowDatacapCollateral) {
            businessFinanceStatisticsType = StatisticsType
                .BusinessFinanceStatisticsType
                .StorageClientEscrowDatacapCollateral;
        } else if (_type == FinanceType.Type.EscrowDataTradingFee) {
            address storageClient = _roles
                .datasets()
                .getDatasetMetadataSubmitter(_datasetId);

            if (_payer == storageClient) {
                businessFinanceStatisticsType = StatisticsType
                    .BusinessFinanceStatisticsType
                    .StorageClientEscrowDataTradingFee;
            } else {
                businessFinanceStatisticsType = StatisticsType
                    .BusinessFinanceStatisticsType
                    .StorageProviderEscrowDataTradingFee;
            }
        } else if (_type == FinanceType.Type.EscrowChallengeCommission) {
            businessFinanceStatisticsType = StatisticsType
                .BusinessFinanceStatisticsType
                .StorageClientEscrowChallengeCommission;
        } else if (_type == FinanceType.Type.EscrowDataTradingCommission) {
            //TODO: platform commission
            businessFinanceStatisticsType = StatisticsType
                .BusinessFinanceStatisticsType
                .None;
        } else if (_type == FinanceType.Type.EscrowDatacapChunkLandCollateral) {
            businessFinanceStatisticsType = StatisticsType
                .BusinessFinanceStatisticsType
                .StorageProviderEscrowDatacapChunkLand;
        } else if (_type == FinanceType.Type.EscrowProofAuditCollateral) {
            businessFinanceStatisticsType = StatisticsType
                .BusinessFinanceStatisticsType
                .DatasetPreparerEscrowProofAuditCollateral;
        } else if (_type == FinanceType.Type.EscrowChallengeAuditCollateral) {
            businessFinanceStatisticsType = StatisticsType
                .BusinessFinanceStatisticsType
                .DatasetAuditorEscrowChallengeAuditCollateral;
        } else if (_type == FinanceType.Type.EscrowDisputeAuditCollateral) {
            businessFinanceStatisticsType = StatisticsType
                .BusinessFinanceStatisticsType
                .DatasetAuditorEscrowDisputeAuditCollateral;
        }
    }

    /// @notice Internal function to determine the statistics payment type based on the payer, payee, and roles.
    /// @param _payer The address of the payer.
    /// @param _payee The address of the payee.
    /// @param _roles The roles contract.
    /// @return The payment type.
    function _getStatisticsPaymentType(
        address _payer,
        address _payee,
        IRoles _roles
    ) internal view returns (StatisticsType.PaymentType) {
        if (_roles.filplus().getBurnAddress() == _payee) {
            return StatisticsType.PaymentType.Burn;
        } else if (_payer == _payee) {
            return StatisticsType.PaymentType.Refund;
        } else {
            return StatisticsType.PaymentType.Payment;
        }
    }

    /// @notice Internal function to determine the statistics type for a payee based on the dataset, payer, payee, finance type, and roles.
    /// @param _datasetId The ID of the dataset.
    /// @param _payer The address of the payer.
    /// @param _payee The address of the payee.
    /// @param _type The finance type.
    /// @param _roles The roles contract.
    /// @return businessFinanceStatisticsType The business finance statistics type.
    function _getPayeeStatisticsType(
        uint64 _datasetId,
        address _payer,
        address _payee,
        FinanceType.Type _type,
        IRoles _roles
    )
        internal
        view
        returns (
            StatisticsType.BusinessFinanceStatisticsType businessFinanceStatisticsType
        )
    {
        StatisticsType.PaymentType _paymentType = _getStatisticsPaymentType(
            _payer,
            _payee,
            _roles
        );

        if (_type == FinanceType.Type.EscrowDatacapCollateral) {
            businessFinanceStatisticsType = StatisticsType
                .BusinessFinanceStatisticsType
                .None;
        } else if (_type == FinanceType.Type.EscrowDataTradingFee) {
            address storageClient = _roles
                .datasets()
                .getDatasetMetadataSubmitter(_datasetId);

            if (_payer == storageClient) {
                businessFinanceStatisticsType = StatisticsType
                    .BusinessFinanceStatisticsType
                    .StorageClientPaidDataTradingFee;
            } else {
                businessFinanceStatisticsType = StatisticsType
                    .BusinessFinanceStatisticsType
                    .StorageProviderPaidDataTradingFee;
            }
        } else if (_type == FinanceType.Type.EscrowChallengeCommission) {
            if (_paymentType == StatisticsType.PaymentType.Payment) {
                businessFinanceStatisticsType = StatisticsType
                    .BusinessFinanceStatisticsType
                    .StorageClientPaidChallengeCommission;
            } else {
                businessFinanceStatisticsType = StatisticsType
                    .BusinessFinanceStatisticsType
                    .None;
            }
        } else if (_type == FinanceType.Type.EscrowDataTradingCommission) {
            //TODO: platform commission
            businessFinanceStatisticsType = StatisticsType
                .BusinessFinanceStatisticsType
                .None;
        } else if (_type == FinanceType.Type.EscrowDatacapChunkLandCollateral) {
            if (_paymentType == StatisticsType.PaymentType.Burn) {
                businessFinanceStatisticsType = StatisticsType
                    .BusinessFinanceStatisticsType
                    .StorageProviderDatacapChunkLandPenalty;
            }
        } else if (_type == FinanceType.Type.EscrowProofAuditCollateral) {
            if (_paymentType == StatisticsType.PaymentType.Burn) {
                businessFinanceStatisticsType = StatisticsType
                    .BusinessFinanceStatisticsType
                    .DatasetPrepareProofDisputePenalty;
            } else {
                businessFinanceStatisticsType = StatisticsType
                    .BusinessFinanceStatisticsType
                    .None;
            }
        } else if (_type == FinanceType.Type.EscrowChallengeAuditCollateral) {
            if (_paymentType == StatisticsType.PaymentType.Burn) {
                businessFinanceStatisticsType = StatisticsType
                    .BusinessFinanceStatisticsType
                    .DatasetAuditorChallengeDisputePenalty;
            } else {
                businessFinanceStatisticsType = StatisticsType
                    .BusinessFinanceStatisticsType
                    .None;
            }
        } else if (_type == FinanceType.Type.EscrowDisputeAuditCollateral) {
            if (_paymentType == StatisticsType.PaymentType.Burn) {
                businessFinanceStatisticsType = StatisticsType
                    .BusinessFinanceStatisticsType
                    .DatasetAuditorFailureDisputePenalty;
            } else {
                businessFinanceStatisticsType = StatisticsType
                    .BusinessFinanceStatisticsType
                    .None;
            }
        }
    }

    /// @notice Internal function to execute statistics for the matched amount based on the dataset ID, matching ID, finance type, token address, and roles.
    /// @param _datasetId The ID of the dataset.
    /// @param _matchingId The ID of the matching.
    /// @param _type The finance type.
    /// @param _token The address of the token.
    /// @param _roles The roles contract.
    function _executeStatisticsMatchedAmount(
        uint64 _datasetId,
        uint64 _matchingId,
        FinanceType.Type _type,
        address _token,
        IRoles _roles
    ) internal {
        if (_type == FinanceType.Type.EscrowDataTradingFee) {
            if (
                msg.sender == address(_roles.matchingsBids()) &&
                _roles.matchings().getMatchingState(_matchingId) ==
                MatchingType.State.Closed
            ) {
                address winner = _roles.matchingsBids().getMatchingWinner(
                    _matchingId
                );
                (, , uint256 current, ) = _roles.finance().getAccountEscrow(
                    _datasetId,
                    _matchingId,
                    winner,
                    _token,
                    _type
                );
                _add(
                    StatisticsType.BusinessFinanceStatisticsType.MatchedAmount,
                    _token,
                    current
                );
            }
        }
    }

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
        )
    {
        storageClientEscrowDatacapCollateral = amounts[
            StatisticsType
                .BusinessFinanceStatisticsType
                .StorageClientEscrowDatacapCollateral
        ][_token];
        storageClientEscrowDataTradingFee = amounts[
            StatisticsType
                .BusinessFinanceStatisticsType
                .StorageClientEscrowDataTradingFee
        ][_token];
        storageClientEscrowChallengeCommission = amounts[
            StatisticsType
                .BusinessFinanceStatisticsType
                .StorageClientEscrowChallengeCommission
        ][_token];
        datasetPreparerEscrowProofAuditCollateral = amounts[
            StatisticsType
                .BusinessFinanceStatisticsType
                .DatasetPreparerEscrowProofAuditCollateral
        ][_token];
        datasetAuditorEscrowChallengeAuditCollateral = amounts[
            StatisticsType
                .BusinessFinanceStatisticsType
                .DatasetAuditorEscrowChallengeAuditCollateral
        ][_token];
        datasetAuditorEscrowDisputeAuditCollateral = amounts[
            StatisticsType
                .BusinessFinanceStatisticsType
                .DatasetAuditorEscrowDisputeAuditCollateral
        ][_token];
        datasetPrepareProofDisputePenalty = amounts[
            StatisticsType
                .BusinessFinanceStatisticsType
                .DatasetPrepareProofDisputePenalty
        ][_token];
        datasetAuditorChallengeDisputePenalty = amounts[
            StatisticsType
                .BusinessFinanceStatisticsType
                .DatasetAuditorChallengeDisputePenalty
        ][_token];
        datasetAuditorFailureDisputePenalty = amounts[
            StatisticsType
                .BusinessFinanceStatisticsType
                .DatasetAuditorFailureDisputePenalty
        ][_token];
        storageClientPaidChallengeCommission = amounts[
            StatisticsType
                .BusinessFinanceStatisticsType
                .StorageClientPaidChallengeCommission
        ][_token];
    }

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
        )
    {
        storageProviderEscrowDataTradingFee = amounts[
            StatisticsType
                .BusinessFinanceStatisticsType
                .StorageProviderEscrowDataTradingFee
        ][_token];
        matchedAmount = amounts[
            StatisticsType.BusinessFinanceStatisticsType.MatchedAmount
        ][_token];
    }

    /// @notice Provides an overview of escrow statistics related to storage.
    /// @param _token The token address.
    /// @return storageProviderEscrowDatacapChunkLand The total escrowed amount for storage provider datacap chunk land.
    /// @return storageProviderPaidDataTradingFee The total escrowed amount for storage provider data trading fee.
    /// @return storageClientPaidDataTradingFee The total escrowed amount for storage client data trading fee.
    /// @return storageProviderDatacapChunkLandPenalty The total penalty amount for storage provider datacap chunk land.
    function storageOverview(
        address _token
    )
        external
        view
        returns (
            uint256 storageProviderEscrowDatacapChunkLand,
            uint256 storageProviderPaidDataTradingFee,
            uint256 storageClientPaidDataTradingFee,
            uint256 storageProviderDatacapChunkLandPenalty
        )
    {
        storageProviderEscrowDatacapChunkLand = amounts[
            StatisticsType
                .BusinessFinanceStatisticsType
                .StorageProviderEscrowDatacapChunkLand
        ][_token];
        storageProviderPaidDataTradingFee = amounts[
            StatisticsType
                .BusinessFinanceStatisticsType
                .StorageProviderPaidDataTradingFee
        ][_token];
        storageClientPaidDataTradingFee = amounts[
            StatisticsType
                .BusinessFinanceStatisticsType
                .StorageClientPaidDataTradingFee
        ][_token];
        storageProviderDatacapChunkLandPenalty = amounts[
            StatisticsType
                .BusinessFinanceStatisticsType
                .StorageProviderDatacapChunkLandPenalty
        ][_token];
    }
}
