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
import {IFilplus} from "src/v0.8/interfaces/core/IFilplus.sol";
import {IStorages} from "src/v0.8/interfaces/module/IStorages.sol";
import {FinanceLIB} from "src/v0.8/core/finance/library/FinanceLIB.sol";
import {IDatasets} from "src/v0.8/interfaces/module/IDatasets.sol";
import {IDatasetsProof} from "src/v0.8/interfaces/module/IDatasetsProof.sol";
import {IDatasetsRequirement} from "src/v0.8/interfaces/module/IDatasetsRequirement.sol";

/// @title DatacapCollateralLIB
/// @dev This library provides functions for managing DatacapCollateral-related operations.
library DatacapCollateralLIB {
    using FinanceLIB for FinanceType.Account;

    /// @dev Retrieves payee information for DatacapCollateral.
    /// @param _datasetId The ID of the dataset.
    /// @param _matchingId The ID of the matching process.
    /// @param _owner The address of the payee/owner.
    /// @param _account The finance account related to the payee.
    /// @param _storages The storage contract interface.
    /// @param _filplus The Filplus contract interface.
    /// @return payee An array containing the payee's address.
    /// @return amount An array containing the escrowed amount for DatacapCollateral.
    function getPayeeInfo(
        uint64 _datasetId,
        uint64 _matchingId,
        address _owner,
        FinanceType.Account storage _account,
        IStorages _storages,
        IFilplus _filplus
    ) internal view returns (address[] memory payee, uint256[] memory amount) {
        payee = new address[](1);
        amount = new uint256[](1);
        amount[0] = 0;
        payee[0] = _owner;
        uint64 height = _account._getEscrowLastHeight(
            FinanceType.Type.DatacapCollateral
        );
        bool expire = _filplus.isCompliantDatacapCollateralExpireBlocks(
            uint64(block.number) - height
        );
        bool datasetApprovedExpire = _filplus
            .isCompliantDatasetApprovedExpireBlocks(
                uint64(block.number) - height
            );
        DatasetType.State state = _storages.datasets().getDatasetState(
            _datasetId
        );

        if (
            (state == DatasetType.State.MetadataRejected) ||
            (state != DatasetType.State.DatasetApproved &&
                datasetApprovedExpire) ||
            expire
        ) {
            amount[0] = _account._getValidEscrow(
                FinanceType.Type.DatacapCollateral
            );
        }
    }

    /// @notice Get dataset pre-conditional collateral requirement.
    /// @param _datasetId The ID of the dataset.
    /// @param _matchingId The ID of the matching process.
    /// @param _owner The address of the payee/owner.
    /// @param _account The finance account related to the payee.
    /// @param _filplus The Filplus contract interface.
    /// @param _datasets The datasets contract interface.
    /// @param _datasetsProof The datasets proof contract interface.
    /// @param _datasetsRequirement The datasets requirement contract interface.
    /// @return amount The collateral requirement amount.
    function getRequirement(
        uint64 _datasetId,
        uint64 _matchingId,
        address _owner,
        FinanceType.Account storage _account,
        IFilplus _filplus,
        IDatasets _datasets,
        IDatasetsProof _datasetsProof,
        IDatasetsRequirement _datasetsRequirement
    ) public view returns (uint256 amount) {
        if (
            _datasetsProof.isDatasetProofallCompleted(
                _datasetId,
                DatasetType.DataType.Source
            )
        ) {
            amount = _getDatasetCollateralRequirement(
                _datasetId,
                _datasetsRequirement
            );
        } else {
            // Others are pre collateral funds
            amount = _getDatasetPreCollateralRequirements(
                _datasetId,
                _datasets
            );
        }
    }

    /// @notice Get dataset pre-conditional collateral requirement.
    /// @param _datasetId The ID of the dataset.
    /// @param _filplus The Filplus contract interface.
    /// @param _datasets The datasets contract interface.
    /// @param _datasetsRequirement The datasets requirement contract interface.
    /// @return amount The pre-conditional collateral requirement amount.
    function _getDatasetPreCollateralRequirements(
        uint64 _datasetId,
        IFilplus _filplus,
        IDatasets _datasets,
        IDatasetsRequirement _datasetsRequirement
    ) public view returns (uint256 amount) {
        (, , , , , , , , uint64 size, , ) = _datasets.getDatasetMetadata(
            _datasetId
        );

        amount =
            size *
            _datasetsRequirement.getDatasetReplicasCount(_datasetId) *
            _filplus.getDatasetPricePreByte();
    }

    /// @notice Get dataset minimum-conditional collateral requirement.
    /// @param _datasetId The ID of the dataset.
    /// @param _filplus The Filplus contract interface.
    /// @param _datasetsProof The datasets proof contract interface.
    /// @param _datasetsRequirement The datasets requirement contract interface.
    /// @return amount The minimum-conditional collateral requirement amount.
    function _getDatasetCollateralRequirement(
        uint64 _datasetId,
        IFilplus _filplus,
        IDatasetsProof _datasetsProof,
        IDatasetsRequirement _datasetsRequirement
    ) public view returns (uint256 amount) {
        amount =
            _datasetsProof.getDatasetSize(
                _datasetId,
                DatasetType.DataType.Source
            ) *
            _datasetsRequirement.getDatasetReplicasCount(_datasetId) *
            _filplus.getDatasetPricePreByte();
    }
}
