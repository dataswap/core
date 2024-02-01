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
import {IDatasetsProof} from "src/v0.8/interfaces/module/IDatasetsProof.sol";

///shared
import {DatasetsEvents} from "src/v0.8/shared/events/DatasetsEvents.sol";
import {DatasetsModifiers} from "src/v0.8/shared/modifiers/DatasetsModifiers.sol";
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
    DatasetsModifiers
{
    using DatasetProofLIB for DatasetType.DatasetProof;

    mapping(uint64 => DatasetType.DatasetProof) private datasetProofs; // Mapping of dataset ID to dataset details

    address public governanceAddress;
    IRoles public roles;

    /// @dev This empty reserved space is put in place to allow future versions to add new
    uint256[32] private __gap;

    /// @notice initialize function to initialize the contract and grant the default admin role to the deployer.
    function initialize(
        address _governanceAddress,
        address _roles
    ) public initializer {
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
        onlyDatasetProofSubmitterOrSubmitterNotExsits(
            this,
            _datasetId,
            msg.sender
        )
        onlyDatasetState(
            roles.datasets(),
            _datasetId,
            DatasetType.State.MetadataApproved
        )
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

    ///@notice Internal submit proof for a dataset
    ///@dev Submit the proof of the dataset in batches,
    /// specifically by submitting the _leafHashes in the order of _leafIndexes.
    function _submitDatasetProof(
        uint64 _datasetId,
        DatasetType.DataType _dataType,
        bytes32[] memory _leafHashes,
        uint64 _leafIndex,
        uint64[] memory _leafSizes,
        bool _completed
    )
        internal
        onlyDatasetState(
            roles.datasets(),
            _datasetId,
            DatasetType.State.MetadataApproved
        )
    {
        DatasetType.DatasetProof storage datasetProof = datasetProofs[
            _datasetId
        ];

        // Checking if the current sender is the submitter.
        require(
            datasetProof.isDatasetSubmitter(msg.sender),
            "Invalid Dataset submitter"
        );

        uint16 replicaCount = roles
            .datasetsRequirement()
            .getDatasetReplicasCount(_datasetId);

        (uint64[] memory leafIds, uint64 size) = roles.carstore().__addCars(
            _leafHashes,
            _datasetId,
            _leafSizes,
            replicaCount
        );

        datasetProof.addDatasetProofBatch(
            _dataType,
            leafIds,
            _leafIndex,
            size,
            _completed
        );
    }

    ///@notice Submit proof completed for a dataset
    function submitDatasetProofCompleted(
        uint64 _datasetId
    ) public returns (DatasetType.State state) {
        //Note: params check in lib
        DatasetType.DatasetProof storage datasetProof = datasetProofs[
            _datasetId
        ];
        if (
            datasetProof.sourceProof.allCompleted &&
            datasetProof.mappingFilesProof.allCompleted
        ) {
            require(
                roles
                    .filplus()
                    .isCompliantRuleMaxProportionOfMappingFilesToDataset(
                        datasetProof.getDatasetSize(
                            DatasetType.DataType.MappingFiles
                        ),
                        datasetProof.getDatasetSize(DatasetType.DataType.Source)
                    ),
                "Invalid mappingFiles percentage"
            );

            roles.datasets().__reportDatasetProofSubmitted(_datasetId);
            emit DatasetsEvents.DatasetProofSubmitted(_datasetId, msg.sender);

            return DatasetType.State.DatasetProofSubmitted;
        }
    }

    ///@notice Submit proof for a dataset
    ///@dev Submit the proof of the dataset in batches,
    /// specifically by submitting the _leafHashes in the order of _leafIndexes.
    function submitDatasetProof(
        uint64 _datasetId,
        DatasetType.DataType _dataType,
        bytes32[] memory _leafHashes,
        uint64 _leafIndex,
        uint64[] memory _leafSizes,
        bool _completed
    ) external {
        _submitDatasetProof(
            _datasetId,
            _dataType,
            _leafHashes,
            _leafIndex,
            _leafSizes,
            _completed
        );

        if (_completed) {
            submitDatasetProofCompleted(_datasetId);
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
        return
            roles.carstore().getCarsHashs(
                datasetProof.getDatasetProof(_dataType, _index, _len)
            );
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

    ///@notice Check if a dataset proof all completed
    function isDatasetProofallCompleted(
        uint64 _datasetId,
        DatasetType.DataType _dataType
    ) public view onlyNotZero(_datasetId) returns (bool) {
        DatasetType.DatasetProof storage datasetProof = datasetProofs[
            _datasetId
        ];
        return datasetProof.isDatasetProofallCompleted(_dataType);
    }

    ///@notice Check if a dataset has a cid
    function isDatasetContainsCar(
        uint64 _datasetId,
        uint64 _id
    ) public view onlyNotZero(_datasetId) returns (bool) {
        return _datasetId == roles.carstore().getCarDatasetId(_id);
    }

    ///@notice Check if a dataset has cids
    function isDatasetContainsCars(
        uint64 _datasetId,
        uint64[] memory _ids
    ) external view onlyNotZero(_datasetId) returns (bool) {
        for (uint64 i = 0; i < _ids.length; i++) {
            if (!isDatasetContainsCar(_datasetId, _ids[i])) return false;
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
