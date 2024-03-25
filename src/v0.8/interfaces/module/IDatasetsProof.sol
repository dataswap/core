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

import {IRoles} from "src/v0.8/interfaces/core/IRoles.sol";
import {DatasetType} from "src/v0.8/types/DatasetType.sol";

/// @title IDatasetsProof
interface IDatasetsProof {
    ///@notice Submit proof root for a dataset
    function submitDatasetProofRoot(
        uint64 _datasetId,
        DatasetType.DataType _dataType,
        string calldata _mappingFilesAccessMethod,
        bytes32 _rootHash
    ) external;

    ///@notice Submit proof for a dataset
    function submitDatasetProof(
        uint64 _datasetId,
        DatasetType.DataType _dataType,
        bytes32[] memory _leafHashes,
        uint64 _leafIndex,
        uint64[] memory _leafSizes,
        bool _completed
    ) external;

    /// @notice Submits dataset proof with specified IDs.
    /// @param _datasetId The ID of the dataset.
    /// @param _dataType The data type of the dataset.
    /// @param _leavesStarts The starting indices of leaves in the Merkle tree.
    /// @param _leavesEnds The ending indices of leaves in the Merkle tree.
    /// @param _leafIndex The index of the leaf to submit proof for.
    /// @param _completed Indicates whether the proof submission is complete.
    function submitDatasetProofWithCarIds(
        uint64 _datasetId,
        DatasetType.DataType _dataType,
        uint64[] memory _leavesStarts,
        uint64[] memory _leavesEnds,
        uint64 _leafIndex,
        bool _completed
    ) external;

    ///@notice Submit proof completed for a dataset
    function submitDatasetProofCompleted(
        uint64 _datasetId
    ) external returns (DatasetType.State);

    /// @notice Completes the escrow process for a specific dataset.
    /// @param _datasetId The ID of the dataset to complete the escrow for.
    function completeEscrow(uint64 _datasetId) external;

    ///@notice Get dataset source CIDs
    function getDatasetProof(
        uint64 _datasetId,
        DatasetType.DataType _dataType,
        uint64 _index,
        uint64 _len
    ) external view returns (bytes32[] memory);

    ///@notice Get dataset proof count
    function getDatasetProofCount(
        uint64 _datasetId,
        DatasetType.DataType _dataType
    ) external view returns (uint64);

    ///@notice Get dataset proof's submitter
    function getDatasetProofSubmitter(
        uint64 _datasetId
    ) external view returns (address);

    ///@notice Get dataset size
    function getDatasetSize(
        uint64 _datasetId,
        DatasetType.DataType _dataType
    ) external view returns (uint64);

    /// @notice Retrieves the height at which the dataset proof is considered complete.
    /// @dev This function returns the height at which the dataset proof is considered complete for the given dataset ID.
    /// @param _datasetId The ID of the dataset.
    /// @return The height at which the dataset proof is considered complete.
    function getDatasetProofCompleteHeight(
        uint64 _datasetId
    ) external view returns (uint64);

    /// @notice Retrieves the Merkle root hash of the dataset for the specified dataset ID and data type.
    /// @param _datasetId The ID of the dataset for which to retrieve the Merkle root hash.
    /// @param _dataType The type of data for which to retrieve the Merkle root hash.
    /// @return rootHash The Merkle root hash of the dataset.
    function getDatasetProofRootHash(
        uint64 _datasetId,
        DatasetType.DataType _dataType
    ) external view returns (bytes32 rootHash);

    ///@notice Check if a dataset has a car id
    function isDatasetContainsCar(
        uint64 _datasetId,
        uint64 _id
    ) external returns (bool);

    ///@notice Check if a dataset has car ids
    function isDatasetContainsCars(
        uint64 _datasetId,
        uint64[] memory _ids
    ) external view returns (bool);

    ///@notice Check if a dataset has submitter
    function isDatasetProofSubmitter(
        uint64 _datasetId,
        address _submitter
    ) external view returns (bool);

    ///@notice Check if a dataset proof all completed
    function isDatasetProofallCompleted(
        uint64 _datasetId,
        DatasetType.DataType _dataType
    ) external view returns (bool);

    /// @notice Checks if the associated dataset contains a specific car.
    /// @dev This function verifies if the given dataset contains the specified car by checking if the car's ID is associated with the dataset.
    /// @param _datasetId The ID of the dataset to check.
    /// @param _carId The ID of the car to search for.
    /// @return True if the associated dataset contains the car, false otherwise.
    function isAssociatedDatasetContainsCar(
        uint64 _datasetId,
        uint64 _carId
    ) external view returns (bool);

    /// @notice Checks if the dataset proof has timed out.
    /// @dev This function determines if the dataset proof for the given dataset ID has timed out.
    /// @param _datasetId The ID of the dataset.
    /// @return True if the dataset proof has timed out, false otherwise.
    function isDatasetProofTimeout(
        uint64 _datasetId
    ) external view returns (bool);

    /// @notice Get the Roles contract.
    /// @return Roles contract address.
    function roles() external view returns (IRoles);
}
