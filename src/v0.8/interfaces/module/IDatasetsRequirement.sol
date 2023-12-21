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
import {IRoles} from "src/v0.8/interfaces/core/IRoles.sol";
import {IMerkleUtils} from "src/v0.8/interfaces/utils/IMerkleUtils.sol";

/// @title IDatasetsRequirement
interface IDatasetsRequirement {
    ///@notice Submit replica requirement for a dataset
    ///        Note: submmiter of dataset can submit dataset replica requirement
    /// @param _datasetId The ID of the dataset for which proof is submitted.
    /// @param _dataPreparers The client specified data preparer, which the client can either specify or not, but the parameter cannot be empty.
    /// @param _storageProviders The client specified storage provider, which the client can either specify or not, but the parameter cannot be empty.
    /// @param _regions The region specified by the client, and the client must specify a region for the replicas.
    /// @param _countrys The country specified by the client, and the client must specify a country for the replicas.
    /// @param _citys The citys specified by the client, when the country of a replica is duplicated, citys must be specified and cannot be empty.
    /// @param _amount The data preparer calculate fees.
    function submitDatasetReplicaRequirements(
        uint64 _datasetId,
        address[][] memory _dataPreparers,
        address[][] memory _storageProviders,
        uint16[] memory _regions,
        uint16[] memory _countrys,
        uint32[][] memory _citys,
        uint256 _amount
    ) external payable;

    ///@notice Get dataset replicas count
    function getDatasetReplicasCount(
        uint64 _datasetId
    ) external view returns (uint16);

    ///@notice Get dataset replica requirement
    function getDatasetReplicaRequirement(
        uint64 _datasetId,
        uint64 _index
    )
        external
        view
        returns (
            address[] memory dataPreparers,
            address[] memory storageProviders,
            uint16 regionCode,
            uint16 countryCode,
            uint32[] memory cityCodes
        );

    ///@notice Get dataset pre conditional
    function getDatasetPreCollateralRequirements(
        uint64 _datasetId
    ) external view returns (uint256);
}
