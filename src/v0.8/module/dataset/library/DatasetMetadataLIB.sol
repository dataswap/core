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

import {DatasetType} from "../../../types/DatasetType.sol";
import {DatasetStateMachineLIB} from "./DatasetStateMachineLIB.sol";

/// @title DatasetMetadataLIB Library,,include add,get,verify.
/// @notice This library provides functions for managing metadata of datasets.
library DatasetMetadataLIB {
    using DatasetStateMachineLIB for DatasetType.Dataset;

    /// @notice Checks if metadata fields are valid.
    /// @param _title Title of the dataset.
    /// @param _industry Industry category of the dataset.
    /// @param _name Name of the dataset.
    /// @param _description Description of the dataset.
    /// @param _source Source of the dataset.
    /// @param _accessMethod Method of accessing the dataset (e.g., URL, API).
    /// @param _sizeInBytes Size of the dataset in bytes.
    function _requireValidDatasetMetadata(
        string memory _title,
        string memory _industry,
        string memory _name,
        string memory _description,
        string memory _source,
        string memory _accessMethod,
        uint256 _sizeInBytes
    ) private pure {
        require(
            bytes(_title).length > 0 &&
                bytes(_industry).length > 0 &&
                bytes(_name).length > 0 &&
                bytes(_description).length > 0 &&
                bytes(_source).length > 0 &&
                bytes(_accessMethod).length > 0 &&
                _sizeInBytes > 0,
            "All fields must be non-empty and size must be greater than 0"
        );
    }

    /// @notice Submits metadata for a dataset.
    /// @dev This function allows submitting metadata for a dataset if it hasn't been submitted before.
    /// @param self The metadata object to store the metadata details.
    /// @param _title Title of the dataset.
    /// @param _industry Industry category of the dataset.
    /// @param _name Name of the dataset.
    /// @param _description Description of the dataset.
    /// @param _source Source of the dataset.
    /// @param _accessMethod Method of accessing the dataset (e.g., URL, API).
    /// @param _sizeInBytes Size of the dataset in bytes.
    /// @param _isPublic Boolean indicating if the dataset is public.
    /// @param _version Version number of the dataset.
    function submitDatasetMetadata(
        DatasetType.Dataset storage self,
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
        _requireValidDatasetMetadata(
            _title,
            _industry,
            _name,
            _description,
            _source,
            _accessMethod,
            _sizeInBytes
        );

        self.metadata.title = _title;
        self.metadata.industry = _industry;
        self.metadata.name = _name;
        self.metadata.description = _description;
        self.metadata.source = _source;
        self.metadata.accessMethod = _accessMethod;
        self.metadata.submitter = msg.sender;
        self.metadata.createdBlockNumber = uint64(block.number);
        self.metadata.sizeInBytes = _sizeInBytes;
        self.metadata.isPublic = _isPublic;
        self.metadata.version = _version;

        self._emitDatasetEvent(DatasetType.Event.SubmitMetadata);
    }

    /// @notice Gets the submitted metadata for a dataset.
    /// @dev This function requires that metadata has been submitted before.
    /// @param self The metadata object to retrieve the metadata details from.
    function getDatasetMetadata(
        DatasetType.Dataset storage self
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
        require(
            bytes(self.metadata.title).length > 0,
            "Metadata does not exist"
        );

        DatasetType.Metadata memory metadata = self.metadata;
        return (
            metadata.title,
            metadata.industry,
            metadata.name,
            metadata.description,
            metadata.source,
            metadata.accessMethod,
            metadata.submitter,
            metadata.createdBlockNumber,
            metadata.sizeInBytes,
            metadata.isPublic,
            metadata.version
        );
    }

    /// @notice Checks if an access method for a dataset has been submitted.
    /// @param self The metadata object to check.
    /// @param _accessMethod The access method to check.
    /// @return True if the access method exists, false otherwise.
    function hasDatasetMetadata(
        DatasetType.Dataset storage self,
        string memory _accessMethod
    ) public view returns (bool) {
        return
            keccak256(bytes(self.metadata.accessMethod)) ==
            keccak256(bytes(_accessMethod));
    }
}
