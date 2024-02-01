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
        return setup.verificationTestSetup(datasetsHelpers, datasets);
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
        return setup.verificationTestSetup(datasetsHelpers, datasets);
    }

    function action(uint64 _id) internal virtual override {
        uint64 pointCount = 1;
        bytes32[] memory leaves = new bytes32[](pointCount);
        bytes32[][] memory siblings = new bytes32[][](pointCount);
        uint32[] memory paths = new uint32[](pointCount);
        uint64 randomSeed;

        datasets.roles().merkleUtils().setMockValidState(false);
        (randomSeed, leaves, siblings, paths) = datasetsHelpers
            .generateVerification(pointCount);

        address admin = datasets.roles().getRoleMember(bytes32(0x00), 0);
        vm.startPrank(admin);
        datasets.roles().grantRole(RolesType.DATASET_AUDITOR, address(200));
        vm.stopPrank();
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

///@notice submit dataset challenge proofs test case with illegal role.
contract SubmittChallengeProofsTestCaseWithIllegalRole is DatasetsTestBase {
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
        return setup.verificationTestSetup(datasetsHelpers, datasets);
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
