/*******************************************************************************
 *   (c) 2023 DataSwap
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
import "forge-std/Test.sol";
import {DatasetTestHelpers} from "./DatasetTestHelpers.sol";
import {ICarstore} from "../../../../../src/v0.8/interfaces/core/ICarstore.sol";
import {IRoles} from "../../../../../src/v0.8/interfaces/core/IRoles.sol";
import {IFilplus} from "../../../../../src/v0.8/interfaces/core/IFilplus.sol";
import {IFilecoin} from "../../../../../src/v0.8/interfaces/core/IFilecoin.sol";
import {Roles} from "../../../../../src/v0.8/core/access/Roles.sol";
import {Filplus} from "../../../../../src/v0.8/core/filplus/Filplus.sol";
import {MockFilecoin} from "../../../../../src/v0.8/mocks/core/filecoin/MockFilecoin.sol";

// Import various shared modules, modifiers, events, and error definitions
import {CarstoreModifiers} from "../../../../../src/v0.8/shared/modifiers/CarstoreModifiers.sol";
import {CarstoreEvents} from "../../../../../src/v0.8/shared/events/CarstoreEvents.sol";
import {DatasetsEvents} from "../../../../../src/v0.8/shared/events/DatasetsEvents.sol";
import {Errors} from "../../../../../src/v0.8/shared/errors/Errors.sol";

// Import necessary custom types
import {CarReplicaType} from "../../../../../src/v0.8/types/CarReplicaType.sol";
import {Carstore} from "../../../../../src/v0.8/core/carstore/Carstore.sol";
import {FilecoinType} from "../../../../../src/v0.8/types/FilecoinType.sol";
import {DatasetType} from "../../../../../src/v0.8/types/DatasetType.sol";
import {RolesType} from "../../../../../src/v0.8/types/RolesType.sol";

// Contract definition for test functions
contract DatasetVerificationTest is Test, DatasetTestHelpers {
    function testSubmitDatasetVerification(
        bytes32 _mappingRootHash,
        bytes32 _sourceRootHash,
        uint64 _randomSeed
    ) external {
        vm.assume(_randomSeed != 0);
        assertSubmitDatasetProofSuccess(_mappingRootHash, _sourceRootHash);
        uint64 pointCount = 10;
        uint64 pointLeafCount = 20;
        bytes32[][] memory siblings = new bytes32[][](pointCount);
        uint32[] memory paths = new uint32[](pointCount);
        for (uint32 i = 0; i < pointCount; i++) {
            bytes32[] memory leaves = new bytes32[](pointLeafCount);
            for (uint32 j = 0; j < pointCount; j++) {
                leaves[j] = convertUint64ToBytes32(i * 100 + j);
            }
            siblings[i] = leaves;
            paths[i] = i;
        }
        role.grantRole(RolesType.DATASET_AUDITOR, address(this));
        vm.expectEmit(true, false, false, true);
        emit DatasetsEvents.DatasetVerificationSubmitted(1, address(this));
        datasets.submitDatasetVerification(1, _randomSeed, siblings, paths);

        assertEq(1, datasets.getDatasetVerificationsCount(1));

        datasets.getDatasetVerification(1, address(this));

        assertEq(1, datasets.getDatasetVerificationsCount(1));
    }

    function testApproveDataset(
        bytes32 _mappingRootHash,
        bytes32 _sourceRootHash
    ) external {
        assertSubmitDatasetProofSuccess(_mappingRootHash, _sourceRootHash);
        vm.prank(governanceContractAddresss);
        vm.expectEmit(true, false, false, true);
        emit DatasetsEvents.DatasetApproved(1);
        datasets.approveDataset(1);
        assertEq(
            uint8(DatasetType.State.DatasetApproved),
            uint8(datasets.getDatasetState(1))
        );
    }

    function testRejectDataset(
        bytes32 _mappingRootHash,
        bytes32 _sourceRootHash
    ) external {
        assertSubmitDatasetProofSuccess(_mappingRootHash, _sourceRootHash);

        vm.prank(governanceContractAddresss);
        vm.expectEmit(true, false, false, true);
        emit DatasetsEvents.DatasetRejected(1);
        datasets.rejectDataset(1);
        assertEq(
            uint8(DatasetType.State.MetadataApproved),
            uint8(datasets.getDatasetState(1))
        );
    }
}
