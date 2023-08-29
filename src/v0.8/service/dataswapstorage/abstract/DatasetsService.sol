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
import {DataswapStorageServiceBase} from "src/v0.8/service/dataswapstorage/abstract/base/DataswapStorageServiceBase.sol";
import {IRoles} from "src/v0.8/interfaces/core/IRoles.sol";
import {IMerkleUtils} from "src/v0.8/interfaces/utils/IMerkleUtils.sol";

/// @title DatasetsService
abstract contract DatasetsService is DataswapStorageServiceBase {
    ///@notice Approve a dataset.
    ///@dev This function changes the state of the dataset to DatasetApproved and emits the DatasetApproved event.
    function approveDataset(uint64 _datasetId) external {
        datasetsInstance.approveDataset(_datasetId);
    }

    ///@notice Approve the metadata of a dataset.
    ///@dev This function changes the state of the dataset to MetadataApproved and emits the MetadataApproved event.
    function approveDatasetMetadata(uint64 _datasetId) external {
        datasetsInstance.approveDatasetMetadata(_datasetId);
    }

    ///@notice Reject a dataset.
    ///@dev This function changes the state of the dataset to DatasetRejected and emits the DatasetRejected event.
    function rejectDataset(uint64 _datasetId) external {
        datasetsInstance.rejectDataset(_datasetId);
    }

    ///@notice Reject the metadata of a dataset.
    ///@dev This function changes the state of the dataset to MetadataRejected and emits the MetadataRejected event.
    function rejectDatasetMetadata(uint64 _datasetId) external {
        datasetsInstance.rejectDatasetMetadata(_datasetId);
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
    ) external {
        datasetsInstance.submitDatasetMetadata(
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
    }

    ///@notice Submit proof for a dataset
    function submitDatasetProof(
        uint64 _datasetId,
        DatasetType.DataType _dataType,
        string calldata accessMethod,
        bytes32 _rootHash,
        bytes32[] calldata _leafHashes,
        uint64[] calldata _leafSizes,
        bool _completed
    ) external {
        datasetsInstance.submitDatasetProof(
            _datasetId,
            _dataType,
            accessMethod,
            _rootHash,
            _leafHashes,
            _leafSizes,
            _completed
        );
    }

    ///@notice Submit proof for a dataset
    function submitDatasetVerification(
        uint64 _datasetId,
        uint64 _randomSeed,
        bytes32[] memory _leaves,
        bytes32[][] memory _siblings,
        uint32[] memory _paths
    ) external {
        datasetsInstance.submitDatasetVerification(
            _datasetId,
            _randomSeed,
            _leaves,
            _siblings,
            _paths
        );
    }

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
        )
    {
        return datasetsInstance.getDatasetMetadata(_datasetId);
    }

    ///@notice Get dataset source CIDs
    function getDatasetProof(
        uint64 _datasetId,
        DatasetType.DataType _dataType,
        uint64 _index,
        uint64 _len
    ) external view returns (bytes32[] memory) {
        return
            datasetsInstance.getDatasetProof(
                _datasetId,
                _dataType,
                _index,
                _len
            );
    }

    ///@notice Get dataset source CIDs
    function getDatasetCars(
        uint64 _datasetId,
        DatasetType.DataType _dataType,
        uint64 _index,
        uint64 _len
    ) external view returns (bytes32[] memory) {
        return
            datasetsInstance.getDatasetCars(
                _datasetId,
                _dataType,
                _index,
                _len
            );
    }

    function getDatasetProofCount(
        uint64 _datasetId,
        DatasetType.DataType _dataType
    ) external view returns (uint64) {
        return datasetsInstance.getDatasetProofCount(_datasetId, _dataType);
    }

    ///@notice Get dataset proof's submitter
    function getDatasetProofSubmitter(
        uint64 _datasetId
    ) external view returns (address submitter) {
        return datasetsInstance.getDatasetProofSubmitter(_datasetId);
    }

    ///@notice Get dataset source CIDs
    function getDatasetCarsCount(
        uint64 _datasetId,
        DatasetType.DataType _dataType
    ) external view returns (uint64) {
        return datasetsInstance.getDatasetCarsCount(_datasetId, _dataType);
    }

    ///@notice Get dataset size
    function getDatasetSize(
        uint64 _datasetId,
        DatasetType.DataType _dataType
    ) external view returns (uint64) {
        return datasetsInstance.getDatasetSize(_datasetId, _dataType);
    }

    ///@notice Get dataset state
    function getDatasetState(
        uint64 _datasetId
    ) external view returns (DatasetType.State) {
        return datasetsInstance.getDatasetState(_datasetId);
    }

    ///@notice Get dataset verification
    function getDatasetVerification(
        uint64 _datasetId,
        address _auditor
    )
        external
        view
        returns (
            bytes32[] memory,
            bytes32[][] memory _siblings,
            uint32[] memory _paths
        )
    {
        return datasetsInstance.getDatasetVerification(_datasetId, _auditor);
    }

    ///@notice Get count of dataset verifications
    function getDatasetVerificationsCount(
        uint64 _datasetId
    ) external view returns (uint16) {
        return datasetsInstance.getDatasetVerificationsCount(_datasetId);
    }

    ///@notice Check if a dataset has metadata
    function hasDatasetMetadata(
        string memory _accessMethod
    ) external view returns (bool) {
        return datasetsInstance.hasDatasetMetadata(_accessMethod);
    }

    ///@notice Check if a dataset has a cid
    function isDatasetContainsCar(
        uint64 _datasetId,
        bytes32 _cid
    ) external view returns (bool) {
        return datasetsInstance.isDatasetContainsCar(_datasetId, _cid);
    }

    ///@notice Check if a dataset has cids
    function isDatasetContainsCars(
        uint64 _datasetId,
        bytes32[] memory _cids
    ) external view returns (bool) {
        return datasetsInstance.isDatasetContainsCars(_datasetId, _cids);
    }

    ///@notice Check if a dataset has submitter
    function isDatasetProofSubmitter(
        uint64 _datasetId,
        address _submitter
    ) external view returns (bool) {
        return datasetsInstance.isDatasetProofSubmitter(_datasetId, _submitter);
    }

    ///@notice Checking if duplicate verifications of the Dataset
    function isDatasetVerificationDuplicate(
        uint64 _datasetId,
        address _auditor,
        uint64 _randomSeed
    ) external view returns (bool) {
        return
            datasetsInstance.isDatasetVerificationDuplicate(
                _datasetId,
                _auditor,
                _randomSeed
            );
    }

    /// @notice Default getter functions for public variables
    function datasetsCount() external view returns (uint64) {
        return datasetsInstance.datasetsCount();
    }

    /// @notice get roles instance
    function roles() external view returns (IRoles role_) {
        return datasetsInstance.roles();
    }

    /// @notice  get governance contract address
    function governanceAddress()
        external
        view
        returns (address governanceAddress_)
    {
        return datasetsInstance.governanceAddress();
    }

    /// @notice get  merkle utils
    function merkleUtils() external view returns (IMerkleUtils) {
        return datasetsInstance.merkleUtils();
    }

    ///@notice Get a dataset challenge count
    function getChallengeCount(
        uint64 _datasetId
    ) external view returns (uint64) {
        return datasetsInstance.getChallengeCount(_datasetId);
    }
}
