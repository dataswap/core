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

import {Base} from "src/v0.8/core/finance/base/Base.sol";

/// @title ChallengeCommission
/// @dev This contract provides functions for managing ChallengeCommission-related operations.
contract ChallengeCommission is Base {
    /// @notice Get dataset ChallengeCommission requirement.
    /// @param _datasetId The ID of the dataset.
    /// @param _roles The roles contract interface.
    /// @return amount The requirement amount.
    function getRequirement(
        uint64 _datasetId,
        uint64 /*_matchingId*/,
        address /*_owner*/,
        address /*_token*/,
        IRoles _roles
    ) public view override returns (uint256 amount) {
        return
            _roles.datasetsChallenge().getChallengeSubmissionCount(_datasetId) *
            _roles.filplus().getChallengeProofsSubmiterCount() *
            _roles.filplus().getChallengeProofsPricePrePoint();
    }

    /// @dev Internal function to get owners associated with a dataset and matching process.
    /// @param _datasetId The ID of the dataset.
    /// @param _roles The roles contract interface.
    /// @return owners An array containing the addresses of the dataset and matching process owners.
    function _getOwners(
        uint64 _datasetId,
        uint64 /*_matchingId*/,
        IRoles _roles
    ) internal view override returns (address[] memory owners) {
        owners = new address[](1);
        owners[0] = _roles.datasets().getDatasetMetadataSubmitter(_datasetId);
    }

    /// @dev Internal function to get payees associated with a dataset and matching process.
    /// @param _datasetId The ID of the dataset.
    /// @param _roles The roles contract interface.
    /// @return payees An array containing the address of the matching process initiator.
    function _getPayees(
        uint64 _datasetId,
        uint64 /*_matchingId*/,
        IRoles _roles
    ) internal view override returns (address[] memory payees) {
        (payees, ) = _roles
            .datasetsChallenge()
            .getDatasetChallengeProofsSubmitters(_datasetId);
    }

    /// @dev Internal function to get refund amount.
    /// @param _datasetId The ID of the dataset.
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
        (, , amount) = _roles.finance().getAccountEscrow(
            _datasetId,
            _matchingId,
            _owner,
            _token,
            FinanceType.Type.ChallengeCommission
        );
    }

    /// @dev Internal function to get payment amount.
    /// @param _datasetId The ID of the dataset.
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
        (, , uint256 total) = _roles.finance().getAccountEscrow(
            _datasetId,
            _matchingId,
            _owner,
            _token,
            FinanceType.Type.ChallengeCommission
        );
        address[] memory payees = _getPayees(_datasetId, _matchingId, _roles);
        amount = total / payees.length;
    }

    /// @dev Internal function to check if a refund is applicable.
    /// @return refund A boolean indicating whether a refund is applicable.
    function _isRefund(
        uint64 /*_datasetId*/,
        uint64 /*_matchingId*/,
        IRoles /*_roles*/
    ) internal pure override returns (bool refund) {
        return false; // TODO: Expiration refund.
    }

    /// @dev Internal function to check if a payment is applicable.
    /// @param _datasetId The ID of the dataset.
    /// @param _roles The roles contract interface.
    /// @return payment A boolean indicating whether a payment is applicable.
    function _isPayment(
        uint64 _datasetId,
        uint64 /*_matchingId*/,
        IRoles _roles
    ) internal view override returns (bool payment) {
        return (_roles.datasets().getDatasetState(_datasetId) ==
            DatasetType.State.Approved);
    }
}
