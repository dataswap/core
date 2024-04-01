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

import {DatasetsTestSetup} from "test/v0.8/testcases/module/dataset/setup/DatasetsTestSetup.sol";
import {DatasetsTestBase} from "test/v0.8/testcases/module/dataset/abstract/DatasetsTestBase.sol";

import {DatasetType} from "src/v0.8/types/DatasetType.sol";
import {RolesType} from "src/v0.8/types/RolesType.sol";
import {IDatasets} from "src/v0.8/interfaces/module/IDatasets.sol";
import {IDatasetsRequirement} from "src/v0.8/interfaces/module/IDatasetsRequirement.sol";
import {IDatasetsProof} from "src/v0.8/interfaces/module/IDatasetsProof.sol";
import {IDatasetsChallenge} from "src/v0.8/interfaces/module/IDatasetsChallenge.sol";
import {IDatasetsAssertion} from "test/v0.8/interfaces/assertions/module/IDatasetsAssertion.sol";
import {IDatasetsHelpers} from "test/v0.8/interfaces/helpers/module/IDatasetsHelpers.sol";
import {FinanceType} from "src/v0.8/types/FinanceType.sol";

///@notice submit dataset challenge proofs test case with success.
contract SubmittChallengeProofsTestCaseWithSuccess is DatasetsTestBase {
    constructor(
        IDatasets _datasets,
        IDatasetsRequirement _datasetsRequirement,
        IDatasetsProof _datasetsProof,
        IDatasetsChallenge _datasetsChallenge,
        IDatasetsHelpers _datasetsHelpers,
        IDatasetsAssertion _datasetsAssertion
    )
        DatasetsTestBase(
            _datasets,
            _datasetsRequirement,
            _datasetsProof,
            _datasetsChallenge,
            _datasetsHelpers,
            _datasetsAssertion
        ) // solhint-disable-next-line
    {}

    function before() internal virtual override returns (uint64 id) {
        DatasetsTestSetup setup = new DatasetsTestSetup();
        return
            setup.completeAuditorElectionTestSetup(
                datasetsHelpers,
                address(199)
            );
    }

    function action(uint64 _id) internal virtual override {
        uint64 pointCount = datasets
            .roles()
            .filplus()
            .datasetRuleChallengePointsPerAuditor();
        bytes32[] memory leaves = new bytes32[](pointCount);
        bytes32[][] memory siblings = new bytes32[][](pointCount);
        uint32[] memory paths = new uint32[](pointCount);
        uint64 randomSeed;

        datasetsAssertion.isWinnerAssersion(_id, address(199), true);

        (randomSeed, leaves, siblings, paths) = datasetsHelpers
            .generateVerification(pointCount);

        datasetsAssertion.submitDatasetChallengeProofsAssertion(
            address(199),
            _id,
            randomSeed,
            leaves,
            siblings,
            paths
        );
    }
}

///@notice submit dataset challenge proofs test case with fail.
contract SubmittChallengeProofsTestCaseWithFail is DatasetsTestBase {
    constructor(
        IDatasets _datasets,
        IDatasetsRequirement _datasetsRequirement,
        IDatasetsProof _datasetsProof,
        IDatasetsChallenge _datasetsChallenge,
        IDatasetsHelpers _datasetsHelpers,
        IDatasetsAssertion _datasetsAssertion
    )
        DatasetsTestBase(
            _datasets,
            _datasetsRequirement,
            _datasetsProof,
            _datasetsChallenge,
            _datasetsHelpers,
            _datasetsAssertion
        ) // solhint-disable-next-line
    {}

    function before() internal virtual override returns (uint64 id) {
        DatasetsTestSetup setup = new DatasetsTestSetup();
        return
            setup.completeAuditorElectionTestSetup(
                datasetsHelpers,
                address(200)
            );
    }

    function action(uint64 _id) internal virtual override {
        uint64 pointCount = datasets
            .roles()
            .filplus()
            .datasetRuleChallengePointsPerAuditor();
        bytes32[] memory leaves = new bytes32[](pointCount);
        bytes32[][] memory siblings = new bytes32[][](pointCount);
        uint32[] memory paths = new uint32[](pointCount);
        uint64 randomSeed;

        datasets.roles().merkleUtils().setMockValidState(false);
        (randomSeed, leaves, siblings, paths) = datasetsHelpers
            .generateVerification(pointCount);

        vm.expectRevert(bytes("mockValidState must is true"));
        datasetsAssertion.submitDatasetChallengeProofsAssertion(
            address(200),
            _id,
            randomSeed,
            leaves,
            siblings,
            paths
        );
    }
}

///@notice submit dataset challenge proofs test case with timeout.
contract SubmittChallengeProofsTestCaseWithTimeout is DatasetsTestBase {
    constructor(
        IDatasets _datasets,
        IDatasetsRequirement _datasetsRequirement,
        IDatasetsProof _datasetsProof,
        IDatasetsChallenge _datasetsChallenge,
        IDatasetsHelpers _datasetsHelpers,
        IDatasetsAssertion _datasetsAssertion
    )
        DatasetsTestBase(
            _datasets,
            _datasetsRequirement,
            _datasetsProof,
            _datasetsChallenge,
            _datasetsHelpers,
            _datasetsAssertion
        ) // solhint-disable-next-line
    {}

    function before() internal virtual override returns (uint64 id) {
        DatasetsTestSetup setup = new DatasetsTestSetup();
        return
            setup.completeAuditorElectionTestSetup(
                datasetsHelpers,
                address(199)
            );
    }

    function action(uint64 _id) internal virtual override {
        uint64 pointCount = datasets
            .roles()
            .filplus()
            .datasetRuleChallengePointsPerAuditor();
        bytes32[] memory leaves = new bytes32[](pointCount);
        bytes32[][] memory siblings = new bytes32[][](pointCount);
        uint32[] memory paths = new uint32[](pointCount);
        uint64 randomSeed;
        (randomSeed, leaves, siblings, paths) = datasetsHelpers
            .generateVerification(pointCount);

        vm.roll(1000000);
        vm.prank(address(199));
        datasetsChallenge.submitDatasetChallengeProofs(
            _id,
            randomSeed,
            leaves,
            siblings,
            paths
        );

        datasetsAssertion.getDatasetStateAssertion(
            _id,
            DatasetType.State.Rejected
        );
    }
}

///@notice submit dataset challenge proofs test case with success.
contract ResubmittDatasetChallengeProofsTestCaseWithSuccess is
    DatasetsTestBase
{
    constructor(
        IDatasets _datasets,
        IDatasetsRequirement _datasetsRequirement,
        IDatasetsProof _datasetsProof,
        IDatasetsChallenge _datasetsChallenge,
        IDatasetsHelpers _datasetsHelpers,
        IDatasetsAssertion _datasetsAssertion
    )
        DatasetsTestBase(
            _datasets,
            _datasetsRequirement,
            _datasetsProof,
            _datasetsChallenge,
            _datasetsHelpers,
            _datasetsAssertion
        ) // solhint-disable-next-line
    {}

    function before() internal virtual override returns (uint64 id) {
        DatasetsTestSetup setup = new DatasetsTestSetup();
        return
            setup.challengeTestForResubmitDatasetSetup(
                datasetsHelpers,
                datasetsAssertion
            );
    }

    function action(uint64 _id) internal virtual override {
        uint64 pointCount = datasets
            .roles()
            .filplus()
            .datasetRuleChallengePointsPerAuditor();
        bytes32[] memory leaves = new bytes32[](pointCount);
        bytes32[][] memory siblings = new bytes32[][](pointCount);
        uint32[] memory paths = new uint32[](pointCount);
        uint64 randomSeed;
        (randomSeed, leaves, siblings, paths) = datasetsHelpers
            .generateVerification(pointCount);

        vm.startPrank(address(199));
        vm.deal(address(199), 1000 ether);
        datasets.roles().finance().deposit{value: 1000 ether}(
            _id,
            0,
            address(199),
            FinanceType.FIL
        );
        datasetsChallenge.nominateAsDatasetAuditorCandidate(_id);
        vm.stopPrank();
        uint64 delayBlocks = datasetsChallenge.getAuditorElectionEndHeight(_id);
        vm.roll(delayBlocks);

        datasetsAssertion.submitDatasetChallengeProofsAssertion(
            address(199),
            _id,
            randomSeed,
            leaves,
            siblings,
            paths
        );
    }
}
