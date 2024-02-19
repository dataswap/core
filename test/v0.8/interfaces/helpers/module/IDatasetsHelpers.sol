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
import {IDatasetsProof} from "src/v0.8/interfaces/module/IDatasetsProof.sol";

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
    /// @param _dataType The data type of the dataset.
    /// @param _offset The offset of leaves in the tree.
    /// @return An array of proof elements, an array of leaf sizes, and the tree height.
    function generateProof(
        uint64 _leavesCount,
        DatasetType.DataType _dataType,
        uint64 _offset
    )
        external
        returns (bytes32[] memory, uint64[] memory, uint64[] memory, uint64);

    ///  @notice Generate actors of replicas.
    ///  @param _replicasCount The number of car's replicas.
    ///  @param _countPerReplica The actor's number of a replica.
    ///  @param _duplicateInReplicas The duplicate number of replicas.
    ///  @param _duplicatePerReplica The duplicate number per replica.
    ///  @param _contain The member that mast in actors.
    ///  @return The total size of the Merkle tree.
    function generateReplicasActors(
        uint16 _replicasCount,
        uint16 _countPerReplica,
        uint16 _duplicateInReplicas,
        uint16 _duplicatePerReplica,
        address _contain
    ) external returns (address[][] memory);

    /// @notice Generate an array of uint16 for testing.
    /// @param _count The number of row element's count.
    /// @param _duplicate The duplicate number of row elements.
    /// @return An array of uint16[].
    function generateReplicasPositions(
        uint16 _count,
        uint16 _duplicate
    ) external returns (uint16[] memory);

    /// @notice Generate an two-dimensional of uint32 for testing.
    ///  @param _replicasCount The number of car's replicas.
    ///  @param _countPerReplica The city's number of a replica.
    ///  @param _duplicateInReplicas The duplicate city's number of replicas.
    ///  @param _duplicatePerReplica The duplicate city's number per replica.
    /// @return An array of uint32[][].
    function generateReplicasCitys(
        uint16 _replicasCount,
        uint16 _countPerReplica,
        uint16 _duplicateInReplicas,
        uint16 _duplicatePerReplica
    ) external returns (uint32[][] memory);

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

    /// @notice Submit a proof for a dataset.
    /// @param caller The address of the caller.
    /// @param _datasetId The ID of the dataset.
    /// @param _associatedDatasetId The ID of the dataset.
    /// @param _dataType The data type of the dataset.
    /// @param _accessMethod The access method for the dataset.
    /// @param _complete A flag indicating if the proof is complete.
    function submitDatasetProofWithCarIds(
        address caller,
        uint64 _datasetId,
        uint64 _associatedDatasetId,
        DatasetType.DataType _dataType,
        string memory _accessMethod,
        bool _complete
    ) external;

    ///@notice Submit replica requirement for a dataset.
    /// @param caller The address of the caller.
    /// @param _datasetId The ID of the dataset for which proof is submitted.
    /// @param _replicasCount The number of replicas of the dataset.
    /// @param _duplicateDataPreparers The duplicate count of the data prepares.
    /// @param _duplicateStorageProviders The duplicate count of the storage providers.
    /// @param _duplicateRegions The duplicate count of the regions.
    /// @param _duplicateCountrys The duplicate count of the data countrys.
    /// @param _duplicateCitys The duplicate count of the data citys.
    function submitDatasetReplicaRequirements(
        address caller,
        uint64 _datasetId,
        uint16 _replicasCount,
        uint16 _duplicateDataPreparers,
        uint16 _duplicateStorageProviders,
        uint16 _duplicateRegions,
        uint16 _duplicateCountrys,
        uint16 _duplicateCitys
    ) external;

    /// @notice Generate data verification parameters.
    /// @param _pointCount The number of data verification points.
    /// @return _randomSeed The random seed for verification.
    /// @return leaves The Merkle tree leaves for the verification points.
    /// @return _siblings The Merkle tree siblings for the verification points.
    /// @return _paths The Merkle tree paths for the verification points.
    function generateVerification(
        uint64 _pointCount
    )
        external
        returns (
            uint64 _randomSeed,
            bytes32[] memory leaves,
            bytes32[][] memory _siblings,
            uint32[] memory _paths
        );

    /// @notice Submit a dataset verification.
    /// @param caller The address of the caller.
    /// @param _datasetId The ID of the dataset.
    function submitDatasetVerification(
        address caller,
        uint64 _datasetId
    ) external;

    /// @notice Complete the dataset workflow.
    /// @param _accessMethod The access method for the dataset.
    /// @param _sourceLeavesCount The number of leaves in the source data Merkle tree.
    /// @param _mappingFilesLeavesCount The number of leaves in the mapping files Merkle tree.
    /// @return datasetId The ID of the completed dataset.
    function completeDatasetWorkflow(
        string memory _accessMethod,
        uint64 _sourceLeavesCount,
        uint64 _mappingFilesLeavesCount
    ) external returns (uint64 datasetId);

    /// @notice Get DatasetsProof object
    function getDatasetsProof() external view returns (IDatasetsProof);
}
