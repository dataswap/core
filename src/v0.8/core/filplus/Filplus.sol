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

import "../../shared/utils/contract/ModifierCommon.sol";

/// @title Filplus
/// @author waynewyang
contract Filplus is ModifierCommon {
    address payable internal immutable governanceAddress; //The address of the governance contract.

    ///@notice car rules
    uint256 public carRuleMaxCarReplicas; // Represents the maximum number of car replicas in the entire network
    event SetCarRuleMaxCarReplicas(uint256 newValue);

    ///@notice dataset region rules
    uint256 public datasetRuleMinRegionsPerDataset; // Minimum required number of regions (e.g., 3).
    event SetDatasetRuleMinRegionsPerDataset(uint256 newValue);

    uint256 public datasetRuleDefaultMaxReplicasPerCountry; // Default maximum replicas allowed per country.
    event SetDatasetRuleDefaultMaxReplicasPerCountry(uint256 newValue);

    mapping(bytes32 => uint256) private datasetRuleMaxReplicasInCountries; // Maximum replicas allowed per country.
    event SetDatasetRuleMaxReplicasInCountry(
        bytes32 countryCode,
        uint256 newValue
    );

    uint256 public datasetRuleMaxReplicasPerCity; // Maximum replicas allowed per city (e.g., 1).
    event SetDatasetRuleMaxReplicasPerCity(uint256 newValue);

    ///@notice dataset sp rules
    uint256 public datasetRuleMinSPsPerDataset; // Minimum required number of storage providers (e.g., 5).
    event SetDatasetRuleMinSPsPerDataset(uint256 newValue);

    uint256 public datasetRuleMaxReplicasPerSP; // Maximum replicas allowed per storage provider (e.g., 1).
    event SetDatasetRuleMaxReplicasPerSP(uint256 newValue);

    uint256 public datasetRuleMinTotalReplicasPerDataset; // Minimum required total replicas (e.g., 5).
    event SetDatasetRuleMinTotalReplicasPerDataset(uint256 newValue);

    uint256 public datasetRuleMaxTotalReplicasPerDataset; // Maximum allowed total replicas (e.g., 10).
    event SetDatasetRuleMaxTotalReplicasPerDataset(uint256 newValue);

    ///@notice datacap rules
    uint256 public datacapRulesMaxAllocatedSizePerTime; // Maximum allocate datacap size per time.
    event SetDatacapRulesMaxAllocatedSizePerTime(uint256 newValue);

    uint256 public datacapRulesMaxRemainingPercentageForNext; // Minimum completion percentage for the next allocation.
    event SetDatacapRulesMaxRemainingPercentageForNext(uint256 newValue);

    ///@notice matching rules
    uint256 public matchingRulesDataswapCommissionPercentage; // Percentage of commission.
    event SetMatchingRulesDataswapCommissionPercentage(uint256 newValue);

    MatchingRuleCommissionType public matchingRulesCommissionType; // Type of commission for matching.
    event SetMatchingRulesCommissionType(MatchingRuleCommissionType newType);

    enum MatchingRuleCommissionType {
        BuyerPays,
        SellerPays,
        SplitPayment
    }

    constructor(address payable _governanceAddress) {
        governanceAddress = _governanceAddress;

        //TODO: add default value for every
    }

    // Public getter function to access datasetRuleMaxReplicasInCountries
    function getDatasetRuleMaxReplicasInCountry(
        bytes32 countryCode
    ) public view returns (uint256) {
        if (datasetRuleMaxReplicasInCountries[countryCode] == 0) {
            return datasetRuleDefaultMaxReplicasPerCountry;
        } else {
            return datasetRuleMaxReplicasInCountries[countryCode];
        }
    }

    // Set functions for public variables
    function setCarRuleMaxCarReplicas(
        uint256 newValue
    ) external onlyAddress(governanceAddress) {
        carRuleMaxCarReplicas = newValue;
        emit SetCarRuleMaxCarReplicas(newValue);
    }

    function setDatasetRuleMinRegionsPerDataset(
        uint256 newValue
    ) external onlyAddress(governanceAddress) {
        datasetRuleMinRegionsPerDataset = newValue;
        emit SetDatasetRuleMinRegionsPerDataset(newValue);
    }

    function setDatasetRuleDefaultMaxReplicasPerCountry(
        uint256 newValue
    ) external onlyAddress(governanceAddress) {
        datasetRuleDefaultMaxReplicasPerCountry = newValue;
        emit SetDatasetRuleDefaultMaxReplicasPerCountry(newValue);
    }

    function setDatasetRuleMaxReplicasInCountry(
        bytes32 countryCode,
        uint256 newValue
    ) external onlyAddress(governanceAddress) {
        datasetRuleMaxReplicasInCountries[countryCode] = newValue;
        emit SetDatasetRuleMaxReplicasInCountry(countryCode, newValue);
    }

    function setDatasetRuleMaxReplicasPerCity(
        uint256 newValue
    ) external onlyAddress(governanceAddress) {
        datasetRuleMaxReplicasPerCity = newValue;
        emit SetDatasetRuleMaxReplicasPerCity(newValue);
    }

    function setDatasetRuleMinSPsPerDataset(
        uint256 newValue
    ) external onlyAddress(governanceAddress) {
        datasetRuleMinSPsPerDataset = newValue;
        emit SetDatasetRuleMinSPsPerDataset(newValue);
    }

    function setDatasetRuleMaxReplicasPerSP(
        uint256 newValue
    ) external onlyAddress(governanceAddress) {
        datasetRuleMaxReplicasPerSP = newValue;
        emit SetDatasetRuleMaxReplicasPerSP(newValue);
    }

    function setDatasetRuleMinTotalReplicasPerDataset(
        uint256 newValue
    ) external onlyAddress(governanceAddress) {
        datasetRuleMinTotalReplicasPerDataset = newValue;
        emit SetDatasetRuleMinTotalReplicasPerDataset(newValue);
    }

    function setDatasetRuleMaxTotalReplicasPerDataset(
        uint256 newValue
    ) external onlyAddress(governanceAddress) {
        datasetRuleMaxTotalReplicasPerDataset = newValue;
        emit SetDatasetRuleMaxTotalReplicasPerDataset(newValue);
    }

    function setDatacapRulesMaxAllocatedSizePerTime(
        uint256 newValue
    ) external onlyAddress(governanceAddress) {
        datacapRulesMaxAllocatedSizePerTime = newValue;
        emit SetDatacapRulesMaxAllocatedSizePerTime(newValue);
    }

    function setDatacapRulesMaxRemainingPercentageForNext(
        uint256 newValue
    ) external onlyAddress(governanceAddress) {
        datacapRulesMaxRemainingPercentageForNext = newValue;
        emit SetDatacapRulesMaxRemainingPercentageForNext(newValue);
    }

    function setMatchingRulesDataswapCommissionPercentage(
        uint256 newValue
    ) external onlyAddress(governanceAddress) {
        matchingRulesDataswapCommissionPercentage = newValue;
        emit SetMatchingRulesDataswapCommissionPercentage(newValue);
    }

    function setMatchingRulesCommissionType(
        MatchingRuleCommissionType newType
    ) external onlyAddress(governanceAddress) {
        matchingRulesCommissionType = newType;
        emit SetMatchingRulesCommissionType(newType);
    }
}
