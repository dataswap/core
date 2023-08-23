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
import {IRoles} from "src/v0.8/interfaces/core/IRoles.sol";
import {IFilplus} from "src/v0.8/interfaces/core/IFilplus.sol";
import {IFilecoin} from "src/v0.8/interfaces/core/IFilecoin.sol";
import {ICarstore} from "src/v0.8/interfaces/core/ICarstore.sol";
import {IDatasets} from "src/v0.8/interfaces/module/IDatasets.sol";
///shared
import {CarstoreModifiers} from "src/v0.8/shared/modifiers/CarstoreModifiers.sol";
import {Errors} from "src/v0.8/shared/errors/Errors.sol";

///types
import {DatasetType} from "src/v0.8/types/DatasetType.sol";

/// @title storages
/// @dev Manages the storage of matched data after successful matching with Filecoin storage deals.
contract DatasetsModifiers is CarstoreModifiers {
    IRoles private roles;
    IFilplus private filplus;
    IFilecoin private filecoin;
    ICarstore private carstore;
    IDatasets private datasets;

    // solhint-disable-next-line
    constructor(
        IRoles _roles,
        IFilplus _filplus,
        IFilecoin _filecoin,
        ICarstore _carstore,
        IDatasets _datasets
    ) CarstoreModifiers(_roles, _filplus, _filecoin, _carstore) {
        roles = _roles;
        filplus = _filplus;
        carstore = _carstore;
        datasets = _datasets;
    }

    /// @dev Modifier to ensure that a dataset metadata  with the given accessMethod exists.
    modifier onlyDatasetMetadataExsits(string memory _accessMethod) {
        if (!datasets.hasDatasetMetadata(_accessMethod)) {
            revert Errors.DatasetMetadataNotExist(_accessMethod);
        }
        _;
    }

    /// @dev Modifier to ensure that a dataset metadata with the given accessMethod not exists.
    modifier onlyDatasetMetadataNotExsits(string memory _accessMethod) {
        if (datasets.hasDatasetMetadata(_accessMethod)) {
            revert Errors.DatasetMetadataAlreadyExist(_accessMethod);
        }
        _;
    }

    modifier onlyDatasetState(uint64 _datasetId, DatasetType.State _state) {
        if (_state != datasets.getDatasetState(_datasetId)) {
            revert Errors.InvalidDatasetState(_datasetId);
        }
        _;
    }
    /// @notice The sender of the dataset proof transaction must be the submitter of the proof.
    modifier onlyDatasetProofSubmitterOrSubmitterNotExsits(
        uint64 _datasetId,
        address _sender
    ) {
        if (
            datasets.getDatasetProofCount(
                _datasetId,
                DatasetType.DataType.Source
            ) !=
            0 ||
            datasets.getDatasetProofCount(
                _datasetId,
                DatasetType.DataType.MappingFiles
            ) !=
            0
        ) {
            if (datasets.isDatasetProofSubmitter(_datasetId, _sender) != true) {
                revert Errors.InvalidDatasetProofsSubmitter(
                    _datasetId,
                    _sender
                );
            }
        }
        _;
    }
}
