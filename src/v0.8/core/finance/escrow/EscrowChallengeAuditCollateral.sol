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

import {EscrowBase} from "src/v0.8/core/finance/escrow/EscrowBase.sol";

/// @title EscrowChallengeAuditCollateral
/// @dev This contract provides functions for managing EscrowChallengeAuditCollateral-related operations.
contract EscrowChallengeAuditCollateral is EscrowBase {
    /// @notice Get dataset EscrowChallengeAuditCollateral requirement.
    /// @param _datasetId The ID of the dataset.
    /// @param _matchingId The ID of the matching process.
    /// @param _payer An array containing the addresses of the dataset and matching process owners.
    /// @param _token The type of token for escrow handling (e.g., FIL, ERC-20).
    /// @return amount The requirement amount.
    function getRequirement(
        uint64 _datasetId,
        uint64 _matchingId,
        address _payer,
        address _token
    ) public view override returns (uint256 amount) {
        (, , uint256 current, ) = roles.finance().getAccountEscrow(
            _datasetId,
            _matchingId,
            _payer,
            _token,
            FinanceType.Type.EscrowChallengeAuditCollateral
        );

        amount = roles.filplus().getChallengeAuditFee();

        amount = current >= amount ? 0 : amount - current;
    }

    /// @dev Internal function to get owners associated with a dataset and matching process.
    /// @param _datasetId The ID of the dataset process.
    /// @return owners An array containing the addresses of the dataset and matching process owners.
    function _getPayers(
        uint64 _datasetId,
        uint64 /*_matchingId*/
    ) internal view override returns (address[] memory owners) {
        // TODO: Add get payers interface.
        // owners = new address[](1);
        // owners[0] = roles.datasetsChallenge().getDatasetChallengeProofsSubmitters(_datasetId);
    }

    /// @dev Internal function to get payees associated with a dataset and matching process.
    /// @param _matchingId The ID of the matching process.
    /// @return payees An array containing the address of the matching process initiator.
    function _getPayees(
        uint64 /*_datasetId*/,
        uint64 _matchingId
    ) internal view override returns (address[] memory payees) {
        // TODO: Add get payees interface.
        // payees = new address[](1);
        // payees[0] = roles.matchings().getMatchingInitiator(_matchingId);
    }

    /// @dev Internal function to get refund amount.
    /// @param _matchingId The ID of the matching process.
    /// @param _payer An array containing the addresses of the dataset and matching process owners.
    /// @param _token The type of token for escrow handling (e.g., FIL, ERC-20).
    /// @return amount The refund amount.
    function _getRefundAmount(
        uint64 _datasetId,
        uint64 _matchingId,
        address _payer,
        address _token
    ) internal view override returns (uint256 amount) {
        (, , amount, ) = roles.finance().getAccountEscrow(
            _datasetId,
            _matchingId,
            _payer,
            _token,
            FinanceType.Type.EscrowChallengeAuditCollateral
        ); 
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
        (, , amount, ) = roles.finance().getAccountEscrow(
            _datasetId,
            _matchingId,
            _payer,
            _token,
            FinanceType.Type.EscrowChallengeAuditCollateral
        ); 
    }

    /// @dev Internal function to check if a refund is applicable.
    /// @param _datasetId The ID of the dataset.
    /// @return refund A boolean indicating whether a refund is applicable.
    function _isRefund(
        uint64 _datasetId,
        uint64 /*_matchingId*/
    ) internal view override returns (bool refund) {
        //TODO: refund when reject without dispute
        // return (roles.datasets().getDatasetState(_datasetId) ==
        //     DatasetType.State.Approved);
    }

    /// @dev Internal function to check if a payment is applicable.
    /// @param _datasetId The ID of the dataset process.
    /// @return payment A boolean indicating whether a payment is applicable.
    function _isPayment(
        uint64 _datasetId,
        uint64 /*_matchingId*/
    ) internal view override returns (bool payment) {
        //TODO: only payment when reject withdispute
        // return (
        //     roles.datasets().getDatasetState(_datasetId) ==
        //     DatasetType.State.Rejected);
    }
}
