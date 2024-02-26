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

library FilplusType {
    struct Rules {
        ///@notice dataset region rules
        uint16 datasetRuleMinRegionsPerDataset; // Minimum required number of regions (e.g., 3).
        uint16 datasetRuleDefaultMaxReplicasPerCountry; // Default maximum replicas allowed per country.
        mapping(uint16 => uint16) datasetRuleMaxReplicasInCountries; // Maximum replicas allowed per country.
        uint16 datasetRuleMaxReplicasPerCity; // Maximum replicas allowed per city (e.g., 1).
        uint8 datasetRuleMaxProportionOfMappingFilesToDataset; //Maximum proportion of dataset mapping files,measured in ten-thousandths.(e.g.,40)
        ///@notice dataset sp rules
        uint16 datasetRuleMinSPsPerDataset; // Minimum required number of storage providers (e.g., 5).
        uint16 datasetRuleMaxReplicasPerSP; // Maximum replicas allowed per storage provider (e.g., 1).
        uint16 datasetRuleMinTotalReplicasPerDataset; // Minimum required total replicas (e.g., 5).
        uint16 datasetRuleMaxTotalReplicasPerDataset; // Maximum allowed total replicas (e.g., 10).
        /// @notice dataset runtime rules
        uint64 datasetRuleMinProofTimeout;
        uint64 datasetRuleMinAuditTimeout;
        uint64 datasetRuleRequirementTimeout;
        ///@notice datacap rules
        uint64 datacapRulesMaxAllocatedSizePerTime; // Maximum allocate datacap size per time.
        uint8 datacapRulesMaxRemainingPercentageForNext; // Minimum completion percentage for the next allocation.
        uint256 datacapPricePreByte; // The datacap price pre byte.
        uint256 datacapChunkLandPricePreByte; // The datacap chunk land price pre byte.
        uint256 challengeProofsPricePrePoint; // The challenge proofs price pre point.
        uint16 challengeProofsSubmiterCount; // The challenge proofs submiter count.
        uint64 datacapdatasetApprovedLockDays; // The datacap collateral days when dataset approved. 
        uint64 datacapCollateralMaxLockDays; // The datacap collateral max lock days.
        uint256 proofAuditFee; // The proof audit fee.
        uint256 challengeAuditFee; // The challenge audit fee.
        uint256 disputeAuditFee; // The dispute audit fee.
    }
}
