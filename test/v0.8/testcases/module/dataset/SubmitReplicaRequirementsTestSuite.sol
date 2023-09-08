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

///@notice submit dataset replica requirement test case with success.
contract SubmitReplicaRequirementsTestCaseWithSuccess is DatasetsTestBase {
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

    function before() internal virtual override returns (uint64) {
        DatasetsTestSetup setup = new DatasetsTestSetup();
        return setup.replicaRequirementTestSetup(datasetsHelpers);
    }

    function action(uint64 _datasetId) internal virtual override {
        address[][] memory dps = datasetsHelpers.generateReplicasActors(
            5,
            3,
            0,
            0,
            address(99)
        );
        address[][] memory sps = datasetsHelpers.generateReplicasActors(
            5,
            3,
            0,
            0,
            address(199)
        );
        uint16[] memory regions = datasetsHelpers.generateReplicasPositions(
            5,
            0
        );
        uint16[] memory countrys = datasetsHelpers.generateReplicasPositions(
            5,
            0
        );
        uint32[][] memory citys = datasetsHelpers.generateReplicasCitys(
            5,
            3,
            0,
            0
        );

        datasetsAssertion.submitDatasetReplicaRequirementsAssertion(
            address(9),
            _datasetId,
            dps,
            sps,
            regions,
            countrys,
            citys
        );
    }
}

///@notice submit dataset replica requirement test case with invalid .
contract SubmitReplicaRequirementsTestCaseWithInvalidReplicas is
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

    function before() internal virtual override returns (uint64) {
        DatasetsTestSetup setup = new DatasetsTestSetup();
        return setup.replicaRequirementTestSetup(datasetsHelpers);
    }

    function action(uint64 _datasetId) internal virtual override {
        address[][] memory dps = datasetsHelpers.generateReplicasActors(
            11,
            3,
            0,
            0,
            address(99)
        );
        address[][] memory sps = datasetsHelpers.generateReplicasActors(
            11,
            3,
            0,
            0,
            address(199)
        );
        uint16[] memory regions = datasetsHelpers.generateReplicasPositions(
            11,
            0
        );
        uint16[] memory countrys = datasetsHelpers.generateReplicasPositions(
            11,
            0
        );
        uint32[][] memory citys = datasetsHelpers.generateReplicasCitys(
            11,
            3,
            0,
            0
        );

        vm.expectRevert(bytes("Invalid replicas count"));
        datasetsAssertion.submitDatasetReplicaRequirementsAssertion(
            address(9),
            _datasetId,
            dps,
            sps,
            regions,
            countrys,
            citys
        );
    }
}

///@notice submit dataset replica requirement test case with duplicate citys .
contract SubmitReplicaRequirementsTestCaseWithDuplicateCitys is
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

    function before() internal virtual override returns (uint64) {
        DatasetsTestSetup setup = new DatasetsTestSetup();
        return setup.replicaRequirementTestSetup(datasetsHelpers);
    }

    function action(uint64 _datasetId) internal virtual override {
        address[][] memory dps = datasetsHelpers.generateReplicasActors(
            5,
            3,
            0,
            0,
            address(99)
        );
        address[][] memory sps = datasetsHelpers.generateReplicasActors(
            5,
            3,
            0,
            0,
            address(199)
        );
        uint16[] memory regions = datasetsHelpers.generateReplicasPositions(
            5,
            0
        );
        uint16[] memory countrys = datasetsHelpers.generateReplicasPositions(
            5,
            0
        );
        uint32[][] memory citys = datasetsHelpers.generateReplicasCitys(
            5,
            3,
            0,
            2
        );

        vm.expectRevert(bytes("Invalid duplicate city"));
        datasetsAssertion.submitDatasetReplicaRequirementsAssertion(
            address(9),
            _datasetId,
            dps,
            sps,
            regions,
            countrys,
            citys
        );
    }
}
