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

import {Base} from "src/v0.8/core/finance/base/Base.sol";

/// @title DataTradingFee
/// @dev This contract provides functions for managing DataTradingFee-related operations.
contract DataTradingFee is Base {
    /// @dev Internal function to get bids refund information.
    /// @param _matchingId The ID of the matching process.
    /// @param _roles The roles contract interface.
    /// @return refunds An array containing payment information for refund.
    function _getBidsRefundInfo(
        uint64 /*_datasetId*/,
        uint64 _matchingId,
        address /*_token*/,
        IRoles _roles
    )
        internal
        view
        override
        returns (FinanceType.PaymentInfo[] memory refunds)
    {
        (
            address[] memory bidders,
            uint256[] memory amounts,
            ,
            address winner
        ) = _roles.matchingsBids().getMatchingBids(_matchingId);

        uint256 biddersLen = bidders.length;
        refunds = new FinanceType.PaymentInfo[](biddersLen - 1);

        for (uint256 i = 0; i < biddersLen; i++) {
            if (bidders[i] != winner) {
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

    /// @notice Get dataset pre-conditional collateral requirement.
    /// @param _datasetId The ID of the dataset.
    /// @param _matchingId The ID of the matching process.
    /// @param _roles The roles contract interface.
    /// @return amount The collateral requirement amount.
    function getRequirement(
        uint64 _datasetId,
        uint64 _matchingId,
        address _owner,
        address /*_token*/,
        IRoles _roles
    )
        public
        view
        override
        returns (
            uint256 amount // solhint-disable-next-line
        )
    {
        if (
            _owner == _roles.datasets().getDatasetMetadataSubmitter(_datasetId)
        ) {
            /// TODO: Add dataTradingFee requirement get interface.
        } else if (
            _owner == _roles.matchingsBids().getMatchingWinner(_matchingId)
        ) {
            amount = _roles.matchingsBids().getMatchingBidAmount(
                _matchingId,
                _owner
            );
        } else {
            require(false, "owner account does not exist");
        }
    }

    /// @dev Internal function to get owners associated with a dataset and matching process.
    /// @param _datasetId The ID of the dataset.
    /// @param _matchingId The ID of the matching process.
    /// @param _roles The roles contract interface.
    /// @return owners An array containing the addresses of the dataset and matching process owners.
    function _getOwners(
        uint64 _datasetId,
        uint64 _matchingId,
        IRoles _roles
    ) internal view override returns (address[] memory owners) {
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
    ) internal view override returns (address[] memory payees) {
        payees = new address[](1);
        payees[0] = _roles.matchings().getMatchingInitiator(_matchingId);
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
    ) internal view override returns (uint256 amount) {
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
    ) internal view override returns (uint256 amount) {
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
    ) internal view override returns (bool refund) {
        return (
            ((_matchingId != 0 &&
                (_roles.storages().isStorageExpiration(_matchingId) ||
                    _roles.matchings().getMatchingState(_matchingId) ==
                    MatchingType.State.Closed)) ||
                _roles.datasets().getDatasetState(_datasetId) ==
                DatasetType.State.Rejected)
        );
    }

    /// @dev Internal function to check if a bids refund is applicable.
    /// @param _datasetId The ID of the dataset.
    /// @param _matchingId The ID of the matching process.
    /// @param _roles The roles contract interface.
    /// @return refund A boolean indicating whether a refund is applicable.
    function _isBidsRefund(
        uint64 _datasetId,
        uint64 _matchingId,
        IRoles _roles
    ) internal view override returns (bool refund) {
        return (
            !((_matchingId != 0 &&
                _roles.storages().isStorageExpiration(_matchingId)) ||
                _roles.datasets().getDatasetState(_datasetId) ==
                DatasetType.State.Rejected)
        );
    }

    /// @dev Internal function to check if a payment is applicable.
    /// @param _matchingId The ID of the matching process.
    /// @param _roles The roles contract interface.
    /// @return payment A boolean indicating whether a payment is applicable.
    function _isPayment(
        uint64 /*_datasetId*/,
        uint64 _matchingId,
        IRoles _roles
    ) internal view override returns (bool payment) {
        return (_matchingId != 0 &&
            _roles.storages().getStoredCarCount(_matchingId) > 0);
    }
}
