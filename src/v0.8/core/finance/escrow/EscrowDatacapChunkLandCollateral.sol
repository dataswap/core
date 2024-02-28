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

import {RolesType} from "src/v0.8/types/RolesType.sol";
import {DatasetType} from "src/v0.8/types/DatasetType.sol";
import {FinanceType} from "src/v0.8/types/FinanceType.sol";
import {IRoles} from "src/v0.8/interfaces/core/IRoles.sol";

import {EscrowBase} from "src/v0.8/core/finance/escrow/EscrowBase.sol";

/// @title EscrowDatacapChunkLandCollateral
/// @dev This contract provides functions for managing EscrowDatacapChunkLandCollateral-related operations.
contract EscrowDatacapChunkLandCollateral is EscrowBase {
    /// @notice Get dataset EscrowDatacapChunkLandCollateral requirement.
    /// @param _datasetId The ID of the dataset.
    /// @param _matchingId The ID of the matching process.
    /// @param _payer An array containing the addresses of the dataset and matching process owners.
    /// @param _token The type of token for escrow handling (e.g., FIL, ERC-20).
    /// @return amount The requirement amount.
    function __getRequirement(
        uint64 _datasetId,
        uint64 _matchingId,
        address _payer,
        address _token
    ) public view override onlyRole(roles, RolesType.DATASWAP_CONTRACT) returns (uint256 amount) {
        (, , uint256 current, ) = roles.finance().getAccountEscrow(
            _datasetId,
            _matchingId,
            _payer,
            _token,
            FinanceType.Type.EscrowDatacapChunkLandCollateral
        );

        uint256 price = roles.filplus().getDatacapChunkLandPricePreByte();
        (uint256 totalSize, , , , , , ) = roles
            .storages()
            .getMatchingStorageOverview(_matchingId);

        uint64 maxAllocated = roles
            .filplus()
            .datacapRulesMaxAllocatedSizePerTime();

        amount = Math.min(totalSize, maxAllocated) * price;

        amount = current >= amount ? 0 : amount - current;
    }

    /// @dev Internal function to get owners associated with a dataset and matching process.
    /// @param _matchingId The ID of the matching process.
    /// @return owners An array containing the addresses of the dataset and matching process owners.
    function _getPayers(
        uint64 /*_datasetId*/,
        uint64 _matchingId
    ) internal view override returns (address[] memory owners) {
        owners = new address[](1);
        owners[0] = roles.matchingsBids().getMatchingWinner(_matchingId);
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
        (, , uint256 current, ) = roles.finance().getAccountEscrow(
            _datasetId,
            _matchingId,
            _payer,
            _token,
            FinanceType.Type.EscrowDatacapChunkLandCollateral
        );

        (uint256 totalSize, uint256 storedSize, , , , , ) = roles
            .storages()
            .getMatchingStorageOverview(_matchingId);

        uint256 price = roles.filplus().getDatacapChunkLandPricePreByte();
        uint256 burned = (totalSize - storedSize) * price;

        return burned < current ? current - burned : 0;
    }

    /// @dev Internal function to get burn amount.
    /// @param _matchingId The ID of the matching process.
    /// @param _payer An array containing the addresses of the dataset and matching process owners.
    /// @param _token The type of token for escrow handling (e.g., FIL, ERC-20).
    /// @return amount The burn amount.
    function _getBurnAmount(
        uint64 _datasetId,
        uint64 _matchingId,
        address _payer,
        address _token
    ) internal view override returns (uint256 amount) {
        (, , uint256 current, ) = roles.finance().getAccountEscrow(
            _datasetId,
            _matchingId,
            _payer,
            _token,
            FinanceType.Type.EscrowDatacapChunkLandCollateral
        );

        (uint256 totalSize, uint256 storedSize, , , , , ) = roles
            .storages()
            .getMatchingStorageOverview(_matchingId);

        uint256 price = roles.filplus().getDatacapChunkLandPricePreByte();
        uint256 burned = (totalSize - storedSize) * price;

        amount = Math.min(current, burned);
    }

    /// @dev Internal function to check if a refund is applicable.
    /// @param _datasetId The ID of the dataset.
    /// @param _matchingId The ID of the matching process.
    /// @return refund A boolean indicating whether a refund is applicable.
    function _isRefund(
        uint64 _datasetId,
        uint64 _matchingId
    ) internal view override returns (bool refund) {
        return ((_matchingId != 0 &&
            roles.storages().isStorageExpiration(_matchingId)) ||
            roles.datasets().getDatasetState(_datasetId) ==
            DatasetType.State.Rejected);
    }

    /// @dev Internal function to check if a burn is applicable.
    /// @param _matchingId The ID of the matching process.
    /// @return burn A boolean indicating whether a burn is applicable.
    function _isBurn(
        uint64 /*_datasetId*/,
        uint64 _matchingId
    ) internal view override returns (bool burn) {
        return (_matchingId != 0 &&
            roles.storages().isStorageExpiration(_matchingId));
    }
}
