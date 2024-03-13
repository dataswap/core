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
import {IDatasetsProof} from "src/v0.8/interfaces/module/IDatasetsProof.sol";
import {IDatasetsHelpers} from "test/v0.8/interfaces/helpers/module/IDatasetsHelpers.sol";
import {IDatasetsAssertion} from "test/v0.8/interfaces/assertions/module/IDatasetsAssertion.sol";
import {FinanceType} from "src/v0.8/types/FinanceType.sol";

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
        vm.deal(address(9), 1000 ether);
        vm.startPrank(address(9));
        _datasetsHelpers.getRoles().datasetsProof().completeEscrow(datasetId);
        vm.stopPrank();
        _datasetsHelpers.getRoles().datasetsProof().submitDatasetProofCompleted(
            datasetId
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
        IDatasets /*_datasets*/
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

    ///@notice Setup verification conditions for dataset test caset.
    function verificationTestSetup(
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

        vm.deal(address(9), 1000 ether);
        vm.startPrank(address(9));
        _datasetsHelpers.getRoles().datasetsProof().completeEscrow(datasetId);
        vm.stopPrank();
        _datasetsHelpers.getRoles().datasetsProof().submitDatasetProofCompleted(
            datasetId
        );
        return datasetId;
    }

    function completeAuditorElectionTestSetup(
        IDatasetsHelpers _datasetsHelpers,
        address _caller
    ) public returns (uint64 id) {
        id = verificationTestSetup(_datasetsHelpers);
        vm.startPrank(_caller);

        vm.deal(_caller, 1000 ether);
        _datasetsHelpers.getRoles().finance().deposit{value: 1000 ether}(
            id,
            0,
            _caller,
            FinanceType.FIL
        );
        uint256 amount = _datasetsHelpers
            .getRoles()
            .datasetsChallenge()
            .getChallengeAuditCollateralRequirement();
        _datasetsHelpers.getRoles().datasetsChallenge().auditorStake(
            id,
            amount
        );
        vm.stopPrank();
        uint64 delayBlocks = _datasetsHelpers
            .getRoles()
            .datasetsChallenge()
            .getAuditorElectionEndHeight(id);
        vm.roll(delayBlocks);
    }

    function challengeTestForResubmitDatasetSetup(
        IDatasetsHelpers _datasetsHelpers,
        IDatasetsAssertion _datasetsAssertion
    ) public returns (uint64 id) {
        uint64 associatedDatasetId = _datasetsHelpers.submitDatasetMetadata(
            address(9),
            "TEST"
        );
        _datasetsHelpers.submitDatasetReplicaRequirements(
            address(9),
            associatedDatasetId,
            5,
            0,
            0,
            0,
            0,
            0
        );

        _datasetsHelpers.submitDatasetProof(
            address(99),
            associatedDatasetId,
            DatasetType.DataType.Source,
            "",
            100,
            true
        );
        _datasetsHelpers.submitDatasetProof(
            address(99),
            associatedDatasetId,
            DatasetType.DataType.MappingFiles,
            "accessmethod",
            10,
            false
        );

        vm.roll(10000000);
        vm.prank(address(199));
        _datasetsHelpers.getRoles().datasetsProof().submitDatasetProofCompleted(
            associatedDatasetId
        );

        (, , , , , string memory accessMethod, , , , , ) = _datasetsHelpers
            .getRoles()
            .datasets()
            .getDatasetMetadata(associatedDatasetId);

        _datasetsAssertion.submitDatasetMetadataAssertion(
            address(9),
            875,
            accessMethod,
            10000,
            associatedDatasetId
        );

        uint64 datasetId = _datasetsHelpers
            .getRoles()
            .datasets()
            .datasetsCount();
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

        _datasetsHelpers.submitDatasetProofWithCarIds(
            address(99),
            datasetId,
            associatedDatasetId,
            DatasetType.DataType.Source,
            "accessmethod",
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

        vm.deal(address(9), 1000 ether);
        vm.startPrank(address(9));
        _datasetsHelpers.getRoles().datasetsProof().completeEscrow(datasetId);
        vm.stopPrank();
        _datasetsHelpers.getRoles().datasetsProof().submitDatasetProofCompleted(
            datasetId
        );
        return datasetId;
    }
}
