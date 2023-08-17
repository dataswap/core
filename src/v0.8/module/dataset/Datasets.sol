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

/// interface
import {IRoles} from "../../interfaces/core/IRoles.sol";
import {IFilplus} from "../../interfaces/core/IFilplus.sol";
import {ICarstore} from "../../interfaces/core/ICarstore.sol";
import {IDatasets} from "../../interfaces/module/IDatasets.sol";
///shared
import {DatasetsEvents} from "../../shared/events/DatasetsEvents.sol";
import {DatasetsModifiers} from "../../shared/modifiers/DatasetsModifiers.sol";
/// library
import {DatasetMetadataLIB} from "./library/DatasetMetadataLIB.sol";
import {DatasetProofLIB} from "./library/proof/DatasetProofLIB.sol";
import {DatasetStateMachineLIB} from "./library/DatasetStateMachineLIB.sol";
import {DatasetVerificationLIB} from "./library/challenge/DatasetVerificationLIB.sol";
import {DatasetAuditLIB} from "./library/DatasetAuditLIB.sol";
/// type
import {RolesType} from "../../types/RolesType.sol";
import {CarReplicaType} from "../../types/CarReplicaType.sol";
import {DatasetType} from "../../types/DatasetType.sol";

/// @title Datasets Base Contract
/// @notice This contract serves as the base for managing datasets, metadata, proofs, and verifications.
/// @dev This contract is intended to be inherited by specific dataset-related contracts.
contract Datasets is IDatasets, DatasetsModifiers {
    using DatasetMetadataLIB for DatasetType.Dataset;
    using DatasetProofLIB for DatasetType.Dataset;
    using DatasetStateMachineLIB for DatasetType.Dataset;
    using DatasetVerificationLIB for DatasetType.Dataset;
    using DatasetAuditLIB for DatasetType.Dataset;

    uint64 public datasetsCount; // Total count of datasets
    mapping(uint64 => DatasetType.Dataset) private datasets; // Mapping of dataset ID to dataset details

    address private governanceAddress;
    IRoles private roles;
    IFilplus private filplus;
    ICarstore private carstore;

    constructor(
        address _governanceAddress,
        IRoles _roles,
        IFilplus _filplus,
        ICarstore _carstore
    ) DatasetsModifiers(_roles, _filplus, _carstore, this) {
        governanceAddress = _governanceAddress;
        roles = _roles;
        filplus = _filplus;
        carstore = _carstore;
    }

    ///@notice Approve a dataset.
    ///@dev This function changes the state of the dataset to DatasetApproved and emits the DatasetApproved event.
    function approveDataset(
        uint64 _datasetId
    )
        external
        onlyNotZero(_datasetId)
        onlyDatasetState(_datasetId, DatasetType.State.DatasetProofSubmitted)
        onlyAddress(governanceAddress)
    {
        DatasetType.Dataset storage dataset = datasets[_datasetId];
        dataset.approveDataset();

        emit DatasetsEvents.DatasetApproved(_datasetId);
    }

    ///@notice Approve the metadata of a dataset.
    ///@dev This function changes the state of the dataset to MetadataApproved and emits the MetadataApproved event.
    function approveDatasetMetadata(
        uint64 _datasetId
    )
        external
        onlyNotZero(_datasetId)
        onlyDatasetState(_datasetId, DatasetType.State.MetadataSubmitted)
        onlyAddress(governanceAddress)
    {
        DatasetType.Dataset storage dataset = datasets[_datasetId];
        dataset.approveDatasetMetadata();

        emit DatasetsEvents.DatasetMetadataApproved(_datasetId);
    }

    ///@notice Reject the metadata of a dataset.
    ///@dev This function changes the state of the dataset to MetadataRejected and emits the MetadataRejected event.
    function rejectDatasetMetadata(
        uint64 _datasetId
    )
        external
        onlyNotZero(_datasetId)
        onlyDatasetState(_datasetId, DatasetType.State.MetadataSubmitted)
        onlyAddress(governanceAddress)
    {
        DatasetType.Dataset storage dataset = datasets[_datasetId];
        dataset.rejectDatasetMetadata();

        emit DatasetsEvents.DatasetMetadataRejected(_datasetId);
    }

    ///@notice Reject a dataset.
    ///@dev This function changes the state of the dataset to DatasetRejected and emits the DatasetRejected event.
    function rejectDataset(
        uint64 _datasetId
    )
        external
        onlyNotZero(_datasetId)
        onlyDatasetState(_datasetId, DatasetType.State.DatasetProofSubmitted)
        onlyAddress(governanceAddress)
    {
        DatasetType.Dataset storage dataset = datasets[_datasetId];
        dataset.rejectDataset();

        emit DatasetsEvents.DatasetRejected(_datasetId);
    }

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
    ) external onlyDatasetMetadataNotExsits(_accessMethod) {
        //Note: params check in lib
        datasetsCount++;
        DatasetType.Dataset storage dataset = datasets[datasetsCount];
        dataset.submitDatasetMetadata(
            _title,
            _industry,
            _name,
            _description,
            _source,
            _accessMethod,
            _sizeInBytes,
            _isPublic,
            _version
        );

        emit DatasetsEvents.DatasetMetadataSubmitted(datasetsCount, msg.sender);
    }

    ///@notice Submit proof for a dataset
    /// Proof and verification functionality is provided here as a sample code structure.
    /// The actual functionality is pending completion.
    function submitDatasetProofBatch(
        uint64 _datasetId,
        DatasetType.DataType _dataType,
        string calldata _mappingFilesAccessMethod,
        bytes32 _rootHash,
        bytes32[] calldata _leafHashes,
        uint64[] calldata _leafSizes,
        bool _completed
    ) external {
        //Note: params check in lib
        DatasetType.Dataset storage dataset = datasets[_datasetId];
        if (_dataType == DatasetType.DataType.MappingFiles) {
            //TODO: check  mappingFilesAccessMethod is not set
            dataset.mappingFilesAccessMethod = _mappingFilesAccessMethod;
        }
        dataset.addDatasetProofBatch(
            _dataType,
            _rootHash,
            _leafHashes,
            _leafSizes,
            _completed
        );
        //TODO: hashes to CID
        carstore.addCars(_leafHashes, _datasetId, _leafSizes);

        if (
            dataset.sourceProof.allCompleted &&
            dataset.mappingFilesProof.allCompleted
        ) {
            emit DatasetsEvents.DatasetProofSubmitted(_datasetId, msg.sender);
        }
    }

    ///@notice Submit proof for a dataset
    /// Proof and verification functionality is provided here as a sample code structure.
    /// The actual functionality is pending completion.
    function submitDatasetVerification(
        uint64 _datasetId,
        uint64 _randomSeed,
        bytes32[][] memory _siblings,
        uint32[] memory _paths
    ) external onlyRole(RolesType.DATASET_AUDITOR) {
        DatasetType.Dataset storage dataset = datasets[_datasetId];
        dataset._submitDatasetVerification(_randomSeed, _siblings, _paths);
        emit DatasetsEvents.DatasetVerificationSubmitted(
            _datasetId,
            msg.sender
        );
    }

    ///@notice Get dataset metadata
    function getDatasetMetadata(
        uint64 _datasetId
    )
        public
        view
        onlyNotZero(_datasetId)
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
        )
    {
        DatasetType.Dataset storage dataset = datasets[_datasetId];
        return dataset.getDatasetMetadata();
    }

    ///@notice Get dataset source CIDs
    function getDatasetProof(
        uint64 _datasetId,
        DatasetType.DataType _dataType,
        uint64 _startCount,
        uint64 _endCount
    ) public view onlyNotZero(_datasetId) returns (bytes32[] memory) {
        DatasetType.Dataset storage dataset = datasets[_datasetId];
        return dataset.getDatasetProof(_dataType, _startCount, _endCount);
    }

    ///@notice Get dataset source CIDs
    function getDatasetCars(
        uint64 _datasetId,
        DatasetType.DataType _dataType,
        uint64 _startCount,
        uint64 _endCount
    ) public view onlyNotZero(_datasetId) returns (bytes32[] memory) {
        return getDatasetProof(_datasetId, _dataType, _startCount, _endCount);
    }

    function getDatasetProofCount(
        uint64 _datasetId,
        DatasetType.DataType _dataType
    ) public view onlyNotZero(_datasetId) returns (uint64) {
        DatasetType.Dataset storage dataset = datasets[_datasetId];
        return dataset.getDatasetCount(_dataType);
    }

    ///@notice Get dataset source CIDs
    function getDatasetCarsCount(
        uint64 _datasetId,
        DatasetType.DataType _dataType
    ) public view onlyNotZero(_datasetId) returns (uint64) {
        return getDatasetProofCount(_datasetId, _dataType);
    }

    ///@notice Get dataset size
    function getDatasetSize(
        uint64 _datasetId,
        DatasetType.DataType _dataType
    ) public view onlyNotZero(_datasetId) returns (uint64) {
        DatasetType.Dataset storage dataset = datasets[_datasetId];
        return dataset.getDatasetSize(_dataType);
    }

    ///@notice Get dataset state
    function getDatasetState(
        uint64 _datasetId
    ) public view onlyNotZero(_datasetId) returns (DatasetType.State) {
        DatasetType.Dataset storage dataset = datasets[_datasetId];
        return dataset.getDatasetState();
    }

    ///@notice Get dataset verification
    function getDatasetVerification(
        uint64 _datasetId,
        address _auditor
    )
        public
        view
        onlyNotZero(_datasetId)
        returns (bytes32[][] memory _siblings, uint32[] memory _paths)
    {
        DatasetType.Dataset storage dataset = datasets[_datasetId];
        return dataset.getDatasetVerification(_auditor);
    }

    ///@notice Get count of dataset verifications
    function getDatasetVerificationsCount(
        uint64 _datasetId
    ) public view onlyNotZero(_datasetId) returns (uint16) {
        DatasetType.Dataset storage dataset = datasets[_datasetId];
        return dataset.getDatasetVerificationsCount();
    }

    ///@notice Check if a dataset has metadata
    function hasDatasetMetadata(
        string memory _accessMethod
    ) public view returns (bool) {
        for (uint64 i = 1; i < datasetsCount; i++) {
            DatasetType.Dataset storage dataset = datasets[i];
            if (dataset.hasDatasetMetadata(_accessMethod)) return true;
        }
        return false;
    }

    ///@notice Check if a dataset has a cid
    function isDatasetContainsCar(
        uint64 _datasetId,
        bytes32 _cid
    ) public view onlyNotZero(_datasetId) returns (bool) {
        return _datasetId == carstore.getCarDatasetId(_cid);
    }

    ///@notice Check if a dataset has cids
    function isDatasetContainsCars(
        uint64 _datasetId,
        bytes32[] memory _cids
    ) external view onlyNotZero(_datasetId) returns (bool) {
        for (uint64 i = 0; i < _cids.length; i++) {
            if (!isDatasetContainsCar(_datasetId, _cids[i])) return false;
        }
        return true;
    }
}
