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

// Importing Solidity libraries and contracts
import {DSTest} from "ds-test/test.sol";
import {Test} from "forge-std/Test.sol";
import {DatasetType} from "src/v0.8/types/DatasetType.sol";
import {ICarstore} from "src/v0.8/interfaces/core/ICarstore.sol";
import {IDatasets} from "src/v0.8/interfaces/module/IDatasets.sol";
import {IDatasetsRequirement} from "src/v0.8/interfaces/module/IDatasetsRequirement.sol";
import {IDatasetsProof} from "src/v0.8/interfaces/module/IDatasetsProof.sol";
import {IDatasetsChallenge} from "src/v0.8/interfaces/module/IDatasetsChallenge.sol";
import {IDatasetsAssertion} from "test/v0.8/interfaces/assertions/module/IDatasetsAssertion.sol";

/// @notice This contract defines assertion functions for testing an IDatasets contract.
/// @dev NOTE: All methods that do not change the state must be tested by methods that will change the state to ensure test coverage.
contract DatasetsAssertion is DSTest, Test, IDatasetsAssertion {
    ICarstore public carstore;
    IDatasets public datasets;
    IDatasetsRequirement public datasetsRequirement;
    IDatasetsProof public datasetsProof;
    IDatasetsChallenge public datasetsChallenge;

    /// @notice Constructor that sets the address of the IDatasets contract.
    /// @param _datasets The address of the IDatasets contract.
    constructor(
        ICarstore _carstore,
        IDatasets _datasets,
        IDatasetsRequirement _datasetsRequirement,
        IDatasetsProof _datasetsProof,
        IDatasetsChallenge _datasetsChallenge
    ) {
        carstore = _carstore;
        datasets = _datasets;
        datasetsRequirement = _datasetsRequirement;
        datasetsProof = _datasetsProof;
        datasetsChallenge = _datasetsChallenge;
    }

    /// @notice Assertion function for approving a dataset.
    /// @param caller The address of the caller.
    /// @param _datasetId The ID of the dataset to approve.
    function approveDatasetAssertion(
        address caller,
        uint64 _datasetId
    ) external {
        // Before the action, check the initial dataset state.
        getDatasetStateAssertion(
            _datasetId,
            DatasetType.State.DatasetProofSubmitted
        );

        // Check verification count, Judgment strategy depends on actual needs
        getDatasetChallengeProofsCountAssertion(_datasetId, 1);

        // Perform the action.
        vm.prank(caller);
        datasets.approveDataset(_datasetId);

        // After the action, check the updated dataset state.
        getDatasetStateAssertion(_datasetId, DatasetType.State.DatasetApproved);
    }

    /// @notice Assertion function for approving dataset metadata.
    /// @param caller The address of the caller.
    /// @param _datasetId The ID of the dataset for which to approve metadata.
    function approveDatasetMetadataAssertion(
        address caller,
        uint64 _datasetId
    ) external {
        // Before the action, check the initial dataset state.
        getDatasetStateAssertion(
            _datasetId,
            DatasetType.State.MetadataSubmitted
        );

        // Perform the action.
        vm.prank(caller);
        datasets.approveDatasetMetadata(_datasetId);

        // After the action, check the updated dataset state.
        getDatasetStateAssertion(
            _datasetId,
            DatasetType.State.MetadataApproved
        );
    }

    /// @notice Assertion function for rejecting a dataset.
    /// @param caller The address of the caller.
    /// @param _datasetId The ID of the dataset to reject.
    function rejectDatasetAssertion(
        address caller,
        uint64 _datasetId
    ) external {
        // Before the action, check the initial dataset state.
        getDatasetStateAssertion(
            _datasetId,
            DatasetType.State.DatasetProofSubmitted
        );

        // Perform the action.
        vm.prank(caller);
        datasets.rejectDataset(_datasetId);

        // After the action, check the updated dataset state.
        getDatasetStateAssertion(
            _datasetId,
            DatasetType.State.MetadataApproved
        );
    }

    /// @notice Assertion function for rejecting dataset metadata.
    /// @param caller The address of the caller.
    /// @param _datasetId The ID of the dataset for which to reject metadata.
    function rejectDatasetMetadataAssertion(
        address caller,
        uint64 _datasetId
    ) external {
        // Before the action, check the initial dataset state.
        getDatasetStateAssertion(
            _datasetId,
            DatasetType.State.MetadataSubmitted
        );

        // Perform the action.
        vm.prank(caller);
        datasets.rejectDatasetMetadata(_datasetId);

        // After the action, check the updated dataset state.
        getDatasetStateAssertion(
            _datasetId,
            DatasetType.State.MetadataRejected
        );
    }

    /// @notice Assertion function for submitting dataset metadata.
    /// @param caller The address of the caller.
    /// @param _title The title of the dataset.
    /// @param _industry The industry of the dataset.
    /// @param _name The name of the dataset.
    /// @param _description The description of the dataset.
    /// @param _source The source of the dataset.
    /// @param _accessMethod The access method of the dataset.
    /// @param _sizeInBytes The size of the dataset in bytes.
    /// @param _isPublic A boolean indicating if the dataset is public.
    /// @param _version The version of the dataset.
    function submitDatasetMetadataAssertion(
        address caller,
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
        // Before the action, capture the initial state.
        uint64 oldDatasetsCount = datasets.datasetsCount();
        getDatasetStateAssertion(oldDatasetsCount + 1, DatasetType.State.None);
        hasDatasetMetadataAssertion(_accessMethod, false);

        // Perform the action.
        vm.prank(caller);
        vm.deal(caller, 10 ether);
        datasets.submitDatasetMetadata(
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

        // After the action, check the updated state.
        hasDatasetMetadataAssertion(_accessMethod, true);
        uint64 newDatasetsCount = datasets.datasetsCount();

        datasetsCountAssertion(oldDatasetsCount + 1);
        getDatasetMetadataAssertion(
            newDatasetsCount,
            _accessMethod,
            address(caller),
            uint64(block.number)
        );
        getDatasetMetadataSubmitterAssertion(newDatasetsCount, address(caller));
    }

    /// @notice Assertion function for submitting dataset replica requirement.
    /// @param caller The address of the caller.
    /// @param _datasetId The ID of the dataset for which proof is submitted.
    /// @param _dataPreparers The client specified data preparer, which the client can either specify or not, but the parameter cannot be empty.
    /// @param _storageProviders The client specified storage provider, which the client can either specify or not, but the parameter cannot be empty.
    /// @param _regions The region specified by the client, and the client must specify a region for the replicas.
    /// @param _countrys The country specified by the client, and the client must specify a country for the replicas.
    /// @param _citys The citys specified by the client, when the country of a replica is duplicated, citys must be specified and cannot be empty.
    function submitDatasetReplicaRequirementsAssertion(
        address caller,
        uint64 _datasetId,
        address[][] memory _dataPreparers,
        address[][] memory _storageProviders,
        uint16[] memory _regions,
        uint16[] memory _countrys,
        uint32[][] memory _citys
    ) external {
        // Perform the action.
        vm.prank(caller);
        datasetsRequirement.submitDatasetReplicaRequirements(
            _datasetId,
            _dataPreparers,
            _storageProviders,
            _regions,
            _countrys,
            _citys,
            0
        );
        getDatasetStateAssertion(
            _datasetId,
            DatasetType.State.MetadataSubmitted
        );

        getDatasetReplicasCountAssertion(_datasetId, uint16(_regions.length));

        for (uint64 i = 0; i < _regions.length; i++) {
            getDatasetReplicaRequirementAssertion(
                _datasetId,
                i,
                _dataPreparers[i],
                _storageProviders[i],
                _regions[i],
                _countrys[i],
                _citys[i]
            );
        }
    }

    /// @notice Assertion function for submitting dataset proof root.
    /// @param caller The address of the caller.
    /// @param _datasetId The ID of the dataset for which to submit proof.
    /// @param _dataType The data type of the proof.
    /// @param accessMethod The access method of the dataset.
    /// @param _rootHash The root hash of the proof.
    function submitDatasetProofRootAssertion(
        address caller,
        uint64 _datasetId,
        DatasetType.DataType _dataType,
        string calldata accessMethod,
        bytes32 _rootHash
    ) external {
        // Before the action, capture the initial state.
        getDatasetStateAssertion(
            _datasetId,
            DatasetType.State.MetadataApproved
        );

        // Perform the action.
        vm.prank(caller);
        datasetsProof.submitDatasetProofRoot(
            _datasetId,
            _dataType,
            accessMethod,
            _rootHash
        );

        isDatasetProofSubmitterAssertion(_datasetId, caller, true);
    }

    /// @notice Assertion function for submitting dataset proof.
    /// @param caller The address of the caller.
    /// @param _datasetId The ID of the dataset for which to submit proof.
    /// @param _dataType The data type of the proof.
    /// @param _leafHashes The leaf hashes of the proof.
    /// @param _leafIndex The index of leaf hashes.
    /// @param _leafSizes The sizes of the leaf hashes.
    /// @param _completed A boolean indicating if the proof is completed.
    function submitDatasetProofAssertion(
        address caller,
        uint64 _datasetId,
        DatasetType.DataType _dataType,
        bytes32[] calldata _leafHashes,
        uint64 _leafIndex,
        uint64[] calldata _leafSizes,
        bool _completed
    ) external {
        // Before the action, capture the initial state.
        getDatasetStateAssertion(
            _datasetId,
            DatasetType.State.MetadataApproved
        );
        uint64 oldProofCount = datasetsProof.getDatasetProofCount(
            _datasetId,
            _dataType
        );
        uint64 oldDatasetSize = datasetsProof.getDatasetSize(
            _datasetId,
            _dataType
        );
        uint64[] memory _leafIds = carstore.getCarsIds(_leafHashes);
        isDatasetContainsCarAssertion(_datasetId, _leafIds[0], false);
        isDatasetContainsCarsAssertion(_datasetId, _leafIds, false);

        // Perform the action.
        vm.prank(caller);
        datasetsProof.submitDatasetProof(
            _datasetId,
            _dataType,
            _leafHashes,
            _leafIndex,
            _leafSizes,
            _completed
        );

        // After the action, check the updated state.
        _afterSubmitDatasetProof(
            caller,
            _datasetId,
            _dataType,
            _leafHashes,
            _leafSizes,
            oldProofCount,
            oldDatasetSize
        );
    }

    /// @notice After the action, check the updated state.
    /// @param caller The address of the caller.
    /// @param _datasetId The ID of the dataset for which to submit proof.
    /// @param _dataType The data type of the proof.
    /// @param _leafHashes The leaf hashes of the proof.
    /// @param _leafSizes The sizes of the leaf hashes.
    /// @param _oldProofCount A boolean indicating if the proof is completed.
    /// @param _oldDatasetSize A boolean indicating if the proof is completed.
    function _afterSubmitDatasetProof(
        address caller,
        uint64 _datasetId,
        DatasetType.DataType _dataType,
        bytes32[] calldata _leafHashes,
        uint64[] calldata _leafSizes,
        uint64 _oldProofCount,
        uint64 _oldDatasetSize
    ) internal {
        // Check proof count.
        assertEq(
            datasetsProof.getDatasetProofCount(_datasetId, _dataType),
            _oldProofCount + uint64(_leafHashes.length)
        );
        // assert leves
        getDatasetProofCountAssertion(
            _datasetId,
            _dataType,
            datasetsProof.getDatasetProofCount(_datasetId, _dataType)
        );
        getDatasetCarsCountAssertion(
            _datasetId,
            _dataType,
            datasetsProof.getDatasetProofCount(_datasetId, _dataType)
        );

        getDatasetProofAssertion(
            _datasetId,
            _dataType,
            _oldProofCount,
            uint64(_leafHashes.length),
            _leafHashes
        );
        getDatasetCarsAssertion(
            _datasetId,
            _dataType,
            _oldProofCount,
            uint64(_leafHashes.length),
            _leafHashes
        );

        // Check dataset size.
        getDatasetSizeAssertion(
            _datasetId,
            _dataType,
            _getDatasetSizeWithNewProof(_oldDatasetSize, _leafSizes)
        );

        // Check dataset submitter.
        getDatasetProofSubmitterAssertion(_datasetId, caller);

        // Check if dataset contains car(s).
        uint64[] memory _leafIds = carstore.getCarsIds(_leafHashes);
        isDatasetContainsCarAssertion(_datasetId, _leafIds[0], true);
        isDatasetContainsCarsAssertion(_datasetId, _leafIds, true);
        isDatasetProofSubmitterAssertion(_datasetId, caller, true);
        /// @dev TODO:check state after submit proof,need add method in dataset interface:https://github.com/dataswap/core/issues/71
    }

    /// @notice Calculate the new size of the target.
    /// @param _oldDatasetSize The old value of the target.
    /// @param _leafSizes The _leafSizes array used for updating the size of the target.
    /// @return The new size value of the target.
    function _getDatasetSizeWithNewProof(
        uint64 _oldDatasetSize,
        uint64[] memory _leafSizes
    ) internal pure returns (uint64) {
        uint64 newDatasetSize = _oldDatasetSize;
        for (uint64 i = 0; i < _leafSizes.length; i++) {
            newDatasetSize += _leafSizes[i];
        }
        return newDatasetSize;
    }

    /// @notice Assertion function for submitting dataset verification.
    /// @param caller The address of the caller.
    /// @param _datasetId The ID of the dataset for which to submit verification.
    /// @param _randomSeed The random seed for verification.
    /// @param _siblings The Merkle tree siblings for verification.
    /// @param _paths The Merkle tree paths for verification.
    function submitDatasetChallengeProofsAssertion(
        address caller,
        uint64 _datasetId,
        uint64 _randomSeed,
        bytes32[] memory _leaves,
        bytes32[][] memory _siblings,
        uint32[] memory _paths
    ) external {
        // Before the action, capture the initial state.
        uint16 oldCount = datasetsChallenge.getDatasetChallengeProofsCount(
            _datasetId
        );

        isDatasetChallengeProofDuplicateAssertion(
            _datasetId,
            caller,
            _randomSeed,
            false
        );

        // Perform the action.
        vm.prank(caller);
        datasetsChallenge.submitDatasetChallengeProofs(
            _datasetId,
            _randomSeed,
            _leaves,
            _siblings,
            _paths
        );

        // After the action, check the updated state.
        getDatasetChallengeProofsCountAssertion(_datasetId, oldCount + 1);
        getDatasetChallengeProofsAssertion(
            _datasetId,
            caller,
            _leaves,
            _siblings,
            _paths
        );
    }

    /// @notice Assertion function for getting dataset metadata.
    /// @param _datasetId The ID of the dataset.
    /// @param _expectAccessMethod The expected access method.
    /// @param _expectSubmitter The expected submitter address.
    /// @param _expectCreatedBlockNumber The expected block number when metadata was created.
    function getDatasetMetadataAssertion(
        uint64 _datasetId,
        string memory _expectAccessMethod,
        address _expectSubmitter,
        uint64 _expectCreatedBlockNumber
    ) public {
        (
            ,
            ,
            ,
            ,
            ,
            string memory accessMethod,
            address submitter,
            uint64 createdBlockNumber,
            ,
            ,

        ) = datasets.getDatasetMetadata(_datasetId);
        assertEq(
            accessMethod,
            _expectAccessMethod,
            "access method not matched"
        );
        assertEq(submitter, _expectSubmitter, "submitter not matched");
        assertEq(
            createdBlockNumber,
            _expectCreatedBlockNumber,
            "block number not matched"
        );
    }

    /// @notice Assertion function for getting dataset metadata's submitter.
    /// @param _datasetId The ID of the dataset.
    /// @param _expectSubmitter The expected submitter address.
    function getDatasetMetadataSubmitterAssertion(
        uint64 _datasetId,
        address _expectSubmitter
    ) public {
        address submitter = datasets.getDatasetMetadataSubmitter(_datasetId);
        assertEq(submitter, _expectSubmitter, "submitter not matched");
    }

    /// @notice Assertion function for getting dataset proof.
    /// @param _datasetId The ID of the dataset.
    /// @param _dataType The data type of the proof.
    /// @param _index The index of the proof.
    /// @param _len The length of the proof.
    /// @param _expectProof The expected proof.
    function getDatasetProofAssertion(
        uint64 _datasetId,
        DatasetType.DataType _dataType,
        uint64 _index,
        uint64 _len,
        bytes32[] memory _expectProof
    ) public {
        bytes32[] memory proof = datasetsProof.getDatasetProof(
            _datasetId,
            _dataType,
            _index,
            _len
        );

        assertEq(proof.length, _expectProof.length, "length not matched");
        for (uint64 i = 0; i < proof.length; i++) {
            assertEq(proof[i], _expectProof[i], "proof not matched");
        }
    }

    /// @notice Assertion function for getting dataset cars (leaf hashes).
    /// @param _datasetId The ID of the dataset.
    /// @param _dataType The data type of the proof.
    /// @param _index The index of the proof.
    /// @param _len The length of the proof.
    /// @param _expectCars The expected cars (leaf hashes).
    function getDatasetCarsAssertion(
        uint64 _datasetId,
        DatasetType.DataType _dataType,
        uint64 _index,
        uint64 _len,
        bytes32[] memory _expectCars
    ) public {
        bytes32[] memory cars = datasetsProof.getDatasetCars(
            _datasetId,
            _dataType,
            _index,
            _len
        );

        assertEq(cars.length, _expectCars.length, "length not matched");
        for (uint64 i = 0; i < cars.length; i++) {
            assertEq(cars[i], _expectCars[i], "cars not matched");
        }
    }

    function getDatasetProofSubmitterAssertion(
        uint64 _datasetId,
        address _submitter
    ) public {
        assertEq(
            datasetsProof.getDatasetProofSubmitter(_datasetId),
            _submitter,
            "invalid submitter"
        );
    }

    /// @notice Assertion function for getting dataset proof count.
    /// @param _datasetId The ID of the dataset.
    /// @param _dataType The data type of the proof.
    /// @param _expectCount The expected proof count.
    function getDatasetProofCountAssertion(
        uint64 _datasetId,
        DatasetType.DataType _dataType,
        uint64 _expectCount
    ) public {
        assertEq(
            datasetsProof.getDatasetProofCount(_datasetId, _dataType),
            _expectCount,
            "count not matched"
        );
    }

    /// @notice Assertion function for getting dataset cars (leaf hashes) count.
    /// @param _datasetId The ID of the dataset.
    /// @param _dataType The data type of the proof.
    /// @param _expectCount The expected cars count.
    function getDatasetCarsCountAssertion(
        uint64 _datasetId,
        DatasetType.DataType _dataType,
        uint64 _expectCount
    ) public {
        assertEq(
            datasetsProof.getDatasetCarsCount(_datasetId, _dataType),
            _expectCount,
            "count not matched"
        );
    }

    /// @notice Assertion function for getting replica's count of dataset.
    /// @param _datasetId The ID of the dataset.
    /// @param _expectCount The expected cars count.
    function getDatasetReplicasCountAssertion(
        uint64 _datasetId,
        uint16 _expectCount
    ) public {
        assertEq(
            datasetsRequirement.getDatasetReplicasCount(_datasetId),
            _expectCount,
            "replicas not matched"
        );
    }

    ///@notice Get dataset replica requirement
    function getDatasetReplicaRequirementAssertion(
        uint64 _datasetId,
        uint64 _index,
        address[] memory _expectDataPreprares,
        address[] memory _expectStorageProviders,
        uint16 _expectRegion,
        uint16 _expectCountry,
        uint32[] memory _expectCitys
    ) public {
        (
            address[] memory dps,
            address[] memory sps,
            uint16 region,
            uint16 country,
            uint32[] memory citys
        ) = datasetsRequirement.getDatasetReplicaRequirement(
                _datasetId,
                _index
            );
        assertEq(
            dps.length,
            _expectDataPreprares.length,
            "dps length not match"
        );
        assertEq(
            sps.length,
            _expectStorageProviders.length,
            "sps length not match"
        );
        assertEq(citys.length, _expectCitys.length, "citys length not match");

        assertEq(region, _expectRegion, "region not match");
        assertEq(country, _expectCountry, "country not match");
    }

    /// @notice Assertion function for getting dataset size.
    /// @param _datasetId The ID of the dataset.
    /// @param _dataType The data type of the proof.
    /// @param _expectSize The expected dataset size.
    function getDatasetSizeAssertion(
        uint64 _datasetId,
        DatasetType.DataType _dataType,
        uint64 _expectSize
    ) public {
        assertEq(
            datasetsProof.getDatasetSize(_datasetId, _dataType),
            _expectSize,
            "size not matched"
        );
    }

    /// @notice Assertion function for getting dataset state.
    /// @param _datasetId The ID of the dataset.
    /// @param _expectState The expected dataset state.
    function getDatasetStateAssertion(
        uint64 _datasetId,
        DatasetType.State _expectState
    ) public {
        assertEq(
            uint8(datasets.getDatasetState(_datasetId)),
            uint8(_expectState),
            "state not matched"
        );
    }

    /// @notice Assertion function for getting dataset verification.
    /// @param _datasetId The ID of the dataset.
    /// @param _auditor The auditor address.
    /// @param _expectSiblings The expected Merkle tree siblings.
    /// @param _expectPaths The expected Merkle tree paths.
    function getDatasetChallengeProofsAssertion(
        uint64 _datasetId,
        address _auditor,
        bytes32[] memory _expectLeaves,
        bytes32[][] memory _expectSiblings,
        uint32[] memory _expectPaths
    ) public {
        assertEq(
            _expectSiblings.length,
            _expectLeaves.length,
            "length not matched"
        );
        assertEq(
            _expectPaths.length,
            _expectLeaves.length,
            "length not matched"
        );

        (
            bytes32[] memory leaves,
            bytes32[][] memory siblings,
            uint32[] memory paths
        ) = datasetsChallenge.getDatasetChallengeProofs(_datasetId, _auditor);

        assertEq(leaves.length, _expectLeaves.length, "length not matched");
        assertEq(siblings.length, _expectSiblings.length, "length not matched");
        assertEq(paths.length, _expectPaths.length, "length not matched");

        for (uint64 i = 0; i < _expectLeaves.length; i++) {
            assertEq(paths[i], _expectPaths[i], "paths not matched");
            assertEq(leaves[i], _expectLeaves[i], "leaves not matched");
            assertEq(
                siblings[i].length,
                _expectSiblings[i].length,
                "length not matched"
            );
            for (uint64 j = 0; j < siblings[i].length; j++) {
                assertEq(
                    siblings[i][j],
                    _expectSiblings[i][j],
                    "siblings not matched"
                );
            }
        }
    }

    /// @notice Assertion function for getting dataset verification count.
    /// @param _datasetId The ID of the dataset.
    /// @param _expectCount The expected verification count.
    function getDatasetChallengeProofsCountAssertion(
        uint64 _datasetId,
        uint16 _expectCount
    ) public {
        assertEq(
            datasetsChallenge.getDatasetChallengeProofsCount(_datasetId),
            _expectCount,
            "count not matched"
        );
    }

    /// @notice Assertion function for checking if dataset metadata exists for a given access method.
    /// @param _accessMethod The access method to check.
    /// @param _expecthasDatasetMetadata The expected result, true if metadata exists, false otherwise.
    function hasDatasetMetadataAssertion(
        string memory _accessMethod,
        bool _expecthasDatasetMetadata
    ) public {
        assertEq(
            datasets.hasDatasetMetadata(_accessMethod),
            _expecthasDatasetMetadata,
            "has dataset metadata not matched"
        );
    }

    /// @notice Assertion function for checking if a dataset contains a specific car (leaf hash).
    /// @param _datasetId The ID of the dataset.
    /// @param _id The car (leaf hash) to check.
    /// @param _expectIsDatasetContainsCar The expected result, true if the car exists in the dataset, false otherwise.
    function isDatasetContainsCarAssertion(
        uint64 _datasetId,
        uint64 _id,
        bool _expectIsDatasetContainsCar
    ) public {
        assertEq(
            datasetsProof.isDatasetContainsCar(_datasetId, _id),
            _expectIsDatasetContainsCar,
            "isDatasetContainsCar not matched"
        );
    }

    /// @notice Assertion function for checking if a dataset contains multiple cars (leaf hashes).
    /// @param _datasetId The ID of the dataset.
    /// @param _ids The cars (leaf hashes) to check.
    /// @param _expectIsDatasetContainsCars The expected result, true if all the cars exist in the dataset, false otherwise.
    function isDatasetContainsCarsAssertion(
        uint64 _datasetId,
        uint64[] memory _ids,
        bool _expectIsDatasetContainsCars
    ) public {
        assertEq(
            datasetsProof.isDatasetContainsCars(_datasetId, _ids),
            _expectIsDatasetContainsCars,
            "isDatasetContainsCars not matched"
        );
    }

    /// @notice Assertion function for checking if a _submitter of the dataset proof is the submitter of the dataset proof.
    /// @param _datasetId The ID of the dataset.
    /// @param _submitter The submitter to check.
    /// @param _expectIsDatasetProofSubmitter The expected result, true if _submitter is the submitter of the dataset proof.
    function isDatasetProofSubmitterAssertion(
        uint64 _datasetId,
        address _submitter,
        bool _expectIsDatasetProofSubmitter
    ) public {
        assertEq(
            datasetsProof.isDatasetProofSubmitter(_datasetId, _submitter),
            _expectIsDatasetProofSubmitter,
            "isDatasetProofSubmitter not matched"
        );
    }

    /// @notice Assertion function for checking if a _randomSeed is duplicate in dataset or the _auditor is submitted.
    /// @param _datasetId The ID of the dataset.
    /// @param _auditor The _auditor to check.
    /// @param _randomSeed The _randomSeed to check.
    /// @param _expectIsDatasetVerificationDuplicate The expected result, true if dupulicated of the dataset varification.
    function isDatasetChallengeProofDuplicateAssertion(
        uint64 _datasetId,
        address _auditor,
        uint64 _randomSeed,
        bool _expectIsDatasetVerificationDuplicate
    ) public {
        assertEq(
            datasetsChallenge.isDatasetChallengeProofDuplicate(
                _datasetId,
                _auditor,
                _randomSeed
            ),
            _expectIsDatasetVerificationDuplicate,
            "isDatasetChallengeProofDuplicate not matched"
        );
    }

    /// @notice Assertion function for checking dataset count.
    /// @param _expectCount The expected dataset count.
    function datasetsCountAssertion(uint64 _expectCount) public {
        assertEq(
            datasets.datasetsCount(),
            _expectCount,
            "datasets count not matched"
        );
    }

    /// @notice Assertion function for checking challenge count.
    /// @param _datasetId The ID of the dataset.
    /// @param _expectCount The expected challenge count.
    function getChallengeCountAssertion(
        uint64 _datasetId,
        uint64 _expectCount
    ) external {
        assertEq(
            datasetsChallenge.getChallengeCount(_datasetId),
            _expectCount,
            "challenge count not matched"
        );
    }
}
