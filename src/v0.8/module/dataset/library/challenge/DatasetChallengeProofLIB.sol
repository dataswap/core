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
import {IMerkleUtils} from "src/v0.8/interfaces/utils/IMerkleUtils.sol";
import {DatasetProofLIB} from "src/v0.8/module/dataset/library/proof/DatasetProofLIB.sol";
import {DatasetChallengeLIB} from "src/v0.8/module/dataset/library/challenge/DatasetChallengeLIB.sol";

/// @title DatasetVerificationLIB Library,include add,get,verify.
/// @notice This library provides functions for managing verification associated with datasets.
/// @dev Note:Need to check carefully,Need rewrite verification logic.
library DatasetChallengeProofLIB {
    using DatasetProofLIB for DatasetType.DatasetProof;
    using DatasetChallengeLIB for DatasetType.Challenge;

    /// @notice Submit a challenge proofs for a dataset.
    /// @dev This function allows submitting a challenge proofs for a dataset and triggers appropriate actions based on challenge results.
    /// @param self The dataset to which the challenge proofs will be submitted.
    function _submitDatasetChallengeProofs(
        DatasetType.DatasetChallengeProof storage self,
        uint64 _randomSeed,
        bytes32[] memory _leaves,
        bytes32[][] memory _siblings,
        uint32[] memory _paths,
        bytes32[] memory _roots,
        IMerkleUtils _merkle
    ) internal {
        //For each challenge proofs submitted by an auditor, the random seed must be different.
        require(
            !isDatasetChallengeProofDuplicate(self, msg.sender, _randomSeed),
            "Verification is duplicate"
        );
        require(_randomSeed > 0, "Invalid random seed");

       require(
            _requireValidChallengeProofs(
                _leaves,
                _siblings,
                _paths,
                _roots,
                _merkle
            ),"Invalid challenge proofs"
        );

        // Update the dataset state here
        self.challengesCount++;
        DatasetType.ChallengeProof storage challengeProof = self
            .challengeProofs[msg.sender];
        for (uint32 i = 0; i < _paths.length; i++) {
            DatasetType.Challenge memory challenge;
            challenge.siblings = new bytes32[](_siblings[i].length);
            challenge.setChallengeProof(_leaves[i], _siblings[i], _paths[i]);
            challengeProof.challenges.push(challenge);
        }
        challengeProof.randomSeed = _randomSeed;
        // Recording the auditor
        self.auditors.push(msg.sender);
    }

    /// @notice Validates the submitted challenge proofs.
    /// @dev This function checks the validity of the submitted Merkle proofs for both the source dataset and mapping files.
    // solhint-disable-next-line
    function _requireValidChallengeProofs(
        bytes32[] memory _leaves,
        bytes32[][] memory _siblings,
        uint32[] memory _paths,
        bytes32[] memory roots,
        IMerkleUtils _merkle
    ) private view returns (bool) {
        require(
            roots.length == _leaves.length,
            "roots.length != _leaves.length"
        );
        require(
            roots.length == _siblings.length,
            "roots.length != _siblings.length"
        );
        require(roots.length == _paths.length, "roots.length != _paths.length");

        for (uint32 i = 0; i < roots.length; i++) {
            if (
                !_merkle.isValidMerkleProof(
                    roots[i],
                    _leaves[i],
                    _siblings[i],
                    _paths[i]
                )
            ) {
                return false;
            }
        }
        return true;
    }

    /// @notice Get the challenge proofs details for a specific index of a dataset.
    /// @dev This function returns the challenge proofs details for a specific challenge proofs conducted on the dataset.
    /// @param self The dataset for which to retrieve challenge proofs details.
    /// @param _auditor address of the auditor.
    function getDatasetChallengeProofs(
        DatasetType.DatasetChallengeProof storage self,
        address _auditor
    )
        internal
        view
        returns (
            bytes32[] memory leaves,
            bytes32[][] memory siblings,
            uint32[] memory paths,
            uint64 randomSeed
        )
    {
        DatasetType.ChallengeProof storage challengeProof = self
            .challengeProofs[_auditor];
        siblings = new bytes32[][](challengeProof.challenges.length);
        paths = new uint32[](challengeProof.challenges.length);
        leaves = new bytes32[](challengeProof.challenges.length);
        randomSeed = challengeProof.randomSeed;

        for (uint256 i = 0; i < challengeProof.challenges.length; i++) {
            DatasetType.Challenge storage challenge = challengeProof.challenges[
                i
            ];
            (bytes32 leaf, bytes32[] memory vsiblings, uint32 path) = challenge
                .getChallengeProof();
            leaves[i] = leaf;
            siblings[i] = vsiblings;
            paths[i] = path;
        }
        return (leaves, siblings, paths ,randomSeed);
    }

    /// @notice Get the count of challenge proofs for a dataset.
    /// @dev This function returns the count of challenge proofs conducted on the dataset.
    /// @param self The dataset for which to retrieve the challenge proofs count.
    function getDatasetChallengeProofsCount(
        DatasetType.DatasetChallengeProof storage self
    ) internal view returns (uint16) {
        return self.challengesCount;
    }

    /// @notice Check if the challange proof is a duplicate.
    /// @param self The dataset for which to retrieve challenge proof details.
    /// @param _auditor The address of the auditor submitting the challenge proof.
    /// @param _randomSeed The random value used for selecting the challenge point.
    function isDatasetChallengeProofDuplicate(
        DatasetType.DatasetChallengeProof storage self,
        address _auditor,
        uint64 _randomSeed
    ) internal view returns (bool) {
        for (uint32 i = 0; i < self.auditors.length; i++) {
            if (self.auditors[i] == _auditor) return true;
            DatasetType.ChallengeProof storage verification = self
                .challengeProofs[_auditor];
            if (verification.randomSeed == _randomSeed) return true;
        }
        return false;
    }

    /// @notice generate a car challenge index.
    /// @dev This function returns a car Challenge information for a specific dataset.
    /// @param _randomSeed The cars challenge random seed.
    /// @param _index The car index of challenge.
    /// @param _carChallengesCount the cars Challenge count for specific dataset.
    function generateChallengeIndex(
        uint64 _randomSeed,
        uint64 _index,
        uint64 _carChallengesCount
    ) internal pure returns (uint64) {
        // Convert randomness and index to bytes
        bytes memory input = new bytes(16);

        bytes8 randomSeedBytes = bytes8(_randomSeed);
        bytes8 indexBytes = bytes8(_index);

        // LittleEndian encode
        for (uint256 i = 0; i < 8; i++) {
            input[i] = randomSeedBytes[7 - i];
            input[i + 8] = indexBytes[7 - i];
        }
        // Calculate SHA-256 hash
        bytes32 hash = sha256(input);

        uint64 carChallenge;
        // from golang binary.LittleEndian.Uint64
        for (uint256 i = 0; i < 8; i++) {
            carChallenge |= uint64(uint8(hash[i])) << uint64(i * 8);
        }

        return carChallenge % _carChallengesCount;
    }
}
