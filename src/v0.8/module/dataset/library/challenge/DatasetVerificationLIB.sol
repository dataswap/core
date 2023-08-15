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

import {DatasetType} from "../../../../types/DatasetType.sol";
import {MerkleUtils} from "../../../../shared/utils/merkle/MerkleUtils.sol";
import {DatasetChallengeProofLIB} from "./DatasetChallengeProofLIB.sol";

/// @title DatasetVerificationLIB Library,include add,get,verify.
/// @notice This library provides functions for managing verification associated with datasets.
/// @dev Note:Need to check carefully,Need rewrite verification logic.
library DatasetVerificationLIB {
    using DatasetChallengeProofLIB for DatasetType.DatasetChallengeProof;

    /// @notice Validates the submitted verification proofs.
    /// @dev This function checks the validity of the submitted Merkle proofs for both the source dataset and mapping files.
    function _requireValidVerification(
        uint64 _randomSeed,
        bytes32[][] memory _siblings,
        uint32[] memory _paths
    ) private pure {
        //TODO
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
        for (uint256 i = 0; i < _paths.length; i++) {
            DatasetType.DatasetChallengeProof
                storage challengeProof = verification.challengeProof[i];
            challengeProof.setChallengeProof(_siblings[i], _paths[i]);
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
        returns (bytes32[][] memory _siblings, uint32[] memory _paths)
    {
        DatasetType.Verification storage verification = self.verifications[
            _auditor
        ];
        for (uint256 i = 0; i < verification.challengeProof.length; i++) {
            DatasetType.DatasetChallengeProof
                storage challengeProof = verification.challengeProof[i];
            (bytes32[] memory _sibling, uint32 path) = challengeProof
                .getChallengeProof();
            _siblings[i] = _sibling;
            _paths[i] = path;
        }
    }

    /// @notice Get the count of verifications for a dataset.
    /// @dev This function returns the count of verifications conducted on the dataset.
    /// @param self The dataset for which to retrieve the verification count.
    function getDatasetVerificationsCount(
        DatasetType.Dataset storage self
    ) public view returns (uint32) {
        return self.verificationsCount;
    }
}
