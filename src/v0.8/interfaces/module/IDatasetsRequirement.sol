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
    ///@notice Submit storage requirement for a dataset
    ///        Note: submmiter of dataset can submit dataset storage requirement
    function submitDatasetReplicaRequirements(
        uint64 _datasetId,
        address[][] memory _dataPreparers,
        address[][] memory _storageProviders,
        uint16[] memory _regions,
        uint16[] memory _countrys,
        uint32[][] memory _citys
    ) external;

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
            address[] memory,
            address[] memory,
            uint16,
            uint16,
            uint32[] memory
        );
}
