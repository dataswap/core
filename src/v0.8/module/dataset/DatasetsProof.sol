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
import {IFilplus} from "src/v0.8/interfaces/core/IFilplus.sol";
import {ICarstore} from "src/v0.8/interfaces/core/ICarstore.sol";
import {IDatasets} from "src/v0.8/interfaces/module/IDatasets.sol";
import {IDatasetsRequirement} from "src/v0.8/interfaces/module/IDatasetsRequirement.sol";
import {IDatasetsProof} from "src/v0.8/interfaces/module/IDatasetsProof.sol";

///shared
import {DatasetsEvents} from "src/v0.8/shared/events/DatasetsEvents.sol";
import {DatasetsModifiers} from "src/v0.8/shared/modifiers/DatasetsModifiers.sol";
import {DatasetsProofModifiers} from "src/v0.8/shared/modifiers/DatasetsModifiers.sol";
/// library
import {DatasetProofLIB} from "src/v0.8/module/dataset/library/proof/DatasetProofLIB.sol";

/// type
import {RolesType} from "src/v0.8/types/RolesType.sol";
import {DatasetType} from "src/v0.8/types/DatasetType.sol";
import {GeolocationType} from "src/v0.8/types/GeolocationType.sol";

import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {UUPSUpgradeable} from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

/// @title DatasetsProof Contract
/// @notice This contract serves as the base for managing datasetProof.
/// @dev This contract is intended to be inherited by specific dataset-related contracts.
contract DatasetsProof is
    Initializable,
    UUPSUpgradeable,
    IDatasetsProof,
    DatasetsModifiers,
    DatasetsProofModifiers
{
    using DatasetProofLIB for DatasetType.DatasetProof;

    mapping(uint64 => DatasetType.DatasetProof) private datasetProofs; // Mapping of dataset ID to dataset details

    address public governanceAddress;
    IRoles public roles;
    IFilplus private filplus;
    ICarstore private carstore;
    IDatasets private datasets;
    IDatasetsRequirement private datasetsRequirement;

    /// @dev This empty reserved space is put in place to allow future versions to add new
    uint256[32] private __gap;

    /// @notice initialize function to initialize the contract and grant the default admin role to the deployer.
    function initialize(
        address _governanceAddress,
        address _roles,
        address _filplus,
        address _filecoin,
        address _carstore,
        address _datasets,
        address _datasetsRequirement
    ) public initializer {
        DatasetsModifiers.datasetsModifiersInitialize(
            _roles,
            _filplus,
            _filecoin,
            _carstore,
            _datasets
        );

        DatasetsProofModifiers.datasetsProofModifiersInitialize(
            _roles,
            _filplus,
            _filecoin,
            _carstore,
            address(this)
        );
        governanceAddress = _governanceAddress;
        roles = IRoles(_roles);
        filplus = IFilplus(_filplus);
        carstore = ICarstore(_carstore);
        datasets = IDatasets(_datasets);
        datasetsRequirement = IDatasetsRequirement(_datasetsRequirement);

        __UUPSUpgradeable_init();
    }

    /// @notice UUPS Upgradeable function to update the roles implementation
    /// @dev Only triggered by contract admin
    function _authorizeUpgrade(
        address newImplementation
    )
        internal
        override
        onlyRole(RolesType.DEFAULT_ADMIN_ROLE) // solhint-disable-next-line
    {}

    /// @notice Returns the implementation contract
    function getImplementation() external view returns (address) {
        return _getImplementation();
    }

    ///@notice Submit proof root for a dataset
    ///@dev Submit the rootHash of the dataset, the mappingFilesAccessMethod,
    /// and confirm that the sender is the submitter of the dataset.
    function submitDatasetProofRoot(
        uint64 _datasetId,
        DatasetType.DataType _dataType,
        string calldata _mappingFilesAccessMethod,
        bytes32 _rootHash
    )
        external
        onlyDatasetProofSubmitterOrSubmitterNotExsits(_datasetId, msg.sender)
        onlyDatasetState(_datasetId, DatasetType.State.MetadataApproved)
    {
        //Note: params check in lib
        DatasetType.DatasetProof storage datasetProof = datasetProofs[
            _datasetId
        ];
        if (_dataType == DatasetType.DataType.MappingFiles) {
            if (bytes(datasetProof.mappingFilesAccessMethod).length == 0) {
                datasetProof
                    .mappingFilesAccessMethod = _mappingFilesAccessMethod;
            }
        }
        // If the Dataset proof has not been submitted before,
        // then set the current sender as the submitter.
        if (
            datasetProof.getDatasetCount(DatasetType.DataType.Source) == 0 &&
            datasetProof.getDatasetCount(DatasetType.DataType.MappingFiles) == 0
        ) {
            datasetProof.proofSubmitter = msg.sender;
        }
        require(
            datasetProof.isDatasetSubmitter(msg.sender),
            "Invalid Dataset submitter"
        );
        datasetProof.addDatasetProofRoot(_dataType, _rootHash);
    }

    ///@notice Submit proof for a dataset
    ///@dev Submit the proof of the dataset in batches,
    /// specifically by submitting the _leafHashes in the order of _leafIndexes.
    function submitDatasetProof(
        uint64 _datasetId,
        DatasetType.DataType _dataType,
        bytes32[] memory _leafHashes,
        uint64[] memory _leafIndexs,
        uint64[] memory _leafSizes,
        bool _completed
    )
        external
        onlyDatasetState(_datasetId, DatasetType.State.MetadataApproved)
    {
        //Note: params check in lib
        DatasetType.DatasetProof storage datasetProof = datasetProofs[
            _datasetId
        ];

        // Checking if the current sender is the submitter.
        require(
            datasetProof.isDatasetSubmitter(msg.sender),
            "Invalid Dataset submitter"
        );

        carstore.addCars(
            _leafHashes,
            _datasetId,
            _leafSizes,
            datasetsRequirement.getDatasetReplicasCount(_datasetId)
        );

        datasetProof.addDatasetProofBatch(
            _dataType,
            _leafHashes,
            _leafIndexs,
            _leafSizes,
            _completed
        );

        if (
            datasetProof.sourceProof.allCompleted &&
            datasetProof.mappingFilesProof.allCompleted
        ) {
            require(
                filplus.isCompliantRuleMaxProportionOfMappingFilesToDataset(
                    datasetProof.getDatasetSize(
                        DatasetType.DataType.MappingFiles
                    ),
                    datasetProof.getDatasetSize(DatasetType.DataType.Source)
                ),
                "Invalid mappingFiles percentage"
            );
            datasets.reportDatasetProofSubmitted(_datasetId);
            emit DatasetsEvents.DatasetProofSubmitted(_datasetId, msg.sender);
        }
    }

    ///@notice Get dataset source CIDs
    function getDatasetProof(
        uint64 _datasetId,
        DatasetType.DataType _dataType,
        uint64 _index,
        uint64 _len
    ) public view onlyNotZero(_datasetId) returns (bytes32[] memory) {
        DatasetType.DatasetProof storage datasetProof = datasetProofs[
            _datasetId
        ];
        return datasetProof.getDatasetProof(_dataType, _index, _len);
    }

    ///@notice Get dataset source CIDs
    function getDatasetCars(
        uint64 _datasetId,
        DatasetType.DataType _dataType,
        uint64 _index,
        uint64 _len
    ) public view onlyNotZero(_datasetId) returns (bytes32[] memory) {
        return getDatasetProof(_datasetId, _dataType, _index, _len);
    }

    /// @notice Get the number of leaf nodes (cars) in the dataset proofs.
    function getDatasetProofCount(
        uint64 _datasetId,
        DatasetType.DataType _dataType
    ) public view onlyNotZero(_datasetId) returns (uint64) {
        DatasetType.DatasetProof storage datasetProof = datasetProofs[
            _datasetId
        ];
        return datasetProof.getDatasetCount(_dataType);
    }

    /// @notice Get submitter of dataset's proofs
    function getDatasetProofSubmitter(
        uint64 _datasetId
    ) public view returns (address) {
        DatasetType.DatasetProof storage datasetProof = datasetProofs[
            _datasetId
        ];
        return datasetProof.getDatasetSubmitter();
    }

    ///@notice Get dataset source CIDs
    function getDatasetCarsCount(
        uint64 _datasetId,
        DatasetType.DataType _dataType
    ) public view onlyNotZero(_datasetId) returns (uint64) {
        return getDatasetProofCount(_datasetId, _dataType);
    }

    ///@notice Get dataset size
    function getDatasetSize(
        uint64 _datasetId,
        DatasetType.DataType _dataType
    ) public view onlyNotZero(_datasetId) returns (uint64) {
        DatasetType.DatasetProof storage datasetProof = datasetProofs[
            _datasetId
        ];
        return datasetProof.getDatasetSize(_dataType);
    }

    ///@notice Check if a dataset has a cid
    function isDatasetContainsCar(
        uint64 _datasetId,
        bytes32 _cid
    ) public view onlyNotZero(_datasetId) returns (bool) {
        return _datasetId == carstore.getCarDatasetId(_cid);
    }

    ///@notice Check if a dataset has cids
    function isDatasetContainsCars(
        uint64 _datasetId,
        bytes32[] memory _cids
    ) external view onlyNotZero(_datasetId) returns (bool) {
        for (uint64 i = 0; i < _cids.length; i++) {
            if (!isDatasetContainsCar(_datasetId, _cids[i])) return false;
        }
        return true;
    }

    ///@notice Check if a dataset has submitter
    function isDatasetProofSubmitter(
        uint64 _datasetId,
        address _submitter
    ) public view returns (bool) {
        DatasetType.DatasetProof storage datasetProof = datasetProofs[
            _datasetId
        ];
        return datasetProof.isDatasetSubmitter(_submitter);
    }
}
