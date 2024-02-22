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

import {DatasetType} from "src/v0.8/types/DatasetType.sol";
import {FinanceType} from "src/v0.8/types/FinanceType.sol";
import {IRoles} from "src/v0.8/interfaces/core/IRoles.sol";
import {MatchingType} from "src/v0.8/types/MatchingType.sol";

import {EscrowBase} from "src/v0.8/core/finance/escrow/EscrowBase.sol";

import {ArraysPaymentInfoLIB} from "src/v0.8/shared/utils/array/ArrayLIB.sol";

/// @title EscrowDataTradingFee
/// @dev This contract provides functions for managing EscrowDataTradingFee-related operations.
contract EscrowDataTradingFee is EscrowBase {
    using ArraysPaymentInfoLIB for FinanceType.PaymentInfo[];

    /// @dev Internal function to get refund information.
    /// @param _datasetId The ID of the dataset.
    /// @param _matchingId The ID of the matching process.
    /// @param _payers An array containing the addresses of the dataset and matching process payers.
    /// @param _token The type of token for escrow handling (e.g., FIL, ERC-20).
    /// @return refunds An array containing payment information for refund.
    function _getRefundInfo(
        uint64 _datasetId,
        uint64 _matchingId,
        address[] memory _payers,
        address _token
    )
        internal
        view
        override
        returns (FinanceType.PaymentInfo[] memory refunds)
    {
        refunds = new FinanceType.PaymentInfo[](0);

        if (_isEscrowRefund(_matchingId)) {
            FinanceType.PaymentInfo[] memory refundInfo = super._getRefundInfo(
                _datasetId,
                _matchingId,
                _payers,
                _token
            );
            refunds = refunds.appendArrays(refundInfo);
        }

        if (_isBidsRefund(_matchingId)) {
            FinanceType.PaymentInfo[] memory refundInfo = _getBidsRefundInfo(
                _datasetId,
                _matchingId,
                _token
            );
            refunds = refunds.appendArrays(refundInfo);
        }

        if (_isSourceAccountRefund(_datasetId)) {
            FinanceType.PaymentInfo[]
                memory refundInfo = _getMoveSourceAccountRefundInfo(
                    _datasetId,
                    _token
                );
            refunds = refunds.appendArrays(refundInfo);
        }
    }

    /// @dev Internal function to get source account refund information.
    /// @param _datasetId The ID of the dataset.
    /// @param _token The type of token for escrow handling (e.g., FIL, ERC-20).
    /// @return refunds An array containing payment information for refund.
    function _getMoveSourceAccountRefundInfo(
        uint64 _datasetId,
        address _token
    ) internal view returns (FinanceType.PaymentInfo[] memory refunds) {
        address payer = roles.datasets().getDatasetMetadataSubmitter(
            _datasetId
        );
        (, , uint256 current, ) = roles.finance().getAccountEscrow(
            _datasetId,
            0,
            payer,
            _token,
            FinanceType.Type.EscrowDataTradingFee
        );

        if (current != 0) {
            FinanceType.PayeeInfo[] memory payees = new FinanceType.PayeeInfo[](
                1
            );
            payees[0] = FinanceType.PayeeInfo(payer, current);

            refunds = new FinanceType.PaymentInfo[](1);
            refunds[0] = FinanceType.PaymentInfo(payer, current, payees);
        }
    }

    /// @dev Internal function to get bids refund information.
    /// @param _datasetId The ID of the dataset.
    /// @param _matchingId The ID of the matching process.
    /// @param _token The type of token for escrow handling (e.g., FIL, ERC-20).
    /// @return refunds An array containing payment information for refund.
    function _getBidsRefundInfo(
        uint64 _datasetId,
        uint64 _matchingId,
        address _token
    ) internal view returns (FinanceType.PaymentInfo[] memory refunds) {
        (
            address[] memory bidders,
            uint256[] memory amounts,
            ,
            address winner
        ) = roles.matchingsBids().getMatchingBids(_matchingId);

        uint256 biddersLen = bidders.length;
        refunds = new FinanceType.PaymentInfo[](biddersLen - 1);

        for (uint256 i = 0; i < biddersLen; i++) {
            if (bidders[i] != winner) {
                (, , uint256 current, ) = roles.finance().getAccountEscrow(
                    _datasetId,
                    _matchingId,
                    bidders[i],
                    _token,
                    FinanceType.Type.EscrowDataTradingFee
                );
                if (current == 0) {
                    continue; // Refunded
                }

                FinanceType.PayeeInfo[]
                    memory payees = new FinanceType.PayeeInfo[](1);
                payees[0] = FinanceType.PayeeInfo(bidders[i], amounts[i]);
                refunds[i] = FinanceType.PaymentInfo(
                    bidders[i],
                    amounts[i],
                    payees
                );
            }
        }
    }

    /// @dev Internal function to get move source account information.
    /// @param _datasetId The ID of the dataset.
    /// @param _destMatchingId The ID of the matching process.
    /// @param _token The type of token for escrow handling (e.g., FIL, ERC-20).
    /// @return destAccountInfo An array containing payment information.
    function _getMoveSourceAccountInfo(
        uint64 _datasetId,
        uint64 _destMatchingId,
        address _token
    )
        internal
        view
        override
        returns (FinanceType.PaymentInfo[] memory destAccountInfo)
    {
        address payer = roles.datasets().getDatasetMetadataSubmitter(
            _datasetId
        );

        // Source account balance
        (, , uint256 current, ) = roles.finance().getAccountEscrow(
            _datasetId,
            0,
            payer,
            _token,
            FinanceType.Type.EscrowDataTradingFee
        );

        (, , uint64 matchingSize, , , ) = roles
            .matchingsTarget()
            .getMatchingTarget(_destMatchingId);

        (uint256 usedSize, , , , , ) = roles
            .storages()
            .getDatasetStorageOverview(_datasetId);

        uint256 unusedSize = roles.datasetsProof().getDatasetSize(
            _datasetId,
            DatasetType.DataType.Source
        ) *
            roles.datasetsRequirement().getDatasetReplicasCount(_datasetId) -
            usedSize;

        uint256 amount = (current / unusedSize) * matchingSize;

        FinanceType.PayeeInfo[] memory payees = new FinanceType.PayeeInfo[](1);
        payees[0] = FinanceType.PayeeInfo(payer, amount);

        destAccountInfo = new FinanceType.PaymentInfo[](1);
        destAccountInfo[0] = FinanceType.PaymentInfo(payer, amount, payees);
    }

    /// @notice Get dataset pre-conditional collateral requirement.
    /// @param _datasetId The ID of the dataset.
    /// @param _matchingId The ID of the matching process.
    /// @param _payer An array containing the addresses of the dataset and matching process payers.
    /// @param _token The type of token for escrow handling (e.g., FIL, ERC-20).
    /// @return amount The collateral requirement amount.
    function getRequirement(
        uint64 _datasetId,
        uint64 _matchingId,
        address _payer,
        address _token
    ) public view override returns (uint256 amount) {
        if (_payer == roles.matchingsBids().getMatchingWinner(_matchingId)) {
            amount = roles.matchingsBids().getMatchingBidAmount(
                _matchingId,
                _payer
            );
        } else {
            require(false, "payer account does not exist");
        }

        (, , uint256 current, ) = roles.finance().getAccountEscrow(
            _datasetId,
            _matchingId,
            _payer,
            _token,
            FinanceType.Type.EscrowDataTradingFee
        );

        amount = current >= amount ? 0 : amount - current;
    }

    /// @dev Internal function to get payers associated with a dataset and matching process.
    /// @param _datasetId The ID of the dataset.
    /// @param _matchingId The ID of the matching process.
    /// @return payers An array containing the addresses of the dataset and matching process payers.
    function _getPayers(
        uint64 _datasetId,
        uint64 _matchingId
    ) internal view override returns (address[] memory payers) {
        payers = new address[](2);
        payers[0] = roles.matchingsBids().getMatchingWinner(_matchingId);
        payers[1] = roles.datasets().getDatasetMetadataSubmitter(_datasetId);
    }

    /// @dev Internal function to get payees associated with a dataset and matching process.
    /// @param _matchingId The ID of the matching process.
    /// @return payees An array containing the address of the matching process initiator.
    function _getPayees(
        uint64 /*_datasetId*/,
        uint64 _matchingId
    ) internal view override returns (address[] memory payees) {
        payees = new address[](1);
        payees[0] = roles.matchings().getMatchingInitiator(_matchingId);
    }

    /// @dev Internal function to get refund amount.
    /// @param _datasetId The ID of the dataset.
    /// @param _matchingId The ID of the matching process.
    /// @param _payer An array containing the addresses of the dataset and matching process payers.
    /// @param _token The type of token for escrow handling (e.g., FIL, ERC-20).
    /// @return amount The refund amount.
    function _getRefundAmount(
        uint64 _datasetId,
        uint64 _matchingId,
        address _payer,
        address _token
    ) internal view override returns (uint256 amount) {
        (, , uint256 current, uint256 total) = roles.finance().getAccountEscrow(
            _datasetId,
            _matchingId,
            _payer,
            _token,
            FinanceType.Type.EscrowDataTradingFee
        );
        if (current != 0) {
            // Not refunded
            (uint256 totalSize, uint256 storedSize, , , , , ) = roles
                .storages()
                .getMatchingStorageOverview(_matchingId);

            amount = (total / totalSize) * (totalSize - storedSize);
        }
    }

    /// @dev Internal function to get payment amount.
    /// @param _datasetId The ID of the dataset.
    /// @param _matchingId The ID of the matching process.
    /// @param _payer An array containing the addresses of the dataset and matching process payers.
    /// @param _token The type of token for escrow handling (e.g., FIL, ERC-20).
    /// @return amount The payment amount.
    function _getPaymentAmount(
        uint64 _datasetId,
        uint64 _matchingId,
        address _payer,
        address _token
    ) internal view override returns (uint256 amount) {
        (, uint256 expenditure, , uint256 total) = roles
            .finance()
            .getAccountEscrow(
                _datasetId,
                _matchingId,
                _payer,
                _token,
                FinanceType.Type.EscrowDataTradingFee
            );

        (uint256 totalSize, uint256 storedSize, , , , , ) = roles
            .storages()
            .getMatchingStorageOverview(_matchingId);

        amount = (total / totalSize) * (storedSize) - expenditure;
    }

    /// @dev Internal function to check if a refund is applicable.
    /// @param _datasetId The ID of the dataset.
    /// @param _matchingId The ID of the matching process.
    /// @return refund A boolean indicating whether a refund is applicable.
    function _isRefund(
        uint64 _datasetId,
        uint64 _matchingId
    ) internal view override returns (bool) {
        return (_isEscrowRefund(_matchingId) ||
            _isSourceAccountRefund(_datasetId) ||
            _isBidsRefund(_matchingId));
    }

    /// @dev Internal function to check if an escrow refund is applicable.
    /// @param _matchingId The ID of the matching process.
    /// @return refund A boolean indicating whether an escrow refund is applicable.
    function _isEscrowRefund(uint64 _matchingId) internal view returns (bool) {
        return
            _matchingId != 0 &&
            roles.storages().isStorageExpiration(_matchingId);
    }

    /// @dev Internal function to check if a parent account refund is applicable.
    /// @param _datasetId The ID of the dataset.
    /// @return refund A boolean indicating whether a parent account refund is applicable.
    function _isSourceAccountRefund(
        uint64 _datasetId
    ) internal view returns (bool) {
        return
            roles.datasets().getDatasetState(_datasetId) ==
            DatasetType.State.Rejected;
    }

    /// @dev Internal function to check if a bids refund is applicable.
    /// @param _matchingId The ID of the matching process.
    /// @return refund A boolean indicating whether a refund is applicable.
    function _isBidsRefund(
        uint64 _matchingId
    ) internal view returns (bool refund) {
        return (roles.matchings().getMatchingState(_matchingId) ==
            MatchingType.State.Closed);
    }

    /// @dev Internal function to check if a payment is applicable.
    /// @param _matchingId The ID of the matching process.
    /// @return payment A boolean indicating whether a payment is applicable.
    function _isPayment(
        uint64 /*_datasetId*/,
        uint64 _matchingId
    ) internal view override returns (bool payment) {
        return (roles.storages().getStoredCarCount(_matchingId) > 0);
    }
}
