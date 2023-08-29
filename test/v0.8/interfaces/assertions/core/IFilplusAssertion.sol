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

// Interface for asserting Filplus actions
/// @dev All methods that do not change the state must be tested by methods that will change the state to ensure test coverage.
interface IFilplusAssertion {
    // Setter assertions

    /// @notice Asserts the setting of the maximum number of car replicas allowed.
    /// @param _caller The address of the caller.
    /// @param _newValue The expected new maximum number of car replicas.
    function setCarRuleMaxCarReplicasAssertion(
        address _caller,
        uint16 _newValue
    ) external;

    /// @notice Asserts the setting of the minimum number of regions per dataset.
    /// @param _caller The address of the caller.
    /// @param _newValue The expected new minimum number of regions per dataset.
    function setDatasetRuleMinRegionsPerDatasetAssertion(
        address _caller,
        uint16 _newValue
    ) external;

    /// @notice Asserts the setting of the default maximum replicas per country for datasets.
    /// @param _caller The address of the caller.
    /// @param _newValue The expected new default maximum replicas per country.
    function setDatasetRuleDefaultMaxReplicasPerCountryAssertion(
        address _caller,
        uint16 _newValue
    ) external;

    /// @notice Asserts the setting of the maximum replicas per country for a specific country code.
    /// @param _caller The address of the caller.
    /// @param _countryCode The country code for which the maximum replicas are being set.
    /// @param _newValue The expected new maximum replicas for the specified country.
    function setDatasetRuleMaxReplicasInCountryAssertion(
        address _caller,
        bytes32 _countryCode,
        uint16 _newValue
    ) external;

    /// @notice Asserts the setting of the maximum replicas per city for datasets.
    /// @param _caller The address of the caller.
    /// @param _newValue The expected new maximum replicas per city.
    function setDatasetRuleMaxReplicasPerCityAssertion(
        address _caller,
        uint16 _newValue
    ) external;

    /// @notice Sets the maximum proportion of dataset mapping files and asserts the value.
    /// @param _caller The address of the caller.
    /// @param _newValue The new max proportion of mapping files to dataset value.
    function setDatasetRuleMaxProportionOfMappingFilesToDatasetAssertion(
        address _caller,
        uint8 _newValue
    ) external;

    /// @notice Asserts the setting of the minimum number of storage providers (SPs) per dataset.
    /// @param _caller The address of the caller.
    /// @param _newValue The expected new minimum number of SPs per dataset.
    function setDatasetRuleMinSPsPerDatasetAssertion(
        address _caller,
        uint16 _newValue
    ) external;

    /// @notice Asserts the setting of the maximum replicas per storage provider (SP) for datasets.
    /// @param _caller The address of the caller.
    /// @param _newValue The expected new maximum replicas per SP.
    function setDatasetRuleMaxReplicasPerSPAssertion(
        address _caller,
        uint16 _newValue
    ) external;

    /// @notice Asserts the setting of the minimum total replicas per dataset.
    /// @param _caller The address of the caller.
    /// @param _newValue The expected new minimum total replicas per dataset.
    function setDatasetRuleMinTotalReplicasPerDatasetAssertion(
        address _caller,
        uint16 _newValue
    ) external;

    /// @notice Asserts the setting of the maximum total replicas per dataset.
    /// @param _caller The address of the caller.
    /// @param _newValue The expected new maximum total replicas per dataset.
    function setDatasetRuleMaxTotalReplicasPerDatasetAssertion(
        address _caller,
        uint16 _newValue
    ) external;

    /// @notice Asserts the setting of the maximum allocated size per time period for datacap rules.
    /// @param _caller The address of the caller.
    /// @param _newValue The expected new maximum allocated size per time period.
    function setDatacapRulesMaxAllocatedSizePerTimeAssertion(
        address _caller,
        uint64 _newValue
    ) external;

    /// @notice Asserts the setting of the maximum remaining percentage for the next allocation in datacap rules.
    /// @param _caller The address of the caller.
    /// @param _newValue The expected new maximum remaining percentage for the next allocation.
    function setDatacapRulesMaxRemainingPercentageForNextAssertion(
        address _caller,
        uint8 _newValue
    ) external;

    /// @notice Asserts the setting of the Dataswap commission percentage in matching rules.
    /// @param _caller The address of the caller.
    /// @param _newValue The expected new Dataswap commission percentage.
    function setMatchingRulesDataswapCommissionPercentageAssertion(
        address _caller,
        uint8 _newValue
    ) external;

    /// @notice Asserts the setting of the commission type in matching rules.
    /// @param _caller The address of the caller.
    /// @param _newType The expected new commission type.
    function setMatchingRulesCommissionTypeAssertion(
        address _caller,
        uint8 _newType
    ) external;

    // Getter assertions

    /// @notice Asserts the maximum number of car replicas allowed.
    /// @param _expectCount The expected maximum number of car replicas.
    function carRuleMaxCarReplicasAssertion(uint16 _expectCount) external;

    /// @notice Asserts the minimum number of regions per dataset.
    /// @param _expectCount The expected minimum number of regions per dataset.
    function datasetRuleMinRegionsPerDatasetAssertion(
        uint16 _expectCount
    ) external;

    /// @notice Asserts the default maximum replicas per country for datasets.
    /// @param _expectCount The expected default maximum replicas per country.
    function datasetRuleDefaultMaxReplicasPerCountryAssertion(
        uint16 _expectCount
    ) external;

    /// @notice Asserts the maximum replicas per city for datasets.
    /// @param _expectCount The expected maximum replicas per city.
    function datasetRuleMaxReplicasPerCityAssertion(
        uint16 _expectCount
    ) external;

    /// @notice Asserts the minimum number of storage providers (SPs) per dataset.
    /// @param _expectCount The expected minimum number of SPs per dataset.
    function datasetRuleMinSPsPerDatasetAssertion(uint16 _expectCount) external;

    /// @notice Asserts the maximum replicas per storage provider (SP) for datasets.
    /// @param _expectCount The expected maximum replicas per SP.
    function datasetRuleMaxReplicasPerSPAssertion(uint16 _expectCount) external;

    /// @notice Asserts the minimum total replicas per dataset.
    /// @param _expectCount The expected minimum total replicas per dataset.
    function datasetRuleMinTotalReplicasPerDatasetAssertion(
        uint16 _expectCount
    ) external;

    /// @notice Asserts the maximum total replicas per dataset.
    /// @param _expectCount The expected maximum total replicas per dataset.
    function datasetRuleMaxTotalReplicasPerDatasetAssertion(
        uint16 _expectCount
    ) external;

    /// @notice Asserts the maximum allocated size per time period in datacap rules.
    /// @param _expectSize The expected maximum allocated size per time period.
    function datacapRulesMaxAllocatedSizePerTimeAssertion(
        uint64 _expectSize
    ) external;

    /// @notice Asserts the maximum remaining percentage for the next allocation in datacap rules.
    /// @param _expectPercentage The expected maximum remaining percentage for the next allocation.
    function datacapRulesMaxRemainingPercentageForNextAssertion(
        uint8 _expectPercentage
    ) external;

    /// @notice Asserts the Dataswap commission percentage in matching rules.
    /// @param _expectPercentage The expected Dataswap commission percentage.
    function matchingRulesDataswapCommissionPercentageAssertion(
        uint8 _expectPercentage
    ) external;

    /// @notice Asserts the commission type in matching rules.
    /// @param _expectType The expected commission type.
    function getMatchingRulesCommissionTypeAssertion(
        uint8 _expectType
    ) external;

    /// @notice Asserts the maximum replicas per country for a specific country code in dataset rules.
    /// @param _countryCode The country code for which the maximum replicas are being asserted.
    /// @param _expectCount The expected maximum replicas for the specified country.
    function getDatasetRuleMaxReplicasInCountryAssertion(
        bytes32 _countryCode,
        uint16 _expectCount
    ) external;
}
