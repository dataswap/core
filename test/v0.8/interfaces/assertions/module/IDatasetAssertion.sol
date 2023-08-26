/*******************************************************************************
 *   (c) 2023 Dataswap
 *
 *  Licensed under the GNU General external License, Version 3.0 or later (the "License");
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

import {DatasetType} from "src/v0.8/types/DatasetType.sol";

// NOTE: view asserton functions must all be tested by the functions that will change state
interface IDatasetAssertion {
    function approveDatasetAssertion(uint64 _datasetId) external;

    function approveDatasetMetadataAssertion(uint64 _datasetId) external;

    function rejectDatasetAssertion(uint64 _datasetId) external;

    function rejectDatasetMetadataAssertion(uint64 _datasetId) external;

    function submitDatasetMetadataAssertion(
        string memory _title,
        string memory _industry,
        string memory _name,
        string memory _description,
        string memory _source,
        string memory _accessMethod,
        uint64 _sizeInBytes,
        bool _isexternal,
        uint64 _version
    ) external;

    function submitDatasetProofBatchAssertion(
        uint64 _datasetId,
        DatasetType.DataType _dataType,
        string calldata accessMethod,
        bytes32 _rootHash,
        bytes32[] calldata _leafHashes,
        uint64[] calldata _leafSizes,
        bool _completed
    ) external;

    function submitDatasetVerificationAssertion(
        uint64 _datasetId,
        uint64 _randomSeed,
        bytes32[][] memory _siblings,
        uint32[] memory _paths
    ) external;

    function getDatasetMetadataAssertion(
        uint64 _datasetId,
        string memory _expectAccessMethod,
        address _expectSubmitter,
        uint64 _expectCreatedBlockNumber
    ) external;

    function getDatasetProofAssertion(
        uint64 _datasetId,
        DatasetType.DataType _dataType,
        uint64 _index,
        uint64 _len,
        bytes32[] memory _expectProof
    ) external;

    function getDatasetCarsAssertion(
        uint64 _datasetId,
        DatasetType.DataType _dataType,
        uint64 _index,
        uint64 _len,
        bytes32[] memory _expectCars
    ) external;

    function getDatasetProofCountAssertion(
        uint64 _datasetId,
        DatasetType.DataType _dataType,
        uint64 _expectCount
    ) external;

    function getDatasetCarsCountAssertion(
        uint64 _datasetId,
        DatasetType.DataType _dataType,
        uint64 _expectCount
    ) external;

    function getDatasetSizeAssertion(
        uint64 _datasetId,
        DatasetType.DataType _dataType,
        uint64 _expectSize
    ) external;

    function getDatasetStateAssertion(
        uint64 _datasetId,
        DatasetType.State _expectState
    ) external;

    function getDatasetVerificationAssertion(
        uint64 _datasetId,
        address _auditor,
        bytes32[][] memory _expectSiblings,
        uint32[] memory _expectPaths
    ) external;

    function getDatasetVerificationsCountAssertion(
        uint64 _datasetId,
        uint16 _expectCount
    ) external;

    function hasDatasetMetadataAssertion(
        string memory _accessMethod,
        bool _expecthasDatasetMetadata
    ) external;

    function isDatasetContainsCarAssertion(
        uint64 _datasetId,
        bytes32 _cid,
        bool _expectIsDatasetContainsCar
    ) external;

    function isDatasetContainsCarsAssertion(
        uint64 _datasetId,
        bytes32[] memory _cids,
        bool _expectIsDatasetContainsCars
    ) external;

    function datasetsCountAssertion(uint64 _expectCount) external;
}
