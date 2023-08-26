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
import {TestHelpers} from "src/v0.8/shared/utils/common/TestHelpers.sol";
import {DatasetType} from "src/v0.8/types/DatasetType.sol";
import {IDatasets} from "src/v0.8/interfaces/module/IDatasets.sol";
import {LeavesGenerator} from "test/v0.8/helpers/utils/LeavesGenerator.sol";
import {DatasetsStepHelpers} from "test/v0.8/helpers/module/dataset/DatasetsStepHelpers.sol";
import {DatasetsAssertion} from "test/v0.8/assertions/module/dataset/DatasetsAssertion.sol";

// Contract definition for test helper functions
contract DatasetsHelpers is Test {
    IDatasets public datasets;
    LeavesGenerator private generator;
    DatasetsStepHelpers private stepHelpers;
    DatasetsAssertion private assertion;

    constructor(
        IDatasets _datasets,
        LeavesGenerator _generator,
        DatasetsStepHelpers _stepHelpers,
        DatasetsAssertion _assertion
    ) {
        datasets = _datasets;
        generator = _generator;
        stepHelpers = _stepHelpers;
        assertion = _assertion;
    }

    //helper need test, make sure ok
    function done(string memory _accessMethod) public {
        // 1 submit meta
        stepHelpers.submitDatasetMetadata(_accessMethod);
        uint64 datasetId = datasets.datasetsCount();
        assertion.getDatasetStateAssertion(
            datasetId,
            DatasetType.State.MetadataSubmitted
        );

        // 2 approve metadata
        datasets.approveDatasetMetadata(datasetId);
        assertion.getDatasetStateAssertion(
            datasetId,
            DatasetType.State.MetadataApproved
        );

        //3 submit proof
        stepHelpers.submitDatasetProof(
            datasetId,
            DatasetType.DataType.MappingFiles,
            10,
            true
        );
        stepHelpers.submitDatasetProof(
            datasetId,
            DatasetType.DataType.Source,
            100,
            false
        );
        stepHelpers.submitDatasetProof(
            datasetId,
            DatasetType.DataType.Source,
            100,
            true
        );
        assertion.getDatasetStateAssertion(
            datasetId,
            DatasetType.State.DatasetProofSubmitted
        );

        //4 approve
        datasets.approveDataset(datasetId);
        assertion.getDatasetStateAssertion(
            datasetId,
            DatasetType.State.DatasetApproved
        );
    }
}
