/*******************************************************************************
 *   (c) 2023 DataSwap
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

import "../../types/DatasetType.sol";

/// @title IDatasets
interface IDatasets {
    ///@notice Approve a dataset.
    ///@dev This function changes the state of the dataset to DatasetApproved and emits the DatasetApproved event.
    function approveDataset(uint256 _datasetId) external;

    ///@notice Approve the metadata of a dataset.
    ///@dev This function changes the state of the dataset to MetadataApproved and emits the MetadataApproved event.
    function approveDatasetMetadata(uint256 _datasetId) external;

    ///@notice Reject a dataset.
    ///@dev This function changes the state of the dataset to DatasetRejected and emits the DatasetRejected event.
    function rejectDataset(uint256 _datasetId) external;

    ///@notice Reject the metadata of a dataset.
    ///@dev This function changes the state of the dataset to MetadataRejected and emits the MetadataRejected event.
    function rejectDatasetMetadata(uint256 _datasetId) external;

    ///@notice Submit metadata for a dataset
    ///        Note:anyone can submit dataset metadata
    function submitDatasetMetadata(
        string memory _title,
        string memory _industry,
        string memory _name,
        string memory _description,
        string memory _source,
        string memory _accessMethod,
        uint256 _sizeInBytes,
        bool _isPublic,
        uint64 _version
    ) external;

    ///@notice Submit proof for a dataset
    /// TODO:Proof and verification functionality is provided here as a sample code structure.
    /// The actual functionality is pending completion.
    function submitDatasetProof(
        uint256 _datasetId,
        bytes32 _sourceDatasetRootHash,
        bytes32[] calldata _sourceDatasetLeafHashes,
        bytes32 _sourceToCarMappingFilesRootHashes,
        bytes32[] calldata _sourceToCarMappingFilesLeafHashes,
        string calldata _sourceToCarMappingFilesAccessMethod
    ) external;

    ///@notice Submit proof for a dataset
    /// TODO:Proof and verification functionality is provided here as a sample code structure.
    /// The actual functionality is pending completion.
    function submitDatasetVerification(
        uint256 _datasetId,
        uint64 _randomSeed,
        bytes32[] calldata _sourceDatasetProofRootHashes,
        bytes32[][] calldata _sourceDatasetProofLeafHashes,
        bytes32[] calldata _sourceToCarMappingFilesProofRootHashes,
        bytes32[][] calldata _sourceToCarMappingFilesProofLeafHashes
    ) external;

    ///@notice Get dataset metadata
    function getDatasetMetadata(
        uint256 _datasetId
    )
        external
        view
        returns (
            string memory title,
            string memory industry,
            string memory name,
            string memory description,
            string memory source,
            string memory accessMethod,
            address submitter,
            uint256 createdBlockNumber,
            uint256 sizeInBytes,
            bool isPublic,
            uint64 version
        );

    ///@notice Get dataset source cars
    function getDatasetSourceCars(
        uint256 _datasetId
    ) external view returns (bytes32[] memory);

    // Get dataset source proof
    function getDatasetSourceProof(
        uint256 _datasetId
    ) external view returns (bytes32, bytes32[] memory);

    ///@notice Get dataset source-to-CAR mapping files cars
    function getDatasetSourceToCarMappingFilesCars(
        uint256 _datasetId
    ) external view returns (bytes32[] memory);

    ///@notice Get dataset source-to-CAR mapping files proof
    function getDatasetSourceToCarMappingFilesProof(
        uint256 _datasetId
    ) external view returns (bytes32, bytes32[] memory);

    ///@notice Get dataset size
    function getDatasetSize(uint256 _datasetId) external view returns (uint256);

    ///@notice Get dataset state
    function getDatasetState(
        uint256 _datasetId
    ) external view returns (DatasetType.State);

    ///@notice Get dataset verification
    function getDatasetVerification(
        uint256 _datasetId,
        address _auditor
    )
        external
        view
        returns (
            uint64 randomSeed,
            bytes32[] memory sourceDatasetProofRootHashes,
            bytes32[][] memory sourceDatasetProofLeafHashes,
            bytes32[] memory sourceToCarMappingFilesProofRootHashes,
            bytes32[][] memory sourceToCarMappingFilesProofLeafHashes
        );

    ///@notice Get count of dataset verifications
    function getDatasetVerificationsCount(
        uint256 _datasetId
    ) external view returns (uint256);

    ///@notice Check if a dataset has metadata
    function hasDatasetMetadata(
        string memory _accessMethod
    ) external view returns (bool);

    ///@notice Check if a dataset has a cid
    function isDatasetContainsCar(
        uint256 _datasetId,
        bytes32 _cid
    ) external returns (bool);

    ///@notice Check if a dataset has cids
    function isDatasetContainsCars(
        uint256 _datasetId,
        bytes32[] memory _cids
    ) external view returns (bool);

    // Default getter functions for public variables
    function datasetsCount() external view returns (uint256);
}
