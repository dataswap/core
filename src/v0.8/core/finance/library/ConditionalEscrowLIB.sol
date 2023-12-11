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

import {Errors} from "src/v0.8/shared/errors/Errors.sol";
import {EscrowType} from "src/v0.8/types/EscrowType.sol";
import {DatasetType} from "src/v0.8/types/DatasetType.sol";
import {MatchingType} from "src/v0.8/types/MatchingType.sol";

import {IStorages} from "src/v0.8/interfaces/module/IStorages.sol";
import {IDatacaps} from "src/v0.8/interfaces/module/IDatacaps.sol";
import {IDatasetsProof} from "src/v0.8/interfaces/module/IDatasetsProof.sol";
import {IDatasetsRequirement} from "src/v0.8/interfaces/module/IDatasetsRequirement.sol";

/// @title ConditionalEscrowLIB
/// @dev This library provides functionality to manage the release conditions of escrow collateral.
library ConditionalEscrowLIB {
    uint256 public constant PER_DAY_BLOCKNUMBER = 2880;

    /// @dev Determines the amount available for collateral from a datacap collateral
    /// @param _id The business id associated with the credited funds.
    /// @param _storages The storages contract object.
    /// @param _datasetsProof The datasetsProof contract object.
    /// @param _createBlockNumber The escrow account create block number.
    /// @param _total The escrow account total funds.
    function datacapCollateral(
        uint64 _id, // datasetId
        IStorages _storages,
        IDatasetsProof _datasetsProof,
        uint64 _createBlockNumber,
        uint256 _total
    ) internal view returns (uint256) {
        uint256 collateralFunds = 0;

        // Check the dataset's status:
        // - If it's in the 'MetadataRejected' status,
        // - or if it's not in the 'MetadataApproved' status and has been staked for over 180 days,
        // - or if it has been mortgaged for over 365 days, the funds are eligible for withdrawal.
        DatasetType.State datasetState = _storages.datasets().getDatasetState(
            _id
        );

        if (
            (datasetState == DatasetType.State.MetadataRejected) ||
            (datasetState != DatasetType.State.DatasetApproved &&
                block.number >
                (_createBlockNumber + PER_DAY_BLOCKNUMBER * 180)) ||
            block.number > (_createBlockNumber + PER_DAY_BLOCKNUMBER * 365)
        ) {
            return collateralFunds; // Release all collateral funds
        }

        // Check the datasetProof's status:
        // - If it's in the 'allCompleted' status,
        // - it's all proof completed collateral funds
        if (
            _datasetsProof.isDatasetProofallCompleted(
                _id,
                DatasetType.DataType.Source
            )
        ) {
            collateralFunds = _datasetsProof.getDatasetCollateralRequirement(
                _id
            );
        } else {
            // Others are pre collateral funds
            collateralFunds = _datasetsProof
                .datasetsRequirement()
                .getDatasetPreCollateralRequirements(_id);
        }

        if (_total < collateralFunds) {
            revert Errors.ExceedValidCollateralAmount(_total, collateralFunds);
        }

        return collateralFunds;
    }

    /// @dev Determines the amount available for collateral from a datacap chunk collateral
    /// @param _id The business id associated with the credited funds.
    /// @param _datacaps The datacaps contract object.
    function datacapChunkCollateral(
        uint64 _id, // matchingId
        IDatacaps _datacaps
    ) internal view returns (uint256) {
        return _datacaps.getDatacapChunkCollateralFunds(_id);
    }

    /// @dev Determines the amount available for burn from a datacap chunk collateral
    /// @param _id The business id associated with the credited funds.
    /// @param _datacaps The datacaps contract object.
    function datacapChunkBurn(
        uint64 _id, // matchingId
        IDatacaps _datacaps
    ) internal view returns (uint256) {
        return _datacaps.getDatacapChunkBurnFunds(_id);
    }

    /// @dev Determines the amount available for payment from a data prepare fee by provider
    /// @param _id The business id associated with the credited funds.
    /// @param _storages The storages contract object.
    function providerLockPayment(
        uint64 _id, // matchingId
        IStorages _storages
    ) internal view returns (uint256) {
        return _storages.getProviderLockPayment(_id);
    }

    /// @dev Determines the amount available for payment from a data prepare fee by client
    /// @param _id The business id associated with the credited funds.
    /// @param _storages The storages contract object.
    function clientLockPayment(
        uint64 _id, // matchingId
        IStorages _storages
    ) internal view returns (uint256) {
        return _storages.getClientLockPayment(_id);
    }

    /// @dev Handles the logic for refunding payments based on escrow type, ID.
    /// @param _type The Escrow type for the credited funds.
    /// @param _owner The destination address for the credited funds.
    /// @param _id The business id associated with the credited funds.
    /// @param _storages The storages contract object.
    function isPaymentAllowRefund(
        EscrowType.Type _type,
        address _owner,
        uint64 _id,
        IStorages _storages
    ) internal view returns (bool) {
        // Unsuccessful bidders will be refunded after the matching completed.
        if (
            _type == EscrowType.Type.DataPrepareFeeByProvider &&
            _storages.matchings().getMatchingState(_id) ==
            MatchingType.State.Completed &&
            _storages.matchingsBids().getMatchingWinner(_id) != _owner
        ) {
            return true;
        }

        // Transactions that are not completed after the Expiration can be refunded
        if (
            _type == EscrowType.Type.DataPrepareFeeByProvider ||
            _type == EscrowType.Type.DataPrepareFeeByClient
        ) {
            return _storages.isStorageExpiration(_id);
        }

        // Refunds are available if a dataset is rejected
        if (
            _type == EscrowType.Type.DatasetAuditFee &&
            _storages.datasets().getDatasetState(_id) ==
            DatasetType.State.MetadataApproved
        ) {
            return true;
        }

        return false;
    }

    /// @dev Calculate sub-account deposit amount
    /// @param _id The business id associated with the credited funds.
    /// @param _datasetId The dataset id.
    /// @param _paymentLock The payment lock amount.
    /// @param _datasetsProof The dataetsProof contract object.
    /// @param _storages The storages contract object.
    function clientSubPaymentAccount(
        uint64 _id, // matchingId
        uint64 _datasetId,
        uint256 _paymentLock,
        IDatasetsProof _datasetsProof,
        IStorages _storages
    ) internal view returns (uint256) {
        (, , uint64 matchingSize, , , , ) = _storages
            .matchingsTarget()
            .getMatchingTarget(_id);

        uint64 unusedSize = _datasetsProof.getDatasetSize(
            _datasetId,
            DatasetType.DataType.Source
        ) *
            _datasetsProof.datasetsRequirement().getDatasetReplicasCount(
                _datasetId
            ) -
            _storages.datasets().getDatasetUsedSize(_datasetId);

        return (_paymentLock / unusedSize) * matchingSize;
    }

    /// @dev Calculate the payment amount for a beneficiary in the context of a specific matching.
    /// This function checks if the specified `_beneficiary` is the initiator of the matching with ID `_id`
    /// and if the owner of the matching is `_owner`. If both conditions are met, the function returns the
    /// specified payment lock amount, otherwise it returns 0.
    /// @param _owner The address of the owner.
    /// @param _id The business id associated with the credited funds.
    /// @param _beneficiary The address of the beneficiary.
    /// @param _paymentLock The payment lock amount.
    /// @param _storages The Storages contract providing access to relevant data.
    function paymentBeneficiaryAmountByProvider(
        address _owner,
        uint64 _id,
        address _beneficiary,
        uint256 _paymentLock,
        IStorages _storages
    ) internal view returns (uint256) {
        if (
            _storages.matchings().getMatchingInitiator(_id) == _beneficiary &&
            _storages.matchingsBids().getMatchingWinner(_id) == _owner
        ) {
            return _paymentLock;
        }

        return 0;
    }

    /// @dev Calculate the payment amount for an dataset audit.
    /// @param _id The business id associated with the credited funds.
    /// @param _datasetsProof The dataetsProof contract object.
    function paymentBeneficiaryAmountDataAuditFee(
        uint64 _id,
        IDatasetsProof _datasetsProof
    ) internal view returns (uint256) {
        return _datasetsProof.getDatasetDataAuditorFees(_id);
    }
}
