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
import {ServiceAssertionBase} from "test/v0.8/assertions/service/abstract/base/ServiceAssertionBase.sol";

/// @title FilplusServiceAssertion
abstract contract FilplusServiceAssertion is ServiceAssertionBase {
    /// @notice Sets the maximum number of car replicas allowed and asserts the value.
    /// @param _caller The address of the caller.
    /// @param _newValue The new maximum car replicas value.
    function setCarRuleMaxCarReplicasAssertion(
        address _caller,
        uint16 _newValue
    ) external {
        filplusAssertion.setCarRuleMaxCarReplicasAssertion(_caller, _newValue);
    }

    /// @notice Sets the minimum number of regions per dataset and asserts the value.
    /// @param _caller The address of the caller.
    /// @param _newValue The new minimum regions per dataset value.
    function setDatasetRuleMinRegionsPerDatasetAssertion(
        address _caller,
        uint16 _newValue
    ) external {
        filplusAssertion.setDatasetRuleMinRegionsPerDatasetAssertion(
            _caller,
            _newValue
        );
    }

    /// @notice Sets the default maximum replicas per country for datasets and asserts the value.
    /// @param _caller The address of the caller.
    /// @param _newValue The new default maximum replicas per country value.
    function setDatasetRuleDefaultMaxReplicasPerCountryAssertion(
        address _caller,
        uint16 _newValue
    ) external {
        filplusAssertion.setDatasetRuleDefaultMaxReplicasPerCountryAssertion(
            _caller,
            _newValue
        );
    }

    /// @notice Sets the maximum replicas allowed in a specific country for datasets and asserts the value.
    /// @param _caller The address of the caller.
    /// @param _countryCode The country code.
    /// @param _newValue The new maximum replicas value for the country.
    function setDatasetRuleMaxReplicasInCountryAssertion(
        address _caller,
        bytes32 _countryCode,
        uint16 _newValue
    ) external {
        filplusAssertion.setDatasetRuleMaxReplicasInCountryAssertion(
            _caller,
            _countryCode,
            _newValue
        );
    }

    /// @notice Sets the maximum replicas allowed per city for datasets and asserts the value.
    /// @param _caller The address of the caller.
    /// @param _newValue The new maximum replicas per city value.
    function setDatasetRuleMaxReplicasPerCityAssertion(
        address _caller,
        uint16 _newValue
    ) external {
        filplusAssertion.setDatasetRuleMaxReplicasPerCityAssertion(
            _caller,
            _newValue
        );
    }

    /// @notice Sets the maximum proportion of dataset mapping files and asserts the value.
    /// @param _caller The address of the caller.
    /// @param _newValue The new max proportion of mapping files to dataset value.
    function setDatasetRuleMaxProportionOfMappingFilesToDatasetAssertion(
        address _caller,
        uint8 _newValue
    ) external {
        filplusAssertion
            .setDatasetRuleMaxProportionOfMappingFilesToDatasetAssertion(
                _caller,
                _newValue
            );
    }

    /// @notice Sets the minimum number of storage providers (SPs) per dataset and asserts the value.
    /// @param _caller The address of the caller.
    /// @param _newValue The new minimum SPs per dataset value.
    function setDatasetRuleMinSPsPerDatasetAssertion(
        address _caller,
        uint16 _newValue
    ) external {
        filplusAssertion.setDatasetRuleMinSPsPerDatasetAssertion(
            _caller,
            _newValue
        );
    }

    /// @notice Sets the maximum replicas allowed per storage provider (SP) for datasets and asserts the value.
    /// @param _caller The address of the caller.
    /// @param _newValue The new maximum replicas per SP value.
    function setDatasetRuleMaxReplicasPerSPAssertion(
        address _caller,
        uint16 _newValue
    ) external {
        filplusAssertion.setDatasetRuleMaxReplicasPerSPAssertion(
            _caller,
            _newValue
        );
    }

    /// @notice Sets the minimum total replicas per dataset and asserts the value.
    /// @param _caller The address of the caller.
    /// @param _newValue The new minimum total replicas per dataset value.
    function setDatasetRuleMinTotalReplicasPerDatasetAssertion(
        address _caller,
        uint16 _newValue
    ) external {
        filplusAssertion.setDatasetRuleMinTotalReplicasPerDatasetAssertion(
            _caller,
            _newValue
        );
    }

    /// @notice Sets the maximum total replicas per dataset and asserts the value.
    /// @param _caller The address of the caller.
    /// @param _newValue The new maximum total replicas per dataset value.
    function setDatasetRuleMaxTotalReplicasPerDatasetAssertion(
        address _caller,
        uint16 _newValue
    ) external {
        filplusAssertion.setDatasetRuleMaxTotalReplicasPerDatasetAssertion(
            _caller,
            _newValue
        );
    }

    /// @notice Sets the maximum allocated size per time period for datacap rules and asserts the value.
    /// @param _caller The address of the caller.
    /// @param _newValue The new maximum allocated size per time value.
    function setDatacapRulesMaxAllocatedSizePerTimeAssertion(
        address _caller,
        uint64 _newValue
    ) external {
        filplusAssertion.setDatacapRulesMaxAllocatedSizePerTimeAssertion(
            _caller,
            _newValue
        );
    }

    /// @notice Sets the maximum remaining percentage for the next data allocation for datacap rules and asserts the value.
    /// @param _caller The address of the caller.
    /// @param _newValue The new maximum remaining percentage value.
    function setDatacapRulesMaxRemainingPercentageForNextAssertion(
        address _caller,
        uint8 _newValue
    ) external {
        filplusAssertion.setDatacapRulesMaxRemainingPercentageForNextAssertion(
            _caller,
            _newValue
        );
    }

    /// @notice Sets the dataswap commission percentage for matching rules and asserts the value.
    /// @param _caller The address of the caller.
    /// @param _newValue The new dataswap commission percentage value.
    function setMatchingRulesDataswapCommissionPercentageAssertion(
        address _caller,
        uint8 _newValue
    ) external {
        filplusAssertion.setMatchingRulesDataswapCommissionPercentageAssertion(
            _caller,
            _newValue
        );
    }

    /// @notice Sets the commission type for matching rules and asserts the value.
    /// @param _caller The address of the caller.
    /// @param _newType The new commission type value.
    function setMatchingRulesCommissionTypeAssertion(
        address _caller,
        uint8 _newType
    ) external {
        filplusAssertion.setMatchingRulesCommissionTypeAssertion(
            _caller,
            _newType
        );
    }

    // Assertion functions for getting values

    /// @notice Asserts the maximum number of car replicas allowed.
    /// @param _expectCount The expected maximum car replicas value.
    function carRuleMaxCarReplicasAssertion(uint16 _expectCount) public {
        filplusAssertion.carRuleMaxCarReplicasAssertion(_expectCount);
    }

    /// @notice Asserts the minimum number of regions per dataset.
    /// @param _expectCount The expected minimum regions per dataset value.
    function datasetRuleMinRegionsPerDatasetAssertion(
        uint16 _expectCount
    ) public {
        filplusAssertion.datasetRuleMinRegionsPerDatasetAssertion(_expectCount);
    }

    /// @notice Asserts the default maximum replicas per country for datasets.
    /// @param _expectCount The expected default maximum replicas per country value.
    function datasetRuleDefaultMaxReplicasPerCountryAssertion(
        uint16 _expectCount
    ) public {
        filplusAssertion.datasetRuleDefaultMaxReplicasPerCountryAssertion(
            _expectCount
        );
    }

    /// @notice Asserts the maximum replicas allowed per city for datasets.
    /// @param _expectCount The expected maximum replicas per city value.
    function datasetRuleMaxReplicasPerCityAssertion(
        uint16 _expectCount
    ) public {
        filplusAssertion.datasetRuleMaxReplicasPerCityAssertion(_expectCount);
    }

    /// @notice Asserts the maximum proportion of mapping files to dataset.
    /// @param _expectCount The expected maximum proportion of mapping files to dataset value.
    function datasetRuleMaxProportionOfMappingFilesToDatasetAssertion(
        uint8 _expectCount
    ) public {
        filplusAssertion
            .datasetRuleMaxProportionOfMappingFilesToDatasetAssertion(
                _expectCount
            );
    }

    /// @notice Asserts the minimum number of storage providers (SPs) per dataset.
    /// @param _expectCount The expected minimum SPs per dataset value.
    function datasetRuleMinSPsPerDatasetAssertion(uint16 _expectCount) public {
        filplusAssertion.datasetRuleMinSPsPerDatasetAssertion(_expectCount);
    }

    /// @notice Asserts the maximum replicas allowed per storage provider (SP) for datasets.
    /// @param _expectCount The expected maximum replicas per SP value.
    function datasetRuleMaxReplicasPerSPAssertion(uint16 _expectCount) public {
        filplusAssertion.datasetRuleMaxReplicasPerSPAssertion(_expectCount);
    }

    /// @notice Asserts the minimum total replicas per dataset.
    /// @param _expectCount The expected minimum total replicas per dataset value.
    function datasetRuleMinTotalReplicasPerDatasetAssertion(
        uint16 _expectCount
    ) public {
        filplusAssertion.datasetRuleMinTotalReplicasPerDatasetAssertion(
            _expectCount
        );
    }

    /// @notice Asserts the maximum total replicas per dataset.
    /// @param _expectCount The expected maximum total replicas per dataset value.
    function datasetRuleMaxTotalReplicasPerDatasetAssertion(
        uint16 _expectCount
    ) public {
        filplusAssertion.datasetRuleMaxTotalReplicasPerDatasetAssertion(
            _expectCount
        );
    }

    /// @notice Asserts the maximum allocated size per time period for datacap rules.
    /// @param _expectSize The expected maximum allocated size per time value.
    function datacapRulesMaxAllocatedSizePerTimeAssertion(
        uint64 _expectSize
    ) public {
        filplusAssertion.datacapRulesMaxAllocatedSizePerTimeAssertion(
            _expectSize
        );
    }

    /// @notice Asserts the maximum remaining percentage for the next data allocation for datacap rules.
    /// @param _expectPercentrage The expected maximum remaining percentage value.
    function datacapRulesMaxRemainingPercentageForNextAssertion(
        uint8 _expectPercentrage
    ) public {
        filplusAssertion.datacapRulesMaxRemainingPercentageForNextAssertion(
            _expectPercentrage
        );
    }

    /// @notice Asserts the dataswap commission percentage for matching rules.
    /// @param _expectPercentrage The expected dataswap commission percentage value.
    function matchingRulesDataswapCommissionPercentageAssertion(
        uint8 _expectPercentrage
    ) public {
        filplusAssertion.matchingRulesDataswapCommissionPercentageAssertion(
            _expectPercentrage
        );
    }

    /// @notice Asserts the commission type for matching rules.
    /// @param _expectPercentrage The expected commission type value.
    function getMatchingRulesCommissionTypeAssertion(
        uint8 _expectPercentrage
    ) public {
        filplusAssertion.getMatchingRulesCommissionTypeAssertion(
            _expectPercentrage
        );
    }

    /// @notice Asserts the maximum replicas allowed in a specific country for datasets.
    /// @param _countryCode The country code.
    /// @param _expectCount The expected maximum replicas value for the country.
    function getDatasetRuleMaxReplicasInCountryAssertion(
        bytes32 _countryCode,
        uint16 _expectCount
    ) public {
        filplusAssertion.getDatasetRuleMaxReplicasInCountryAssertion(
            _countryCode,
            _expectCount
        );
    }
}
