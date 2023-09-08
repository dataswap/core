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

/// @title IDatasetsChallenge
interface IDatasetsChallenge {
    ///@notice Submit challenge proof for a dataset
    /// Based on merkle proof challenge.
    /// random challenge method is used to reduce the amount of data and calculation while ensuring algorithm security.
    function submitDatasetChallengeProofs(
        uint64 _datasetId,
        uint64 _randomSeed,
        bytes32[] memory _leaves,
        bytes32[][] memory _siblings,
        uint32[] memory _paths
    ) external;

    ///@notice Get dataset challenge proofs
    function getDatasetChallengeProofs(
        uint64 _datasetId,
        address _auditor
    )
        external
        view
        returns (
            bytes32[] memory,
            bytes32[][] memory _siblings,
            uint32[] memory _paths
        );

    ///@notice Get count of dataset challenge proofs
    function getDatasetChallengeProofsCount(
        uint64 _datasetId
    ) external view returns (uint16);

    ///@notice Checking if duplicate verifications of the Dataset
    function isDatasetChallengeProofDuplicate(
        uint64 _datasetId,
        address _auditor,
        uint64 _randomSeed
    ) external view returns (bool);

    /// @notice Get a dataset challenge count
    function getChallengeCount(
        uint64 _datasetId
    ) external view returns (uint64);

    /// @notice get  merkle utils
    function merkleUtils() external view returns (IMerkleUtils);
}
