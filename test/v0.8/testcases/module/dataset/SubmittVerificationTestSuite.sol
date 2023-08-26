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

import {DatasetsTestBase} from "test/v0.8/testcases/module/dataset/abstract/DatasetsTestBase.sol";

import {DatasetType} from "src/v0.8/types/DatasetType.sol";
import {IRoles} from "src/v0.8/interfaces/core/IRoles.sol";
import {RolesType} from "src/v0.8/types/RolesType.sol";
import {IDatasets} from "src/v0.8/interfaces/module/IDatasets.sol";
import {IDatasetsAssertion} from "test/v0.8/interfaces/assertions/module/IDatasetsAssertion.sol";
import {IDatasetsHelpers} from "test/v0.8/interfaces/helpers/module/IDatasetsHelpers.sol";

contract SubmittVerificationTestCaseWithSuccess is DatasetsTestBase {
    constructor(
        IDatasets _datasets,
        IDatasetsHelpers _datasetsHelpers,
        IDatasetsAssertion _datasetsAssertion
    )
        DatasetsTestBase(_datasets, _datasetsHelpers, _datasetsAssertion) // solhint-disable-next-line
    {}

    function before() internal virtual override returns (uint64 id) {
        uint64 datasetId = datasetsHelpers.submitDatasetMetadata("TEST");
        vm.prank(datasets.governanceAddress());
        datasets.approveDatasetMetadata(datasetId);
        datasetsHelpers.submitDatasetProof(
            datasetId,
            DatasetType.DataType.Source,
            "",
            100,
            true
        );
        datasetsHelpers.submitDatasetProof(
            datasetId,
            DatasetType.DataType.MappingFiles,
            "accessmethod",
            10,
            true
        );
        return datasetId;
    }

    function action(uint64 _id) internal virtual override {
        uint64 pointCount = 10;
        uint64 pointLeavesCount = 100;
        bytes32[][] memory siblings = new bytes32[][](pointCount);
        uint32[] memory paths = new uint32[](pointCount);
        for (uint64 i = 0; i < pointCount; i++) {
            siblings[i] = new bytes32[](pointLeavesCount);
        }
        uint64 randomSeed;
        (randomSeed, siblings, paths) = datasetsHelpers.generateVerification(
            pointCount,
            pointLeavesCount
        );
        IRoles roles = datasets.roles();
        roles.grantRole(RolesType.DATASET_AUDITOR, address(99));
        vm.prank(address(99));
        datasetsAssertion.submitDatasetVerificationAssertion(
            _id,
            randomSeed,
            siblings,
            paths
        );
    }
}
