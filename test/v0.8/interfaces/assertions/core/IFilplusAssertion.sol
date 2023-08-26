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

// assert carstore action
// NOTE: view asserton functions must all be tested by the functions that will change state
interface IFilplusAssertion {
    // set assertion
    function setCarRuleMaxCarReplicasAssertion(uint16 _newValue) external;

    function setDatasetRuleMinRegionsPerDatasetAssertion(
        uint16 _newValue
    ) external;

    function setDatasetRuleDefaultMaxReplicasPerCountryAssertion(
        uint16 _newValue
    ) external;

    function setDatasetRuleMaxReplicasInCountryAssertion(
        bytes32 _countryCode,
        uint16 _newValue
    ) external;

    function setDatasetRuleMaxReplicasPerCityAssertion(
        uint16 _newValue
    ) external;

    function setDatasetRuleMinSPsPerDatasetAssertion(uint16 _newValue) external;

    function setDatasetRuleMaxReplicasPerSPAssertion(uint16 _newValue) external;

    function setDatasetRuleMinTotalReplicasPerDatasetAssertion(
        uint16 _newValue
    ) external;

    function setDatasetRuleMaxTotalReplicasPerDatasetAssertion(
        uint16 _newValue
    ) external;

    function setDatacapRulesMaxAllocatedSizePerTimeAssertion(
        uint64 _newValue
    ) external;

    function setDatacapRulesMaxRemainingPercentageForNextAssertion(
        uint8 _newValue
    ) external;

    function setMatchingRulesDataswapCommissionPercentageAssertion(
        uint8 _newValue
    ) external;

    function setMatchingRulesCommissionTypeAssertion(uint8 _newType) external;

    // get assertion
    function carRuleMaxCarReplicasAssertion(uint16 _expectCount) external;

    function datasetRuleMinRegionsPerDatasetAssertion(
        uint16 _expectCount
    ) external;

    function datasetRuleDefaultMaxReplicasPerCountryAssertion(
        uint16 _expectCount
    ) external;

    function datasetRuleMaxReplicasPerCityAssertion(
        uint16 _expectCount
    ) external;

    function datasetRuleMinSPsPerDatasetAssertion(uint16 _expectCount) external;

    function datasetRuleMaxReplicasPerSPAssertion(uint16 _expectCount) external;

    function datasetRuleMinTotalReplicasPerDatasetAssertion(
        uint16 _expectCount
    ) external;

    function datasetRuleMaxTotalReplicasPerDatasetAssertion(
        uint16 _expectCount
    ) external;

    function datacapRulesMaxAllocatedSizePerTimeAssertion(
        uint64 _expectSize
    ) external;

    function datacapRulesMaxRemainingPercentageForNextAssertion(
        uint8 _expectPercentrage
    ) external;

    function matchingRulesDataswapCommissionPercentageAssertion(
        uint8 _expectPercentrage
    ) external;

    function getMatchingRulesCommissionTypeAssertion(
        uint8 _expectPercentrage
    ) external;

    function getDatasetRuleMaxReplicasInCountryAssertion(
        bytes32 _countryCode,
        uint16 _expectCount
    ) external;
}
