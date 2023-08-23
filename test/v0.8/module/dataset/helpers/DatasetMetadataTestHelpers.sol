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
import {DatasetsEvents} from "src/v0.8/shared/events/DatasetsEvents.sol";
import {DatasetType} from "src/v0.8/types/DatasetType.sol";
import {DatasetTestSetupHelpers} from "test/v0.8/module/dataset/helpers/setup/DatasetTestSetupHelpers.sol";

// Contract definition for test helper functions
contract DatasetMetadataTestHelpers is Test, DatasetTestSetupHelpers {
    /// @dev step 1: setup the env for dataset metadata submission
    function setupForDatasetMetadataSubmission(
        string memory _title,
        string memory _industry,
        string memory _name,
        string memory _description,
        string memory _source,
        string memory _accessMethod,
        uint64 _sizeInBytes,
        bool /*_isPublic*/,
        uint64 /*_version*/
    ) internal pure {
        vm.assume(bytes(_title).length != 0);
        vm.assume(bytes(_industry).length != 0);
        vm.assume(bytes(_name).length != 0);
        vm.assume(bytes(_description).length != 0);
        vm.assume(bytes(_source).length != 0);
        vm.assume(bytes(_accessMethod).length != 0);
        vm.assume(_sizeInBytes != 0);
    }

    /// @dev step 2: do dataset metadata submission action

    /// @dev step 3: assert result after dataset metadata submitted
    function assertDatasetMetadataSubmitted(
        string memory _title,
        string memory /*_industry*/,
        string memory /*_name*/,
        string memory /*_description*/,
        string memory _source,
        string memory _accessMethod,
        uint64 /*_sizeInBytes*/,
        bool /*_isPublic*/,
        uint64 /*_version*/,
        uint64 _oldDatasetsCount
    ) internal {
        assertEq(1, datasets.datasetsCount());
        assertEq(
            uint8(DatasetType.State.MetadataSubmitted),
            uint8(datasets.getDatasetState(1))
        );
        assertTrue(datasets.hasDatasetMetadata(_accessMethod));

        (
            string memory title,
            ,
            ,
            ,
            string memory source,
            string memory accessMethod,
            ,
            ,
            ,
            ,

        ) = datasets.getDatasetMetadata(1);
        assertEq(title, _title);
        assertEq(source, _source);
        assertEq(accessMethod, _accessMethod);
        assertEq(_oldDatasetsCount + 1, datasets.datasetsCount());
    }

    ///@dev success test and  as env set for other module
    function assertDatasetMetadataSubmissionExpectingSuccess(
        string memory _title,
        string memory _industry,
        string memory _name,
        string memory _description,
        string memory _source,
        string memory _accessMethod,
        uint64 _sizeInBytes,
        bool _isPublic,
        uint64 _version
    ) internal {
        /// @dev step 1: setup the env for dataset metadata submission
        setupForDatasetMetadataSubmission(
            _title,
            _industry,
            _name,
            _description,
            _source,
            _accessMethod,
            _sizeInBytes,
            _isPublic,
            _version
        );

        /// @dev step 2: do dataset metadata submission action
        uint64 oldDatasetsCount = datasets.datasetsCount();
        vm.prank(address(10000));
        vm.expectEmit(true, true, false, true);
        emit DatasetsEvents.DatasetMetadataSubmitted(1, address(10000));
        datasets.submitDatasetMetadata(
            _title,
            _industry,
            _name,
            _description,
            _source,
            _accessMethod,
            _sizeInBytes,
            _isPublic,
            _version
        );

        /// @dev step 3: assert result after dataset metadata submitted
        assertDatasetMetadataSubmitted(
            _title,
            _industry,
            _name,
            _description,
            _source,
            _accessMethod,
            _sizeInBytes,
            _isPublic,
            _version,
            oldDatasetsCount
        );
    }
}
