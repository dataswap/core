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
import {DatasetChallengeProofLIB} from "src/v0.8/module/dataset/library/challenge/DatasetChallengeProofLIB.sol";

/// @title DatasetVerificationLIB Library,include add,get,verify.
/// @notice This library provides functions for managing verification associated with datasets.
/// @dev Note:Need to check carefully,Need rewrite verification logic.
library DatasetVerificationLIB {
    using DatasetChallengeProofLIB for DatasetType.DatasetChallengeProof;

    /// @notice Validates the submitted verification proofs.
    /// @dev This function checks the validity of the submitted Merkle proofs for both the source dataset and mapping files.
    // solhint-disable-next-line
    function _requireValidVerification(
        uint64 _randomSeed,
        bytes32[][] memory _siblings,
        uint32[] memory _paths // solhint-disable-next-line
    ) private pure {
        //TODO:_requireValidVerification:https://github.com/dataswap/core/issues/39
    }

    /// @notice Submit a verification for a dataset.
    /// @dev This function allows submitting a verification for a dataset and triggers appropriate actions based on verification results.
    /// @param self The dataset to which the verification will be submitted.
    function _submitDatasetVerification(
        DatasetType.Dataset storage self,
        uint64 _randomSeed,
        bytes32[][] memory _siblings,
        uint32[] memory _paths
    ) internal returns (bool) {
        require(_randomSeed > 0, "Invalid random seed");
        _requireValidVerification(_randomSeed, _siblings, _paths);

        // Update the dataset state here
        self.verificationsCount++;
        DatasetType.Verification storage verification = self.verifications[
            msg.sender
        ];
        for (uint32 i = 0; i < _paths.length; i++) {
            DatasetType.DatasetChallengeProof memory challengeProof;
            challengeProof.siblings = new bytes32[](_siblings[i].length);
            challengeProof.setChallengeProof(_siblings[i], _paths[i]);
            verification.challengeProof.push(challengeProof);
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
    ) public view returns (bytes32[][] memory, uint32[] memory) {
        DatasetType.Verification storage verification = self.verifications[
            _auditor
        ];
        bytes32[][] memory siblingss = new bytes32[][](
            verification.challengeProof.length
        );
        uint32[] memory paths = new uint32[](
            verification.challengeProof.length
        );
        for (uint256 i = 0; i < verification.challengeProof.length; i++) {
            DatasetType.DatasetChallengeProof
                storage challengeProof = verification.challengeProof[i];
            (bytes32[] memory siblings, uint32 path) = challengeProof
                .getChallengeProof();
            siblingss[i] = siblings;
            paths[i] = path;
        }
        return (siblingss, paths);
    }

    /// @notice Get the count of verifications for a dataset.
    /// @dev This function returns the count of verifications conducted on the dataset.
    /// @param self The dataset for which to retrieve the verification count.
    function getDatasetVerificationsCount(
        DatasetType.Dataset storage self
    ) public view returns (uint16) {
        return self.verificationsCount;
    }
}
