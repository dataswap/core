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

/// @title IDatasetsHelpers
interface IDatasetsHelpers {
    function setup() external;

    ///@notice Submit metadata for a dataset
    function submitDatasetMetadata(
        string memory _accessMethod
    ) external returns (uint64 datasetId);

    function generateRoot() external returns (bytes32);

    function generateProof(
        uint64 _leavesCount
    ) external returns (bytes32[] memory, uint64[] memory);

    function submitDatasetProof(
        uint64 _datasetId,
        DatasetType.DataType _dataType,
        uint64 _leavesCount,
        bool _complete
    )
        external
        returns (
            bytes32 rootHash,
            bytes32[] memory,
            uint64[] memory,
            uint64 totalSize
        );

    function generateVerification(
        uint64 _pointCount,
        uint64 _pointLeavesCount
    )
        external
        returns (
            uint64 _randomSeed,
            bytes32[][] memory _siblings,
            uint32[] memory _paths
        );

    function submitDatasetVerification(
        uint64 _datasetId,
        uint64 _challengeCount,
        uint64 _challengeLeavesCount
    ) external;

    function completeDatasetWorkflow(
        string memory _accessMethod,
        uint64 _sourceLeavesCount,
        uint64 _mappingFilesLeavesCount,
        uint64 _challengeCount,
        uint64 _challengeLeavesCount
    ) external returns (uint64 datasetId);
}
