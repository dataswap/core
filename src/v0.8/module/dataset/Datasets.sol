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
import {IEscrow} from "src/v0.8/interfaces/core/IEscrow.sol";
import {IDatasets} from "src/v0.8/interfaces/module/IDatasets.sol";
import {IDatasetsProof} from "src/v0.8/interfaces/module/IDatasetsProof.sol";
import {IDatasetsRequirement} from "src/v0.8/interfaces/module/IDatasetsRequirement.sol";
///shared
import {DatasetsEvents} from "src/v0.8/shared/events/DatasetsEvents.sol";
import {DatasetsModifiers} from "src/v0.8/shared/modifiers/DatasetsModifiers.sol";
import {StatisticsBase} from "src/v0.8/core/statistics/StatisticsBase.sol";

/// library
import {DatasetMetadataLIB} from "src/v0.8/module/dataset/library/metadata/DatasetMetadataLIB.sol";
import {DatasetStateMachineLIB} from "src/v0.8/module/dataset/library/metadata/DatasetStateMachineLIB.sol";
import {DatasetAuditLIB} from "src/v0.8/module/dataset/library/metadata/DatasetAuditLIB.sol";

/// type
import {RolesType} from "src/v0.8/types/RolesType.sol";
import {EscrowType} from "src/v0.8/types/EscrowType.sol";
import {DatasetType} from "src/v0.8/types/DatasetType.sol";
import {GeolocationType} from "src/v0.8/types/GeolocationType.sol";

import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {UUPSUpgradeable} from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

/// @title Datasets Base Contract
/// @notice This contract serves as the base for managing Dataset, metadata, state.
/// @dev This contract is intended to be inherited by specific dataset-related contracts.
contract Datasets is
    Initializable,
    UUPSUpgradeable,
    IDatasets,
    StatisticsBase,
    DatasetsModifiers
{
    using DatasetMetadataLIB for DatasetType.Dataset;
    using DatasetAuditLIB for DatasetType.Dataset;
    using DatasetStateMachineLIB for DatasetType.Dataset;

    mapping(uint64 => DatasetType.Dataset) private datasets; // Mapping of dataset ID to dataset details

    address public governanceAddress;
    IRoles public roles;
    IEscrow public escrow;
    IDatasetsProof public datasetsProof;
    /// @dev This empty reserved space is put in place to allow future versions to add new
    uint256[32] private __gap;

    /// @notice initialize function to initialize the contract and grant the default admin role to the deployer.
    function initialize(
        address _governanceAddress,
        address _roles,
        address _escrow
    ) public initializer {
        StatisticsBase.statisticsBaseInitialize();
        governanceAddress = _governanceAddress;
        roles = IRoles(_roles);
        escrow = IEscrow(_escrow);

        __UUPSUpgradeable_init();
    }

    /// @notice initDependencies function to initialize the datasetsProof contract.
    /// @dev After the contract is deployed, this function needs to be called manually!
    function initDependencies(
        address _datasetsProof
    ) public onlyRole(roles, RolesType.DEFAULT_ADMIN_ROLE) {
        datasetsProof = IDatasetsProof(_datasetsProof);
    }

    /// @notice UUPS Upgradeable function to update the roles implementation
    /// @dev Only triggered by contract admin
    function _authorizeUpgrade(
        address newImplementation
    )
        internal
        override
        onlyRole(roles, RolesType.DEFAULT_ADMIN_ROLE) // solhint-disable-next-line
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
        onlyDatasetState(
            this,
            _datasetId,
            DatasetType.State.DatasetProofSubmitted
        )
        onlyAddress(governanceAddress)
    {
        DatasetType.Dataset storage dataset = datasets[_datasetId];
        (uint256 funds, , , , ) = escrow.getOwnerFund(
            EscrowType.Type.DatacapCollateral,
            dataset.metadata.submitter,
            _datasetId
        );
        uint64 mappingSize = datasetsProof.getDatasetSize(
            _datasetId,
            DatasetType.DataType.MappingFiles
        );
        uint64 sourceSize = datasetsProof.getDatasetSize(
            _datasetId,
            DatasetType.DataType.Source
        );
        if (
            funds >= datasetsProof.getDatasetCollateralRequirement(_datasetId)
        ) {
            // Update collateral funds to collateral requirement
            escrow.__emitCollateralUpdate(
                EscrowType.Type.DatacapCollateral,
                dataset.metadata.submitter,
                _datasetId,
                EscrowType.CollateralEvent.SyncCollateral
            );

            dataset.approveDataset();

            _addCountSuccess(1);
            _addSizeSuccess(mappingSize + sourceSize);
            emit DatasetsEvents.DatasetApproved(_datasetId);
        } else {
            dataset.rejectDataset();
            _addCountFailed(1);
            _addSizeFailed(mappingSize + sourceSize);
            emit DatasetsEvents.DatasetRejected(_datasetId);
        }
    }

    ///@notice Approve the metadata of a dataset.
    ///@dev This function changes the state of the dataset to MetadataApproved and emits the MetadataApproved event.
    function approveDatasetMetadata(
        uint64 _datasetId
    )
        external
        onlyNotZero(_datasetId)
        onlyDatasetState(this, _datasetId, DatasetType.State.MetadataSubmitted)
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
        onlyDatasetState(this, _datasetId, DatasetType.State.MetadataSubmitted)
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
        onlyDatasetState(
            this,
            _datasetId,
            DatasetType.State.DatasetProofSubmitted
        )
        onlyAddress(governanceAddress)
    {
        DatasetType.Dataset storage dataset = datasets[_datasetId];
        dataset.rejectDataset();
        uint64 mappingSize = datasetsProof.getDatasetSize(
            _datasetId,
            DatasetType.DataType.MappingFiles
        );
        uint64 sourceSize = datasetsProof.getDatasetSize(
            _datasetId,
            DatasetType.DataType.Source
        );
        _addCountFailed(1);
        _addSizeFailed(mappingSize + sourceSize);
        emit DatasetsEvents.DatasetRejected(_datasetId);
    }

    ///@notice Submit metadata for a dataset
    ///        Note:anyone can submit dataset metadata
    function submitDatasetMetadata(
        uint64 _client,
        string memory _title,
        string memory _industry,
        string memory _name,
        string memory _description,
        string memory _source,
        string memory _accessMethod,
        uint64 _sizeInBytes,
        bool _isPublic,
        uint64 _version
    )
        external
        onlyDatasetMetadataNotExsits(this, _accessMethod)
        returns (uint64)
    {
        //Note: params check in lib
        _addCountTotal(1);

        DatasetType.Dataset storage dataset = datasets[datasetsCount()];
        dataset.submitDatasetMetadata(
            _client,
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
        emit DatasetsEvents.DatasetMetadataSubmitted(
            datasetsCount(),
            msg.sender
        );
        return datasetsCount();
    }

    /// @notice Update dataset usedSizeInBytes. only called by matching contract. TODO: Need to add permission control
    function addDatasetUsedSize(
        uint64 _datasetId,
        uint64 _size
    ) public onlyNotZero(_datasetId) {
        DatasetType.Dataset storage dataset = datasets[_datasetId];
        dataset.usedSizeInBytes += _size;
    }

    /// @notice Get dataset usedSizeInBytes.
    function getDatasetUsedSize(
        uint64 _datasetId
    ) public view onlyNotZero(_datasetId) returns (uint64) {
        DatasetType.Dataset storage dataset = datasets[_datasetId];
        return dataset.usedSizeInBytes;
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
        require(
            bytes(dataset.metadata.title).length > 0,
            "Metadata does not exist"
        );
        return (
            dataset.metadata.title,
            dataset.metadata.industry,
            dataset.metadata.name,
            dataset.metadata.description,
            dataset.metadata.source,
            dataset.metadata.accessMethod,
            dataset.metadata.submitter,
            dataset.metadata.createdBlockNumber,
            dataset.metadata.sizeInBytes,
            dataset.metadata.isPublic,
            dataset.metadata.version
        );
    }

    /// @notice Get submitter of dataset's metadata
    function getDatasetMetadataSubmitter(
        uint64 _datasetId
    ) public view returns (address) {
        DatasetType.Dataset storage dataset = datasets[_datasetId];
        return dataset.getDatasetMetadataSubmitter();
    }

    /// @notice Get client of dataset's metadata
    function getDatasetMetadataClient(
        uint64 _datasetId
    ) public view returns (uint64) {
        DatasetType.Dataset storage dataset = datasets[_datasetId];
        return dataset.getDatasetMetadataClient();
    }

    ///@notice Get dataset state
    function getDatasetState(
        uint64 _datasetId
    ) public view onlyNotZero(_datasetId) returns (DatasetType.State) {
        DatasetType.Dataset storage dataset = datasets[_datasetId];
        return dataset.getDatasetState();
    }

    ///@notice Check if a dataset has metadata
    function hasDatasetMetadata(
        string memory _accessMethod
    ) public view returns (bool) {
        for (uint64 i = 1; i <= datasetsCount(); i++) {
            DatasetType.Dataset storage dataset = datasets[i];
            if (dataset.hasDatasetMetadata(_accessMethod)) return true;
        }
        return false;
    }

    /// @notice Checks if metadata fields are valid.
    /// @dev This function is intended for use only by the 'dataswap' contract.
    function __requireValidDatasetMetadata(
        uint64 _datasetId
    )
        external
        view
        onlyRole(roles, RolesType.DATASWAP_CONTRACT)
        returns (bool)
    {
        DatasetType.Dataset storage dataset = datasets[_datasetId];
        dataset.requireValidDatasetMetadata();
        return true;
    }

    /// @notice Report the dataset replica has already been submitted.
    /// @dev This function is intended for use only by the 'dataswap' contract.
    function __reportDatasetReplicaRequirementSubmitted(
        uint64 _datasetId
    ) external onlyRole(roles, RolesType.DATASWAP_CONTRACT) {
        DatasetType.Dataset storage dataset = datasets[_datasetId];
        dataset._emitDatasetEvent(DatasetType.Event.SubmitMetadata);
    }

    /// @notice Report the dataset has not enough collateral.
    /// @dev This function is intended for use only by the 'dataswap' contract.
    function __reportFundsNotEnough(
        uint64 _datasetId
    ) external onlyRole(roles, RolesType.DATASWAP_CONTRACT) {
        DatasetType.Dataset storage dataset = datasets[_datasetId];
        dataset._emitDatasetEvent(DatasetType.Event.NotEnoughCollateral);
    }

    /// @notice Report the dataset has enough collateral.
    /// @dev This function is intended for use only by the 'dataswap' contract.
    function __reportFundsEnough(
        uint64 _datasetId
    ) external onlyRole(roles, RolesType.DATASWAP_CONTRACT) {
        DatasetType.Dataset storage dataset = datasets[_datasetId];
        dataset._emitDatasetEvent(DatasetType.Event.EnoughCollateral);
    }

    /// @notice Report the dataset proof has already been submitted.
    /// @dev This function is intended for use only by the 'dataswap' contract.
    function __reportDatasetProofSubmitted(
        uint64 _datasetId
    ) external onlyRole(roles, RolesType.DATASWAP_CONTRACT) {
        DatasetType.Dataset storage dataset = datasets[_datasetId];

        uint64 mappingSize = datasetsProof.getDatasetSize(
            _datasetId,
            DatasetType.DataType.MappingFiles
        );
        uint64 sourceSize = datasetsProof.getDatasetSize(
            _datasetId,
            DatasetType.DataType.Source
        );

        _addSizeTotal(mappingSize + sourceSize);
        dataset._emitDatasetEvent(DatasetType.Event.SubmitDatasetProof);
    }

    /// @notice Public view function to retrieve the count of datasets.
    /// @return Count of datasets.
    function datasetsCount() public view returns (uint64) {
        return uint64(_totalCount());
    }
}
