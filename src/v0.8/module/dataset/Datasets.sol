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

import {DatasetType} from "../../types/DatasetType.sol";
import {RolesType} from "../../types/RolesType.sol";
import {CommonModifiers} from "../../shared/modifiers/CommonModifiers.sol";
import {RolesModifiers} from "../../shared/modifiers/RolesModifiers.sol";
import {IRoles} from "../../interfaces/core/IRoles.sol";
import {IFilplus} from "../../interfaces/core/IFilplus.sol";
import {ICarstore} from "../../interfaces/core/ICarstore.sol";
import {IDatasets} from "../../interfaces/module/IDatasets.sol";
import {DatasetMetadataLIB} from "./library/DatasetMetadataLIB.sol";
import {DatasetProofLIB} from "./library/DatasetProofLIB.sol";
import {DatasetStateMachineLIB} from "./library/DatasetStateMachineLIB.sol";
import {DatasetVerificationLIB} from "./library/DatasetVerificationLIB.sol";
import {DatasetAuditLIB} from "./library/DatasetAuditLIB.sol";

/// @title Datasets Base Contract
/// @notice This contract serves as the base for managing datasets, metadata, proofs, and verifications.
/// @dev This contract is intended to be inherited by specific dataset-related contracts.
contract Datasets is IDatasets, CommonModifiers, RolesModifiers {
    using DatasetMetadataLIB for DatasetType.Dataset;
    using DatasetProofLIB for DatasetType.Dataset;
    using DatasetStateMachineLIB for DatasetType.Dataset;
    using DatasetVerificationLIB for DatasetType.Dataset;
    using DatasetAuditLIB for DatasetType.Dataset;

    uint256 public datasetsCount; // Total count of datasets
    mapping(uint256 => DatasetType.Dataset) private datasets; // Mapping of dataset ID to dataset details

    address private governanceAddress;
    IRoles private roles;
    IFilplus private filplus;
    ICarstore private carstore;

    constructor(
        address _governanceAddress,
        IRoles _roles,
        IFilplus _filplus,
        ICarstore _carstore
    ) RolesModifiers(_roles) {
        governanceAddress = _governanceAddress;
        roles = _roles;
        filplus = _filplus;
        carstore = _carstore;
    }

    /// @dev Modifier to ensure that a dataset metadata  with the given accessMethod exists.
    modifier datasetMetadataExsits(string memory _accessMethod) {
        require(hasDatasetMetadata(_accessMethod), "dataset is not exists");
        _;
    }

    /// @dev Modifier to ensure that a dataset metadata with the given accessMethod not exists.
    modifier datasetMetadataNotExsits(string memory _accessMethod) {
        require(!hasDatasetMetadata(_accessMethod), "dataset is not exists");
        _;
    }

    modifier onlyDatasetState(uint256 _datasetId, DatasetType.State _state) {
        DatasetType.Dataset storage dataset = datasets[_datasetId];
        require(_state == dataset.state, "dataset is not exists");
        _;
    }

    /// @notice Event emitted when metadata is submitted for a new dataset.
    event DatasetMetadataSubmitted(
        uint256 indexed _datasetId,
        address indexed _provider
    );

    /// @notice Event emitted when a proof is submitted for a dataset.
    event DatasetProofSubmitted(
        uint256 indexed _datasetId,
        address indexed _provider
    );

    /// @notice Event emitted when a dataset is verified.
    event DatasetVerificationSubmitted(
        uint256 indexed _datasetId,
        address indexed _verifier
    );

    /// @notice Event emitted when metadata is approved for a dataset.
    event DatasetMetadataApproved(uint256 indexed _datasetId);

    /// @notice Event emitted when metadata is rejected for a dataset.
    event DatasetMetadataRejected(uint256 indexed _datasetId);

    /// @notice Event emitted when a dataset is approved.
    event DatasetApproved(uint256 indexed _datasetId);

    /// @notice Event emitted when a dataset is rejected.
    event DatasetRejected(uint256 indexed _datasetId);

    ///@dev Need add cids to carStore
    function _beforeApproveDataset(uint256 _datasetId) internal {
        carstore.addCars(getDatasetSourceCars(_datasetId), _datasetId);
        carstore.addCars(
            getDatasetSourceToCarMappingFilesCars(_datasetId),
            _datasetId
        );
    }

    ///@notice Get dataset metadata
    function _getDataset(
        uint256 _datasetId
    ) internal view returns (DatasetType.Dataset storage) {
        DatasetType.Dataset storage dataset = datasets[_datasetId];
        return dataset;
    }

    ///@notice Approve a dataset.
    ///@dev This function changes the state of the dataset to DatasetApproved and emits the DatasetApproved event.
    function approveDataset(
        uint256 _datasetId
    )
        external
        notZeroId(_datasetId)
        onlyDatasetState(_datasetId, DatasetType.State.DatasetProofSubmitted)
        onlyAddress(governanceAddress)
    {
        _beforeApproveDataset(_datasetId);
        DatasetType.Dataset storage dataset = datasets[_datasetId];
        dataset.approveDataset();

        emit DatasetApproved(_datasetId);
    }

    ///@notice Approve the metadata of a dataset.
    ///@dev This function changes the state of the dataset to MetadataApproved and emits the MetadataApproved event.
    function approveDatasetMetadata(
        uint256 _datasetId
    )
        external
        notZeroId(_datasetId)
        onlyDatasetState(_datasetId, DatasetType.State.MetadataSubmitted)
        onlyAddress(governanceAddress)
    {
        DatasetType.Dataset storage dataset = datasets[_datasetId];
        dataset.approveDatasetMetadata();

        emit DatasetMetadataApproved(_datasetId);
    }

    ///@notice Reject the metadata of a dataset.
    ///@dev This function changes the state of the dataset to MetadataRejected and emits the MetadataRejected event.
    function rejectDatasetMetadata(
        uint256 _datasetId
    )
        external
        notZeroId(_datasetId)
        onlyDatasetState(_datasetId, DatasetType.State.MetadataSubmitted)
        onlyAddress(governanceAddress)
    {
        DatasetType.Dataset storage dataset = datasets[_datasetId];
        dataset.rejectDatasetMetadata();

        emit DatasetMetadataRejected(_datasetId);
    }

    ///@notice Reject a dataset.
    ///@dev This function changes the state of the dataset to DatasetRejected and emits the DatasetRejected event.
    function rejectDataset(
        uint256 _datasetId
    )
        external
        notZeroId(_datasetId)
        onlyDatasetState(_datasetId, DatasetType.State.DatasetProofSubmitted)
        onlyAddress(governanceAddress)
    {
        DatasetType.Dataset storage dataset = datasets[_datasetId];
        dataset.rejectDataset();

        emit DatasetRejected(_datasetId);
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
        uint256 _sizeInBytes,
        bool _isPublic,
        uint64 _version
    ) external datasetMetadataNotExsits(_accessMethod) {
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

        emit DatasetMetadataSubmitted(datasetsCount, msg.sender);
    }

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
    ) external notZeroId(_datasetId) onlyRole(RolesType.DATASET_PROVIDER) {
        //Note: params check in lib
        DatasetType.Dataset storage dataset = datasets[_datasetId];
        dataset.submitDatasetProof(
            _sourceDatasetRootHash,
            _sourceDatasetLeafHashes,
            _sourceToCarMappingFilesRootHashes,
            _sourceToCarMappingFilesLeafHashes,
            _sourceToCarMappingFilesAccessMethod
        );

        emit DatasetProofSubmitted(_datasetId, msg.sender);
    }

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
    ) external onlyRole(RolesType.DATASET_AUDITOR) {
        DatasetType.Dataset storage dataset = datasets[_datasetId];
        dataset._submitDatasetVerification(
            _randomSeed,
            _sourceDatasetProofRootHashes,
            _sourceDatasetProofLeafHashes,
            _sourceToCarMappingFilesProofRootHashes,
            _sourceToCarMappingFilesProofLeafHashes
        );

        emit DatasetVerificationSubmitted(_datasetId, msg.sender);
    }

    ///@notice Get dataset metadata
    function getDatasetMetadata(
        uint256 _datasetId
    )
        public
        view
        notZeroId(_datasetId)
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
        )
    {
        DatasetType.Dataset storage dataset = datasets[_datasetId];
        return dataset.getDatasetMetadata();
    }

    ///@notice Get dataset source CIDs
    function getDatasetSourceCars(
        uint256 _datasetId
    ) public view notZeroId(_datasetId) returns (bytes32[] memory) {
        DatasetType.Dataset storage dataset = datasets[_datasetId];
        return dataset.getDatasetSourceCids();
    }

    // Get dataset source proof
    function getDatasetSourceProof(
        uint256 _datasetId
    ) public view notZeroId(_datasetId) returns (bytes32, bytes32[] memory) {
        DatasetType.Dataset storage dataset = datasets[_datasetId];
        return dataset.getDatasetSourceProof();
    }

    ///@notice Get dataset source-to-CAR mapping files CIDs
    function getDatasetSourceToCarMappingFilesCars(
        uint256 _datasetId
    ) public view notZeroId(_datasetId) returns (bytes32[] memory) {
        DatasetType.Dataset storage dataset = datasets[_datasetId];
        return dataset.getDatasetSourceToCarMappingFilesCids();
    }

    ///@notice Get dataset source-to-CAR mapping files proof
    function getDatasetSourceToCarMappingFilesProof(
        uint256 _datasetId
    ) public view notZeroId(_datasetId) returns (bytes32, bytes32[] memory) {
        DatasetType.Dataset storage dataset = datasets[_datasetId];
        return dataset.getDatasetSourceToCarMappingFilesProof();
    }

    ///@notice Get dataset size
    function getDatasetSize(
        uint256 _datasetId
    ) public view notZeroId(_datasetId) returns (uint256) {
        (, , , , , , , , uint256 sizeInBytes, , ) = getDatasetMetadata(
            _datasetId
        );
        return sizeInBytes;
    }

    ///@notice Get dataset state
    function getDatasetState(
        uint256 _datasetId
    ) public view notZeroId(_datasetId) returns (DatasetType.State) {
        DatasetType.Dataset storage dataset = datasets[_datasetId];
        return dataset.getDatasetState();
    }

    ///@notice Get dataset verification
    function getDatasetVerification(
        uint256 _datasetId,
        address _auditor
    )
        public
        view
        notZeroId(_datasetId)
        returns (
            uint64 randomSeed,
            bytes32[] memory sourceDatasetProofRootHashes,
            bytes32[][] memory sourceDatasetProofLeafHashes,
            bytes32[] memory sourceToCarMappingFilesProofRootHashes,
            bytes32[][] memory sourceToCarMappingFilesProofLeafHashes
        )
    {
        DatasetType.Dataset storage dataset = datasets[_datasetId];
        return dataset.getDatasetVerification(_auditor);
    }

    ///@notice Get count of dataset verifications
    function getDatasetVerificationsCount(
        uint256 _datasetId
    ) public view notZeroId(_datasetId) returns (uint256) {
        DatasetType.Dataset storage dataset = datasets[_datasetId];
        return dataset.getDatasetVerificationsCount();
    }

    ///@notice Check if a dataset has metadata
    function hasDatasetMetadata(
        string memory _accessMethod
    ) public view returns (bool) {
        for (uint256 i = 1; i < datasetsCount; i++) {
            DatasetType.Dataset storage dataset = datasets[i];
            if (dataset.hasDatasetMetadata(_accessMethod)) return true;
        }
        return false;
    }

    ///@notice Check if a dataset has a cid
    function isDatasetContainsCar(
        uint256 _datasetId,
        bytes32 _cid
    ) public view notZeroId(_datasetId) returns (bool) {
        bytes32[] memory cids = getDatasetSourceToCarMappingFilesCars(
            _datasetId
        );
        for (uint256 i = 0; i < cids.length; i++) {
            if (cids[i] == _cid) return true;
        }
        return false;
    }

    ///@notice Check if a dataset has cids
    function isDatasetContainsCars(
        uint256 _datasetId,
        bytes32[] memory _cids
    ) public view notZeroId(_datasetId) returns (bool) {
        for (uint256 i = 0; i < _cids.length; i++) {
            if (!isDatasetContainsCar(_datasetId, _cids[i])) return false;
        }
        return true;
    }
}
