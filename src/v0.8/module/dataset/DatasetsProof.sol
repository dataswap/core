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
import {ArrayUint64LIB} from "src/v0.8/shared/utils/array/ArrayLIB.sol";
/// type
import {RolesType} from "src/v0.8/types/RolesType.sol";
import {DatasetType} from "src/v0.8/types/DatasetType.sol";
import {FinanceType} from "src/v0.8/types/FinanceType.sol";
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
    using ArrayUint64LIB for uint64[];

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
            DatasetType.State.RequirementSubmitted
        )
    {
        if (isDatasetProofTimeout(_datasetId)) {
            roles.datasets().__reportDatasetWorkflowTimeout(_datasetId);
            return;
        }
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

    /// @notice Submits data to the carstore along with corresponding hashes.
    /// @dev This internal function submits data along with their corresponding leaf hashes to the carstore, associated with a specific dataset.
    /// @param _leafHashes An array containing the hashes of the data leaves.
    /// @param _datasetId The ID of the dataset to which the data belongs.
    /// @param _leafSizes An array containing the sizes of the data leaves.
    /// @return leafIds An array containing the IDs of the submitted data leaves.
    /// @return size The total size of the submitted data.
    /// @return unpadSize The total size of the submitted cars.
    function _submitToCarstoreWithHashs(
        bytes32[] memory _leafHashes,
        uint64 _datasetId,
        uint64[] memory _leafSizes
    )
        internal
        returns (uint64[] memory leafIds, uint64 size, uint64 unpadSize)
    {
        require(
            _leafHashes.length == _leafSizes.length,
            "invalid leaves params"
        );

        uint16 replicaCount = roles
            .datasetsRequirement()
            .getDatasetReplicasCount(_datasetId);

        leafIds = new uint64[](_leafHashes.length);

        for (uint64 i; i < _leafHashes.length; i++) {
            if (!roles.carstore().hasCarHash(_leafHashes[i])) {
                leafIds[i] = roles.carstore().__addCar(
                    _leafHashes[i],
                    _datasetId,
                    _leafSizes[i],
                    replicaCount
                );
            } else {
                leafIds[i] = roles.carstore().getCarId(_leafHashes[i]);
                roles.carstore().__updateCar(
                    leafIds[i],
                    _datasetId,
                    replicaCount
                );
            }
        }
        size = roles.carstore().getPiecesSize(leafIds);
        unpadSize = roles.carstore().getCarsSize(leafIds);
        return (leafIds, size, unpadSize);
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
    ) internal {
        DatasetType.DatasetProof storage datasetProof = datasetProofs[
            _datasetId
        ];

        // Checking if the current sender is the submitter.
        require(
            datasetProof.isDatasetSubmitter(msg.sender),
            "Invalid Dataset submitter"
        );

        (
            uint64[] memory leafIds,
            uint64 size,
            uint64 unpadSize
        ) = _submitToCarstoreWithHashs(_leafHashes, _datasetId, _leafSizes);

        roles.datasets().__reportDatasetProofSubmitted(size);

        datasetProof.addDatasetProofBatch(
            _dataType,
            leafIds,
            _leafIndex,
            size,
            unpadSize,
            _completed
        );
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
    )
        external
        onlyDatasetState(
            roles.datasets(),
            _datasetId,
            DatasetType.State.RequirementSubmitted
        )
    {
        if (isDatasetProofTimeout(_datasetId)) {
            roles.datasets().__reportDatasetWorkflowTimeout(_datasetId);
            return;
        }

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

    /// @notice Submits data to the carstore along with car IDs.
    /// @dev This internal function is responsible for submitting data to the carstore along with the IDs of associated cars.
    /// @param _leavesStarts An array containing the start values for each leaf range.
    /// @param _leavesEnds An array containing the end values for each leaf range.
    /// @param _datasetId The ID of the dataset associated with the data.
    /// @return leafIds An array containing the IDs of the submitted data leaves.
    /// @return size The total size of the submitted data.
    /// @return unpadSize The total size of the submitted cars.
    function _submitToCarstoreWithCarIds(
        uint64[] memory _leavesStarts,
        uint64[] memory _leavesEnds,
        uint64 _datasetId
    )
        internal
        returns (uint64[] memory leafIds, uint64 size, uint64 unpadSize)
    {
        require(
            _leavesStarts.length == _leavesEnds.length,
            "invalid leaves params"
        );

        uint16 replicaCount = roles
            .datasetsRequirement()
            .getDatasetReplicasCount(_datasetId);

        leafIds = _leavesStarts.mergeSequentialArray(_leavesEnds);

        for (uint64 i; i < leafIds.length; i++) {
            if (roles.carstore().hasCar(leafIds[i])) {
                roles.carstore().__updateCar(
                    leafIds[i],
                    _datasetId,
                    replicaCount
                );
            }
        }
        size = roles.carstore().getPiecesSize(leafIds);
        unpadSize = roles.carstore().getCarsSize(leafIds);
        return (leafIds, size, unpadSize);
    }

    /// @notice Submits dataset proof along with car IDs.
    /// @dev This internal function is responsible for submitting dataset proof along with the IDs of associated cars.
    /// @param _datasetId The ID of the dataset.
    /// @param _dataType The type of data.
    /// @param _leavesStarts An array containing the start values for each leaf range.
    /// @param _leavesEnds An array containing the end values for each leaf range.
    /// @param _leafIndex The index of the leaf.
    /// @param _completed A boolean flag indicating whether the proof is complete.
    function _submitDatasetProofWithCarIds(
        uint64 _datasetId,
        DatasetType.DataType _dataType,
        uint64[] memory _leavesStarts,
        uint64[] memory _leavesEnds,
        uint64 _leafIndex,
        bool _completed
    ) internal {
        DatasetType.DatasetProof storage datasetProof = datasetProofs[
            _datasetId
        ];

        // Checking if the current sender is the submitter.
        require(
            datasetProof.isDatasetSubmitter(msg.sender),
            "Invalid Dataset submitter"
        );

        (
            uint64[] memory leafIds,
            uint64 size,
            uint64 unpadSize
        ) = _submitToCarstoreWithCarIds(_leavesStarts, _leavesEnds, _datasetId);

        roles.datasets().__reportDatasetProofSubmitted(size);

        datasetProof.addDatasetProofBatch(
            _dataType,
            leafIds,
            _leafIndex,
            size,
            unpadSize,
            _completed
        );
    }

    /// @notice Submits dataset proof with specified IDs.
    /// @param _datasetId The ID of the dataset.
    /// @param _dataType The data type of the dataset.
    /// @param _leavesStarts The starting indices of leaves in the Merkle tree.
    /// @param _leavesEnds The ending indices of leaves in the Merkle tree.
    /// @param _leafIndex The index of the leaf to submit proof for.
    /// @param _completed Indicates whether the proof submission is complete.
    function submitDatasetProofWithCarIds(
        uint64 _datasetId,
        DatasetType.DataType _dataType,
        uint64[] memory _leavesStarts,
        uint64[] memory _leavesEnds,
        uint64 _leafIndex,
        bool _completed
    )
        external
        onlyDatasetState(
            roles.datasets(),
            _datasetId,
            DatasetType.State.RequirementSubmitted
        )
    {
        if (isDatasetProofTimeout(_datasetId)) {
            roles.datasets().__reportDatasetWorkflowTimeout(_datasetId);
            return;
        }

        _submitDatasetProofWithCarIds(
            _datasetId,
            _dataType,
            _leavesStarts,
            _leavesEnds,
            _leafIndex,
            _completed
        );

        if (_completed) {
            submitDatasetProofCompleted(_datasetId);
        }
    }

    ///@notice _isEscrowEnough
    /// 1. Is EscrowDatacapCollateral escrow enough?
    /// 2. Is EscrowChallengeCommission escrow enough?
    function _isEscrowEnough(
        uint64 _datasetId,
        address _owner
    ) internal view onlyNotZero(_datasetId) returns (bool) {
        if (
            roles.finance().isEscrowEnough(
                _datasetId,
                0,
                _owner,
                FinanceType.FIL,
                FinanceType.Type.EscrowDatacapCollateral
            ) &&
            roles.finance().isEscrowEnough(
                _datasetId,
                0,
                _owner,
                FinanceType.FIL,
                FinanceType.Type.EscrowChallengeCommission
            )
        ) {
            return true;
        } else {
            return false;
        }
    }

    ///@notice Submit proof completed for a dataset
    function submitDatasetProofCompleted(
        uint64 _datasetId
    )
        public
        onlyDatasetState(
            roles.datasets(),
            _datasetId,
            DatasetType.State.RequirementSubmitted
        )
        returns (DatasetType.State state)
    {
        if (isDatasetProofTimeout(_datasetId)) {
            roles.datasets().__reportDatasetWorkflowTimeout(_datasetId);
            return roles.datasets().getDatasetState(_datasetId);
        }
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

            if (
                _isEscrowEnough(
                    _datasetId,
                    roles.datasets().getDatasetMetadataSubmitter(_datasetId)
                )
            ) {
                roles.datasets().__reportDatasetProofCompleted(_datasetId);
                datasetProof.completedHeight = uint64(block.number);
                emit DatasetsEvents.DatasetProofSubmitted(
                    _datasetId,
                    msg.sender
                );
                return DatasetType.State.ProofSubmitted;
            } else {
                roles.datasets().__reportDatasetInsufficientEscrowFunds(
                    _datasetId
                );
                emit DatasetsEvents.InsufficientEscrowFunds(
                    _datasetId,
                    msg.sender
                );
                return DatasetType.State.WaitEscrow;
            }
        }
    }

    /// @notice Completes the escrow process for a specific dataset.
    /// @param _datasetId The ID of the dataset to complete the escrow for.
    function completeEscrow(
        uint64 _datasetId
    )
        external
        onlyAddress(roles.datasets().getDatasetMetadataSubmitter(_datasetId))
        onlyDatasetState(
            roles.datasets(),
            _datasetId,
            DatasetType.State.WaitEscrow
        )
    {
        if (isDatasetProofTimeout(_datasetId)) {
            roles.datasets().__reportDatasetWorkflowTimeout(_datasetId);
            return;
        }
        uint256 amount = roles.finance().getEscrowRequirement(
            _datasetId,
            0,
            msg.sender,
            FinanceType.FIL,
            FinanceType.Type.EscrowDatacapCollateral
        );
        roles.finance().__escrow(
            _datasetId,
            0,
            msg.sender,
            FinanceType.FIL,
            FinanceType.Type.EscrowDatacapCollateral,
            amount
        );

        amount = roles.finance().getEscrowRequirement(
            _datasetId,
            0,
            msg.sender,
            FinanceType.FIL,
            FinanceType.Type.EscrowChallengeCommission
        );
        roles.finance().__escrow(
            _datasetId,
            0,
            msg.sender,
            FinanceType.FIL,
            FinanceType.Type.EscrowChallengeCommission,
            amount
        );

        roles.datasets().__reportDatasetEscrowCompleted(_datasetId);
        emit DatasetsEvents.EscrowCompleted(_datasetId, msg.sender);
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

    ///@notice Get dataset unpad size
    function getDatasetUnpadSize(
        uint64 _datasetId,
        DatasetType.DataType _dataType
    ) public view onlyNotZero(_datasetId) returns (uint64) {
        DatasetType.DatasetProof storage datasetProof = datasetProofs[
            _datasetId
        ];
        return datasetProof.getDatasetUnpadSize(_dataType);
    }

    /// @notice Retrieves the height at which the dataset proof is considered complete.
    /// @dev This function returns the height at which the dataset proof is considered complete for the given dataset ID.
    /// @param _datasetId The ID of the dataset.
    /// @return The height at which the dataset proof is considered complete.
    function getDatasetProofCompleteHeight(
        uint64 _datasetId
    ) external view onlyNotZero(_datasetId) returns (uint64) {
        DatasetType.DatasetProof storage datasetProof = datasetProofs[
            _datasetId
        ];
        return datasetProof.completedHeight;
    }

    /// @notice Retrieves the Merkle root hash of the dataset for the specified dataset ID and data type.
    /// @param _datasetId The ID of the dataset for which to retrieve the Merkle root hash.
    /// @param _dataType The type of data for which to retrieve the Merkle root hash.
    /// @return rootHash The Merkle root hash of the dataset.
    function getDatasetProofRootHash(
        uint64 _datasetId,
        DatasetType.DataType _dataType
    ) external view onlyNotZero(_datasetId) returns (bytes32 rootHash) {
        DatasetType.DatasetProof storage datasetProof = datasetProofs[
            _datasetId
        ];
        rootHash = datasetProof.getDatasetRootHash(_dataType);
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

    /// @notice Checks if the associated dataset contains a specific car.
    /// @dev This function verifies if the given dataset contains the specified car by checking if the car's ID is associated with the dataset.
    /// @param _datasetId The ID of the dataset to check.
    /// @param _carId The ID of the car to search for.
    /// @return True if the associated dataset contains the car, false otherwise.
    function isAssociatedDatasetContainsCar(
        uint64 _datasetId,
        uint64 _carId
    ) public view returns (bool) {
        uint64 associatedDatasetId = roles.datasets().getAssociatedDatasetId(
            _datasetId
        );
        if (associatedDatasetId != 0) {
            if (isDatasetContainsCar(associatedDatasetId, _carId)) {
                return true;
            } else {
                return
                    isAssociatedDatasetContainsCar(associatedDatasetId, _carId);
            }
        }
        return false;
    }

    /// @notice Checks if the dataset proof has timed out.
    /// @dev This function determines if the dataset proof for the given dataset ID has timed out.
    /// @param _datasetId The ID of the dataset.
    /// @return True if the dataset proof has timed out, false otherwise.
    function isDatasetProofTimeout(
        uint64 _datasetId
    ) public view returns (bool) {
        DatasetType.State state = roles.datasets().getDatasetState(_datasetId);
        if (
            state != DatasetType.State.WaitEscrow &&
            state != DatasetType.State.RequirementSubmitted
        ) {
            return false;
        }
        uint64 completedHeight = roles
            .datasetsRequirement()
            .getDatasetRequirementCompleteHeight(_datasetId);

        (uint64 proofBlockCount, ) = roles
            .datasets()
            .getDatasetTimeoutParameters(_datasetId);

        if (uint64(block.number) >= completedHeight + proofBlockCount) {
            return true;
        }
        return false;
    }
}
