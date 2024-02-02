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

/// @title DatacapChunkLand
/// @dev This contract provides functions for managing DatacapChunkLand-related operations.
contract DatacapChunkLand is Base {
    /// @notice Get dataset DatacapChunkLand requirement.
    /// @param _roles The roles contract interface.
    /// @return amount The requirement amount.
    function getRequirement(
        uint64 /*_datasetId*/,
        uint64 _matchingId,
        address /*_owner*/,
        address /*_token*/,
        IRoles _roles
    ) public view override returns (uint256 amount) {
        uint256 price = _roles.filplus().getDatacapChunkLandPricePreByte();
        (uint256 total, , , , , , ) = _roles
            .storages()
            .getMatchingStorageOverview(_matchingId);

        uint64 maxAllocated = _roles
            .filplus()
            .datacapRulesMaxAllocatedSizePerTime();

        amount = Math.min(total, maxAllocated) * price;
    }

    /// @dev Internal function to get owners associated with a dataset and matching process.
    /// @param _matchingId The ID of the matching process.
    /// @param _roles The roles contract interface.
    /// @return owners An array containing the addresses of the dataset and matching process owners.
    function _getOwners(
        uint64 /*_datasetId*/,
        uint64 _matchingId,
        IRoles _roles
    ) internal view override returns (address[] memory owners) {
        owners = new address[](1);
        owners[0] = _roles.matchingsBids().getMatchingWinner(_matchingId);
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
        (, uint256 expenditure, uint256 total) = _roles
            .finance()
            .getAccountEscrow(
                _datasetId,
                _matchingId,
                _owner,
                _token,
                FinanceType.Type.DatacapChunkLandCollateral
            );

        amount = total - expenditure;

        (uint256 totalSize, uint256 storedSize, , , , , ) = _roles
            .storages()
            .getMatchingStorageOverview(_matchingId);

        uint256 price = _roles.filplus().getDatacapChunkLandPricePreByte();
        uint256 burned = (totalSize - storedSize) * price;

        return burned < amount ? amount - burned : 0;
    }

    /// @dev Internal function to get burn amount.
    /// @param _matchingId The ID of the matching process.
    /// @param _owner An array containing the addresses of the dataset and matching process owners.
    /// @param _token The type of token for escrow handling (e.g., FIL, ERC-20).
    /// @param _roles The roles contract interface.
    /// @return amount The burn amount.
    function _getBurnAmount(
        uint64 _datasetId,
        uint64 _matchingId,
        address _owner,
        address _token,
        IRoles _roles
    ) internal view override returns (uint256 amount) {
        (, uint256 expenditure, uint256 total) = _roles
            .finance()
            .getAccountEscrow(
                _datasetId,
                _matchingId,
                _owner,
                _token,
                FinanceType.Type.DatacapChunkLandCollateral
            );

        amount = total - expenditure;

        (uint256 totalSize, uint256 storedSize, , , , , ) = _roles
            .storages()
            .getMatchingStorageOverview(_matchingId);

        uint256 price = _roles.filplus().getDatacapChunkLandPricePreByte();
        uint256 burned = (totalSize - storedSize) * price;

        amount = Math.min(amount, burned);
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
        return ((_matchingId != 0 &&
            _roles.storages().isStorageExpiration(_matchingId)) ||
            _roles.datasets().getDatasetState(_datasetId) ==
            DatasetType.State.Rejected);
    }

    /// @dev Internal function to check if a burn is applicable.
    /// @param _matchingId The ID of the matching process.
    /// @param _roles The roles contract interface.
    /// @return burn A boolean indicating whether a burn is applicable.
    function _isBurn(
        uint64 /*_datasetId*/,
        uint64 _matchingId,
        IRoles _roles
    ) internal view override returns (bool burn) {
        return (_matchingId != 0 &&
            _roles.storages().isStorageExpiration(_matchingId));
    }
}
