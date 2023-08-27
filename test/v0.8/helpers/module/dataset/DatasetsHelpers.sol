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

// Import required external contracts and interfaces
import {Test} from "forge-std/Test.sol";
import {TestHelpers} from "src/v0.8/shared/utils/common/TestHelpers.sol";
import {IDatasetsHelpers} from "test/v0.8/interfaces/helpers/module/IDatasetsHelpers.sol";

import {RolesType} from "src/v0.8/types/RolesType.sol";
import {DatasetType} from "src/v0.8/types/DatasetType.sol";
import {IDatasets} from "src/v0.8/interfaces/module/IDatasets.sol";
import {Generator} from "test/v0.8/helpers/utils/Generator.sol";
import {IDatasetsAssertion} from "test/v0.8/interfaces/assertions/module/IDatasetsAssertion.sol";

// Contract definition for test helper functions
contract DatasetsHelpers is Test, IDatasetsHelpers {
    IDatasets public datasets;
    Generator private generator;
    IDatasetsAssertion private assertion;

    constructor(
        IDatasets _datasets,
        Generator _generator,
        IDatasetsAssertion _assertion
    ) {
        datasets = _datasets;
        generator = _generator;
        assertion = _assertion;
    }

    ///@notice Submit metadata for a dataset
    function submitDatasetMetadata(
        address caller,
        string memory _accessMethod
    ) public returns (uint64 datasetId) {
        uint64 datasetCount = datasets.datasetsCount();
        vm.prank(caller);
        datasets.submitDatasetMetadata(
            "title",
            "industry",
            "name",
            "description",
            "source",
            _accessMethod,
            100,
            true,
            1
        );
        return datasetCount + 1;
    }

    function generateRoot() public returns (bytes32) {
        return generator.generateRoot();
    }

    function generateProof(
        uint64 _leavesCount
    ) public returns (bytes32[] memory, uint64[] memory, uint64) {
        return generator.generateLeavesAndSizes(_leavesCount);
    }

    function submitDatasetProof(
        address caller,
        uint64 _datasetId,
        DatasetType.DataType _dataType,
        string memory _accessMethod,
        uint64 _leavesCount,
        bool _complete
    ) public {
        bytes32 root = generateRoot();
        bytes32[] memory leavesHashes = new bytes32[](_leavesCount);
        uint64[] memory leavesSizes = new uint64[](_leavesCount);
        (leavesHashes, leavesSizes, ) = generateProof(_leavesCount);
        vm.prank(caller);
        datasets.submitDatasetProof(
            _datasetId,
            _dataType,
            _accessMethod,
            root,
            leavesHashes,
            leavesSizes,
            _complete
        );
    }

    function generateVerification(
        uint64 _pointCount,
        uint64 _pointLeavesCount
    ) public returns (uint64, bytes32[][] memory, uint32[] memory) {
        uint64 randomSeed = generator.generateNonce();
        bytes32[][] memory siblings = new bytes32[][](_pointCount);
        uint32[] memory paths = new uint32[](_pointCount);
        for (uint32 i = 0; i < _pointCount; i++) {
            bytes32[] memory leaves = new bytes32[](_pointLeavesCount);
            leaves = generator.generateLeaves(_pointLeavesCount);
            siblings[i] = leaves;
            paths[i] = i;
        }
        return (randomSeed, siblings, paths);
    }

    function submitDatasetVerification(
        address caller,
        uint64 _datasetId,
        uint64 _challengeCount,
        uint64 _challengeLeavesCount
    ) public {
        uint64 randomSeed = generator.generateNonce();
        bytes32[][] memory siblings = new bytes32[][](_challengeCount);
        uint32[] memory paths = new uint32[](_challengeCount);
        for (uint32 i = 0; i < _challengeCount; i++) {
            bytes32[] memory leaves = new bytes32[](_challengeLeavesCount);
            leaves = generator.generateLeaves(_challengeLeavesCount);
            siblings[i] = leaves;
            paths[i] = i;
        }
        vm.prank(caller);
        datasets.submitDatasetVerification(
            _datasetId,
            randomSeed,
            siblings,
            paths
        );
    }

    function completeDatasetWorkflow(
        string memory _accessMethod,
        uint64 _sourceLeavesCount,
        uint64 _mappingFilesLeavesCount,
        uint64 /*_challengeCount*/,
        uint64 /*_challengeLeavesCount*/
    ) external returns (uint64) {
        //1:submit meta
        address admin = datasets.roles().getRoleMember(bytes32(0x00), 0);
        vm.startPrank(admin);
        datasets.roles().grantRole(RolesType.DATASET_PROVIDER, address(9));
        vm.stopPrank();
        uint64 datasetId = submitDatasetMetadata(address(9), _accessMethod);

        //2:approved meta
        assertion.approveDatasetMetadataAssertion(
            datasets.governanceAddress(),
            datasetId
        );

        //3:submit proof
        vm.startPrank(admin);
        datasets.roles().grantRole(RolesType.DATASET_PROVIDER, address(99));
        vm.stopPrank();
        submitDatasetProof(
            address(99),
            datasetId,
            DatasetType.DataType.MappingFiles,
            _accessMethod,
            _sourceLeavesCount,
            true
        );
        submitDatasetProof(
            address(99),
            datasetId,
            DatasetType.DataType.Source,
            _accessMethod,
            _mappingFilesLeavesCount,
            true
        );

        //4:submit verification
        // NOTE:TODO verify before approved
        // submitDatasetVerification(
        //     datasetId,
        //     _challengeCount,
        //     _challengeLeavesCount
        // );

        //5:appvoed
        assertion.approveDatasetAssertion(
            datasets.governanceAddress(),
            datasetId
        );
        return datasetId;
    }
}
