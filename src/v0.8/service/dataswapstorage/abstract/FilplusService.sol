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

import {DataswapStorageServiceBase} from "src/v0.8/service/dataswapstorage/abstract/base/DataswapStorageServiceBase.sol";

/// @title FilplusService
abstract contract FilplusService is DataswapStorageServiceBase {
    // Public getter function to access datasetRuleMaxReplicasInCountries
    function getDatasetRuleMaxReplicasInCountry(
        bytes32 _countryCode
    ) external view returns (uint16) {
        return filplusInstance.getDatasetRuleMaxReplicasInCountry(_countryCode);
    }

    // Set functions for public variables
    function setCarRuleMaxCarReplicas(uint16 _newValue) external {
        filplusInstance.setCarRuleMaxCarReplicas(_newValue);
    }

    function setDatasetRuleMinRegionsPerDataset(uint16 _newValue) external {
        filplusInstance.setDatasetRuleMinRegionsPerDataset(_newValue);
    }

    function setDatasetRuleDefaultMaxReplicasPerCountry(
        uint16 _newValue
    ) external {
        filplusInstance.setDatasetRuleDefaultMaxReplicasPerCountry(_newValue);
    }

    function setDatasetRuleMaxReplicasInCountry(
        bytes32 _countryCode,
        uint16 _newValue
    ) external {
        filplusInstance.setDatasetRuleMaxReplicasInCountry(
            _countryCode,
            _newValue
        );
    }

    function setDatasetRuleMaxReplicasPerCity(uint16 _newValue) external {
        filplusInstance.setDatasetRuleMaxReplicasPerCity(_newValue);
    }

    // set maximum proportion of dataset mapping files
    function setDatasetRuleMaxProportionOfMappingFilesToDataset(
        uint8 _newValue
    ) external {
        filplusInstance.setDatasetRuleMaxProportionOfMappingFilesToDataset(
            _newValue
        );
    }

    function setDatasetRuleMinSPsPerDataset(uint16 _newValue) external {
        filplusInstance.setDatasetRuleMinSPsPerDataset(_newValue);
    }

    function setDatasetRuleMaxReplicasPerSP(uint16 _newValue) external {
        filplusInstance.setDatasetRuleMaxReplicasPerSP(_newValue);
    }

    function setDatasetRuleMinTotalReplicasPerDataset(
        uint16 _newValue
    ) external {
        filplusInstance.setDatasetRuleMinTotalReplicasPerDataset(_newValue);
    }

    function setDatasetRuleMaxTotalReplicasPerDataset(
        uint16 _newValue
    ) external {
        filplusInstance.setDatasetRuleMaxTotalReplicasPerDataset(_newValue);
    }

    function setDatacapRulesMaxAllocatedSizePerTime(uint64 _newValue) external {
        filplusInstance.setDatacapRulesMaxAllocatedSizePerTime(_newValue);
    }

    function setDatacapRulesMaxRemainingPercentageForNext(
        uint8 _newValue
    ) external {
        filplusInstance.setDatacapRulesMaxRemainingPercentageForNext(_newValue);
    }

    function setMatchingRulesDataswapCommissionPercentage(
        uint8 _newValue
    ) external {
        filplusInstance.setMatchingRulesDataswapCommissionPercentage(_newValue);
    }

    function setMatchingRulesCommissionType(uint8 _newType) external {
        filplusInstance.setMatchingRulesCommissionType(_newType);
    }

    // Default getter functions for public variables
    function carRuleMaxCarReplicas() external view returns (uint16) {
        return filplusInstance.carRuleMaxCarReplicas();
    }

    function datasetRuleMinRegionsPerDataset() external view returns (uint16) {
        return filplusInstance.datasetRuleMinRegionsPerDataset();
    }

    function datasetRuleDefaultMaxReplicasPerCountry()
        external
        view
        returns (uint16)
    {
        return filplusInstance.datasetRuleDefaultMaxReplicasPerCountry();
    }

    function datasetRuleMaxReplicasPerCity() external view returns (uint16) {
        return filplusInstance.datasetRuleMaxReplicasPerCity();
    }

    function datasetRuleMaxProportionOfMappingFilesToDataset()
        external
        view
        returns (uint8)
    {
        return
            filplusInstance.datasetRuleMaxProportionOfMappingFilesToDataset();
    }

    function datasetRuleMinSPsPerDataset() external view returns (uint16) {
        return filplusInstance.datasetRuleMinSPsPerDataset();
    }

    function datasetRuleMaxReplicasPerSP() external view returns (uint16) {
        return filplusInstance.datasetRuleMaxReplicasPerSP();
    }

    function datasetRuleMinTotalReplicasPerDataset()
        external
        view
        returns (uint16)
    {
        return filplusInstance.datasetRuleMinTotalReplicasPerDataset();
    }

    function datasetRuleMaxTotalReplicasPerDataset()
        external
        view
        returns (uint16)
    {
        return filplusInstance.datasetRuleMaxTotalReplicasPerDataset();
    }

    function datacapRulesMaxAllocatedSizePerTime()
        external
        view
        returns (uint64)
    {
        return filplusInstance.datacapRulesMaxAllocatedSizePerTime();
    }

    function datacapRulesMaxRemainingPercentageForNext()
        external
        view
        returns (uint8)
    {
        return filplusInstance.datacapRulesMaxRemainingPercentageForNext();
    }

    function matchingRulesDataswapCommissionPercentage()
        external
        view
        returns (uint8)
    {
        return filplusInstance.matchingRulesDataswapCommissionPercentage();
    }

    function getMatchingRulesCommissionType() external view returns (uint8) {
        return filplusInstance.getMatchingRulesCommissionType();
    }
}
