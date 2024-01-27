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
import {IStatistics} from "src/v0.8/interfaces/core/statistics/IStatistics.sol";

/// @title IDatasets
interface IDatasets is IStatistics {
    ///@notice Approve a dataset.
    ///@dev This function changes the state of the dataset to Approved and emits the DatasetApproved event.
    function __approveDataset(uint64 _datasetId) external;

    ///@notice Reject a dataset.
    ///@dev This function changes the state of the dataset to Rejected and emits the DatasetRejected event.
    function __rejectDataset(uint64 _datasetId) external;

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
        uint64 _version,
        uint64 _associatedDatasetId
    ) external returns (uint64);

    /// @notice Updates timeout parameters for a dataset.
    /// @dev Can only be called in the MetadataSubmitted state
    /// @param _datasetId The ID of the dataset.
    /// @param _proofBlockCount The updated block count for proof submission.
    /// @param _auditBlockCount The updated block count for audit submission.
    function updateDatasetTimeoutParameters(
        uint64 _datasetId,
        uint64 _proofBlockCount,
        uint64 _auditBlockCount
    ) external;

    /// @notice Update dataset usedSizeInBytes. only called by matching contract. TODO: Need to add permission control
    function addDatasetUsedSize(uint64 _datasetId, uint64 _size) external;

    /// @notice Get dataset usedSizeInBytes.
    function getDatasetUsedSize(
        uint64 _datasetId
    ) external view returns (uint64);

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

    /// @notice Get submitter of dataset's metadata
    function getDatasetMetadataSubmitter(
        uint64 _datasetId
    ) external view returns (address);

    /// @notice Get client of dataset's metadata
    function getDatasetMetadataClient(
        uint64 _datasetId
    ) external view returns (uint64);

    /// @notice Get timeout params of dataset's metadata
    function getDatasetTimeoutParameters(
        uint64 _datasetId
    ) external view returns (uint64 proofBlockCount, uint64 auditBlockCount);

    ///@notice Get dataset state
    function getDatasetState(
        uint64 _datasetId
    ) external view returns (DatasetType.State);

    ///@notice Check if a dataset has metadata
    function hasDatasetMetadata(
        string memory _accessMethod
    ) external view returns (bool);

    /// @notice Checks if metadata fields are valid.
    /// @dev This function is intended for use only by the 'dataswap' contract.
    function __requireValidDatasetMetadata(
        uint64 _datasetId
    ) external view returns (bool);

    /// @notice Report of insufficient escrow funds of the dataset.
    /// @dev This function is intended for use only by the 'dataswap' contract.
    function __reportDatasetInsufficientEscrowFunds(uint64 _datasetId) external;

    /// @notice Completes the escrow process for a specific dataset.
    /// @param _datasetId The ID of the dataset to complete the escrow for.
    function __reportDatasetEscrowCompleted(uint64 _datasetId) external;

    /// @notice Report the dataset replica has already been submitted.
    /// @dev This function is intended for use only by the 'dataswap' contract.
    function __reportDatasetReplicaRequirementSubmitted(
        uint64 _datasetId
    ) external;

    /// @notice Report the dataset proof has already been submitted.
    /// @dev This function is intended for use only by the 'dataswap' contract.
    function __reportDatasetProofCompleted(uint64 _datasetId) external;

    /// @notice Reports a dataset workflow timeout event.
    /// @param _datasetId The ID of the dataset for which the workflow timed out.
    function __reportDatasetWorkflowTimeout(uint64 _datasetId) external;

    /// @notice Reports that a challenge has been submitted for a dataset.
    /// @param _datasetId The ID of the dataset for which the challenge was submitted.
    function __reportDatasetChallengeCompleted(uint64 _datasetId) external;

    /// @notice Default getter functions for public variables
    function datasetsCount() external view returns (uint64);

    /// @notice Get the Roles contract.
    /// @return Roles contract address.
    function roles() external view returns (IRoles);

    /// @notice get  governance address
    function governanceAddress() external view returns (address);
}
