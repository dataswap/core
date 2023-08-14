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
import {CommonModifiers} from "../../shared/modifiers/CommonModifiers.sol";
import {IRoles} from "../../interfaces/core/IRoles.sol";
import {IFilplus} from "../../interfaces/core/IFilplus.sol";

/// @title Filplus
contract Filplus is IFilplus, CommonModifiers {
    address public immutable governanceAddress; //The address of the governance contract.

    ///@notice car rules
    uint32 public carRuleMaxCarReplicas; // Represents the maximum number of car replicas in the entire network
    event SetCarRuleMaxCarReplicas(uint32 _newValue);

    ///@notice dataset region rules
    uint32 public datasetRuleMinRegionsPerDataset; // Minimum required number of regions (e.g., 3).
    event SetDatasetRuleMinRegionsPerDataset(uint32 _newValue);

    uint32 public datasetRuleDefaultMaxReplicasPerCountry; // Default maximum replicas allowed per country.
    event SetDatasetRuleDefaultMaxReplicasPerCountry(uint32 _newValue);

    mapping(bytes32 => uint32) private datasetRuleMaxReplicasInCountries; // Maximum replicas allowed per country.
    event SetDatasetRuleMaxReplicasInCountry(
        bytes32 _countryCode,
        uint32 _newValue
    );

    uint32 public datasetRuleMaxReplicasPerCity; // Maximum replicas allowed per city (e.g., 1).
    event SetDatasetRuleMaxReplicasPerCity(uint32 _newValue);

    ///@notice dataset sp rules
    uint32 public datasetRuleMinSPsPerDataset; // Minimum required number of storage providers (e.g., 5).
    event SetDatasetRuleMinSPsPerDataset(uint32 _newValue);

    uint32 public datasetRuleMaxReplicasPerSP; // Maximum replicas allowed per storage provider (e.g., 1).
    event SetDatasetRuleMaxReplicasPerSP(uint32 _newValue);

    uint32 public datasetRuleMinTotalReplicasPerDataset; // Minimum required total replicas (e.g., 5).
    event SetDatasetRuleMinTotalReplicasPerDataset(uint32 _newValue);

    uint32 public datasetRuleMaxTotalReplicasPerDataset; // Maximum allowed total replicas (e.g., 10).
    event SetDatasetRuleMaxTotalReplicasPerDataset(uint32 _newValue);

    ///@notice datacap rules
    uint64 public datacapRulesMaxAllocatedSizePerTime; // Maximum allocate datacap size per time.
    event SetDatacapRulesMaxAllocatedSizePerTime(uint64 _newValue);

    uint64 public datacapRulesMaxRemainingPercentageForNext; // Minimum completion percentage for the next allocation.
    event SetDatacapRulesMaxRemainingPercentageForNext(uint64 _newValue);

    ///@notice matching rules
    uint256 public matchingRulesDataswapCommissionPercentage; // Percentage of commission.
    event SetMatchingRulesDataswapCommissionPercentage(uint256 _newValue);

    MatchingRuleCommissionType private matchingRulesCommissionType; // Type of commission for matching.
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

    function getMatchingRulesCommissionType() external view returns (uint8) {
        return uint8(matchingRulesCommissionType);
    }

    // Public getter function to access datasetRuleMaxReplicasInCountries
    function getDatasetRuleMaxReplicasInCountry(
        bytes32 _countryCode
    ) public view returns (uint32) {
        if (datasetRuleMaxReplicasInCountries[_countryCode] == 0) {
            return datasetRuleDefaultMaxReplicasPerCountry;
        } else {
            return datasetRuleMaxReplicasInCountries[_countryCode];
        }
    }

    // Set functions for public variables
    function setCarRuleMaxCarReplicas(
        uint32 _newValue
    ) external onlyAddress(governanceAddress) {
        carRuleMaxCarReplicas = _newValue;
        emit SetCarRuleMaxCarReplicas(_newValue);
    }

    function setDatasetRuleMinRegionsPerDataset(
        uint32 _newValue
    ) external onlyAddress(governanceAddress) {
        datasetRuleMinRegionsPerDataset = _newValue;
        emit SetDatasetRuleMinRegionsPerDataset(_newValue);
    }

    function setDatasetRuleDefaultMaxReplicasPerCountry(
        uint32 _newValue
    ) external onlyAddress(governanceAddress) {
        datasetRuleDefaultMaxReplicasPerCountry = _newValue;
        emit SetDatasetRuleDefaultMaxReplicasPerCountry(_newValue);
    }

    function setDatasetRuleMaxReplicasInCountry(
        bytes32 _countryCode,
        uint32 _newValue
    ) external onlyAddress(governanceAddress) {
        datasetRuleMaxReplicasInCountries[_countryCode] = _newValue;
        emit SetDatasetRuleMaxReplicasInCountry(_countryCode, _newValue);
    }

    function setDatasetRuleMaxReplicasPerCity(
        uint32 _newValue
    ) external onlyAddress(governanceAddress) {
        datasetRuleMaxReplicasPerCity = _newValue;
        emit SetDatasetRuleMaxReplicasPerCity(_newValue);
    }

    function setDatasetRuleMinSPsPerDataset(
        uint32 _newValue
    ) external onlyAddress(governanceAddress) {
        datasetRuleMinSPsPerDataset = _newValue;
        emit SetDatasetRuleMinSPsPerDataset(_newValue);
    }

    function setDatasetRuleMaxReplicasPerSP(
        uint32 _newValue
    ) external onlyAddress(governanceAddress) {
        datasetRuleMaxReplicasPerSP = _newValue;
        emit SetDatasetRuleMaxReplicasPerSP(_newValue);
    }

    function setDatasetRuleMinTotalReplicasPerDataset(
        uint32 _newValue
    ) external onlyAddress(governanceAddress) {
        datasetRuleMinTotalReplicasPerDataset = _newValue;
        emit SetDatasetRuleMinTotalReplicasPerDataset(_newValue);
    }

    function setDatasetRuleMaxTotalReplicasPerDataset(
        uint32 _newValue
    ) external onlyAddress(governanceAddress) {
        datasetRuleMaxTotalReplicasPerDataset = _newValue;
        emit SetDatasetRuleMaxTotalReplicasPerDataset(_newValue);
    }

    function setDatacapRulesMaxAllocatedSizePerTime(
        uint64 _newValue
    ) external onlyAddress(governanceAddress) {
        datacapRulesMaxAllocatedSizePerTime = _newValue;
        emit SetDatacapRulesMaxAllocatedSizePerTime(_newValue);
    }

    function setDatacapRulesMaxRemainingPercentageForNext(
        uint64 _newValue
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
