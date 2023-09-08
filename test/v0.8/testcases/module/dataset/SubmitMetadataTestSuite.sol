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
import {DatasetsTestBase} from "test/v0.8/testcases/module/dataset/abstract/DatasetsTestBase.sol";

import {IDatasets} from "src/v0.8/interfaces/module/IDatasets.sol";
import {IDatasetsRequirement} from "src/v0.8/interfaces/module/IDatasetsRequirement.sol";
import {IDatasetsProof} from "src/v0.8/interfaces/module/IDatasetsProof.sol";
import {IDatasetsChallenge} from "src/v0.8/interfaces/module/IDatasetsChallenge.sol";
import {IDatasetsAssertion} from "test/v0.8/interfaces/assertions/module/IDatasetsAssertion.sol";
import {IDatasetsHelpers} from "test/v0.8/interfaces/helpers/module/IDatasetsHelpers.sol";

///@notice submit metadata of dataset test case with success.
contract SubmitMetadataTestCaseWithSuccess is DatasetsTestBase {
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

    function action(uint64 /*_id*/) internal virtual override {
        datasetsAssertion.submitDatasetMetadataAssertion(
            address(9),
            "a",
            "b",
            "c",
            "d",
            "e",
            "accessMethod",
            10000,
            true,
            0
        );
    }
}

///@notice submit metadata of dataset test case with duplicate.
contract SubmitMetadataTestCaseWithDuplicate is DatasetsTestBase {
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

    function action(uint64 /*_id*/) internal virtual override {
        datasetsAssertion.submitDatasetMetadataAssertion(
            address(9),
            "a",
            "b",
            "c",
            "d",
            "e",
            "accessMethod",
            10000,
            true,
            0
        );
        vm.expectRevert(
            abi.encodeWithSelector(
                Errors.DatasetMetadataAlreadyExist.selector,
                "accessMethod"
            )
        );
        datasetsAssertion.submitDatasetMetadataAssertion(
            address(9),
            "a",
            "b",
            "c",
            "d",
            "e",
            "accessMethod",
            10000,
            true,
            0
        );
    }
}
