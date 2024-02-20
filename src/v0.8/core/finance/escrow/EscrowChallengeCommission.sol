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

/// @title EscrowChallengeCommission
/// @dev This contract provides functions for managing EscrowChallengeCommission-related operations.
contract EscrowChallengeCommission is EscrowBase {
    /// @notice Get dataset EscrowChallengeCommission requirement.
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
            FinanceType.Type.EscrowChallengeCommission
        );

        amount =
            roles.datasetsChallenge().getChallengeSubmissionCount(_datasetId) *
            roles.filplus().getChallengeProofsSubmiterCount() *
            roles.filplus().getChallengeProofsPricePrePoint();

        amount = current >= amount ? 0 : amount - current;
    }

    /// @dev Internal function to get owners associated with a dataset and matching process.
    /// @param _datasetId The ID of the dataset.
    /// @return owners An array containing the addresses of the dataset and matching process owners.
    function _getPayers(
        uint64 _datasetId,
        uint64 /*_matchingId*/
    ) internal view override returns (address[] memory owners) {
        owners = new address[](1);
        owners[0] = roles.datasets().getDatasetMetadataSubmitter(_datasetId);
    }

    /// @dev Internal function to get payees associated with a dataset and matching process.
    /// @param _datasetId The ID of the dataset.
    /// @return payees An array containing the address of the matching process initiator.
    function _getPayees(
        uint64 _datasetId,
        uint64 /*_matchingId*/
    ) internal view override returns (address[] memory payees) {
        (payees, ) = roles
            .datasetsChallenge()
            .getDatasetChallengeProofsSubmitters(_datasetId);
    }

    /// @dev Internal function to get refund amount.
    /// @param _datasetId The ID of the dataset.
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
            FinanceType.Type.EscrowChallengeCommission
        );
    }

    /// @dev Internal function to get payment amount.
    /// @param _datasetId The ID of the dataset.
    /// @param _matchingId The ID of the matching process.
    /// @param _payer An array containing the addresses of the dataset and matching process owners.
    /// @param _token The type of token for escrow handling (e.g., FIL, ERC-20).
    /// @return amount The payment amount.
    function _getPaymentAmount(
        uint64 _datasetId,
        uint64 _matchingId,
        address _payer,
        address _token
    ) internal view override returns (uint256 amount) {
        (, , , uint256 totalPayment) = roles.finance().getAccountEscrow(
            _datasetId,
            _matchingId,
            _payer,
            _token,
            FinanceType.Type.EscrowChallengeCommission
        );
        address[] memory payees = _getPayees(_datasetId, _matchingId);
        amount = totalPayment / payees.length;
    }

    /// @dev Internal function to check if a refund is applicable.
    /// @return refund A boolean indicating whether a refund is applicable.
    function _isRefund(
        uint64 /*_datasetId*/,
        uint64 /*_matchingId*/
    ) internal pure override returns (bool refund) {
        return false; // TODO: Expiration refund.
    }

    /// @dev Internal function to check if a payment is applicable.
    /// @param _datasetId The ID of the dataset.
    /// @return payment A boolean indicating whether a payment is applicable.
    function _isPayment(
        uint64 _datasetId,
        uint64 /*_matchingId*/
    ) internal view override returns (bool payment) {
        return (roles.datasets().getDatasetState(_datasetId) ==
            DatasetType.State.Approved);
    }
}
