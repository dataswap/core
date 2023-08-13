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

import "../../../types/DatasetType.sol";
import "./DatasetStateMachineLIB.sol";

/// @title Dataset Library
/// @notice This library provides functions to manage datasets and their metadata, proofs, and verifications.
/// @dev This library is intended to be used in conjunction with the Dataset contract.
///       Note: only called by governance contract
library DatasetAuditLIB {
    using DatasetStateMachineLIB for DatasetType.Dataset;

    /// @notice Approve the metadata of a dataset.
    /// @dev This function changes the state of the dataset to MetadataApproved and emits the MetadataApproved event.
    /// @param self The dataset for which metadata is being approved.
    function approveDatasetMetadata(DatasetType.Dataset storage self) external {
        require(
            self.state == DatasetType.State.MetadataSubmitted,
            "Invalid state for approval metadata"
        );
        self._emitDatasetEvent(DatasetType.Event.MetadataApproved);
    }

    /// @notice Reject the metadata of a dataset.
    /// @dev This function changes the state of the dataset to MetadataRejected and emits the MetadataRejected event.
    /// @param self The dataset for which metadata is being rejected.
    function rejectDatasetMetadata(DatasetType.Dataset storage self) external {
        require(
            self.state == DatasetType.State.MetadataSubmitted,
            "Invalid state for rejection metadata"
        );
        self._emitDatasetEvent(DatasetType.Event.MetadataRejected);
    }

    /// @notice Approve a dataset.
    /// @dev This function changes the state of the dataset to DatasetApproved and emits the DatasetApproved event.
    /// @param self The dataset to be approved.
    function approveDataset(DatasetType.Dataset storage self) external {
        require(
            self.state == DatasetType.State.DatasetProofSubmitted,
            "Invalid state for approval dataset"
        );
        self._emitDatasetEvent(DatasetType.Event.DatasetApproved);
    }

    /// @notice Reject a dataset.
    /// @dev This function changes the state of the dataset to MetadataApproved and emits the DatasetRejected event.
    /// @param self The dataset to be rejected.
    function rejectDataset(DatasetType.Dataset storage self) external {
        require(
            self.state == DatasetType.State.DatasetProofSubmitted,
            "Invalid state for rejection dataset"
        );
        self._emitDatasetEvent(DatasetType.Event.DatasetRejected);
    }
}
