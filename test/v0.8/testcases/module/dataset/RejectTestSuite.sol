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

import {Errors} from "src/v0.8/shared/errors/Errors.sol";
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

///@notice reject dataset test caset with success.
contract RejectTestCaseWithSuccess is DatasetsTestBase {
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
        address admin = datasets.roles().getRoleMember(bytes32(0x00), 0);
        vm.startPrank(admin);
        datasets.roles().grantRole(
            RolesType.DATASWAP_CONTRACT,
            datasets.governanceAddress()
        );
        vm.stopPrank();
        DatasetsTestSetup setup = new DatasetsTestSetup();
        return setup.verificationTestSetup(datasetsHelpers);
    }

    function action(uint64 _id) internal virtual override {
        datasetsAssertion.rejectDatasetAssertion(
            datasets.governanceAddress(),
            _id
        );
    }
}

///@notice reject dataset test caset with invalid address.
contract RejectTestCaseWithInvalidAddress is DatasetsTestBase {
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
        return setup.verificationTestSetup(datasetsHelpers);
    }

    function action(uint64 _id) internal virtual override {
        vm.expectRevert(bytes("Only allowed role can call"));
        datasetsAssertion.rejectDatasetAssertion(address(8), _id);
    }
}

///@notice reject of dataset test caset with zero dataset id.
contract RejectTestCaseWithZeroID is DatasetsTestBase {
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
        address admin = datasets.roles().getRoleMember(bytes32(0x00), 0);
        vm.startPrank(admin);
        datasets.roles().grantRole(
            RolesType.DATASWAP_CONTRACT,
            datasets.governanceAddress()
        );
        vm.stopPrank();
        return 0;
    }

    function action(uint64) internal virtual override {
        // Perform the action.
        vm.prank(datasets.governanceAddress());
        vm.expectRevert(bytes("Value must not be zero"));
        datasets.__rejectDataset(0);
    }
}

///@notice reject of dataset test caset with invalid state.
contract RejectTestCaseWithInvalidState is DatasetsTestBase {
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
        address admin = datasets.roles().getRoleMember(bytes32(0x00), 0);
        vm.startPrank(admin);
        datasets.roles().grantRole(
            RolesType.DATASWAP_CONTRACT,
            datasets.governanceAddress()
        );
        vm.stopPrank();
        DatasetsTestSetup setup = new DatasetsTestSetup();
        return setup.verificationTestSetup(datasetsHelpers);
    }

    function action(uint64 _id) internal virtual override {
        // Perform the action.
        vm.prank(datasets.governanceAddress());
        datasets.__rejectDataset(_id);
        vm.expectRevert(
            abi.encodeWithSelector(Errors.InvalidDatasetState.selector, _id)
        );
        datasets.__rejectDataset(_id);
    }
}
