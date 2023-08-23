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

///interface
import {IFilplus} from "src/v0.8/interfaces/core/IFilplus.sol";
///shared
import {FilplusEvents} from "src/v0.8/shared/events/FilplusEvents.sol";
import {CommonModifiers} from "src/v0.8/shared/modifiers/CommonModifiers.sol";
///type
import {FilplusType} from "src/v0.8/types/FilplusType.sol";

/// @title Filplus
contract Filplus is IFilplus, CommonModifiers {
    // solhint-disable-next-line
    address public immutable GOVERNANCE_ADDRESS; //The address of the governance contract.

    ///@notice car rules
    uint16 public carRuleMaxCarReplicas; // Represents the maximum number of car replicas in the entire network

    ///@notice dataset region rules
    uint16 public datasetRuleMinRegionsPerDataset; // Minimum required number of regions (e.g., 3).

    uint16 public datasetRuleDefaultMaxReplicasPerCountry; // Default maximum replicas allowed per country.

    mapping(bytes32 => uint16) private datasetRuleMaxReplicasInCountries; // Maximum replicas allowed per country.

    uint16 public datasetRuleMaxReplicasPerCity; // Maximum replicas allowed per city (e.g., 1).

    ///@notice dataset sp rules
    uint16 public datasetRuleMinSPsPerDataset; // Minimum required number of storage providers (e.g., 5).

    uint16 public datasetRuleMaxReplicasPerSP; // Maximum replicas allowed per storage provider (e.g., 1).

    uint16 public datasetRuleMinTotalReplicasPerDataset; // Minimum required total replicas (e.g., 5).

    uint16 public datasetRuleMaxTotalReplicasPerDataset; // Maximum allowed total replicas (e.g., 10).

    ///@notice datacap rules
    uint64 public datacapRulesMaxAllocatedSizePerTime; // Maximum allocate datacap size per time.

    uint8 public datacapRulesMaxRemainingPercentageForNext; // Minimum completion percentage for the next allocation.

    ///@notice matching rules
    uint8 public matchingRulesDataswapCommissionPercentage; // Percentage of commission.

    FilplusType.MatchingRuleCommissionType private matchingRulesCommissionType; // Type of commission for matching.

    // solhint-disable-next-line
    constructor(address payable _governance_address) {
        GOVERNANCE_ADDRESS = _governance_address;
        //defalut car rules
        carRuleMaxCarReplicas = 20;

        //defalut dataset region rules
        datasetRuleMinRegionsPerDataset = 3;
        datasetRuleDefaultMaxReplicasPerCountry = 1;
        datasetRuleMaxReplicasPerCity = 1;

        //defalut dataset sp rules
        datasetRuleMinSPsPerDataset = 5;
        datasetRuleMaxReplicasPerSP = 1;
        datasetRuleMinTotalReplicasPerDataset = 5;
        datasetRuleMaxTotalReplicasPerDataset = 10;

        //defalut datacap rules
        datacapRulesMaxAllocatedSizePerTime = 50 * 1024 * 1024 * 1024 * 1024; //50TB
        datacapRulesMaxRemainingPercentageForNext = 20; //20%

        //default matching rules
        matchingRulesDataswapCommissionPercentage = 3;
        matchingRulesCommissionType = FilplusType
            .MatchingRuleCommissionType
            .BuyerPays;
    }

    function getMatchingRulesCommissionType() external view returns (uint8) {
        return uint8(matchingRulesCommissionType);
    }

    // Public getter function to access datasetRuleMaxReplicasInCountries
    function getDatasetRuleMaxReplicasInCountry(
        bytes32 _countryCode
    ) public view returns (uint16) {
        if (datasetRuleMaxReplicasInCountries[_countryCode] == 0) {
            return datasetRuleDefaultMaxReplicasPerCountry;
        } else {
            return datasetRuleMaxReplicasInCountries[_countryCode];
        }
    }

    // Set functions for public variables
    function setCarRuleMaxCarReplicas(
        uint16 _newValue
    ) external onlyAddress(GOVERNANCE_ADDRESS) {
        carRuleMaxCarReplicas = _newValue;
        emit FilplusEvents.SetCarRuleMaxCarReplicas(_newValue);
    }

    function setDatasetRuleMinRegionsPerDataset(
        uint16 _newValue
    ) external onlyAddress(GOVERNANCE_ADDRESS) {
        datasetRuleMinRegionsPerDataset = _newValue;
        emit FilplusEvents.SetDatasetRuleMinRegionsPerDataset(_newValue);
    }

    function setDatasetRuleDefaultMaxReplicasPerCountry(
        uint16 _newValue
    ) external onlyAddress(GOVERNANCE_ADDRESS) {
        datasetRuleDefaultMaxReplicasPerCountry = _newValue;
        emit FilplusEvents.SetDatasetRuleDefaultMaxReplicasPerCountry(
            _newValue
        );
    }

    function setDatasetRuleMaxReplicasInCountry(
        bytes32 _countryCode,
        uint16 _newValue
    ) external onlyAddress(GOVERNANCE_ADDRESS) onlyNotZero(_newValue) {
        datasetRuleMaxReplicasInCountries[_countryCode] = _newValue;
        emit FilplusEvents.SetDatasetRuleMaxReplicasInCountry(
            _countryCode,
            _newValue
        );
    }

    function setDatasetRuleMaxReplicasPerCity(
        uint16 _newValue
    ) external onlyAddress(GOVERNANCE_ADDRESS) {
        datasetRuleMaxReplicasPerCity = _newValue;
        emit FilplusEvents.SetDatasetRuleMaxReplicasPerCity(_newValue);
    }

    function setDatasetRuleMinSPsPerDataset(
        uint16 _newValue
    ) external onlyAddress(GOVERNANCE_ADDRESS) {
        datasetRuleMinSPsPerDataset = _newValue;
        emit FilplusEvents.SetDatasetRuleMinSPsPerDataset(_newValue);
    }

    function setDatasetRuleMaxReplicasPerSP(
        uint16 _newValue
    ) external onlyAddress(GOVERNANCE_ADDRESS) {
        datasetRuleMaxReplicasPerSP = _newValue;
        emit FilplusEvents.SetDatasetRuleMaxReplicasPerSP(_newValue);
    }

    function setDatasetRuleMinTotalReplicasPerDataset(
        uint16 _newValue
    ) external onlyAddress(GOVERNANCE_ADDRESS) {
        datasetRuleMinTotalReplicasPerDataset = _newValue;
        emit FilplusEvents.SetDatasetRuleMinTotalReplicasPerDataset(_newValue);
    }

    function setDatasetRuleMaxTotalReplicasPerDataset(
        uint16 _newValue
    ) external onlyAddress(GOVERNANCE_ADDRESS) {
        datasetRuleMaxTotalReplicasPerDataset = _newValue;
        emit FilplusEvents.SetDatasetRuleMaxTotalReplicasPerDataset(_newValue);
    }

    function setDatacapRulesMaxAllocatedSizePerTime(
        uint64 _newValue
    ) external onlyAddress(GOVERNANCE_ADDRESS) {
        datacapRulesMaxAllocatedSizePerTime = _newValue;
        emit FilplusEvents.SetDatacapRulesMaxAllocatedSizePerTime(_newValue);
    }

    function setDatacapRulesMaxRemainingPercentageForNext(
        uint8 _newValue
    ) external onlyAddress(GOVERNANCE_ADDRESS) {
        datacapRulesMaxRemainingPercentageForNext = _newValue;
        emit FilplusEvents.SetDatacapRulesMaxRemainingPercentageForNext(
            _newValue
        );
    }

    function setMatchingRulesDataswapCommissionPercentage(
        uint8 _newValue
    ) external onlyAddress(GOVERNANCE_ADDRESS) {
        matchingRulesDataswapCommissionPercentage = _newValue;
        emit FilplusEvents.SetMatchingRulesDataswapCommissionPercentage(
            _newValue
        );
    }

    function setMatchingRulesCommissionType(
        uint8 _newValue
    ) external onlyAddress(GOVERNANCE_ADDRESS) {
        require(
            _newValue < uint8(FilplusType.MatchingRuleCommissionType.Max),
            "Invalid state"
        );
        matchingRulesCommissionType = FilplusType.MatchingRuleCommissionType(
            _newValue
        );
        emit FilplusEvents.SetMatchingRulesCommissionType(
            matchingRulesCommissionType
        );
    }
}
