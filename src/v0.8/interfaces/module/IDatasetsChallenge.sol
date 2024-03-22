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

/// @title IDatasetsChallenge
interface IDatasetsChallenge {
    /// @dev Allows a user to nominate themselves as a candidate for dataset auditor election.
    /// @param _datasetId The ID of the dataset for which the user is nominating themselves as a candidate.
    function nominateAsDatasetAuditorCandidate(uint64 _datasetId) external;

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

    /// @notice Retrieves challenge proofs submitters for a specific dataset.
    /// @dev This external function is used to get arrays of addresses representing auditors and corresponding points for challenge proofs submitters for a given dataset.
    /// @param _datasetId The unique identifier of the dataset.
    /// @return auditors An array of addresses representing challenge proofs submitters (auditors).
    /// @return points An array of corresponding points for each challenge proofs submitter.
    function getDatasetChallengeProofsSubmitters(
        uint64 _datasetId
    ) external view returns (address[] memory auditors, uint64[] memory points);

    ///@notice Get dataset challenge proofs
    function getDatasetChallengeProofs(
        uint64 _datasetId,
        address _auditor
    )
        external
        view
        returns (
            bytes32[] memory leaves,
            bytes32[][] memory siblingss,
            uint32[] memory paths,
            uint64 randomSeed
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

    /// @notice Checks if the dataset audit has timed out.
    /// @dev This function determines if the dataset audit for the given dataset ID has timed out.
    /// @param _datasetId The ID of the dataset.
    /// @return True if the dataset audit has timed out, false otherwise.
    function isDatasetAuditTimeout(
        uint64 _datasetId
    ) external view returns (bool);

    /// @notice Get a dataset challenge count
    function getChallengeSubmissionCount(
        uint64 _datasetId
    ) external view returns (uint64);

    /// @dev Retrieves auditor candidates for a given dataset ID.
    /// @param _datasetId The ID of the dataset for which auditor candidates are requested.
    /// @return candidates An array containing addresses of auditor candidates.
    function getDatasetAuditorCandidates(
        uint64 _datasetId
    ) external view returns (address[] memory candidates);

    /// @notice Retrieves the end height of the auditor election for a specific dataset.
    /// @dev Retrieves the block height at which the auditor election for the specified dataset ends.
    /// @param _datasetId The ID of the dataset for which the end height of the auditor election is retrieved.
    /// @return The end height of the auditor election.
    function getAuditorElectionEndHeight(
        uint64 _datasetId
    ) external view returns (uint64);

    /// @dev Checks whether the given account is a winner for a specific dataset ID.
    /// @param _datasetId The ID of the dataset being checked.
    /// @param _account The address of the account being checked for winner status.
    /// @return A boolean indicating whether the account is a winner for the dataset ID.
    function isWinner(
        uint64 _datasetId,
        address _account
    ) external returns (bool);

    /// @notice Get the Roles contract.
    /// @return Roles contract address.
    function roles() external view returns (IRoles);
}
