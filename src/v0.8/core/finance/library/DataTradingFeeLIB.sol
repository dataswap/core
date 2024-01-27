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

import {ArraysPaymentInfoLIB} from "src/v0.8/shared/utils/array/ArrayLIB.sol";

/// @title DataTradingFeeLIB
/// @dev This library provides functions for managing DataTradingFee-related operations.
library DataTradingFeeLIB {
    using ArraysPaymentInfoLIB for FinanceType.PaymentInfo[];

    /// @dev Retrieves payee information for DataTradingFee.
    /// @param _datasetId The ID of the dataset.
    /// @param _matchingId The ID of the matching process.
    /// @param _token The type of token for escrow handling (e.g., FIL, ERC-20).
    /// @param _roles The roles contract interface.
    /// @return paymentsInfo An array containing the payees's address.
    function getPayeeInfo(
        uint64 _datasetId,
        uint64 _matchingId,
        address _token,
        IRoles _roles
    ) internal view returns (FinanceType.PaymentInfo[] memory paymentsInfo) {
        // 1. Get owners
        address[] memory owners = _getOwners(_datasetId, _matchingId, _roles);
        paymentsInfo = new FinanceType.PaymentInfo[](0);

        if (_isRefund(_datasetId, _matchingId, _roles)) {
            // 2.1 Get refund info
            FinanceType.PaymentInfo[] memory refundInfo = _getRefundInfo(
                _datasetId,
                _matchingId,
                owners,
                _token,
                _roles
            );
            paymentsInfo = paymentsInfo.appendArrays(refundInfo);
        }

        if (_isBurn(_datasetId, _matchingId, _roles)) {
            // 2.2 Get burn info
            FinanceType.PaymentInfo[] memory burnInfo = _getBurnInfo(
                _datasetId,
                _matchingId,
                owners,
                _token,
                _roles
            );
            paymentsInfo = paymentsInfo.appendArrays(burnInfo);
        }

        if (_isPayment(_datasetId, _matchingId, _roles)) {
            // 2.3 Get payment payees
            address[] memory payees = _getPayees(
                _datasetId,
                _matchingId,
                _roles
            );
            // 2.4 Get payment info
            FinanceType.PaymentInfo[] memory paymentInfo = _getPaymentInfo(
                _datasetId,
                _matchingId,
                owners,
                payees,
                _token,
                _roles
            );
            paymentsInfo = paymentsInfo.appendArrays(paymentInfo);
        }
    }

    /// @notice Get dataset pre-conditional collateral requirement.
    /// @param _datasetId The ID of the dataset.
    /// @param _matchingId The ID of the matching process.
    /// @param _token The type of token for escrow handling (e.g., FIL, ERC-20).
    /// @param _roles The roles contract interface.
    /// @return amount The collateral requirement amount.
    function getRequirement(
        uint64 _datasetId,
        uint64 _matchingId,
        address _token,
        IRoles _roles
    )
        internal
        view
        returns (
            uint256 amount // solhint-disable-next-line
        )
    {}

    /// @dev Internal function to get owners associated with a dataset and matching process.
    /// @param _datasetId The ID of the dataset.
    /// @param _matchingId The ID of the matching process.
    /// @param _roles The roles contract interface.
    /// @return owners An array containing the addresses of the dataset and matching process owners.
    function _getOwners(
        uint64 _datasetId,
        uint64 _matchingId,
        IRoles _roles
    ) internal view returns (address[] memory owners) {
        if (_matchingId != 0) {
            owners = new address[](2);
            owners[0] = _roles.matchingsBids().getMatchingWinner(_matchingId);
            owners[1] = _roles.datasets().getDatasetMetadataSubmitter(
                _datasetId
            );
        } else {
            owners = new address[](1);
            owners[0] = _roles.datasets().getDatasetMetadataSubmitter(
                _datasetId
            );
        }
    }

    /// @dev Internal function to get payees associated with a dataset and matching process.
    /// @param _matchingId The ID of the matching process.
    /// @param _roles The roles contract interface.
    /// @return payees An array containing the address of the matching process initiator.
    function _getPayees(
        uint64 /*_datasetId*/,
        uint64 _matchingId,
        IRoles _roles
    ) internal view returns (address[] memory payees) {
        payees = new address[](1);
        payees[0] = _roles.matchings().getMatchingInitiator(_matchingId);
    }

    /// @dev Internal function to get refund information.
    /// @param _datasetId The ID of the dataset.
    /// @param _matchingId The ID of the matching process.
    /// @param _owners An array containing the addresses of the dataset and matching process owners.
    /// @param _token The type of token for escrow handling (e.g., FIL, ERC-20).
    /// @param _roles The roles contract interface.
    /// @return refunds An array containing payment information for refund.
    function _getRefundInfo(
        uint64 _datasetId,
        uint64 _matchingId,
        address[] memory _owners,
        address _token,
        IRoles _roles
    ) internal view returns (FinanceType.PaymentInfo[] memory refunds) {
        uint256 ownersLen = _owners.length;
        refunds = new FinanceType.PaymentInfo[](ownersLen);
        for (uint256 i = 0; i < ownersLen; i++) {
            uint256 amount = _getRefundAmount(
                _datasetId,
                _matchingId,
                _owners[i],
                _token,
                _roles
            );
            FinanceType.PayeeInfo[] memory payees = new FinanceType.PayeeInfo[](
                1
            );
            payees[0] = FinanceType.PayeeInfo(_owners[i], amount);
            refunds[i] = FinanceType.PaymentInfo(_owners[i], amount, payees);
        }
    }

    /// @dev Internal function to get burn information.
    /// @return burns An array containing payment information for burn.
    function _getBurnInfo(
        uint64 /*_datasetId*/,
        uint64 /*_matchingId*/,
        address[] memory /*_owners*/,
        address /*_token*/,
        IRoles /*_roles*/
    )
        internal
        pure
        returns (
            FinanceType.PaymentInfo[] memory burns // solhint-disable-next-line
        )
    {}

    /// @dev Internal function to get payment information.
    /// @param _datasetId The ID of the dataset.
    /// @param _matchingId The ID of the matching process.
    /// @param _owners An array containing the addresses of the dataset and matching process owners.
    /// @param _payees An array containing the address of the matching process initiator.
    /// @param _token The type of token for escrow handling (e.g., FIL, ERC-20).
    /// @param _roles The roles contract interface.
    /// @return payments An array containing payment information.
    function _getPaymentInfo(
        uint64 _datasetId,
        uint64 _matchingId,
        address[] memory _owners,
        address[] memory _payees,
        address _token,
        IRoles _roles
    ) internal view returns (FinanceType.PaymentInfo[] memory payments) {
        uint256 ownersLen = _owners.length;
        uint256 payeesLen = _payees.length;
        payments = new FinanceType.PaymentInfo[](ownersLen);
        for (uint256 i = 0; i < ownersLen; i++) {
            uint256 amount = _getPaymentAmount(
                _datasetId,
                _matchingId,
                _owners[i],
                _token,
                _roles
            );
            FinanceType.PayeeInfo[] memory payees = new FinanceType.PayeeInfo[](
                payeesLen
            );
            for (uint256 j = 0; j < payeesLen; j++) {
                payees[j] = FinanceType.PayeeInfo(
                    _payees[j],
                    amount / payeesLen
                );
            }

            payments[i] = FinanceType.PaymentInfo(_owners[i], amount, payees);
        }
    }

    /// @dev Internal function to get refund amount.
    /// @param _matchingId The ID of the matching process.
    /// @param _owner An array containing the addresses of the dataset and matching process owners.
    /// @param _token The type of token for escrow handling (e.g., FIL, ERC-20).
    /// @param _roles The roles contract interface.
    /// @return amount The refund amount.
    function _getRefundAmount(
        uint64 _datasetId,
        uint64 _matchingId,
        address _owner,
        address _token,
        IRoles _roles
    ) internal view returns (uint256 amount) {
        (uint256 totalSize, uint256 storedSize, , , , , ) = _roles
            .storages()
            .getMatchingStorageOverview(_matchingId);

        address winner = _roles.matchingsBids().getMatchingWinner(_matchingId);
        uint256 totalPayment = 0;
        if (winner == _owner) {
            totalPayment = _roles.matchingsBids().getMatchingBidAmount(
                _matchingId,
                winner
            );
        } else {
            (, , totalPayment) = _roles.finance().getAccountEscrow(
                _datasetId,
                _matchingId,
                _token,
                _owner,
                FinanceType.Type.DataTradingFee
            );
        }

        amount = (totalPayment / totalSize) * (totalSize - storedSize);
    }

    /// @dev Internal function to get burn amount.
    /// @return amount The burn amount.
    function _getBurnAmount(
        uint64 /*_datasetId*/,
        uint64 /*_matchingId*/,
        address /*_owner*/,
        address /*_token*/,
        IRoles /*_roles*/
    )
        internal
        pure
        returns (
            uint256 amount // solhint-disable-next-line
        )
    {}

    /// @dev Internal function to get payment amount.
    /// @param _matchingId The ID of the matching process.
    /// @param _owner An array containing the addresses of the dataset and matching process owners.
    /// @param _token The type of token for escrow handling (e.g., FIL, ERC-20).
    /// @param _roles The roles contract interface.
    /// @return amount The payment amount.
    function _getPaymentAmount(
        uint64 _datasetId,
        uint64 _matchingId,
        address _owner,
        address _token,
        IRoles _roles
    ) internal view returns (uint256 amount) {
        (uint256 totalSize, uint256 storedSize, , , , , ) = _roles
            .storages()
            .getMatchingStorageOverview(_matchingId);

        address winner = _roles.matchingsBids().getMatchingWinner(_matchingId);
        uint256 totalPayment = 0;
        if (winner == _owner) {
            totalPayment = _roles.matchingsBids().getMatchingBidAmount(
                _matchingId,
                winner
            );
        } else {
            (, , totalPayment) = _roles.finance().getAccountEscrow(
                _datasetId,
                _matchingId,
                _owner,
                _token,
                FinanceType.Type.DataTradingFee
            );
        }
        amount = (totalPayment / totalSize) * storedSize;
    }

    /// @dev Internal function to check if a refund is applicable.
    /// @param _datasetId The ID of the dataset.
    /// @param _matchingId The ID of the matching process.
    /// @param _roles The roles contract interface.
    /// @return refund A boolean indicating whether a refund is applicable.
    function _isRefund(
        uint64 _datasetId,
        uint64 _matchingId,
        IRoles _roles
    ) internal view returns (bool refund) {
        return ((_matchingId != 0 &&
            _roles.storages().isStorageExpiration(_matchingId)) ||
            _roles.datasets().getDatasetState(_datasetId) ==
            DatasetType.State.MetadataRejected);
    }

    /// @dev Internal function to check if a burn is applicable.
    /// @return burn A boolean indicating whether a burn is applicable.
    function _isBurn(
        uint64 /*_datasetId*/,
        uint64 /*_matchingId*/,
        IRoles /*_roles*/
    ) internal pure returns (bool burn) {
        burn = false;
    }

    /// @dev Internal function to check if a payment is applicable.
    /// @param _matchingId The ID of the matching process.
    /// @param _roles The roles contract interface.
    /// @return payment A boolean indicating whether a payment is applicable.
    function _isPayment(
        uint64 /*_datasetId*/,
        uint64 _matchingId,
        IRoles _roles
    ) internal view returns (bool payment) {
        return (_matchingId != 0 &&
            _roles.storages().getStoredCarCount(_matchingId) > 0);
    }
}
