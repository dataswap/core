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
import {DatasetType} from "src/v0.8/types/DatasetType.sol";
import {IDatasets} from "src/v0.8/interfaces/module/IDatasets.sol";
import {LeavesGenerator} from "test/v0.8/helpers/utils/LeavesGenerator.sol";

// Contract definition for test helper functions
contract DatasetsStepHelpers is Test {
    IDatasets public datasets;
    LeavesGenerator private generator;

    constructor(IDatasets _datasets, LeavesGenerator _generator) {
        datasets = _datasets;
        generator = _generator;
    }

    function submitDatasetMetadata(string memory _accessMethod) public {
        vm.assume(bytes(_accessMethod).length != 0);
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
    }

    function submitDatasetProof(
        uint64 _datasetId,
        DatasetType.DataType _dataType,
        uint64 _leavesCount,
        bool _complete
    )
        public
        returns (
            bytes32 rootHash,
            bytes32[] memory,
            uint64[] memory,
            uint64 totalSize
        )
    {
        string memory accessMethod;
        bytes32[] memory leavesHashes = new bytes32[](_leavesCount);
        uint64[] memory leavesSizes = new uint64[](_leavesCount);
        rootHash = generator.generateRoot();

        (leavesHashes, leavesSizes, totalSize) = generator
            .generateLeavesAndSizes(_leavesCount);

        if (DatasetType.DataType.MappingFiles == _dataType) {
            accessMethod = "mappingFilesAccessMethod";
        }
        datasets.submitDatasetProof(
            _datasetId,
            _dataType,
            accessMethod,
            rootHash,
            leavesHashes,
            leavesSizes,
            _complete
        );
        return (rootHash, leavesHashes, leavesSizes, totalSize);
    }

    function submitDatasetVerification(
        uint64 _datasetId,
        uint64 _pointCount,
        uint64 _pointLeavesCount
    ) external {
        bytes32[][] memory siblings = new bytes32[][](_pointCount);
        uint32[] memory paths = new uint32[](_pointCount);
        for (uint32 i = 0; i < _pointCount; i++) {
            bytes32[] memory leaves = new bytes32[](_pointLeavesCount);
            leaves = generator.generateLeaves(_pointLeavesCount);
            siblings[i] = leaves;
            paths[i] = i;
        }
        datasets.submitDatasetVerification(
            _datasetId,
            generator.generateNonce(),
            siblings,
            paths
        );
    }
}
