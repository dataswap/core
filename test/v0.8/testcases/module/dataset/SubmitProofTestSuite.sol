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

///@notice submit dataset proof test case with success.
contract SubmitProofTestCaseWithSuccess is DatasetsTestBase {
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
        return setup.proofTestSetup(datasetsHelpers, datasets);
    }

    function action(uint64 _datasetId) internal virtual override {
        bytes32 sourceRoot = datasetsHelpers.generateRoot();
        uint64 sourceLeavesCount = 100;
        bytes32[] memory sourceLeavesHashes = new bytes32[](sourceLeavesCount);
        uint64[] memory sourceLeavesIndexs = new uint64[](sourceLeavesCount);
        uint64[] memory sourceLeavesSizes = new uint64[](sourceLeavesCount);
        // firset submit
        (
            sourceLeavesHashes,
            sourceLeavesIndexs,
            sourceLeavesSizes,

        ) = datasetsHelpers.generateProof(
            sourceLeavesCount,
            DatasetType.DataType.Source,
            0
        );
        // vm.prank();
        datasetsAssertion.submitDatasetProofRootAssertion(
            address(99),
            _datasetId,
            DatasetType.DataType.Source,
            "",
            sourceRoot
        );
        datasetsAssertion.submitDatasetProofAssertion(
            address(99),
            _datasetId,
            DatasetType.DataType.Source,
            sourceLeavesHashes,
            sourceLeavesIndexs[0],
            sourceLeavesSizes,
            false
        );

        uint64 count = datasetsProof.getDatasetProofCount(
            _datasetId,
            DatasetType.DataType.Source
        );
        // second submit
        (
            sourceLeavesHashes,
            sourceLeavesIndexs,
            sourceLeavesSizes,

        ) = datasetsHelpers.generateProof(
            sourceLeavesCount,
            DatasetType.DataType.Source,
            count
        );

        datasetsAssertion.submitDatasetProofAssertion(
            address(99),
            _datasetId,
            DatasetType.DataType.Source,
            sourceLeavesHashes,
            sourceLeavesIndexs[0],
            sourceLeavesSizes,
            true
        );
    }
}

///@notice submit dataset proof test case with invalid submitter.
contract SubmitProofTestCaseWithInvalidSubmitter is DatasetsTestBase {
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
        return setup.proofTestSetup(datasetsHelpers, datasets);
    }

    function action(uint64 _datasetId) internal virtual override {
        bytes32 sourceRoot = datasetsHelpers.generateRoot();
        uint64 sourceLeavesCount = 100;
        bytes32[] memory sourceLeavesHashes = new bytes32[](sourceLeavesCount);
        uint64[] memory sourceLeavesIndexs = new uint64[](sourceLeavesCount);
        uint64[] memory sourceLeavesSizes = new uint64[](sourceLeavesCount);
        // firset submit
        (
            sourceLeavesHashes,
            sourceLeavesIndexs,
            sourceLeavesSizes,

        ) = datasetsHelpers.generateProof(
            sourceLeavesCount,
            DatasetType.DataType.Source,
            0
        );
        // vm.prank();
        datasetsAssertion.submitDatasetProofRootAssertion(
            address(99),
            _datasetId,
            DatasetType.DataType.Source,
            "",
            sourceRoot
        );

        datasetsAssertion.submitDatasetProofAssertion(
            address(99),
            _datasetId,
            DatasetType.DataType.Source,
            sourceLeavesHashes,
            sourceLeavesIndexs[0],
            sourceLeavesSizes,
            false
        );

        uint64 count = datasetsProof.getDatasetProofCount(
            _datasetId,
            DatasetType.DataType.Source
        );

        // second submit
        (
            sourceLeavesHashes,
            sourceLeavesIndexs,
            sourceLeavesSizes,

        ) = datasetsHelpers.generateProof(
            sourceLeavesCount,
            DatasetType.DataType.Source,
            count
        );
        vm.expectRevert(bytes("Invalid Dataset submitter"));
        datasetsAssertion.submitDatasetProofAssertion(
            address(199),
            _datasetId,
            DatasetType.DataType.Source,
            sourceLeavesHashes,
            sourceLeavesIndexs[0],
            sourceLeavesSizes,
            true
        );
    }
}

///@notice submit dataset proof test case with invalid index.
contract SubmitProofTestCaseWithInvalidIndex is DatasetsTestBase {
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
        return setup.proofTestSetup(datasetsHelpers, datasets);
    }

    function action(uint64 _datasetId) internal virtual override {
        bytes32 sourceRoot = datasetsHelpers.generateRoot();
        uint64 sourceLeavesCount = 100;
        bytes32[] memory sourceLeavesHashes = new bytes32[](sourceLeavesCount);
        uint64[] memory sourceLeavesIndexs = new uint64[](sourceLeavesCount);
        uint64[] memory sourceLeavesSizes = new uint64[](sourceLeavesCount);
        // firset submit
        (
            sourceLeavesHashes,
            sourceLeavesIndexs,
            sourceLeavesSizes,

        ) = datasetsHelpers.generateProof(
            sourceLeavesCount,
            DatasetType.DataType.Source,
            0
        );
        // vm.prank();
        datasetsAssertion.submitDatasetProofRootAssertion(
            address(99),
            _datasetId,
            DatasetType.DataType.Source,
            "",
            sourceRoot
        );

        datasetsAssertion.submitDatasetProofAssertion(
            address(99),
            _datasetId,
            DatasetType.DataType.Source,
            sourceLeavesHashes,
            sourceLeavesIndexs[0],
            sourceLeavesSizes,
            false
        );

        uint64 count = datasetsProof.getDatasetProofCount(
            _datasetId,
            DatasetType.DataType.Source
        );

        // second submit
        (
            sourceLeavesHashes,
            sourceLeavesIndexs,
            sourceLeavesSizes,

        ) = datasetsHelpers.generateProof(
            sourceLeavesCount,
            DatasetType.DataType.Source,
            count + 10
        );
        vm.expectRevert(bytes("index must match Count"));
        datasetsAssertion.submitDatasetProofAssertion(
            address(99),
            _datasetId,
            DatasetType.DataType.Source,
            sourceLeavesHashes,
            sourceLeavesIndexs[0],
            sourceLeavesSizes,
            true
        );
    }
}

///@notice submit dataset proof test case with invalid proportion.
contract SubmitProofTestCaseWithInvalidProportion is DatasetsTestBase {
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
        return setup.proofTestSetup(datasetsHelpers, datasets);
    }

    function action(uint64 _datasetId) internal virtual override {
        bytes32 sourceRoot = datasetsHelpers.generateRoot();
        uint64 sourceLeavesCount = 100;
        bytes32[] memory sourceLeavesHashes = new bytes32[](sourceLeavesCount);
        uint64[] memory sourceLeavesIndexs = new uint64[](sourceLeavesCount);
        uint64[] memory sourceLeavesSizes = new uint64[](sourceLeavesCount);
        // firset submit
        (
            sourceLeavesHashes,
            sourceLeavesIndexs,
            sourceLeavesSizes,

        ) = datasetsHelpers.generateProof(
            sourceLeavesCount,
            DatasetType.DataType.Source,
            0
        );
        // vm.prank();
        datasetsAssertion.submitDatasetProofRootAssertion(
            address(99),
            _datasetId,
            DatasetType.DataType.Source,
            "",
            sourceRoot
        );
        datasetsAssertion.submitDatasetProofAssertion(
            address(99),
            _datasetId,
            DatasetType.DataType.Source,
            sourceLeavesHashes,
            sourceLeavesIndexs[0],
            sourceLeavesSizes,
            true
        );

        (
            sourceLeavesHashes,
            sourceLeavesIndexs,
            sourceLeavesSizes,

        ) = datasetsHelpers.generateProof(
            sourceLeavesCount,
            DatasetType.DataType.MappingFiles,
            0
        );

        vm.expectRevert(bytes("Invalid mappingFiles percentage"));
        datasetsAssertion.submitDatasetProofAssertion(
            address(99),
            _datasetId,
            DatasetType.DataType.MappingFiles,
            sourceLeavesHashes,
            sourceLeavesIndexs[0],
            sourceLeavesSizes,
            true
        );
    }
}

///@notice submit dataset proof test case with timeout.
contract SubmitProofTestCaseWithTimeout is DatasetsTestBase {
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
        return setup.proofTestSetup(datasetsHelpers, datasets);
    }

    function action(uint64 _datasetId) internal virtual override {
        bytes32 sourceRoot = datasetsHelpers.generateRoot();
        uint64 sourceLeavesCount = 100;
        bytes32[] memory sourceLeavesHashes = new bytes32[](sourceLeavesCount);
        uint64[] memory sourceLeavesIndexs = new uint64[](sourceLeavesCount);
        uint64[] memory sourceLeavesSizes = new uint64[](sourceLeavesCount);
        // firset submit
        (
            sourceLeavesHashes,
            sourceLeavesIndexs,
            sourceLeavesSizes,

        ) = datasetsHelpers.generateProof(
            sourceLeavesCount,
            DatasetType.DataType.Source,
            0
        );
        // vm.prank();
        datasetsAssertion.submitDatasetProofRootAssertion(
            address(99),
            _datasetId,
            DatasetType.DataType.Source,
            "",
            sourceRoot
        );
        datasetsAssertion.submitDatasetProofAssertion(
            address(99),
            _datasetId,
            DatasetType.DataType.Source,
            sourceLeavesHashes,
            sourceLeavesIndexs[0],
            sourceLeavesSizes,
            false
        );

        uint64 count = datasetsProof.getDatasetProofCount(
            _datasetId,
            DatasetType.DataType.Source
        );
        // second submit
        (
            sourceLeavesHashes,
            sourceLeavesIndexs,
            sourceLeavesSizes,

        ) = datasetsHelpers.generateProof(
            sourceLeavesCount,
            DatasetType.DataType.Source,
            count
        );
        vm.roll(1000000);
        vm.prank(address(99));
        datasetsProof.submitDatasetProof(
            _datasetId,
            DatasetType.DataType.Source,
            sourceLeavesHashes,
            sourceLeavesIndexs[0],
            sourceLeavesSizes,
            true
        );
        datasetsAssertion.getDatasetStateAssertion(
            _datasetId,
            DatasetType.State.Rejected
        );
    }
}
