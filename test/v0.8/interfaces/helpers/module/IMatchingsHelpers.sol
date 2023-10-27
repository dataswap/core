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
import {IDatasets} from "src/v0.8/interfaces/module/IDatasets.sol";
import {IDatasetsProof} from "src/v0.8/interfaces/module/IDatasetsProof.sol";

/// @title IMatchingsHelpers
/// @dev Interface for managing matching-related operations.
interface IMatchingsHelpers {
    /// @notice Initialize a dataset with the provided parameters.
    /// @param _accessMethod The access method for the dataset.
    /// @param _sourceLeavesCount The number of leaves in the source data Merkle tree.
    /// @param _mappingFilesLeavesCount The number of leaves in the mapping files Merkle tree.
    /// @return datasetId The ID of the created dataset.
    function setup(
        string memory _accessMethod,
        uint64 _sourceLeavesCount,
        uint64 _mappingFilesLeavesCount
    ) external returns (uint64 datasetId);

    /// @notice Get the cars and the count of cars associated with a dataset and data type.
    /// @param _datasetId The ID of the dataset.
    /// @param _dataType The data type of the cars to retrieve.
    /// @return An array of car IDs and the count of cars.
    function getDatasetCarsAndCarsCount(
        uint64 _datasetId,
        DatasetType.DataType _dataType
    ) external returns (uint64[] memory, uint64);

    /// @notice Complete the workflow for a matching.
    /// @return datasetId The ID of the dataset associated with the completed matching.
    /// @return matchingId The ID of the completed matching.
    function completeMatchingWorkflow()
        external
        returns (uint64 datasetId, uint64 matchingId);

    function datasets() external returns (IDatasets);

    function datasetsProof() external returns (IDatasetsProof);
}
