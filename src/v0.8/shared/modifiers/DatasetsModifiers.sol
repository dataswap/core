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

///interface
import {IDatasets} from "src/v0.8/interfaces/module/IDatasets.sol";
import {IDatasetsProof} from "src/v0.8/interfaces/module/IDatasetsProof.sol";
///shared
import {CarstoreModifiers} from "src/v0.8/shared/modifiers/CarstoreModifiers.sol";
import {Errors} from "src/v0.8/shared/errors/Errors.sol";

///types
import {DatasetType} from "src/v0.8/types/DatasetType.sol";

/// @title storages
/// @dev Manages the storage of matched data after successful matching with Filecoin storage deals.
contract DatasetsModifiers is CarstoreModifiers {
    /// @dev Modifier to ensure that a dataset metadata  with the given accessMethod exists.
    modifier onlyDatasetMetadataExsits(
        IDatasets _datasets,
        string memory _accessMethod
    ) {
        if (!_datasets.hasDatasetMetadata(_accessMethod)) {
            revert Errors.DatasetMetadataNotExist(_accessMethod);
        }
        _;
    }

    /// @dev Modifier to ensure that a dataset metadata with the given accessMethod not exists.
    modifier onlyDatasetMetadataNotExsits(
        IDatasets _datasets,
        string memory _accessMethod
    ) {
        if (_datasets.hasDatasetMetadata(_accessMethod)) {
            revert Errors.DatasetMetadataAlreadyExist(_accessMethod);
        }
        _;
    }

    /// @dev Modifier to ensure that dataset has the special state
    modifier onlyDatasetState(
        IDatasets _datasets,
        uint64 _datasetId,
        DatasetType.State _state
    ) {
        if (_state != _datasets.getDatasetState(_datasetId)) {
            revert Errors.InvalidDatasetState(_datasetId);
        }
        _;
    }

    /// @notice The sender of the dataset proof transaction must be the submitter of the proof.
    modifier onlyDatasetProofSubmitterOrSubmitterNotExsits(
        IDatasetsProof _datasetsProof,
        uint64 _datasetId,
        address _sender
    ) {
        if (
            _datasetsProof.getDatasetProofCount(
                _datasetId,
                DatasetType.DataType.Source
            ) !=
            0 ||
            _datasetsProof.getDatasetProofCount(
                _datasetId,
                DatasetType.DataType.MappingFiles
            ) !=
            0
        ) {
            if (
                _datasetsProof.isDatasetProofSubmitter(_datasetId, _sender) !=
                true
            ) {
                revert Errors.InvalidDatasetProofsSubmitter(
                    _datasetId,
                    _sender
                );
            }
        }
        _;
    }
}
