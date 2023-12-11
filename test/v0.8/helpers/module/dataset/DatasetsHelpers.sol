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
import {IDatasetsHelpers} from "test/v0.8/interfaces/helpers/module/IDatasetsHelpers.sol";

import {RolesType} from "src/v0.8/types/RolesType.sol";
import {DatasetType} from "src/v0.8/types/DatasetType.sol";
import {IDatasets} from "src/v0.8/interfaces/module/IDatasets.sol";
import {IDatasetsRequirement} from "src/v0.8/interfaces/module/IDatasetsRequirement.sol";
import {IDatasetsProof} from "src/v0.8/interfaces/module/IDatasetsProof.sol";
import {IDatasetsChallenge} from "src/v0.8/interfaces/module/IDatasetsChallenge.sol";
import {Generator} from "test/v0.8/helpers/utils/Generator.sol";
import {IDatasetsAssertion} from "test/v0.8/interfaces/assertions/module/IDatasetsAssertion.sol";

// Contract definition for test helper functions
contract DatasetsHelpers is Test, IDatasetsHelpers {
    IDatasets public datasets;
    IDatasetsRequirement public datasetsRequirement;
    IDatasetsProof public datasetsProof;
    IDatasetsChallenge public datasetsChallenge;
    Generator private generator;
    IDatasetsAssertion private assertion;

    constructor(
        IDatasets _datasets,
        IDatasetsRequirement _datasetsRequirement,
        IDatasetsProof _datasetsProof,
        IDatasetsChallenge _datasetsChallenge,
        Generator _generator,
        IDatasetsAssertion _assertion
    ) {
        datasets = _datasets;
        datasetsRequirement = _datasetsRequirement;
        datasetsProof = _datasetsProof;
        datasetsChallenge = _datasetsChallenge;
        generator = _generator;
        assertion = _assertion;
    }

    ///  @notice Submit metadata for a dataset.
    ///  @param caller The address of the caller.
    ///  @param _accessMethod The access method for the dataset.
    ///  @return datasetId The ID of the created dataset.
    function submitDatasetMetadata(
        address caller,
        string memory _accessMethod
    ) public returns (uint64 datasetId) {
        uint64 datasetCount = datasets.datasetsCount();
        vm.prank(caller);
        vm.deal(caller, 10 ether);
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

    /// @notice Generate a Merkle root hash.
    /// @return The generated Merkle root hash.
    function generateRoot() public returns (bytes32) {
        return generator.generateRoot();
    }

    ///  @notice Generate Merkle proof data.
    ///  @param _leavesCount The number of leaves in the Merkle tree.
    ///  @param _dataType The data type of the dataset.
    ///  @param _offset The offset of leaves in the Merkle tree.
    ///  @return leavesHashes The hashes of Merkle tree leaves.
    ///  @return leavesIndexs The index of Merkle tree leaves.
    ///  @return leavesSizes The sizes of Merkle tree leaves.
    ///  @return The total size of the Merkle tree.
    function generateProof(
        uint64 _leavesCount,
        DatasetType.DataType _dataType,
        uint64 _offset
    )
        public
        returns (
            bytes32[] memory leavesHashes,
            uint64[] memory leavesIndexs,
            uint64[] memory leavesSizes,
            uint64
        )
    {
        return
            generator.generateLeavesAndSizes(_leavesCount, _dataType, _offset);
    }

    ///  @notice Generate actors of replicas.
    ///  @param _replicasCount The number of car's replicas.
    ///  @param _countPerReplica The actor's number of a replica.
    ///  @param _duplicateInReplicas The duplicate number of replicas.
    ///  @param _duplicatePerReplica The duplicate number per replica.
    ///  @param _contain The member that mast in actors.
    ///  @return The total size of the Merkle tree.
    function generateReplicasActors(
        uint16 _replicasCount,
        uint16 _countPerReplica,
        uint16 _duplicateInReplicas,
        uint16 _duplicatePerReplica,
        address _contain
    ) public returns (address[][] memory) {
        return
            generator.generateGeolocationActors(
                _replicasCount,
                _countPerReplica,
                _duplicateInReplicas,
                _duplicatePerReplica,
                _contain
            );
    }

    /// @notice Generate an array of uint16 for testing.
    /// @param _count The number of row element's count.
    /// @param _duplicate The duplicate number of row elements.
    /// @return An array of uint16[].
    function generateReplicasPositions(
        uint16 _count,
        uint16 _duplicate
    ) public returns (uint16[] memory) {
        return generator.generateGeolocationPositions(_count, _duplicate);
    }

    /// @notice Generate an two-dimensional of uint32 for testing.
    ///  @param _replicasCount The number of car's replicas.
    ///  @param _countPerReplica The city's number of a replica.
    ///  @param _duplicateInReplicas The duplicate city's number of replicas.
    ///  @param _duplicatePerReplica The duplicate city's number per replica.
    /// @return An array of uint32[][].
    function generateReplicasCitys(
        uint16 _replicasCount,
        uint16 _countPerReplica,
        uint16 _duplicateInReplicas,
        uint16 _duplicatePerReplica
    ) public returns (uint32[][] memory) {
        return
            generator.generateGeolocationCitys(
                _replicasCount,
                _countPerReplica,
                _duplicateInReplicas,
                _duplicatePerReplica
            );
    }

    /// @notice Submit a proof for a dataset.
    /// @param caller The address of the caller.
    /// @param _datasetId The ID of the dataset.
    /// @param _dataType The data type of the dataset.
    /// @param _accessMethod The access method for the dataset.
    /// @param _leavesCount The number of leaves in the Merkle tree.
    /// @param _complete A flag indicating if the proof is complete.
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
        uint64[] memory leavesIndexs = new uint64[](_leavesCount);
        uint64[] memory leavesSizes = new uint64[](_leavesCount);
        uint64 count = datasetsProof.getDatasetProofCount(
            _datasetId,
            _dataType
        );
        (leavesHashes, leavesIndexs, leavesSizes, ) = generateProof(
            _leavesCount,
            _dataType,
            count
        );
        vm.prank(caller);
        datasetsProof.submitDatasetProofRoot(
            _datasetId,
            _dataType,
            _accessMethod,
            root
        );

        vm.prank(caller);
        datasetsProof.submitDatasetProof(
            _datasetId,
            _dataType,
            leavesHashes,
            leavesIndexs[0],
            leavesSizes,
            _complete
        );
    }

    ///@notice Submit replica requirement for a dataset.
    /// @param caller The address of the caller.
    /// @param _datasetId The ID of the dataset for which proof is submitted.
    /// @param _replicasCount The number of replicas of the dataset.
    /// @param _duplicateDataPreparers The duplicate count of the data prepares.
    /// @param _duplicateStorageProviders The duplicate count of the storage providers.
    /// @param _duplicateRegions The duplicate count of the regions.
    /// @param _duplicateCountrys The duplicate count of the data countrys.
    /// @param _duplicateCitys The duplicate count of the data citys.
    function submitDatasetReplicaRequirements(
        address caller,
        uint64 _datasetId,
        uint16 _replicasCount,
        uint16 _duplicateDataPreparers,
        uint16 _duplicateStorageProviders,
        uint16 _duplicateRegions,
        uint16 _duplicateCountrys,
        uint16 _duplicateCitys
    ) public {
        vm.startPrank(caller);
        datasetsRequirement.submitDatasetReplicaRequirements(
            _datasetId,
            generator.generateGeolocationActors(
                _replicasCount,
                3,
                _duplicateDataPreparers,
                0,
                address(99)
            ),
            generator.generateGeolocationActors(
                _replicasCount,
                3,
                _duplicateStorageProviders,
                0,
                address(199)
            ),
            generator.generateGeolocationPositions(
                _replicasCount,
                _duplicateRegions
            ),
            generator.generateGeolocationPositions(
                _replicasCount,
                _duplicateCountrys
            ),
            generator.generateGeolocationCitys(
                _replicasCount,
                3,
                _duplicateCitys,
                0
            ),
            0
        );
        vm.stopPrank();
    }

    /// @notice Generate Merkle verification data.
    /// @param _pointCount The number of points to generate.
    /// @return randomSeed The random seed used for generation.
    /// @return leaves The leaves hashes for each point.
    /// @return siblings The sibling hashes for each point.
    /// @return paths The paths for each point.
    function generateVerification(
        uint64 _pointCount
    )
        public
        returns (
            uint64 randomSeed,
            bytes32[] memory leaves,
            bytes32[][] memory siblings,
            uint32[] memory paths
        )
    {
        randomSeed = generator.generateNonce();
        leaves = new bytes32[](_pointCount);
        siblings = new bytes32[][](_pointCount);
        paths = new uint32[](_pointCount);
        for (uint32 i = 0; i < _pointCount; i++) {
            bytes32[] memory tmpLeaves = new bytes32[](1);
            (tmpLeaves, ) = generator.generateLeaves(1, 0);
            leaves[i] = tmpLeaves[0];
            (siblings[i], ) = generator.generateLeaves(_pointCount, 0);
            paths[i] = i;
        }
    }

    ///  @notice Submit verification data for a dataset.
    ///  @param caller The address of the caller.
    ///  @param _datasetId The ID of the dataset.
    function submitDatasetVerification(
        address caller,
        uint64 _datasetId
    ) public {
        uint64 randomSeed = generator.generateNonce();
        uint64 challengeCount = datasetsChallenge.getChallengeSubmissionCount(
            _datasetId
        );
        assertion.getChallengeSubmissionCountAssertion(
            _datasetId,
            challengeCount
        );
        bytes32[][] memory siblings = new bytes32[][](challengeCount);
        uint32[] memory paths = new uint32[](challengeCount);
        bytes32[] memory leaves = new bytes32[](challengeCount);
        for (uint32 i = 0; i < challengeCount; i++) {
            bytes32[] memory tmpLeaves = new bytes32[](1);
            (tmpLeaves, ) = generator.generateLeaves(1, 0);
            leaves[i] = tmpLeaves[0];
            (siblings[i], ) = generator.generateLeaves(challengeCount, 0);
            paths[i] = i;
        }
        vm.prank(caller);
        datasetsChallenge.submitDatasetChallengeProofs(
            _datasetId,
            randomSeed,
            leaves,
            siblings,
            paths
        );
    }

    /// @notice Complete the dataset workflow.
    /// @param _accessMethod The access method for the dataset.
    /// @param _sourceLeavesCount The number of leaves for the source data.
    /// @param _mappingFilesLeavesCount The number of leaves for the mapping files data.
    /// @return datasetId The ID of the created dataset.
    function completeDatasetWorkflow(
        string memory _accessMethod,
        uint64 _sourceLeavesCount,
        uint64 _mappingFilesLeavesCount
    ) external returns (uint64 datasetId) {
        // 1: Submit metadata
        address admin = datasets.roles().getRoleMember(bytes32(0x00), 0);
        vm.startPrank(admin);
        datasets.roles().grantRole(RolesType.DATASET_PROVIDER, address(9));
        vm.stopPrank();
        datasetId = submitDatasetMetadata(address(9), _accessMethod);

        submitDatasetReplicaRequirements(
            address(9),
            datasetId,
            5,
            0,
            0,
            0,
            0,
            0
        );

        // 2: Approve metadata
        assertion.approveDatasetMetadataAssertion(
            datasets.governanceAddress(),
            datasetId
        );

        // 3: Submit proof
        vm.startPrank(admin);
        datasets.roles().grantRole(RolesType.DATASET_PROVIDER, address(99));
        vm.stopPrank();
        submitDatasetProof(
            address(99),
            datasetId,
            DatasetType.DataType.Source,
            _accessMethod,
            _sourceLeavesCount,
            true
        );
        submitDatasetProof(
            address(99),
            datasetId,
            DatasetType.DataType.MappingFiles,
            _accessMethod,
            _mappingFilesLeavesCount,
            true
        );
        uint256 collateralRequirement = datasetsProof
            .getDatasetAppendCollateral(datasetId);
        uint256 datasetAuditorFee = datasetsProof
            .getDatasetDataAuditorFeesRequirement(datasetId);
        vm.deal(address(9), 100 ether);
        vm.prank(address(9));
        datasetsProof.appendDatasetFunds{value: 100 ether}(
            datasetId,
            collateralRequirement,
            datasetAuditorFee
        );

        datasetsProof.submitDatasetProofCompleted(datasetId);
        vm.startPrank(admin);
        datasets.roles().grantRole(RolesType.DATASET_AUDITOR, address(299));
        vm.stopPrank();
        // 4: Submit verification
        submitDatasetVerification(address(299), datasetId);

        // 5: Approve dataset
        assertion.approveDatasetAssertion(
            datasets.governanceAddress(),
            datasetId
        );
    }

    /// @notice Get datasetsProof object
    function getDatasetsProof() external view returns (IDatasetsProof) {
        return datasetsProof;
    }
}
