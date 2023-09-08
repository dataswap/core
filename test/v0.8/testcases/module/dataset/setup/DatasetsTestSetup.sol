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

import {Test} from "forge-std/Test.sol";
import {RolesType} from "src/v0.8/types/RolesType.sol";
import {DatasetType} from "src/v0.8/types/DatasetType.sol";

import {IDatasets} from "src/v0.8/interfaces/module/IDatasets.sol";
import {IDatasetsHelpers} from "test/v0.8/interfaces/helpers/module/IDatasetsHelpers.sol";

/// @title DatasetsTestSetup
/// @dev Preset conditions for datasets testing.
contract DatasetsTestSetup is Test {
    ///@notice Setup metadata conditions for dataset test caset.
    function metadataTestSetup(
        IDatasetsHelpers _datasetsHelpers
    ) public returns (uint64 id) {
        uint64 datasetId = _datasetsHelpers.submitDatasetMetadata(
            address(9),
            "TEST"
        );
        _datasetsHelpers.submitDatasetReplicaRequirements(
            address(9),
            datasetId,
            5,
            0,
            0,
            0,
            0,
            0
        );

        return datasetId;
    }

    ///@notice Setup source dataset conditions for dataset test caset.
    function datasetTestSetup(
        IDatasetsHelpers _datasetsHelpers,
        IDatasets _datasets
    ) public returns (uint64 id) {
        uint64 datasetId = _datasetsHelpers.submitDatasetMetadata(
            address(9),
            "TEST"
        );
        _datasetsHelpers.submitDatasetReplicaRequirements(
            address(9),
            datasetId,
            5,
            0,
            0,
            0,
            0,
            0
        );

        vm.prank(_datasets.governanceAddress());
        _datasets.approveDatasetMetadata(datasetId);

        address admin = _datasets.roles().getRoleMember(bytes32(0x00), 0);
        vm.startPrank(admin);
        _datasets.roles().grantRole(RolesType.DATASET_PROVIDER, address(99));
        _datasets.roles().grantRole(RolesType.DATASET_AUDITOR, address(99));
        vm.stopPrank();
        _datasetsHelpers.submitDatasetProof(
            address(99),
            datasetId,
            DatasetType.DataType.Source,
            "",
            100,
            true
        );
        _datasetsHelpers.submitDatasetProof(
            address(99),
            datasetId,
            DatasetType.DataType.MappingFiles,
            "accessmethod",
            10,
            true
        );
        _datasetsHelpers.submitDatasetVerification(address(99), datasetId);

        return datasetId;
    }

    ///@notice Setup proof conditions for dataset test caset.
    function replicaRequirementTestSetup(
        IDatasetsHelpers _datasetsHelpers
    ) public returns (uint64 id) {
        uint64 datasetId = _datasetsHelpers.submitDatasetMetadata(
            address(9),
            "TEST"
        );
        return datasetId;
    }

    ///@notice Setup proof conditions for dataset test caset.
    function proofTestSetup(
        IDatasetsHelpers _datasetsHelpers,
        IDatasets _datasets
    ) public returns (uint64 id) {
        uint64 datasetId = _datasetsHelpers.submitDatasetMetadata(
            address(9),
            "TEST"
        );
        _datasetsHelpers.submitDatasetReplicaRequirements(
            address(9),
            datasetId,
            5,
            0,
            0,
            0,
            0,
            0
        );
        vm.prank(_datasets.governanceAddress());
        _datasets.approveDatasetMetadata(datasetId);
        return datasetId;
    }

    ///@notice Setup verification conditions for dataset test caset.
    function verificationTestSetup(
        IDatasetsHelpers _datasetsHelpers,
        IDatasets _datasets
    ) public returns (uint64 id) {
        uint64 datasetId = _datasetsHelpers.submitDatasetMetadata(
            address(9),
            "TEST"
        );
        _datasetsHelpers.submitDatasetReplicaRequirements(
            address(9),
            datasetId,
            5,
            0,
            0,
            0,
            0,
            0
        );

        vm.prank(_datasets.governanceAddress());
        _datasets.approveDatasetMetadata(datasetId);

        address admin = _datasets.roles().getRoleMember(bytes32(0x00), 0);
        vm.startPrank(admin);
        _datasets.roles().grantRole(RolesType.DATASET_PROVIDER, address(99));
        vm.stopPrank();
        _datasetsHelpers.submitDatasetProof(
            address(99),
            datasetId,
            DatasetType.DataType.Source,
            "",
            100,
            true
        );
        _datasetsHelpers.submitDatasetProof(
            address(99),
            datasetId,
            DatasetType.DataType.MappingFiles,
            "accessmethod",
            10,
            true
        );

        return datasetId;
    }
}
