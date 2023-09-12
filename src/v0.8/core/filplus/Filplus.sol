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

///interface
import {IFilplus} from "src/v0.8/interfaces/core/IFilplus.sol";
///shared
import {FilplusEvents} from "src/v0.8/shared/events/FilplusEvents.sol";
///type
import {RolesType} from "src/v0.8/types/RolesType.sol";
import {FilplusType} from "src/v0.8/types/FilplusType.sol";

import {RolesModifiers} from "src/v0.8/shared/modifiers/RolesModifiers.sol";

import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {UUPSUpgradeable} from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

/// @title Filplus
contract Filplus is Initializable, UUPSUpgradeable, IFilplus, RolesModifiers {
    // solhint-disable-next-line
    address public GOVERNANCE_ADDRESS; //The address of the governance contract.

    ///@notice car rules
    uint16 public carRuleMaxCarReplicas; // Represents the maximum number of car replicas in the entire network

    ///@notice dataset region rules
    uint16 public datasetRuleMinRegionsPerDataset; // Minimum required number of regions (e.g., 3).

    uint16 public datasetRuleDefaultMaxReplicasPerCountry; // Default maximum replicas allowed per country.

    mapping(bytes32 => uint16) private datasetRuleMaxReplicasInCountries; // Maximum replicas allowed per country.

    uint16 public datasetRuleMaxReplicasPerCity; // Maximum replicas allowed per city (e.g., 1).

    uint8 public datasetRuleMaxProportionOfMappingFilesToDataset; //Maximum proportion of dataset mapping files,measured in ten-thousandths.(e.g.,40)

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

    /// @dev This empty reserved space is put in place to allow future versions to add new
    uint256[32] private __gap;

    /// @notice initialize function to initialize the contract and grant the default admin role to the deployer.
    // solhint-disable-next-line
    function initialize(
        address payable _governanceAddress,
        address _roles
    ) public initializer {
        GOVERNANCE_ADDRESS = _governanceAddress;
        //defalut car rules
        carRuleMaxCarReplicas = 20;

        //defalut dataset region rules
        datasetRuleMinRegionsPerDataset = 3;
        datasetRuleDefaultMaxReplicasPerCountry = 1;
        datasetRuleMaxReplicasPerCity = 1;
        datasetRuleMaxProportionOfMappingFilesToDataset = 40; // 40/10000

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

        RolesModifiers.rolesModifiersInitialize(_roles);
        __UUPSUpgradeable_init();
    }

    /// @notice UUPS Upgradeable function to update the roles implementation
    /// @dev Only triggered by contract admin
    function _authorizeUpgrade(
        address newImplementation
    )
        internal
        override
        onlyRole(RolesType.DEFAULT_ADMIN_ROLE) // solhint-disable-next-line
    {}

    /// @notice Returns the implementation contract
    function getImplementation() external view returns (address) {
        return _getImplementation();
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

    /// @notice set maximum proportion of dataset mapping files
    function setDatasetRuleMaxProportionOfMappingFilesToDataset(
        uint8 _newValue
    ) external onlyAddress(GOVERNANCE_ADDRESS) {
        datasetRuleMaxProportionOfMappingFilesToDataset = _newValue;
        emit FilplusEvents.SetDatasetRuleMaxProportionOfMappingFilesToDataset(
            _newValue
        );
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
