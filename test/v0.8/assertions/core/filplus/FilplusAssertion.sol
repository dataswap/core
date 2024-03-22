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

// Importing Solidity libraries and contracts
import {DSTest} from "ds-test/test.sol";
import {Test} from "forge-std/Test.sol";
import {IFilplus} from "src/v0.8/interfaces/core/IFilplus.sol";
import {IFilplusAssertion} from "test/v0.8/interfaces/assertions/core/IFilplusAssertion.sol";

/// @notice This contract defines assertion functions for testing an IFilplus contract.
/// @dev NOTE: All methods that do not change the state must be tested by methods that will change the state to ensure test coverage.
contract FilplusAssertion is DSTest, Test, IFilplusAssertion {
    IFilplus public filplus;
    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    /// @notice Constructor that sets the address of the IFilplus contract.
    /// @param _filplus The address of the IFilplus contract.
    constructor(IFilplus _filplus) {
        filplus = _filplus;
    }

    // Assertion functions for setting values

    /// @notice Sets the minimum number of regions per dataset and asserts the value.
    /// @param _caller The address of the caller.
    /// @param _newValue The new minimum regions per dataset value.
    function setDatasetRuleMinRegionsPerDatasetAssertion(
        address _caller,
        uint16 _newValue
    ) external {
        vm.prank(_caller);
        filplus.setDatasetRuleMinRegionsPerDataset(_newValue);
        datasetRuleMinRegionsPerDatasetAssertion(_newValue);
    }

    /// @notice Sets the default maximum replicas per country for datasets and asserts the value.
    /// @param _caller The address of the caller.
    /// @param _newValue The new default maximum replicas per country value.
    function setDatasetRuleDefaultMaxReplicasPerCountryAssertion(
        address _caller,
        uint16 _newValue
    ) external {
        vm.prank(_caller);
        filplus.setDatasetRuleDefaultMaxReplicasPerCountry(_newValue);
        datasetRuleDefaultMaxReplicasPerCountryAssertion(_newValue);
    }

    /// @notice Sets the maximum replicas allowed in a specific country for datasets and asserts the value.
    /// @param _caller The address of the caller.
    /// @param _countryCode The country code.
    /// @param _newValue The new maximum replicas value for the country.
    function setDatasetRuleMaxReplicasInCountryAssertion(
        address _caller,
        uint16 _countryCode,
        uint16 _newValue
    ) external {
        vm.prank(_caller);
        filplus.setDatasetRuleMaxReplicasInCountry(_countryCode, _newValue);
        getDatasetRuleMaxReplicasInCountryAssertion(_countryCode, _newValue);
    }

    /// @notice Sets the maximum replicas allowed per city for datasets and asserts the value.
    /// @param _caller The address of the caller.
    /// @param _newValue The new maximum replicas per city value.
    function setDatasetRuleMaxReplicasPerCityAssertion(
        address _caller,
        uint16 _newValue
    ) external {
        vm.prank(_caller);
        filplus.setDatasetRuleMaxReplicasPerCity(_newValue);
        datasetRuleMaxReplicasPerCityAssertion(_newValue);
    }

    /// @notice Sets the maximum proportion of dataset mapping files and asserts the value.
    /// @param _caller The address of the caller.
    /// @param _newValue The new max proportion of mapping files to dataset value.
    function setDatasetRuleMaxProportionOfMappingFilesToDatasetAssertion(
        address _caller,
        uint8 _newValue
    ) external {
        vm.prank(_caller);
        filplus.setDatasetRuleMaxProportionOfMappingFilesToDataset(_newValue);
        datasetRuleMaxProportionOfMappingFilesToDatasetAssertion(_newValue);
    }

    /// @notice Sets the minimum number of storage providers (SPs) per dataset and asserts the value.
    /// @param _caller The address of the caller.
    /// @param _newValue The new minimum SPs per dataset value.
    function setDatasetRuleMinSPsPerDatasetAssertion(
        address _caller,
        uint16 _newValue
    ) external {
        vm.prank(_caller);
        filplus.setDatasetRuleMinSPsPerDataset(_newValue);
        datasetRuleMinSPsPerDatasetAssertion(_newValue);
    }

    /// @notice Sets the maximum replicas allowed per storage provider (SP) for datasets and asserts the value.
    /// @param _caller The address of the caller.
    /// @param _newValue The new maximum replicas per SP value.
    function setDatasetRuleMaxReplicasPerSPAssertion(
        address _caller,
        uint16 _newValue
    ) external {
        vm.prank(_caller);
        filplus.setDatasetRuleMaxReplicasPerSP(_newValue);
        datasetRuleMaxReplicasPerSPAssertion(_newValue);
    }

    /// @notice Sets the minimum total replicas per dataset and asserts the value.
    /// @param _caller The address of the caller.
    /// @param _newValue The new minimum total replicas per dataset value.
    function setDatasetRuleMinTotalReplicasPerDatasetAssertion(
        address _caller,
        uint16 _newValue
    ) external {
        vm.prank(_caller);
        filplus.setDatasetRuleMinTotalReplicasPerDataset(_newValue);
        datasetRuleMinTotalReplicasPerDatasetAssertion(_newValue);
    }

    /// @notice Sets the maximum total replicas per dataset and asserts the value.
    /// @param _caller The address of the caller.
    /// @param _newValue The new maximum total replicas per dataset value.
    function setDatasetRuleMaxTotalReplicasPerDatasetAssertion(
        address _caller,
        uint16 _newValue
    ) external {
        vm.prank(_caller);
        filplus.setDatasetRuleMaxTotalReplicasPerDataset(_newValue);
        datasetRuleMaxTotalReplicasPerDatasetAssertion(_newValue);
    }

    /// @notice Sets the maximum allocated size per time period for datacap rules and asserts the value.
    /// @param _caller The address of the caller.
    /// @param _newValue The new maximum allocated size per time value.
    function setDatacapRulesMaxAllocatedSizePerTimeAssertion(
        address _caller,
        uint64 _newValue
    ) external {
        vm.prank(_caller);
        filplus.setDatacapRuleMaxAllocatedSizePerTime(_newValue);
        datacapRulesMaxAllocatedSizePerTimeAssertion(_newValue);
    }

    /// @notice Sets the maximum remaining percentage for the next data allocation for datacap rules and asserts the value.
    /// @param _caller The address of the caller.
    /// @param _newValue The new maximum remaining percentage value.
    function setDatacapRulesMaxRemainingPercentageForNextAssertion(
        address _caller,
        uint8 _newValue
    ) external {
        vm.prank(_caller);
        filplus.setDatacapRuleMaxRemainingPercentageForNext(_newValue);
        datacapRulesMaxRemainingPercentageForNextAssertion(_newValue);
    }

    // Assertion functions for getting values

    /// @notice Asserts the minimum number of regions per dataset.
    /// @param _expectCount The expected minimum regions per dataset value.
    function datasetRuleMinRegionsPerDatasetAssertion(
        uint16 _expectCount
    ) public {
        assertEq(filplus.datasetRuleMinRegionsPerDataset(), _expectCount);
    }

    /// @notice Asserts the default maximum replicas per country for datasets.
    /// @param _expectCount The expected default maximum replicas per country value.
    function datasetRuleDefaultMaxReplicasPerCountryAssertion(
        uint16 _expectCount
    ) public {
        assertEq(
            filplus.datasetRuleDefaultMaxReplicasPerCountry(),
            _expectCount
        );
    }

    /// @notice Asserts the maximum replicas allowed per city for datasets.
    /// @param _expectCount The expected maximum replicas per city value.
    function datasetRuleMaxReplicasPerCityAssertion(
        uint16 _expectCount
    ) public {
        assertEq(filplus.datasetRuleMaxReplicasPerCity(), _expectCount);
    }

    /// @notice Asserts the maximum proportion of mapping files to dataset.
    /// @param _expectCount The expected maximum proportion of mapping files to dataset value.
    function datasetRuleMaxProportionOfMappingFilesToDatasetAssertion(
        uint8 _expectCount
    ) public {
        assertEq(
            filplus.datasetRuleMaxProportionOfMappingFilesToDataset(),
            _expectCount
        );
    }

    /// @notice Asserts the minimum number of storage providers (SPs) per dataset.
    /// @param _expectCount The expected minimum SPs per dataset value.
    function datasetRuleMinSPsPerDatasetAssertion(uint16 _expectCount) public {
        assertEq(filplus.datasetRuleMinSPsPerDataset(), _expectCount);
    }

    /// @notice Asserts the maximum replicas allowed per storage provider (SP) for datasets.
    /// @param _expectCount The expected maximum replicas per SP value.
    function datasetRuleMaxReplicasPerSPAssertion(uint16 _expectCount) public {
        assertEq(filplus.datasetRuleMaxReplicasPerSP(), _expectCount);
    }

    /// @notice Asserts the minimum total replicas per dataset.
    /// @param _expectCount The expected minimum total replicas per dataset value.
    function datasetRuleMinTotalReplicasPerDatasetAssertion(
        uint16 _expectCount
    ) public {
        assertEq(filplus.datasetRuleMinTotalReplicasPerDataset(), _expectCount);
    }

    /// @notice Asserts the maximum total replicas per dataset.
    /// @param _expectCount The expected maximum total replicas per dataset value.
    function datasetRuleMaxTotalReplicasPerDatasetAssertion(
        uint16 _expectCount
    ) public {
        assertEq(filplus.datasetRuleMaxTotalReplicasPerDataset(), _expectCount);
    }

    /// @notice Asserts the maximum allocated size per time period for datacap rules.
    /// @param _expectSize The expected maximum allocated size per time value.
    function datacapRulesMaxAllocatedSizePerTimeAssertion(
        uint64 _expectSize
    ) public {
        assertEq(filplus.datacapRuleMaxAllocatedSizePerTime(), _expectSize);
    }

    /// @notice Asserts the maximum remaining percentage for the next data allocation for datacap rules.
    /// @param _expectPercentrage The expected maximum remaining percentage value.
    function datacapRulesMaxRemainingPercentageForNextAssertion(
        uint8 _expectPercentrage
    ) public {
        assertEq(
            filplus.datacapRuleMaxRemainingPercentageForNext(),
            _expectPercentrage
        );
    }

    /// @notice Asserts the maximum replicas allowed in a specific country for datasets.
    /// @param _countryCode The country code.
    /// @param _expectCount The expected maximum replicas value for the country.
    function getDatasetRuleMaxReplicasInCountryAssertion(
        uint16 _countryCode,
        uint16 _expectCount
    ) public {
        assertEq(
            filplus.getDatasetRuleMaxReplicasInCountry(_countryCode),
            _expectCount
        );
    }

    /// @notice Check if the storage area complies with filplus rules.
    function isCompliantRuleGeolocationAsseretion(
        uint16[] memory _regions,
        uint16[] memory _countrys,
        uint32[][] memory _citys,
        bool _expectResult
    ) public {
        assertEq(
            filplus.isCompliantRuleGeolocation(_regions, _countrys, _citys),
            _expectResult
        );
    }

    /// @notice Check if the mappingFiles percentage in the dataset complies with filplus rules.
    function isCompliantRuleMaxProportionOfMappingFilesToDatasetAsseretion(
        uint64 _mappingFilesSize,
        uint64 _sourceSize,
        bool _expectResult
    ) public {
        assertEq(
            filplus.isCompliantRuleMaxProportionOfMappingFilesToDataset(
                _mappingFilesSize,
                _sourceSize
            ),
            _expectResult
        );
    }

    /// @notice Check if the total number of storage replicas complies with filplus rules.
    function isCompliantRuleTotalReplicasPerDatasetAsseretion(
        address[][] memory _dataPreparers,
        address[][] memory _storageProviders,
        uint16[] memory _regions,
        uint16[] memory _countrys,
        uint32[][] memory _citys,
        bool _expectResult
    ) public {
        assertEq(
            filplus.isCompliantRuleTotalReplicasPerDataset(
                _dataPreparers,
                _storageProviders,
                _regions,
                _countrys,
                _citys
            ),
            _expectResult
        );
    }

    /// @notice Check if the storage provider for each dataset complies with filplus rules `datasetRuleMinSPsPerDataset`.
    function isCompliantRuleMinSPsPerDatasetAsseretion(
        uint16 _requirementValue,
        uint16 _totalExists,
        uint16 _uniqueExists,
        bool _expectResult
    ) public {
        assertEq(
            filplus.isCompliantRuleMinSPsPerDataset(
                _requirementValue,
                _totalExists,
                _uniqueExists
            ),
            _expectResult
        );
    }

    /// @notice Check if the storage provider for each dataset complies with filplus rules `datasetRuleMaxReplicasPerSP`.
    function isCompliantRuleMaxReplicasPerSPAsseretion(
        uint16 _value,
        bool _expectResult
    ) public {
        assertEq(
            filplus.isCompliantRuleMaxReplicasPerSP(_value),
            _expectResult
        );
    }
}
