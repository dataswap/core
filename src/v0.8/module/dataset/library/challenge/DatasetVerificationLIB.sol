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
import {DatasetChallengeProofLIB} from "src/v0.8/module/dataset/library/challenge/DatasetChallengeProofLIB.sol";

/// @title DatasetVerificationLIB Library,include add,get,verify.
/// @notice This library provides functions for managing verification associated with datasets.
/// @dev Note:Need to check carefully,Need rewrite verification logic.
library DatasetVerificationLIB {
    using DatasetProofLIB for DatasetType.Dataset;
    using DatasetChallengeProofLIB for DatasetType.DatasetChallengeProof;

    /// @notice Submit a verification for a dataset.
    /// @dev This function allows submitting a verification for a dataset and triggers appropriate actions based on verification results.
    /// @param self The dataset to which the verification will be submitted.
    function _submitDatasetVerification(
        DatasetType.Dataset storage self,
        uint64 _randomSeed,
        bytes32[] memory _leaves,
        bytes32[][] memory _siblings,
        uint32[] memory _paths,
        IMerkleUtils _merkle
    ) internal returns (bool) {
        //For each verification submitted by an auditor, the random seed must be different.
        require(
            !isDatasetVerificationDuplicate(self, msg.sender, _randomSeed),
            "Verification is duplicate"
        );
        require(_randomSeed > 0, "Invalid random seed");

        if (
            !_requireValidVerification(
                self,
                _randomSeed,
                _leaves,
                _siblings,
                _paths,
                _merkle
            )
        ) {
            return false;
        }

        // Update the dataset state here
        self.verificationsCount++;
        DatasetType.Verification storage verification = self.verifications[
            msg.sender
        ];
        for (uint32 i = 0; i < _paths.length; i++) {
            DatasetType.DatasetChallengeProof memory challengeProof;
            challengeProof.siblings = new bytes32[](_siblings[i].length);
            challengeProof.setChallengeProof(
                _leaves[i],
                _siblings[i],
                _paths[i]
            );
            verification.challengeProof.push(challengeProof);
        }
        // Recording the auditor
        self.auditors.push(msg.sender);

        return true;
    }

    /// @notice Validates the submitted verification proofs.
    /// @dev This function checks the validity of the submitted Merkle proofs for both the source dataset and mapping files.
    // solhint-disable-next-line
    function _requireValidVerification(
        DatasetType.Dataset storage self,
        uint64 _randomSeed,
        bytes32[] memory _leaves,
        bytes32[][] memory _siblings,
        uint32[] memory _paths,
        IMerkleUtils _merkle
    ) private view returns (bool) {
        uint64 carChallengesCount = getChallengeCount(self);

        bytes32[] memory roots = generateCarChallenge(
            self,
            _randomSeed,
            carChallengesCount
        );

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

    /// @notice Get the verification details for a specific index of a dataset.
    /// @dev This function returns the verification details for a specific verification conducted on the dataset.
    /// @param self The dataset for which to retrieve verification details.
    /// @param _auditor address of the auditor.
    function getDatasetVerification(
        DatasetType.Dataset storage self,
        address _auditor
    )
        public
        view
        returns (bytes32[] memory, bytes32[][] memory, uint32[] memory)
    {
        DatasetType.Verification storage verification = self.verifications[
            _auditor
        ];
        bytes32[][] memory siblingss = new bytes32[][](
            verification.challengeProof.length
        );
        uint32[] memory paths = new uint32[](
            verification.challengeProof.length
        );
        bytes32[] memory leaves = new bytes32[](
            verification.challengeProof.length
        );

        for (uint256 i = 0; i < verification.challengeProof.length; i++) {
            DatasetType.DatasetChallengeProof
                storage challengeProof = verification.challengeProof[i];
            (
                bytes32 leaf,
                bytes32[] memory siblings,
                uint32 path
            ) = challengeProof.getChallengeProof();
            leaves[i] = leaf;
            siblingss[i] = siblings;
            paths[i] = path;
        }
        return (leaves, siblingss, paths);
    }

    /// @notice Get the count of verifications for a dataset.
    /// @dev This function returns the count of verifications conducted on the dataset.
    /// @param self The dataset for which to retrieve the verification count.
    function getDatasetVerificationsCount(
        DatasetType.Dataset storage self
    ) public view returns (uint16) {
        return self.verificationsCount;
    }

    /// @notice Check if the verification is a duplicate.
    /// @param self The dataset for which to retrieve verification details.
    /// @param _auditor The address of the auditor submitting the verification.
    /// @param _randomSeed The random value used for selecting the challenge point.
    function isDatasetVerificationDuplicate(
        DatasetType.Dataset storage self,
        address _auditor,
        uint64 _randomSeed
    ) public view returns (bool) {
        for (uint32 i = 0; i < self.auditors.length; i++) {
            if (self.auditors[i] == _auditor) return true;
            DatasetType.Verification storage verification = self.verifications[
                _auditor
            ];
            if (verification.randomSeed == _randomSeed) return true;
        }
        return false;
    }

    /// @notice Get Challenge count.
    /// @dev This function returns the cars Challenge count for a specific dataset.
    /// @param self The dataset for which to challenge details.
    function getChallengeCount(
        DatasetType.Dataset storage self
    ) internal view returns (uint64) {
        uint32 smallDataSet = 1000;
        uint64 carCount = self.getDatasetCount(DatasetType.DataType.Source);
        if (carCount < smallDataSet) {
            return 1;
        } else {
            return carCount / smallDataSet + 1;
        }
    }

    /// @notice generate cars challenge.
    /// @dev This function returns the cars Challenge information for a specific dataset.
    /// @param self The dataset for which to challenge details.
    /// @param _randomSeed The cars challenge random seed.
    /// @param _carChallengesCount the cars Challenge count for specific dataset.
    function generateCarChallenge(
        DatasetType.Dataset storage self,
        uint64 _randomSeed,
        uint64 _carChallengesCount
    ) internal view returns (bytes32[] memory) {
        bytes32[] memory carChallenges = new bytes32[](_carChallengesCount);
        for (uint64 i = 0; i < _carChallengesCount; i++) {
            carChallenges[i] = generateChallenge(
                self,
                _randomSeed,
                i,
                _carChallengesCount
            );
        }
        return carChallenges;
    }

    /// @notice generate a car challenge.
    /// @dev This function returns a car Challenge information for a specific dataset.
    /// @param self The dataset for which to challenge details.
    /// @param _randomSeed The cars challenge random seed.
    /// @param _index The car index of challenge.
    /// @param _carChallengesCount the cars Challenge count for specific dataset.
    function generateChallenge(
        DatasetType.Dataset storage self,
        uint64 _randomSeed,
        uint64 _index,
        uint64 _carChallengesCount
    ) internal view returns (bytes32) {
        uint64 index = generateChallengeIndex(
            _randomSeed,
            _index,
            _carChallengesCount
        );

        return self.getDatasetProof(DatasetType.DataType.Source, index, 1)[0];
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
