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

/// @title Filplus
library FilplusEvents {
    // Event emitted when the maximum number of car replicas per car rule is set
    event SetCarRuleMaxCarReplicas(uint32 _newValue);

    // Event emitted when the minimum regions per dataset rule is set
    event SetDatasetRuleMinRegionsPerDataset(uint32 _newValue);

    // Event emitted when the default maximum replicas per country rule is set for a dataset
    event SetDatasetRuleDefaultMaxReplicasPerCountry(uint32 _newValue);

    // Event emitted when the maximum replicas per country rule is set for a dataset
    event SetDatasetRuleMaxReplicasInCountry(
        uint16 _countryCode,
        uint16 _newValue
    );

    // Event emitted when the maximum replicas per city rule is set for a dataset
    event SetDatasetRuleMaxReplicasPerCity(uint32 _newValue);

    // Event emitted when the maximum proportion of dataset mapping files rule is set for a dataset
    event SetDatasetRuleMaxProportionOfMappingFilesToDataset(uint8 _newValue);

    // Event emitted when the minimum service providers (SPs) per dataset rule is set
    event SetDatasetRuleMinSPsPerDataset(uint32 _newValue);

    // Event emitted when the maximum replicas per SP (service provider) rule is set for a dataset
    event SetDatasetRuleMaxReplicasPerSP(uint32 _newValue);

    // Event emitted when the minimum total replicas per dataset rule is set
    event SetDatasetRuleMinTotalReplicasPerDataset(uint32 _newValue);

    // Event emitted when the maximum total replicas per dataset rule is set
    event SetDatasetRuleMaxTotalReplicasPerDataset(uint32 _newValue);

    // Event emitted when the maximum allocated datacap size per time rule is set
    event SetDatacapRulesMaxAllocatedSizePerTime(uint64 _newValue);

    // Event emitted when the maximum remaining percentage for the next allocation rule is set
    event SetDatacapRulesMaxRemainingPercentageForNext(uint64 _newValue);
}
