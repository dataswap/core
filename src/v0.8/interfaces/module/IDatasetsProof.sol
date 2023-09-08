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

import {DatasetType} from "src/v0.8/types/DatasetType.sol";
import {IRoles} from "src/v0.8/interfaces/core/IRoles.sol";
import {IMerkleUtils} from "src/v0.8/interfaces/utils/IMerkleUtils.sol";

/// @title IDatasetsProof
interface IDatasetsProof {
    ///@notice Submit proof root for a dataset
    function submitDatasetProofRoot(
        uint64 _datasetId,
        DatasetType.DataType _dataType,
        string calldata _mappingFilesAccessMethod,
        bytes32 _rootHash
    ) external;

    ///@notice Submit proof for a dataset
    function submitDatasetProof(
        uint64 _datasetId,
        DatasetType.DataType _dataType,
        bytes32[] memory _leafHashes,
        uint64[] memory _leafIndexs,
        uint64[] memory _leafSizes,
        bool _completed
    ) external;

    ///@notice Get dataset source CIDs
    function getDatasetProof(
        uint64 _datasetId,
        DatasetType.DataType _dataType,
        uint64 _index,
        uint64 _len
    ) external view returns (bytes32[] memory);

    ///@notice Get dataset source CIDs
    function getDatasetCars(
        uint64 _datasetId,
        DatasetType.DataType _dataType,
        uint64 _index,
        uint64 _len
    ) external view returns (bytes32[] memory);

    function getDatasetProofCount(
        uint64 _datasetId,
        DatasetType.DataType _dataType
    ) external view returns (uint64);

    ///@notice Get dataset proof's submitter
    function getDatasetProofSubmitter(
        uint64 _datasetId
    ) external view returns (address);

    ///@notice Get dataset source CIDs
    function getDatasetCarsCount(
        uint64 _datasetId,
        DatasetType.DataType _dataType
    ) external view returns (uint64);

    ///@notice Get dataset size
    function getDatasetSize(
        uint64 _datasetId,
        DatasetType.DataType _dataType
    ) external view returns (uint64);

    ///@notice Check if a dataset has a cid
    function isDatasetContainsCar(
        uint64 _datasetId,
        bytes32 _cid
    ) external returns (bool);

    ///@notice Check if a dataset has cids
    function isDatasetContainsCars(
        uint64 _datasetId,
        bytes32[] memory _cids
    ) external view returns (bool);

    ///@notice Check if a dataset has submitter
    function isDatasetProofSubmitter(
        uint64 _datasetId,
        address _submitter
    ) external view returns (bool);
}
