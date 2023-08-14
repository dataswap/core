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

/// @title IFilplus
interface IFilplus {
    // Public getter function to access datasetRuleMaxReplicasInCountries
    function getDatasetRuleMaxReplicasInCountry(
        bytes32 _countryCode
    ) external view returns (uint32);

    // Set functions for public variables
    function setCarRuleMaxCarReplicas(uint32 _newValue) external;

    function setDatasetRuleMinRegionsPerDataset(uint32 _newValue) external;

    function setDatasetRuleDefaultMaxReplicasPerCountry(
        uint32 _newValue
    ) external;

    function setDatasetRuleMaxReplicasInCountry(
        bytes32 _countryCode,
        uint32 _newValue
    ) external;

    function setDatasetRuleMaxReplicasPerCity(uint32 _newValue) external;

    function setDatasetRuleMinSPsPerDataset(uint32 _newValue) external;

    function setDatasetRuleMaxReplicasPerSP(uint32 _newValue) external;

    function setDatasetRuleMinTotalReplicasPerDataset(
        uint32 _newValue
    ) external;

    function setDatasetRuleMaxTotalReplicasPerDataset(
        uint32 _newValue
    ) external;

    function setDatacapRulesMaxAllocatedSizePerTime(uint64 _newValue) external;

    function setDatacapRulesMaxRemainingPercentageForNext(
        uint64 _newValue
    ) external;

    function setMatchingRulesDataswapCommissionPercentage(
        uint256 _newValue
    ) external;

    function setMatchingRulesCommissionType(uint8 _newType) external;

    // Default getter functions for public variables
    function governanceAddress() external view returns (address);

    function carRuleMaxCarReplicas() external view returns (uint32);

    function datasetRuleMinRegionsPerDataset() external view returns (uint32);

    function datasetRuleDefaultMaxReplicasPerCountry()
        external
        view
        returns (uint32);

    function datasetRuleMaxReplicasPerCity() external view returns (uint32);

    function datasetRuleMinSPsPerDataset() external view returns (uint32);

    function datasetRuleMaxReplicasPerSP() external view returns (uint32);

    function datasetRuleMinTotalReplicasPerDataset()
        external
        view
        returns (uint32);

    function datasetRuleMaxTotalReplicasPerDataset()
        external
        view
        returns (uint32);

    function datacapRulesMaxAllocatedSizePerTime()
        external
        view
        returns (uint64);

    function datacapRulesMaxRemainingPercentageForNext()
        external
        view
        returns (uint64);

    function matchingRulesDataswapCommissionPercentage()
        external
        view
        returns (uint256);

    function getMatchingRulesCommissionType() external view returns (uint8);
}
