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
import {RolesType} from "src/v0.8/types/RolesType.sol";
import {IDatasets} from "src/v0.8/interfaces/module/IDatasets.sol";
import {IDatasetsAssertion} from "test/v0.8/interfaces/assertions/module/IDatasetsAssertion.sol";
import {IDatasetsHelpers} from "test/v0.8/interfaces/helpers/module/IDatasetsHelpers.sol";

///@notice submit dataset verification test case with success.
contract SubmittVerificationTestCaseWithSuccess is DatasetsTestBase {
    constructor(
        IDatasets _datasets,
        IDatasetsHelpers _datasetsHelpers,
        IDatasetsAssertion _datasetsAssertion
    )
        DatasetsTestBase(_datasets, _datasetsHelpers, _datasetsAssertion) // solhint-disable-next-line
    {}

    function before() internal virtual override returns (uint64 id) {
        uint64 datasetId = datasetsHelpers.submitDatasetMetadata(
            address(9),
            "TEST"
        );
        vm.prank(datasets.governanceAddress());
        datasets.approveDatasetMetadata(datasetId);

        address admin = datasets.roles().getRoleMember(bytes32(0x00), 0);
        vm.startPrank(admin);
        datasets.roles().grantRole(RolesType.DATASET_PROVIDER, address(99));
        vm.stopPrank();
        datasetsHelpers.submitDatasetProof(
            address(99),
            datasetId,
            DatasetType.DataType.Source,
            "",
            100,
            true
        );
        datasetsHelpers.submitDatasetProof(
            address(99),
            datasetId,
            DatasetType.DataType.MappingFiles,
            "accessmethod",
            10,
            true
        );
        return datasetId;
    }

    function action(uint64 _id) internal virtual override {
        uint64 pointCount = 1;
        bytes32[] memory leaves = new bytes32[](pointCount);
        bytes32[][] memory siblings = new bytes32[][](pointCount);
        uint32[] memory paths = new uint32[](pointCount);
        uint64 randomSeed;
        (randomSeed, leaves, siblings, paths) = datasetsHelpers
            .generateVerification(pointCount);

        address admin = datasets.roles().getRoleMember(bytes32(0x00), 0);
        vm.startPrank(admin);
        datasets.roles().grantRole(RolesType.DATASET_AUDITOR, address(199));
        vm.stopPrank();
        datasetsAssertion.submitDatasetVerificationAssertion(
            address(199),
            _id,
            randomSeed,
            leaves,
            siblings,
            paths
        );
    }
}

///@notice submit dataset verification test case with fail.
contract SubmittVerificationTestCaseWithFail is DatasetsTestBase {
    constructor(
        IDatasets _datasets,
        IDatasetsHelpers _datasetsHelpers,
        IDatasetsAssertion _datasetsAssertion
    )
        DatasetsTestBase(_datasets, _datasetsHelpers, _datasetsAssertion) // solhint-disable-next-line
    {}

    function before() internal virtual override returns (uint64 id) {
        uint64 datasetId = datasetsHelpers.submitDatasetMetadata(
            address(9),
            "TEST"
        );
        vm.prank(datasets.governanceAddress());
        datasets.approveDatasetMetadata(datasetId);

        datasets.merkleUtils().setMockValidState(false);

        address admin = datasets.roles().getRoleMember(bytes32(0x00), 0);
        vm.startPrank(admin);
        datasets.roles().grantRole(RolesType.DATASET_PROVIDER, address(99));
        vm.stopPrank();
        datasetsHelpers.submitDatasetProof(
            address(99),
            datasetId,
            DatasetType.DataType.Source,
            "",
            100,
            true
        );
        datasetsHelpers.submitDatasetProof(
            address(99),
            datasetId,
            DatasetType.DataType.MappingFiles,
            "accessmethod",
            10,
            true
        );
        return datasetId;
    }

    function action(uint64 _id) internal virtual override {
        uint64 pointCount = 1;
        bytes32[] memory leaves = new bytes32[](pointCount);
        bytes32[][] memory siblings = new bytes32[][](pointCount);
        uint32[] memory paths = new uint32[](pointCount);
        uint64 randomSeed;
        (randomSeed, leaves, siblings, paths) = datasetsHelpers
            .generateVerification(pointCount);

        address admin = datasets.roles().getRoleMember(bytes32(0x00), 0);
        vm.startPrank(admin);
        datasets.roles().grantRole(RolesType.DATASET_AUDITOR, address(200));
        vm.stopPrank();
        vm.expectRevert(bytes("mockValidState must is true"));
        datasetsAssertion.submitDatasetVerificationAssertion(
            address(200),
            _id,
            randomSeed,
            leaves,
            siblings,
            paths
        );
    }
}

///@notice submit dataset verification test case with illegal role.
contract SubmittVerificationTestCaseWithIllegalRole is DatasetsTestBase {
    constructor(
        IDatasets _datasets,
        IDatasetsHelpers _datasetsHelpers,
        IDatasetsAssertion _datasetsAssertion
    )
        DatasetsTestBase(_datasets, _datasetsHelpers, _datasetsAssertion) // solhint-disable-next-line
    {}

    function before() internal virtual override returns (uint64 id) {
        uint64 datasetId = datasetsHelpers.submitDatasetMetadata(
            address(9),
            "TEST"
        );
        vm.prank(datasets.governanceAddress());
        datasets.approveDatasetMetadata(datasetId);

        address admin = datasets.roles().getRoleMember(bytes32(0x00), 0);
        vm.startPrank(admin);
        datasets.roles().grantRole(RolesType.DATASET_PROVIDER, address(99));
        vm.stopPrank();
        datasetsHelpers.submitDatasetProof(
            address(99),
            datasetId,
            DatasetType.DataType.Source,
            "",
            100,
            true
        );
        datasetsHelpers.submitDatasetProof(
            address(99),
            datasetId,
            DatasetType.DataType.MappingFiles,
            "accessmethod",
            10,
            true
        );
        return datasetId;
    }

    function action(uint64 _id) internal virtual override {
        uint64 pointCount = 1;
        bytes32[] memory leaves = new bytes32[](pointCount);
        bytes32[][] memory siblings = new bytes32[][](pointCount);
        uint32[] memory paths = new uint32[](pointCount);
        uint64 randomSeed;
        (randomSeed, leaves, siblings, paths) = datasetsHelpers
            .generateVerification(pointCount);

        vm.expectRevert(bytes("Only allowed role can call"));
        datasetsAssertion.submitDatasetVerificationAssertion(
            address(199),
            _id,
            randomSeed,
            leaves,
            siblings,
            paths
        );
    }
}
