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

import "@openzeppelin/contracts/access/Ownable2Step.sol";
import "../../types/DatasetType.sol";
import "../..//types/RolesType.sol";
import "./library/DatasetLIB.sol";
import "../../shared/Common.sol";
import "../../shared/utils/StringUtils.sol";
import "../../core/accessControl/IRoles.sol";
import "../../core/carStore/CarStore.sol";

/// @title Datasets Base Contract
/// @notice This contract serves as the base for managing datasets, metadata, proofs, and verifications.
/// @dev This contract is intended to be inherited by specific dataset-related contracts.
abstract contract Datasets is Ownable2Step, CarStore {
    uint256 public datasetCount;
    mapping(uint256 => DatasetType.Dataset) public datasets;
    address public immutable rolesContract;
    address payable public immutable governanceContract;
    address public immutable carsStorageContract;

    using DatasetLIB for DatasetType.Dataset;

    /// @notice Contract constructor.
    /// @dev Initializes the contract with the provided addresses for governance, roles, and cars storage contracts.
    /// @param _governanceContract The address of the governance contract.
    /// @param _rolesContract The address of the roles contract.
    /// @param _carsStorageContract The address of the cars storage contract.:w
    constructor(
        address payable _governanceContract,
        address _rolesContract,
        address _carsStorageContract
    ) {
        governanceContract = _governanceContract;
        rolesContract = _rolesContract;
        carsStorageContract = _carsStorageContract;
    }

    /// @notice Event emitted when metadata is submitted for a new dataset.
    event MetadataSubmitted(
        uint256 indexed _datasetId,
        address indexed _provider,
        string metadata
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
    event MetadataApproved(uint256 indexed _datasetId);

    /// @notice Event emitted when metadata is rejected for a dataset.
    event MetadataRejected(uint256 indexed _datasetId);

    /// @notice Event emitted when a dataset is approved.
    event DatasetApproved(uint256 indexed _datasetId);

    /// @notice Event emitted when a dataset is rejected.
    event DatasetRejected(uint256 indexed _datasetId);

    /// @notice Modifier: Only Governance Contract
    modifier onlyGovernance() {
        require(
            msg.sender == governanceContract,
            "Only governance contract can call this function"
        );
        _;
    }

    /// @notice Modifier: Only Specific Role
    /// @param _role The role required for access.
    modifier onlyRole(bytes32 _role) {
        IRoles role = IRoles(rolesContract);
        require(role.hasRole(_role, msg.sender), "No permission!");
        _;
    }

    /// @notice Submit metadata for a new dataset.
    /// @dev This function allows submitting metadata for a new dataset and increments the datasetCount.
    /// @param _metadata The metadata to be submitted.
    function submitMetadata(DatasetType.Metadata calldata _metadata) public {
        //TODO:check if metadata exsits
        Common.requireValidDataset(_metadata);

        // Increment the datasetCount
        datasetCount++;

        // Create a new DatasetType.Dataset instance for the new dataset
        DatasetType.Dataset storage newDataset = datasets[datasetCount];

        // Use the Dataset library method to submit metadata
        newDataset.submitMetadata(_metadata);
        emit MetadataSubmitted(datasetCount, msg.sender, _metadata.accessInfo);
    }

    /// @notice Submit a proof for a dataset.
    /// @dev This function allows submitting a proof for a dataset.
    /// @param _datasetId The ID of the dataset to which the proof will be submitted.
    /// @param _proof The proof to be submitted.
    function submitProof(
        uint256 _datasetId,
        DatasetType.Proof calldata _proof
    ) public onlyRole(RolesType.DATASET_PROVIDER) {
        // Ensure the provided datasetId is within the valid range
        require(
            _datasetId > 0 && _datasetId <= datasetCount,
            "Invalid dataset ID"
        );

        // Get the Dataset instance for the provided datasetId
        DatasetType.Dataset storage dataset = datasets[_datasetId];

        // Use the Dataset library method to submit the proof
        dataset.submitProof(_proof);
        emit DatasetProofSubmitted(_datasetId, msg.sender);
    }

    /// @notice Submit a verification for a dataset.
    /// @dev This function allows submitting a verification for a dataset.
    /// @param _datasetId The ID of the dataset to which the verification will be submitted.
    /// @param _verification The verification to be submitted.
    /// @return The result of the verification submission.
    function submitVerification(
        uint256 _datasetId,
        DatasetType.Verification calldata _verification
    )
        public
        onlyRole(RolesType.DATASET_AUDITOR)
        returns (DatasetType.VerifyResult)
    {
        // Ensure the provided datasetId is within the valid range
        require(
            _datasetId > 0 && _datasetId <= datasetCount,
            "Invalid dataset ID"
        );

        // Get the Dataset instance for the provided datasetId
        DatasetType.Dataset storage dataset = datasets[_datasetId];

        emit DatasetVerificationSubmitted(_datasetId, msg.sender);
        // Use the Dataset library method to submit the verification and return the result
        return
            dataset.submitVerification(
                _verification,
                governanceContract,
                _datasetId,
                address(this)
            );
    }

    /// @notice Approve the metadata of a dataset.
    /// @dev This function allows approving the metadata of a dataset.
    /// @param _datasetId The ID of the dataset to approve the metadata for.
    function approveMetadata(uint256 _datasetId) public onlyGovernance {
        // Get the Dataset instance for the provided datasetId
        DatasetType.Dataset storage dataset = datasets[_datasetId];

        // Use the Dataset library method to approve metadata
        dataset.approveMetadata();
        emit MetadataApproved(_datasetId);
    }

    /// @notice Reject the metadata of a dataset.
    /// @dev This function allows rejecting the metadata of a dataset.
    /// @param _datasetId The ID of the dataset to reject the metadata for.
    function rejectMetadata(uint256 _datasetId) public onlyGovernance {
        // Get the Dataset instance for the provided datasetId
        DatasetType.Dataset storage dataset = datasets[_datasetId];

        // Use the Dataset library method to reject metadata
        dataset.rejectMetadata();
        emit MetadataRejected(_datasetId);
    }

    /// @notice Approve a dataset.
    /// @dev This function allows approving a dataset.
    /// @param _datasetId The ID of the dataset to approve.
    function approveDataset(uint256 _datasetId) public onlyGovernance {
        // Get the Dataset instance for the provided datasetId
        DatasetType.Dataset storage dataset = datasets[_datasetId];

        // Use the Dataset library method to approve the dataset
        dataset.approveDataset();
        postApprovedAction(_datasetId);
    }

    /// @notice Reject a dataset.
    /// @dev This function allows rejecting a dataset.
    /// @param _datasetId The ID of the dataset to reject.
    function rejectDataset(uint256 _datasetId) public onlyGovernance {
        // Get the Dataset instance for the provided datasetId
        DatasetType.Dataset storage dataset = datasets[_datasetId];

        // Use the Dataset library method to reject the dataset
        dataset.rejectDataset();

        emit DatasetRejected(_datasetId);
    }

    /// @notice Get the state of a dataset.
    /// @param datasetId The ID of the dataset to retrieve the state for.
    /// @return The current state of the dataset
    function getState(
        uint256 datasetId
    ) public view returns (DatasetType.State) {
        DatasetType.Dataset storage dataset = datasets[datasetId];
        return dataset.getState();
    }

    /// @notice Perform actions after dataset approval.
    /// @dev This internal function is used to perform additional actions after a dataset is approved.
    /// @param _datasetId The ID of the approved dataset.
    function postApprovedAction(uint256 _datasetId) internal {
        DatasetType.Dataset storage dataset = datasets[_datasetId];
        addCars(dataset.proof.leafHashes, _datasetId);
        addCars(dataset.proof.mappingFilesLeafHashes, _datasetId);
    }
}
