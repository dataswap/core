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

/// interface
import {IRoles} from "src/v0.8/interfaces/core/IRoles.sol";
import {IFilplus} from "src/v0.8/interfaces/core/IFilplus.sol";
import {ICarstore} from "src/v0.8/interfaces/core/ICarstore.sol";
import {IDatasets} from "src/v0.8/interfaces/module/IDatasets.sol";
import {IMerkleUtils} from "src/v0.8/interfaces/utils/IMerkleUtils.sol";
///shared
import {DatasetsEvents} from "src/v0.8/shared/events/DatasetsEvents.sol";
import {DatasetsModifiers} from "src/v0.8/shared/modifiers/DatasetsModifiers.sol";
/// library
import {DatasetMetadataLIB} from "src/v0.8/module/dataset/library/DatasetMetadataLIB.sol";
import {DatasetProofLIB} from "src/v0.8/module/dataset/library/proof/DatasetProofLIB.sol";
import {DatasetStateMachineLIB} from "src/v0.8/module/dataset/library/DatasetStateMachineLIB.sol";
import {DatasetVerificationLIB} from "src/v0.8/module/dataset/library/challenge/DatasetVerificationLIB.sol";
import {DatasetAuditLIB} from "src/v0.8/module/dataset/library/DatasetAuditLIB.sol";
/// type
import {RolesType} from "src/v0.8/types/RolesType.sol";
import {DatasetType} from "src/v0.8/types/DatasetType.sol";

import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {UUPSUpgradeable} from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

/// @title Datasets Base Contract
/// @notice This contract serves as the base for managing datasets, metadata, proofs, and verifications.
/// @dev This contract is intended to be inherited by specific dataset-related contracts.
contract Datasets is
    Initializable,
    UUPSUpgradeable,
    IDatasets,
    DatasetsModifiers
{
    using DatasetMetadataLIB for DatasetType.Dataset;
    using DatasetProofLIB for DatasetType.Dataset;
    using DatasetStateMachineLIB for DatasetType.Dataset;
    using DatasetVerificationLIB for DatasetType.Dataset;
    using DatasetAuditLIB for DatasetType.Dataset;

    uint64 public datasetsCount; // Total count of datasets
    mapping(uint64 => DatasetType.Dataset) private datasets; // Mapping of dataset ID to dataset details

    address public governanceAddress;
    IRoles public roles;
    IFilplus private filplus;
    ICarstore private carstore;
    IMerkleUtils public merkleUtils;
    /// @dev This empty reserved space is put in place to allow future versions to add new
    uint256[32] private __gap;

    /// @notice initialize function to initialize the contract and grant the default admin role to the deployer.
    function initialize(
        address _governanceAddress,
        address _roles,
        address _filplus,
        address _filecoin,
        address _carstore,
        address _merkleUtils
    ) public initializer {
        DatasetsModifiers.datasetsModifiersInitialize(
            _roles,
            _filplus,
            _filecoin,
            _carstore,
            address(this)
        );
        governanceAddress = _governanceAddress;
        roles = IRoles(_roles);
        filplus = IFilplus(_filplus);
        carstore = ICarstore(_carstore);
        merkleUtils = IMerkleUtils(_merkleUtils);
        __UUPSUpgradeable_init();
    }

    /// @notice UUPS Upgradeable function to update the roles implementation
    /// @dev Only triggered by contract admin
    function _authorizeUpgrade(
        address newImplementation
    )
        internal
        override
        onlyRole(RolesType.DEFAULT_ADMIN_ROLE) // solhint-disable-next-line
    {}

    /// @notice Returns the implementation contract
    function getImplementation() external view returns (address) {
        return _getImplementation();
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

    ///@notice Submit proof root for a dataset
    ///@dev Submit the rootHash of the dataset, the mappingFilesAccessMethod,
    /// and confirm that the sender is the submitter of the dataset.
    function submitDatasetProofRoot(
        uint64 _datasetId,
        DatasetType.DataType _dataType,
        string calldata _mappingFilesAccessMethod,
        bytes32 _rootHash
    )
        external
        onlyDatasetProofSubmitterOrSubmitterNotExsits(_datasetId, msg.sender)
        onlyDatasetState(_datasetId, DatasetType.State.MetadataApproved)
    {
        //Note: params check in lib
        DatasetType.Dataset storage dataset = datasets[_datasetId];
        if (_dataType == DatasetType.DataType.MappingFiles) {
            if (bytes(dataset.mappingFilesAccessMethod).length == 0) {
                dataset.mappingFilesAccessMethod = _mappingFilesAccessMethod;
            }
        }
        // If the Dataset proof has not been submitted before,
        // then set the current sender as the submitter.
        if (
            dataset.getDatasetCount(DatasetType.DataType.Source) == 0 &&
            dataset.getDatasetCount(DatasetType.DataType.MappingFiles) == 0
        ) {
            dataset.proofSubmitter = msg.sender;
        }
        require(
            dataset.isDatasetSubmitter(msg.sender),
            "Invalid Dataset submitter"
        );
        dataset.addDatasetProofRoot(_dataType, _rootHash);
    }

    ///@notice Submit proof for a dataset
    ///@dev Submit the proof of the dataset in batches,
    /// specifically by submitting the _leafHashes in the order of _leafIndexes.
    function submitDatasetProof(
        uint64 _datasetId,
        DatasetType.DataType _dataType,
        bytes32[] calldata _leafHashes,
        uint64[] calldata _leafIndexs,
        uint64[] calldata _leafSizes,
        bool _completed
    )
        external
        onlyDatasetState(_datasetId, DatasetType.State.MetadataApproved)
    {
        //Note: params check in lib
        DatasetType.Dataset storage dataset = datasets[_datasetId];

        // Checking if the current sender is the submitter.
        require(
            dataset.isDatasetSubmitter(msg.sender),
            "Invalid Dataset submitter"
        );

        carstore.addCars(_leafHashes, _datasetId, _leafSizes);

        dataset.addDatasetProofBatch(
            _dataType,
            _leafHashes,
            _leafIndexs,
            _leafSizes,
            _completed
        );

        if (
            dataset.sourceProof.allCompleted &&
            dataset.mappingFilesProof.allCompleted
        ) {
            dataset._emitDatasetEvent((DatasetType.Event.SubmitDatasetProof));
            emit DatasetsEvents.DatasetProofSubmitted(_datasetId, msg.sender);
        }
    }

    ///@notice Submit proof verification for a dataset
    /// Based on merkle proof verification.
    /// random challenge method is used to reduce the amount of data and calculation while ensuring algorithm security.
    function submitDatasetVerification(
        uint64 _datasetId,
        uint64 _randomSeed,
        bytes32[] memory _leaves,
        bytes32[][] memory _siblings,
        uint32[] memory _paths
    ) external onlyRole(RolesType.DATASET_AUDITOR) {
        DatasetType.Dataset storage dataset = datasets[_datasetId];
        dataset._submitDatasetVerification(
            _randomSeed,
            _leaves,
            _siblings,
            _paths,
            merkleUtils
        );
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
        uint64 _index,
        uint64 _len
    ) public view onlyNotZero(_datasetId) returns (bytes32[] memory) {
        DatasetType.Dataset storage dataset = datasets[_datasetId];
        return dataset.getDatasetProof(_dataType, _index, _len);
    }

    ///@notice Get dataset source CIDs
    function getDatasetCars(
        uint64 _datasetId,
        DatasetType.DataType _dataType,
        uint64 _index,
        uint64 _len
    ) public view onlyNotZero(_datasetId) returns (bytes32[] memory) {
        return getDatasetProof(_datasetId, _dataType, _index, _len);
    }

    /// @notice Get the number of leaf nodes (cars) in the dataset proofs.
    function getDatasetProofCount(
        uint64 _datasetId,
        DatasetType.DataType _dataType
    ) public view onlyNotZero(_datasetId) returns (uint64) {
        DatasetType.Dataset storage dataset = datasets[_datasetId];
        return dataset.getDatasetCount(_dataType);
    }

    /// @notice Get submitter of dataset's proofs
    function getDatasetProofSubmitter(
        uint64 _datasetId
    ) public view returns (address) {
        DatasetType.Dataset storage dataset = datasets[_datasetId];
        return dataset.getDatasetSubmitter();
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
        returns (
            bytes32[] memory,
            bytes32[][] memory _siblings,
            uint32[] memory _paths
        )
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
        for (uint64 i = 1; i <= datasetsCount; i++) {
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

    ///@notice Check if a dataset has submitter
    function isDatasetProofSubmitter(
        uint64 _datasetId,
        address _submitter
    ) public view returns (bool) {
        DatasetType.Dataset storage dataset = datasets[_datasetId];
        return dataset.isDatasetSubmitter(_submitter);
    }

    ///@notice Check if the verification is a duplicate.
    function isDatasetVerificationDuplicate(
        uint64 _datasetId,
        address _auditor,
        uint64 _randomSeed
    ) public view returns (bool) {
        DatasetType.Dataset storage dataset = datasets[_datasetId];
        return dataset.isDatasetVerificationDuplicate(_auditor, _randomSeed);
    }

    ///@notice Get a dataset challenge count
    function getChallengeCount(
        uint64 _datasetId
    ) external view returns (uint64) {
        DatasetType.Dataset storage dataset = datasets[_datasetId];
        return dataset.getChallengeCount();
    }
}
