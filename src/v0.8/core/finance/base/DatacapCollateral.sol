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

import {Math} from "@openzeppelin/contracts/utils/math/Math.sol";

import {DatasetType} from "src/v0.8/types/DatasetType.sol";
import {FinanceType} from "src/v0.8/types/FinanceType.sol";
import {IRoles} from "src/v0.8/interfaces/core/IRoles.sol";

import {Base} from "src/v0.8/core/finance/base/Base.sol";

/// @title DatacapCollateral
/// @dev This contract provides functions for managing DatacapCollateral-related operations.
contract DatacapCollateral is Base {
    /// @notice Get dataset DatacapCollateral requirement.
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
        (, , , , , , , , uint256 datasetSize, , ) = _roles
            .datasets()
            .getDatasetMetadata(_datasetId);

        if (
            _roles.datasetsProof().isDatasetProofallCompleted(
                _datasetId,
                DatasetType.DataType.Source
            )
        ) {
            datasetSize = _roles.datasetsProof().getDatasetSize(
                _datasetId,
                DatasetType.DataType.Source
            );
        }
        amount =
            datasetSize *
            _roles.datasetsRequirement().getDatasetReplicasCount(_datasetId) *
            _roles.filplus().getDatacapPricePreByte();
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

    /// @dev Internal function to get refund amount.
    /// @param _matchingId The ID of the matching process.
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
        amount = getRequirement(
            _datasetId,
            _matchingId,
            _owner,
            _token,
            _roles
        );
    }

    /// @dev Internal function to check if a refund is applicable.
    /// @param _datasetId The ID of the dataset.
    /// @param _roles The roles contract interface.
    /// @return refund A boolean indicating whether a refund is applicable.
    function _isRefund(
        uint64 _datasetId,
        uint64 /*_matchingId*/,
        IRoles _roles
    ) internal view override returns (bool refund) {
        DatasetType.State state = _roles.datasets().getDatasetState(_datasetId);

        return state == DatasetType.State.Rejected ? true : false;
        // TODO: Expiration refund.
    }
}