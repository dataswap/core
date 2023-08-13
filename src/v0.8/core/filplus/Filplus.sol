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
import "./IFilplus.sol";

/// @title Filplus
/// @author waynewyang
abstract contract Filplus is ModifierCommon {
    address payable public immutable governanceAddress; //The address of the governance contract.

    ///@notice car rules
    uint256 public carRuleMaxCarReplicas; // Represents the maximum number of car replicas in the entire network
    event SetCarRuleMaxCarReplicas(uint256 _newValue);

    ///@notice dataset region rules
    uint256 public datasetRuleMinRegionsPerDataset; // Minimum required number of regions (e.g., 3).
    event SetDatasetRuleMinRegionsPerDataset(uint256 _newValue);

    uint256 public datasetRuleDefaultMaxReplicasPerCountry; // Default maximum replicas allowed per country.
    event SetDatasetRuleDefaultMaxReplicasPerCountry(uint256 _newValue);

    mapping(bytes32 => uint256) private datasetRuleMaxReplicasInCountries; // Maximum replicas allowed per country.
    event SetDatasetRuleMaxReplicasInCountry(
        bytes32 _countryCode,
        uint256 _newValue
    );

    uint256 public datasetRuleMaxReplicasPerCity; // Maximum replicas allowed per city (e.g., 1).
    event SetDatasetRuleMaxReplicasPerCity(uint256 _newValue);

    ///@notice dataset sp rules
    uint256 public datasetRuleMinSPsPerDataset; // Minimum required number of storage providers (e.g., 5).
    event SetDatasetRuleMinSPsPerDataset(uint256 _newValue);

    uint256 public datasetRuleMaxReplicasPerSP; // Maximum replicas allowed per storage provider (e.g., 1).
    event SetDatasetRuleMaxReplicasPerSP(uint256 _newValue);

    uint256 public datasetRuleMinTotalReplicasPerDataset; // Minimum required total replicas (e.g., 5).
    event SetDatasetRuleMinTotalReplicasPerDataset(uint256 _newValue);

    uint256 public datasetRuleMaxTotalReplicasPerDataset; // Maximum allowed total replicas (e.g., 10).
    event SetDatasetRuleMaxTotalReplicasPerDataset(uint256 _newValue);

    ///@notice datacap rules
    uint256 public datacapRulesMaxAllocatedSizePerTime; // Maximum allocate datacap size per time.
    event SetDatacapRulesMaxAllocatedSizePerTime(uint256 _newValue);

    uint256 public datacapRulesMaxRemainingPercentageForNext; // Minimum completion percentage for the next allocation.
    event SetDatacapRulesMaxRemainingPercentageForNext(uint256 _newValue);

    ///@notice matching rules
    uint256 public matchingRulesDataswapCommissionPercentage; // Percentage of commission.
    event SetMatchingRulesDataswapCommissionPercentage(uint256 _newValue);

    MatchingRuleCommissionType public matchingRulesCommissionType; // Type of commission for matching.
    event SetMatchingRulesCommissionType(MatchingRuleCommissionType _newType);

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
        bytes32 _countryCode
    ) public view returns (uint256) {
        if (datasetRuleMaxReplicasInCountries[_countryCode] == 0) {
            return datasetRuleDefaultMaxReplicasPerCountry;
        } else {
            return datasetRuleMaxReplicasInCountries[_countryCode];
        }
    }

    // Set functions for public variables
    function setCarRuleMaxCarReplicas(
        uint256 _newValue
    ) external onlyAddress(governanceAddress) {
        carRuleMaxCarReplicas = _newValue;
        emit SetCarRuleMaxCarReplicas(_newValue);
    }

    function setDatasetRuleMinRegionsPerDataset(
        uint256 _newValue
    ) external onlyAddress(governanceAddress) {
        datasetRuleMinRegionsPerDataset = _newValue;
        emit SetDatasetRuleMinRegionsPerDataset(_newValue);
    }

    function setDatasetRuleDefaultMaxReplicasPerCountry(
        uint256 _newValue
    ) external onlyAddress(governanceAddress) {
        datasetRuleDefaultMaxReplicasPerCountry = _newValue;
        emit SetDatasetRuleDefaultMaxReplicasPerCountry(_newValue);
    }

    function setDatasetRuleMaxReplicasInCountry(
        bytes32 _countryCode,
        uint256 _newValue
    ) external onlyAddress(governanceAddress) {
        datasetRuleMaxReplicasInCountries[_countryCode] = _newValue;
        emit SetDatasetRuleMaxReplicasInCountry(_countryCode, _newValue);
    }

    function setDatasetRuleMaxReplicasPerCity(
        uint256 _newValue
    ) external onlyAddress(governanceAddress) {
        datasetRuleMaxReplicasPerCity = _newValue;
        emit SetDatasetRuleMaxReplicasPerCity(_newValue);
    }

    function setDatasetRuleMinSPsPerDataset(
        uint256 _newValue
    ) external onlyAddress(governanceAddress) {
        datasetRuleMinSPsPerDataset = _newValue;
        emit SetDatasetRuleMinSPsPerDataset(_newValue);
    }

    function setDatasetRuleMaxReplicasPerSP(
        uint256 _newValue
    ) external onlyAddress(governanceAddress) {
        datasetRuleMaxReplicasPerSP = _newValue;
        emit SetDatasetRuleMaxReplicasPerSP(_newValue);
    }

    function setDatasetRuleMinTotalReplicasPerDataset(
        uint256 _newValue
    ) external onlyAddress(governanceAddress) {
        datasetRuleMinTotalReplicasPerDataset = _newValue;
        emit SetDatasetRuleMinTotalReplicasPerDataset(_newValue);
    }

    function setDatasetRuleMaxTotalReplicasPerDataset(
        uint256 _newValue
    ) external onlyAddress(governanceAddress) {
        datasetRuleMaxTotalReplicasPerDataset = _newValue;
        emit SetDatasetRuleMaxTotalReplicasPerDataset(_newValue);
    }

    function setDatacapRulesMaxAllocatedSizePerTime(
        uint256 _newValue
    ) external onlyAddress(governanceAddress) {
        datacapRulesMaxAllocatedSizePerTime = _newValue;
        emit SetDatacapRulesMaxAllocatedSizePerTime(_newValue);
    }

    function setDatacapRulesMaxRemainingPercentageForNext(
        uint256 _newValue
    ) external onlyAddress(governanceAddress) {
        datacapRulesMaxRemainingPercentageForNext = _newValue;
        emit SetDatacapRulesMaxRemainingPercentageForNext(_newValue);
    }

    function setMatchingRulesDataswapCommissionPercentage(
        uint256 _newValue
    ) external onlyAddress(governanceAddress) {
        matchingRulesDataswapCommissionPercentage = _newValue;
        emit SetMatchingRulesDataswapCommissionPercentage(_newValue);
    }

    function setMatchingRulesCommissionType(
        uint8 _newValue
    ) external onlyAddress(governanceAddress) {
        matchingRulesCommissionType = MatchingRuleCommissionType(_newValue);
        emit SetMatchingRulesCommissionType(matchingRulesCommissionType);
    }
}
