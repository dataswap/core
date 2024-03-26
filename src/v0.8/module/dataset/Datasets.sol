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
import {IDatasets} from "src/v0.8/interfaces/module/IDatasets.sol";

///shared
import {DatasetsEvents} from "src/v0.8/shared/events/DatasetsEvents.sol";
import {StatisticsEvents} from "src/v0.8/shared/events/StatisticsEvents.sol";
import {DatasetsModifiers} from "src/v0.8/shared/modifiers/DatasetsModifiers.sol";
import {StatisticsBase} from "src/v0.8/core/statistics/StatisticsBase.sol";

/// library
import {DatasetMetadataLIB} from "src/v0.8/module/dataset/library/metadata/DatasetMetadataLIB.sol";
import {DatasetStateMachineLIB} from "src/v0.8/module/dataset/library/metadata/DatasetStateMachineLIB.sol";

/// type
import {RolesType} from "src/v0.8/types/RolesType.sol";
import {DatasetType} from "src/v0.8/types/DatasetType.sol";
import {FinanceType} from "src/v0.8/types/FinanceType.sol";
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
    using DatasetStateMachineLIB for DatasetType.Dataset;

    mapping(uint64 => DatasetType.Dataset) private datasets; // Mapping of dataset ID to dataset details
    mapping(bytes32 => uint64) private accessMethodsToDatasetIds; // Mapping of dataset accesss method to dataset Id

    address public governanceAddress;
    IRoles public roles;
    /// @dev This empty reserved space is put in place to allow future versions to add new
    uint256[32] private __gap;

    /// @notice initialize function to initialize the contract and grant the default admin role to the deployer.
    function initialize(
        address _governanceAddress,
        address _roles
    ) public initializer {
        StatisticsBase.statisticsBaseInitialize();
        governanceAddress = _governanceAddress;
        roles = IRoles(_roles);

        __UUPSUpgradeable_init();
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

    /// @dev Claims the dataset escrow for a given dataset ID.
    /// @param _datasetId The ID of the dataset for which the escrow is being claimed.
    function _claimDatasetEscrow(uint64 _datasetId) internal {
        roles.finance().claimEscrow(
            _datasetId,
            0,
            FinanceType.FIL,
            FinanceType.Type.EscrowChallengeCommission
        );
        roles.finance().claimEscrow(
            _datasetId,
            0,
            FinanceType.FIL,
            FinanceType.Type.EscrowChallengeAuditCollateral
        );
    }

    ///@notice Approve a dataset.
    ///@dev This function changes the state of the dataset to Approved and emits the DatasetApproved event.
    function __approveDataset(
        uint64 _datasetId
    )
        public
        onlyNotZero(_datasetId)
        onlyDatasetState(this, _datasetId, DatasetType.State.ProofSubmitted)
        onlyRole(roles, RolesType.DATASWAP_CONTRACT)
    {
        DatasetType.Dataset storage dataset = datasets[_datasetId];

        uint64 mappingSize = roles.datasetsProof().getDatasetSize(
            _datasetId,
            DatasetType.DataType.MappingFiles
        );
        uint64 sourceSize = roles.datasetsProof().getDatasetSize(
            _datasetId,
            DatasetType.DataType.Source
        );

        _addCountSuccess(1);
        _addSizeSuccess(mappingSize + sourceSize);

        dataset._emitDatasetEvent(DatasetType.Event.Approved);

        _claimDatasetEscrow(_datasetId);

        emit DatasetsEvents.DatasetApproved(_datasetId);
        emit StatisticsEvents.DatasetsStatistics(
            uint64(block.number),
            count.total,
            count.success,
            count.failed,
            size.total,
            size.success,
            size.failed
        );
    }

    ///@notice Reject a dataset.
    ///@dev This function changes the state of the dataset to Rejected and emits the DatasetRejected event.
    function __rejectDataset(
        uint64 _datasetId
    )
        external
        onlyNotZero(_datasetId)
        onlyDatasetState(this, _datasetId, DatasetType.State.ProofSubmitted)
        onlyRole(roles, RolesType.DATASWAP_CONTRACT)
    {
        DatasetType.Dataset storage dataset = datasets[_datasetId];

        dataset._emitDatasetEvent(DatasetType.Event.Rejected);

        _claimDatasetEscrow(_datasetId);

        uint64 mappingSize = roles.datasetsProof().getDatasetSize(
            _datasetId,
            DatasetType.DataType.MappingFiles
        );
        uint64 sourceSize = roles.datasetsProof().getDatasetSize(
            _datasetId,
            DatasetType.DataType.Source
        );
        _addCountFailed(1);
        _addSizeFailed(mappingSize + sourceSize);
        emit DatasetsEvents.DatasetRejected(_datasetId);
        emit StatisticsEvents.DatasetsStatistics(
            uint64(block.number),
            count.total,
            count.success,
            count.failed,
            size.total,
            size.success,
            size.failed
        );
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
    ) external onlyDatasetMetadataValid(this, _accessMethod) returns (uint64) {
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

        dataset.submitDatasetRuntimeParameters(
            roles.filplus().datasetRuleMinProofTimeout(),
            roles.filplus().datasetRuleMinAuditTimeout(),
            accessMethodsToDatasetIds[dataset.getDatasetAccessMethodKey()]
        );

        _updateDatasetIdForAccessMethod(datasetsCount());

        dataset._emitDatasetEvent(DatasetType.Event.SubmitMetadata);
        emit DatasetsEvents.DatasetMetadataSubmitted(
            datasetsCount(),
            msg.sender
        );
        emit StatisticsEvents.DatasetsStatistics(
            uint64(block.number),
            count.total,
            count.success,
            count.failed,
            size.total,
            size.success,
            size.failed
        );

        return datasetsCount();
    }

    /// @notice Reports a dataset workflow timeout event.
    /// @param _datasetId The ID of the dataset for which the workflow timed out.
    function reportDatasetWorkflowTimeout(uint64 _datasetId) public {
        if (
            roles.datasetsRequirement().isDatasetRequirementTimeout(
                _datasetId
            ) ||
            roles.datasetsProof().isDatasetProofTimeout(_datasetId) ||
            roles.datasetsChallenge().isDatasetAuditTimeout(_datasetId)
        ) {
            __reportDatasetWorkflowTimeout(_datasetId);
        }
    }

    /// @notice Updates the dataset ID for a given access method.
    /// @param _datasetId The ID of the dataset to be updated.
    function _updateDatasetIdForAccessMethod(uint64 _datasetId) internal {
        // Retrieve the dataset storage reference
        DatasetType.Dataset storage dataset = datasets[_datasetId];

        // Update the mapping of access methods to dataset IDs
        accessMethodsToDatasetIds[
            dataset.getDatasetAccessMethodKey()
        ] = _datasetId;
    }

    /// @notice Updates timeout parameters for a dataset.
    /// @param _datasetId The ID of the dataset.
    /// @param _proofBlockCount The updated block count for proof submission.
    /// @param _auditBlockCount The updated block count for audit submission.
    function updateDatasetTimeoutParameters(
        uint64 _datasetId,
        uint64 _proofBlockCount,
        uint64 _auditBlockCount
    )
        public
        onlyDatasetState(this, _datasetId, DatasetType.State.MetadataSubmitted)
    {
        DatasetType.Dataset storage dataset = datasets[_datasetId];

        require(
            _proofBlockCount > roles.filplus().datasetRuleMinProofTimeout() &&
                _auditBlockCount > roles.filplus().datasetRuleMinAuditTimeout(),
            "invalid dataset timeout parameters"
        );

        dataset.metadata.proofBlockCount = _proofBlockCount;
        dataset.metadata.auditBlockCount = _auditBlockCount;
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

    /// @notice Get timeout params of dataset's metadata
    function getDatasetTimeoutParameters(
        uint64 _datasetId
    ) external view returns (uint64 proofBlockCount, uint64 auditBlockCount) {
        DatasetType.Dataset storage dataset = datasets[_datasetId];
        return (
            dataset.metadata.proofBlockCount,
            dataset.metadata.auditBlockCount
        );
    }

    ///@notice Get dataset state
    function getDatasetState(
        uint64 _datasetId
    ) public view onlyNotZero(_datasetId) returns (DatasetType.State) {
        DatasetType.Dataset storage dataset = datasets[_datasetId];
        return dataset.getDatasetState();
    }

    /// @notice Retrieves the associated dataset ID for a given dataset ID.
    /// @param _datasetId The ID of the dataset for which the associated dataset ID is being retrieved.
    /// @return The associated dataset ID.
    function getAssociatedDatasetId(
        uint64 _datasetId
    ) public view returns (uint64) {
        DatasetType.Dataset storage dataset = datasets[_datasetId];
        return dataset.metadata.associatedDatasetId;
    }

    /// @notice Retrieves the dataset ID associated with a given access method.
    /// @dev This function returns the dataset ID mapped to the keccak256 hash of the input access method.
    /// @param _accessMethod The access method for which the dataset ID is being retrieved.
    /// @return The dataset ID associated with the given access method.
    function getDatasetIdForAccessMethod(
        string memory _accessMethod
    ) public view returns (uint64) {
        // Retrieve and return the dataset ID mapped to the keccak256 hash of the input access method
        return
            accessMethodsToDatasetIds[
                keccak256(abi.encodePacked(_accessMethod))
            ];
    }

    ///@notice Check if a dataset has metadata
    function hasDatasetMetadata(
        string memory _accessMethod
    ) public view returns (bool) {
        if (
            accessMethodsToDatasetIds[
                keccak256(abi.encodePacked(_accessMethod))
            ] != 0
        ) {
            return true;
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
        dataset._emitDatasetEvent(DatasetType.Event.SubmitRequirements);
    }

    /// @notice Report of insufficient escrow funds of the dataset.
    /// @dev This function is intended for use only by the 'dataswap' contract.
    function __reportDatasetInsufficientEscrowFunds(
        uint64 _datasetId
    ) external onlyRole(roles, RolesType.DATASWAP_CONTRACT) {
        DatasetType.Dataset storage dataset = datasets[_datasetId];
        dataset._emitDatasetEvent(DatasetType.Event.InsufficientEscrowFunds);
    }

    /// @notice Completes the escrow process for a specific dataset.
    /// @param _datasetId The ID of the dataset to complete the escrow for.
    function __reportDatasetEscrowCompleted(
        uint64 _datasetId
    ) external onlyRole(roles, RolesType.DATASWAP_CONTRACT) {
        DatasetType.Dataset storage dataset = datasets[_datasetId];
        dataset._emitDatasetEvent(DatasetType.Event.EscrowCompleted);
    }

    /// @notice Reports that dataset proof has been submitted.
    /// @param _proofSize The size of the dataset proof submitted.
    function __reportDatasetProofSubmitted(
        uint64 _proofSize
    ) external onlyRole(roles, RolesType.DATASWAP_CONTRACT) {
        _addSizeTotal(_proofSize);
    }

    /// @notice Report the dataset proof has already been submitted.
    /// @dev This function is intended for use only by the 'dataswap' contract.
    function __reportDatasetProofCompleted(
        uint64 _datasetId
    ) external onlyRole(roles, RolesType.DATASWAP_CONTRACT) {
        DatasetType.Dataset storage dataset = datasets[_datasetId];
        dataset._emitDatasetEvent(DatasetType.Event.ProofCompleted);
    }

    /// @notice Reports a dataset workflow timeout event.
    /// @param _datasetId The ID of the dataset for which the workflow timed out.
    function __reportDatasetWorkflowTimeout(
        uint64 _datasetId
    ) public onlyRole(roles, RolesType.DATASWAP_CONTRACT) {
        DatasetType.Dataset storage dataset = datasets[_datasetId];
        dataset._emitDatasetEvent(DatasetType.Event.WorkflowTimeout);

        _claimDatasetEscrow(_datasetId);

        uint64 mappingSize = roles.datasetsProof().getDatasetSize(
            _datasetId,
            DatasetType.DataType.MappingFiles
        );
        uint64 sourceSize = roles.datasetsProof().getDatasetSize(
            _datasetId,
            DatasetType.DataType.Source
        );
        _addCountFailed(1);
        _addSizeFailed(mappingSize + sourceSize);
        emit DatasetsEvents.DatasetRejected(_datasetId);
        emit StatisticsEvents.DatasetsStatistics(
            uint64(block.number),
            count.total,
            count.success,
            count.failed,
            size.total,
            size.success,
            size.failed
        );
    }

    /// @notice Reports that a challenge has been submitted for a dataset.
    /// @param _datasetId The ID of the dataset for which the challenge was submitted.
    function __reportDatasetChallengeCompleted(
        uint64 _datasetId
    ) external onlyRole(roles, RolesType.DATASWAP_CONTRACT) {
        //TODO: Consider adding ChallengeCompleted status and event for waiting for disputes

        __approveDataset(_datasetId);
    }

    /// @notice Public view function to retrieve the count of datasets.
    /// @return Count of datasets.
    function datasetsCount() public view returns (uint64) {
        return uint64(_totalCount());
    }
}
