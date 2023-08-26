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

import {DSTest} from "ds-test/test.sol";
import {Test} from "forge-std/Test.sol";
import {DatasetType} from "src/v0.8/types/DatasetType.sol";
import {IDatasets} from "src/v0.8/interfaces/module/IDatasets.sol";
import {IDatasetsAssertion} from "test/v0.8/interfaces/assertions/module/IDatasetsAssertion.sol";

// assert carstore action
// NOTE: view asserton functions must all be tested by the functions that will change state
contract DatasetsAssertion is DSTest, Test, IDatasetsAssertion {
    IDatasets public datasets;

    constructor(IDatasets _datasets) {
        datasets = _datasets;
    }

    function approveDatasetAssertion(uint64 _datasetId) external {
        //before action
        getDatasetStateAssertion(
            _datasetId,
            DatasetType.State.DatasetProofSubmitted
        );
        //action
        datasets.approveDataset(_datasetId);
        //after action
        getDatasetStateAssertion(_datasetId, DatasetType.State.DatasetApproved);
    }

    function approveDatasetMetadataAssertion(uint64 _datasetId) external {
        //before action
        getDatasetStateAssertion(
            _datasetId,
            DatasetType.State.MetadataSubmitted
        );
        //action
        //TODO:need delete
        vm.prank(datasets.governanceAddress());
        datasets.approveDatasetMetadata(_datasetId);
        //after action
        getDatasetStateAssertion(
            _datasetId,
            DatasetType.State.MetadataApproved
        );
    }

    function rejectDatasetAssertion(uint64 _datasetId) external {
        //before action
        getDatasetStateAssertion(
            _datasetId,
            DatasetType.State.DatasetProofSubmitted
        );
        //action
        datasets.rejectDataset(_datasetId);
        //after action
        getDatasetStateAssertion(
            _datasetId,
            DatasetType.State.MetadataApproved
        );
    }

    function rejectDatasetMetadataAssertion(uint64 _datasetId) external {
        //before action
        getDatasetStateAssertion(
            _datasetId,
            DatasetType.State.MetadataSubmitted
        );
        //action
        datasets.rejectDataset(_datasetId);
        //after action
        getDatasetStateAssertion(
            _datasetId,
            DatasetType.State.MetadataRejected
        );
    }

    function submitDatasetMetadataAssertion(
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
        // before action
        uint64 oldDatasetsCount = datasets.datasetsCount();
        getDatasetStateAssertion(oldDatasetsCount + 1, DatasetType.State.None);
        hasDatasetMetadataAssertion(_accessMethod, false);

        // action
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

        // after action
        hasDatasetMetadataAssertion(_accessMethod, true);
        uint64 newDatasetsCount = datasets.datasetsCount();
        getDatasetStateAssertion(
            oldDatasetsCount + 1,
            DatasetType.State.MetadataSubmitted
        );
        datasetsCountAssertion(oldDatasetsCount + 1);
        getDatasetMetadataAssertion(
            newDatasetsCount,
            _accessMethod,
            //TODO:check
            address(this),
            uint64(block.number)
        );
    }

    function submitDatasetProofAssertion(
        uint64 _datasetId,
        DatasetType.DataType _dataType,
        string calldata accessMethod,
        bytes32 _rootHash,
        bytes32[] calldata _leafHashes,
        uint64[] calldata _leafSizes,
        bool _completed
    ) external {
        // before action
        getDatasetStateAssertion(
            _datasetId,
            DatasetType.State.MetadataApproved
        );
        uint64 oldProofCount = datasets.getDatasetProofCount(
            _datasetId,
            _dataType
        );
        uint64 oldDatasetSize = datasets.getDatasetSize(_datasetId, _dataType);
        isDatasetContainsCarAssertion(_datasetId, _leafHashes[0], false);
        isDatasetContainsCarsAssertion(_datasetId, _leafHashes, false);

        // action
        datasets.submitDatasetProof(
            _datasetId,
            _dataType,
            accessMethod,
            _rootHash,
            _leafHashes,
            _leafSizes,
            _completed
        );

        //after action
        // assert count
        uint64 newProofCount = datasets.getDatasetProofCount(
            _datasetId,
            _dataType
        );
        // assert leves
        getDatasetProofCountAssertion(
            _datasetId,
            _dataType,
            oldProofCount + uint64(_leafHashes.length)
        );
        getDatasetCarsCountAssertion(
            _datasetId,
            _dataType,
            oldProofCount + uint64(_leafHashes.length)
        );
        getDatasetProofAssertion(
            _datasetId,
            _dataType,
            oldProofCount,
            newProofCount,
            _leafHashes
        );
        getDatasetCarsAssertion(
            _datasetId,
            _dataType,
            oldProofCount,
            newProofCount,
            _leafHashes
        );

        //assert size
        uint64 newDatasetSize = oldDatasetSize;
        for (uint64 i = 0; i < _leafSizes.length; i++) {
            newDatasetSize += _leafSizes[i];
        }
        getDatasetSizeAssertion(_datasetId, _dataType, newDatasetSize);
        isDatasetContainsCarAssertion(_datasetId, _leafHashes[0], true);
        isDatasetContainsCarsAssertion(_datasetId, _leafHashes, true);
        //TODO:check state after submit proof,need add method in dataset interface
    }

    function submitDatasetVerificationAssertion(
        uint64 _datasetId,
        uint64 _randomSeed,
        bytes32[][] memory _siblings,
        uint32[] memory _paths
    ) external {
        //before action
        uint16 oldCount = datasets.getDatasetVerificationsCount(_datasetId);
        // action
        datasets.submitDatasetVerification(
            _datasetId,
            _randomSeed,
            _siblings,
            _paths
        );

        //after action
        getDatasetVerificationsCountAssertion(_datasetId, oldCount + 1);
        getDatasetVerificationAssertion(
            _datasetId,
            msg.sender,
            _siblings,
            _paths
        );
    }

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

    function getDatasetProofAssertion(
        uint64 _datasetId,
        DatasetType.DataType _dataType,
        uint64 _index,
        uint64 _len,
        bytes32[] memory _expectProof
    ) public {
        bytes32[] memory proof = datasets.getDatasetProof(
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

    function getDatasetCarsAssertion(
        uint64 _datasetId,
        DatasetType.DataType _dataType,
        uint64 _index,
        uint64 _len,
        bytes32[] memory _expectCars
    ) public {
        bytes32[] memory cars = datasets.getDatasetCars(
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

    function getDatasetProofCountAssertion(
        uint64 _datasetId,
        DatasetType.DataType _dataType,
        uint64 _expectCount
    ) public {
        assertEq(
            datasets.getDatasetProofCount(_datasetId, _dataType),
            _expectCount,
            "count not matched"
        );
    }

    function getDatasetCarsCountAssertion(
        uint64 _datasetId,
        DatasetType.DataType _dataType,
        uint64 _expectCount
    ) public {
        assertEq(
            datasets.getDatasetCarsCount(_datasetId, _dataType),
            _expectCount,
            "count not matched"
        );
    }

    function getDatasetSizeAssertion(
        uint64 _datasetId,
        DatasetType.DataType _dataType,
        uint64 _expectSize
    ) public {
        assertEq(
            datasets.getDatasetSize(_datasetId, _dataType),
            _expectSize,
            "size not matched"
        );
    }

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

    function getDatasetVerificationAssertion(
        uint64 _datasetId,
        address _auditor,
        bytes32[][] memory _expectSiblings,
        uint32[] memory _expectPaths
    ) public {
        (bytes32[][] memory siblings, uint32[] memory paths) = datasets
            .getDatasetVerification(_datasetId, _auditor);
        assertEq(siblings.length, _expectSiblings.length, "length not matched");
        assertEq(paths.length, _expectPaths.length, "length not matched");
        for (uint64 i = 0; i < paths.length; i++) {
            assertEq(paths[i], _expectPaths[i], "paths not matched");
        }
        for (uint64 i = 0; i < siblings.length; i++) {
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

    function getDatasetVerificationsCountAssertion(
        uint64 _datasetId,
        uint16 _expectCount
    ) public {
        assertEq(
            datasets.getDatasetVerificationsCount(_datasetId),
            _expectCount,
            "count not matched"
        );
    }

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

    function isDatasetContainsCarAssertion(
        uint64 _datasetId,
        bytes32 _cid,
        bool _expectIsDatasetContainsCar
    ) public {
        assertEq(
            datasets.isDatasetContainsCar(_datasetId, _cid),
            _expectIsDatasetContainsCar,
            "isDatasetContainsCar not matched"
        );
    }

    function isDatasetContainsCarsAssertion(
        uint64 _datasetId,
        bytes32[] memory _cids,
        bool _expectIsDatasetContainsCars
    ) public {
        assertEq(
            datasets.isDatasetContainsCars(_datasetId, _cids),
            _expectIsDatasetContainsCars,
            "isDatasetContainsCars not matched"
        );
    }

    function datasetsCountAssertion(uint64 _expectCount) public {
        assertEq(datasets.datasetsCount(), _expectCount, "count not matched");
    }
}
