/*******************************************************************************
 *   (c) 2023 DataSwap
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
import "forge-std/Test.sol";
import {ICarstore} from "../../../../../src/v0.8/interfaces/core/ICarstore.sol";
import {IRoles} from "../../../../../src/v0.8/interfaces/core/IRoles.sol";
import {IFilplus} from "../../../../../src/v0.8/interfaces/core/IFilplus.sol";
import {IFilecoin} from "../../../../../src/v0.8/interfaces/core/IFilecoin.sol";
import {Roles} from "../../../../../src/v0.8/core/access/Roles.sol";
import {Filplus} from "../../../../../src/v0.8/core/filplus/Filplus.sol";
import {MockFilecoin} from "../../../../../src/v0.8/mocks/core/filecoin/MockFilecoin.sol";

// Import various shared modules, modifiers, events, and error definitions
import {CarstoreModifiers} from "../../../../../src/v0.8/shared/modifiers/CarstoreModifiers.sol";
import {CarstoreEvents} from "../../../../../src/v0.8/shared/events/CarstoreEvents.sol";
import {DatasetsEvents} from "../../../../../src/v0.8/shared/events/DatasetsEvents.sol";
import {Errors} from "../../../../../src/v0.8/shared/errors/Errors.sol";

// Import necessary custom types
import {CarReplicaType} from "../../../../../src/v0.8/types/CarReplicaType.sol";
import {Carstore} from "../../../../../src/v0.8/core/carstore/Carstore.sol";
import {Datasets} from "../../../../../src/v0.8/module/dataset/Datasets.sol";
import {FilecoinType} from "../../../../../src/v0.8/types/FilecoinType.sol";
import {DatasetType} from "../../../../../src/v0.8/types/DatasetType.sol";

// Contract definition for test helper functions
contract DatasetTestHelpers is Test {
    Datasets datasets;
    address payable governanceContractAddresss;
    Roles role = new Roles();
    Filplus filplus = new Filplus(governanceContractAddresss);
    MockFilecoin filecoin = new MockFilecoin();
    Carstore carstore = new Carstore(role, filplus, filecoin);

    // Helper function to set up the initial environment
    function setUp() public {
        datasets = new Datasets(
            governanceContractAddresss,
            role,
            filplus,
            filecoin,
            carstore
        );
    }

    // Helper function to convert uint64 to bytes32
    function convertUint64ToBytes32(
        uint64 value
    ) internal pure returns (bytes32) {
        bytes32 convertedValue;
        assembly {
            convertedValue := value
        }
        return convertedValue;
    }

    function assertApproveDatasetMetadataSuccess(
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
        assertSubmitDatasetMetadataSuccess(
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
        vm.prank(governanceContractAddresss);
        vm.expectEmit(true, false, false, true);
        emit DatasetsEvents.DatasetMetadataApproved(1);
        datasets.approveDatasetMetadata(1);
        assertEq(
            uint8(DatasetType.State.MetadataApproved),
            uint8(datasets.getDatasetState(1))
        );
    }

    function assertSubmitDatasetMetadataSuccess(
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
        vm.assume(bytes(_title).length != 0);
        vm.assume(bytes(_industry).length != 0);
        vm.assume(bytes(_name).length != 0);
        vm.assume(bytes(_description).length != 0);
        vm.assume(bytes(_source).length != 0);
        vm.assume(bytes(_accessMethod).length != 0);
        vm.assume(_sizeInBytes != 0);
        vm.prank(address(10000));
        vm.expectEmit(true, true, false, true);
        emit DatasetsEvents.DatasetMetadataSubmitted(1, address(10000));
        submitDatasetMetadataAndAssert(
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
    }

    function submitDatasetMetadataAndAssert(
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
        assertDatasetMetadataSubmitted(
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
    }

    function assertDatasetMetadataSubmitted(
        string memory _title,
        string memory /*_industry*/,
        string memory /*_name*/,
        string memory /*_description*/,
        string memory _source,
        string memory _accessMethod,
        uint64 /*_sizeInBytes*/,
        bool /*_isPublic*/,
        uint64 /*_version*/
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
    }

    function assertSubmitDatasetProofSuccess(
        bytes32 _mappingRootHash,
        bytes32 _sourceRootHash
    ) internal {
        vm.assume(_mappingRootHash.length == 32);
        vm.assume(_sourceRootHash.length == 32);
        assertApproveDatasetMetadataSuccess(
            "a",
            "b",
            "c",
            "d",
            "e",
            "_source_accessMethod",
            123456789,
            true,
            0
        );

        assertEq(
            uint8(DatasetType.State.MetadataApproved),
            uint8(datasets.getDatasetState(1))
        );
        uint64 mappingLeavesCount = 10;
        bytes32[] memory mappingLeafHashes = new bytes32[](mappingLeavesCount);
        uint64[] memory mappingLeafSizes = new uint64[](mappingLeavesCount);
        for (uint64 i = 0; i < mappingLeavesCount; i++) {
            mappingLeafSizes[i] = 10;
            mappingLeafHashes[i] = convertUint64ToBytes32(i);
        }
        datasets.submitDatasetProofBatch(
            1,
            DatasetType.DataType.MappingFiles,
            "_mapping_accessmethod",
            _mappingRootHash,
            mappingLeafHashes,
            mappingLeafSizes,
            true
        );

        uint64 sourceLeavesCount = 100;
        bytes32[] memory sourceLeafHashes = new bytes32[](sourceLeavesCount);
        uint64[] memory sourceLeafSizes = new uint64[](sourceLeavesCount);
        for (uint64 i = 0; i < sourceLeavesCount; i++) {
            sourceLeafSizes[i] = 10000;
            sourceLeafHashes[i] = convertUint64ToBytes32(i + 10000);
        }
        vm.prank(address(199));
        vm.expectEmit(true, false, false, true);
        emit DatasetsEvents.DatasetProofSubmitted(1, address(199));
        datasets.submitDatasetProofBatch(
            1,
            DatasetType.DataType.Source,
            "",
            _sourceRootHash,
            sourceLeafHashes,
            sourceLeafSizes,
            true
        );

        assertEq(
            uint8(DatasetType.State.DatasetProofSubmitted),
            uint8(datasets.getDatasetState(1))
        );
        assertTrue(datasets.isDatasetContainsCar(1, mappingLeafHashes[0]));
        assertTrue(
            datasets.isDatasetContainsCars(
                1,
                datasets.getDatasetProof(
                    1,
                    DatasetType.DataType.Source,
                    0,
                    sourceLeavesCount
                )
            )
        );
        assertTrue(
            datasets.isDatasetContainsCars(
                1,
                datasets.getDatasetCars(
                    1,
                    DatasetType.DataType.MappingFiles,
                    0,
                    mappingLeavesCount
                )
            )
        );
        assertEq(
            10000 * sourceLeavesCount,
            datasets.getDatasetSize(1, DatasetType.DataType.Source)
        );
        assertEq(
            10 * mappingLeavesCount,
            datasets.getDatasetSize(1, DatasetType.DataType.MappingFiles)
        );
        assertTrue(datasets.isDatasetContainsCars(1, sourceLeafHashes));
        assertEq(
            sourceLeavesCount,
            datasets.getDatasetCarsCount(1, DatasetType.DataType.Source)
        );
        assertEq(
            mappingLeavesCount,
            datasets.getDatasetProofCount(1, DatasetType.DataType.MappingFiles)
        );
    }
}
