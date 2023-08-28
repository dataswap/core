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

/// @title IDatasetsHelpers
/// @dev Interface for managing dataset-related operations.
interface IDatasetsHelpers {
    /// @notice Submit metadata for a dataset.
    /// @param caller The address of the caller.
    /// @param _accessMethod The access method for the dataset.
    /// @return datasetId The ID of the created dataset.
    function submitDatasetMetadata(
        address caller,
        string memory _accessMethod
    ) external returns (uint64 datasetId);

    /// @notice Generate a root hash for a dataset.
    /// @return The generated root hash.
    function generateRoot() external returns (bytes32);

    /// @notice Generate a Merkle tree proof.
    /// @param _leavesCount The number of leaves in the tree.
    /// @return An array of proof elements, an array of leaf sizes, and the tree height.
    function generateProof(
        uint64 _leavesCount
    ) external returns (bytes32[] memory, uint64[] memory, uint64);

    /// @notice Submit a proof for a dataset.
    /// @param caller The address of the caller.
    /// @param _datasetId The ID of the dataset.
    /// @param _dataType The data type of the dataset.
    /// @param _accessMethod The access method for the dataset.
    /// @param _leavesCount The number of leaves in the Merkle tree.
    /// @param _complete A flag indicating if the proof is complete.
    function submitDatasetProof(
        address caller,
        uint64 _datasetId,
        DatasetType.DataType _dataType,
        string memory _accessMethod,
        uint64 _leavesCount,
        bool _complete
    ) external;

    /// @notice Generate data verification parameters.
    /// @param _pointCount The number of data verification points.
    /// @param _pointLeavesCount The number of leaves in the point Merkle tree.
    /// @return _randomSeed The random seed for verification.
    /// @return _siblings The Merkle tree siblings for the verification points.
    /// @return _paths The Merkle tree paths for the verification points.
    function generateVerification(
        uint64 _pointCount,
        uint64 _pointLeavesCount
    )
        external
        returns (
            uint64 _randomSeed,
            bytes32[][] memory _siblings,
            uint32[] memory _paths
        );

    /// @notice Submit a dataset verification.
    /// @param caller The address of the caller.
    /// @param _datasetId The ID of the dataset.
    /// @param _challengeCount The number of verification challenges.
    /// @param _challengeLeavesCount The number of leaves in the challenge Merkle tree.
    function submitDatasetVerification(
        address caller,
        uint64 _datasetId,
        uint64 _challengeCount,
        uint64 _challengeLeavesCount
    ) external;

    /// @notice Complete the dataset workflow.
    /// @param _accessMethod The access method for the dataset.
    /// @param _sourceLeavesCount The number of leaves in the source data Merkle tree.
    /// @param _mappingFilesLeavesCount The number of leaves in the mapping files Merkle tree.
    /// @param _challengeCount The number of verification challenges.
    /// @param _challengeLeavesCount The number of leaves in the challenge Merkle tree.
    /// @return datasetId The ID of the completed dataset.
    function completeDatasetWorkflow(
        string memory _accessMethod,
        uint64 _sourceLeavesCount,
        uint64 _mappingFilesLeavesCount,
        uint64 _challengeCount,
        uint64 _challengeLeavesCount
    ) external returns (uint64 datasetId);
}
