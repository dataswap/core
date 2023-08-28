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
import {IRoles} from "src/v0.8/interfaces/core/IRoles.sol";
import {RolesType} from "src/v0.8/types/RolesType.sol";
import {IDatasets} from "src/v0.8/interfaces/module/IDatasets.sol";
import {IDatasetsAssertion} from "test/v0.8/interfaces/assertions/module/IDatasetsAssertion.sol";
import {IDatasetsHelpers} from "test/v0.8/interfaces/helpers/module/IDatasetsHelpers.sol";

///@notice submit dataset proof test case with success.
contract SubmitProofTestCaseWithSuccess is DatasetsTestBase {
    constructor(
        IDatasets _datasets,
        IDatasetsHelpers _datasetsHelpers,
        IDatasetsAssertion _datasetsAssertion
    )
        DatasetsTestBase(_datasets, _datasetsHelpers, _datasetsAssertion) // solhint-disable-next-line
    {}

    function before() internal virtual override returns (uint64) {
        uint64 datasetId = datasetsHelpers.submitDatasetMetadata(
            address(9),
            "TEST"
        );
        vm.prank(datasets.governanceAddress());
        datasets.approveDatasetMetadata(datasetId);
        return datasetId;
    }

    function action(uint64 _datasetId) internal virtual override {
        bytes32 sourceRoot = datasetsHelpers.generateRoot();
        uint64 sourceLeavesCount = 100;
        bytes32[] memory sourceLeavesHashes = new bytes32[](sourceLeavesCount);
        uint64[] memory sourceLeavesSizes = new uint64[](sourceLeavesCount);
        // firset submit
        (sourceLeavesHashes, sourceLeavesSizes, ) = datasetsHelpers
            .generateProof(sourceLeavesCount);
        // vm.prank();
        address admin = datasets.roles().getRoleMember(bytes32(0x00), 0);
        vm.startPrank(admin);
        datasets.roles().grantRole(RolesType.DATASET_PROVIDER, address(99));
        vm.stopPrank();
        datasetsAssertion.submitDatasetProofAssertion(
            address(99),
            _datasetId,
            DatasetType.DataType.Source,
            "",
            sourceRoot,
            sourceLeavesHashes,
            sourceLeavesSizes,
            false
        );

        // second submit
        (sourceLeavesHashes, sourceLeavesSizes, ) = datasetsHelpers
            .generateProof(sourceLeavesCount);
        datasetsAssertion.submitDatasetProofAssertion(
            address(99),
            _datasetId,
            DatasetType.DataType.Source,
            "",
            sourceRoot,
            sourceLeavesHashes,
            sourceLeavesSizes,
            true
        );
    }
}
