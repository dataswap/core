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

/// @title IDatasets
interface IDatasets {
    ///@notice Approve a dataset.
    ///@dev This function changes the state of the dataset to DatasetApproved and emits the DatasetApproved event.
    function approveDataset(uint64 _datasetId) external;

    ///@notice Approve the metadata of a dataset.
    ///@dev This function changes the state of the dataset to MetadataApproved and emits the MetadataApproved event.
    function approveDatasetMetadata(uint64 _datasetId) external;

    ///@notice Reject a dataset.
    ///@dev This function changes the state of the dataset to DatasetRejected and emits the DatasetRejected event.
    function rejectDataset(uint64 _datasetId) external;

    ///@notice Reject the metadata of a dataset.
    ///@dev This function changes the state of the dataset to MetadataRejected and emits the MetadataRejected event.
    function rejectDatasetMetadata(uint64 _datasetId) external;

    ///@notice Submit metadata for a dataset
    ///        Note:anyone can submit dataset metadata
    function submitDatasetMetadata(
        string memory _title,
        string memory _industry,
        string memory _name,
        string memory _description,
        string memory _source,
        string memory _accessMethod,
        uint64 _sizeInBytes,
        bool _isPublic,
        uint64 _version
    ) external;

    ///@notice Submit proof for a dataset
    function submitDatasetProofBatch(
        uint64 _datasetId,
        DatasetType.DataType _dataType,
        string calldata accessMethod,
        bytes32 _rootHash,
        bytes32[] calldata _leafHashes,
        uint64[] calldata _leafSizes,
        bool _completed
    ) external;

    ///@notice Submit proof for a dataset
    function submitDatasetVerification(
        uint64 _datasetId,
        uint64 _randomSeed,
        bytes32[][] memory _siblings,
        uint32[] memory _paths
    ) external;

    ///@notice Get dataset metadata
    function getDatasetMetadata(
        uint64 _datasetId
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
            uint64 createdBlockNumber,
            uint64 sizeInBytes,
            bool isPublic,
            uint64 version
        );

    ///@notice Get dataset source CIDs
    function getDatasetProof(
        uint64 _datasetId,
        DatasetType.DataType _dataType,
        uint64 _index,
        uint64 _len
    ) external view returns (bytes32[] memory);

    ///@notice Get dataset source CIDs
    function getDatasetCars(
        uint64 _datasetId,
        DatasetType.DataType _dataType,
        uint64 _index,
        uint64 _len
    ) external view returns (bytes32[] memory);

    function getDatasetProofCount(
        uint64 _datasetId,
        DatasetType.DataType _dataType
    ) external view returns (uint64);

    ///@notice Get dataset source CIDs
    function getDatasetCarsCount(
        uint64 _datasetId,
        DatasetType.DataType _dataType
    ) external view returns (uint64);

    ///@notice Get dataset size
    function getDatasetSize(
        uint64 _datasetId,
        DatasetType.DataType _dataType
    ) external view returns (uint64);

    ///@notice Get dataset state
    function getDatasetState(
        uint64 _datasetId
    ) external view returns (DatasetType.State);

    ///@notice Get dataset verification
    function getDatasetVerification(
        uint64 _datasetId,
        address _auditor
    )
        external
        view
        returns (bytes32[][] memory _siblings, uint32[] memory _paths);

    ///@notice Get count of dataset verifications
    function getDatasetVerificationsCount(
        uint64 _datasetId
    ) external view returns (uint16);

    ///@notice Check if a dataset has metadata
    function hasDatasetMetadata(
        string memory _accessMethod
    ) external view returns (bool);

    ///@notice Check if a dataset has a cid
    function isDatasetContainsCar(
        uint64 _datasetId,
        bytes32 _cid
    ) external returns (bool);

    ///@notice Check if a dataset has cids
    function isDatasetContainsCars(
        uint64 _datasetId,
        bytes32[] memory _cids
    ) external view returns (bool);

    // Default getter functions for public variables
    function datasetsCount() external view returns (uint64);

    function roles() external view returns (IRoles);
}
