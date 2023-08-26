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

import {DSTest} from "ds-test/test.sol";
import {Test} from "forge-std/Test.sol";
import {IFilplus} from "src/v0.8/interfaces/core/IFilplus.sol";
import {IFilplusAssertion} from "test/v0.8/interfaces/assertions/core/IFilplusAssertion.sol";

// assert carstore action
// NOTE: view asserton functions must all be tested by the functions that will change state
contract FilplusAssertion is DSTest, Test, IFilplusAssertion {
    IFilplus public filplus;
    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    constructor(IFilplus _filplus) {
        filplus = _filplus;
    }

    // get assertion
    function setCarRuleMaxCarReplicasAssertion(uint16 _newValue) external {
        filplus.setCarRuleMaxCarReplicas(_newValue);
        carRuleMaxCarReplicasAssertion(_newValue);
    }

    function setDatasetRuleMinRegionsPerDatasetAssertion(
        uint16 _newValue
    ) external {
        //action
        filplus.setDatasetRuleMinRegionsPerDataset(_newValue);
        //after action
        datasetRuleMinRegionsPerDatasetAssertion(_newValue);
    }

    function setDatasetRuleDefaultMaxReplicasPerCountryAssertion(
        uint16 _newValue
    ) external {
        filplus.setDatasetRuleDefaultMaxReplicasPerCountry(_newValue);
        datasetRuleDefaultMaxReplicasPerCountryAssertion(_newValue);
    }

    function setDatasetRuleMaxReplicasInCountryAssertion(
        bytes32 _countryCode,
        uint16 _newValue
    ) external {
        filplus.setDatasetRuleMaxReplicasInCountry(_countryCode, _newValue);
        getDatasetRuleMaxReplicasInCountryAssertion(_countryCode, _newValue);
    }

    function setDatasetRuleMaxReplicasPerCityAssertion(
        uint16 _newValue
    ) external {
        filplus.setDatasetRuleMaxReplicasPerCity(_newValue);
        datasetRuleMaxReplicasPerCityAssertion(_newValue);
    }

    function setDatasetRuleMinSPsPerDatasetAssertion(
        uint16 _newValue
    ) external {
        filplus.setDatasetRuleMinSPsPerDataset(_newValue);
        datasetRuleMinSPsPerDatasetAssertion(_newValue);
    }

    function setDatasetRuleMaxReplicasPerSPAssertion(
        uint16 _newValue
    ) external {
        filplus.setDatasetRuleMaxReplicasPerSP(_newValue);
        datasetRuleMaxReplicasPerSPAssertion(_newValue);
    }

    function setDatasetRuleMinTotalReplicasPerDatasetAssertion(
        uint16 _newValue
    ) external {
        filplus.setDatasetRuleMinTotalReplicasPerDataset(_newValue);
        datasetRuleMinTotalReplicasPerDatasetAssertion(_newValue);
    }

    function setDatasetRuleMaxTotalReplicasPerDatasetAssertion(
        uint16 _newValue
    ) external {
        filplus.setDatasetRuleMaxTotalReplicasPerDataset(_newValue);
        datasetRuleMaxTotalReplicasPerDatasetAssertion(_newValue);
    }

    function setDatacapRulesMaxAllocatedSizePerTimeAssertion(
        uint64 _newValue
    ) external {
        filplus.setDatacapRulesMaxAllocatedSizePerTime(_newValue);
        datacapRulesMaxAllocatedSizePerTimeAssertion(_newValue);
    }

    function setDatacapRulesMaxRemainingPercentageForNextAssertion(
        uint8 _newValue
    ) external {
        filplus.setDatacapRulesMaxRemainingPercentageForNext(_newValue);
        datacapRulesMaxRemainingPercentageForNextAssertion(_newValue);
    }

    function setMatchingRulesDataswapCommissionPercentageAssertion(
        uint8 _newValue
    ) external {
        filplus.setMatchingRulesDataswapCommissionPercentage(_newValue);
        matchingRulesDataswapCommissionPercentageAssertion(_newValue);
    }

    function setMatchingRulesCommissionTypeAssertion(uint8 _newType) external {
        filplus.setMatchingRulesCommissionType(_newType);
        getMatchingRulesCommissionTypeAssertion(_newType);
    }

    // get assertion
    function carRuleMaxCarReplicasAssertion(uint16 _expectCount) public {
        assertEq(filplus.carRuleMaxCarReplicas(), _expectCount);
    }

    function datasetRuleMinRegionsPerDatasetAssertion(
        uint16 _expectCount
    ) public {
        assertEq(filplus.datasetRuleMinRegionsPerDataset(), _expectCount);
    }

    function datasetRuleDefaultMaxReplicasPerCountryAssertion(
        uint16 _expectCount
    ) public {
        assertEq(
            filplus.datasetRuleDefaultMaxReplicasPerCountry(),
            _expectCount
        );
    }

    function datasetRuleMaxReplicasPerCityAssertion(
        uint16 _expectCount
    ) public {
        assertEq(filplus.datasetRuleMaxReplicasPerCity(), _expectCount);
    }

    function datasetRuleMinSPsPerDatasetAssertion(uint16 _expectCount) public {
        assertEq(filplus.datasetRuleMinSPsPerDataset(), _expectCount);
    }

    function datasetRuleMaxReplicasPerSPAssertion(uint16 _expectCount) public {
        assertEq(filplus.datasetRuleMaxReplicasPerSP(), _expectCount);
    }

    function datasetRuleMinTotalReplicasPerDatasetAssertion(
        uint16 _expectCount
    ) public {
        assertEq(filplus.datasetRuleMinTotalReplicasPerDataset(), _expectCount);
    }

    function datasetRuleMaxTotalReplicasPerDatasetAssertion(
        uint16 _expectCount
    ) public {
        assertEq(filplus.datasetRuleMaxTotalReplicasPerDataset(), _expectCount);
    }

    function datacapRulesMaxAllocatedSizePerTimeAssertion(
        uint64 _expectSize
    ) public {
        assertEq(filplus.datacapRulesMaxAllocatedSizePerTime(), _expectSize);
    }

    function datacapRulesMaxRemainingPercentageForNextAssertion(
        uint8 _expectPercentrage
    ) public {
        assertEq(
            filplus.datacapRulesMaxRemainingPercentageForNext(),
            _expectPercentrage
        );
    }

    function matchingRulesDataswapCommissionPercentageAssertion(
        uint8 _expectPercentrage
    ) public {
        assertEq(
            filplus.matchingRulesDataswapCommissionPercentage(),
            _expectPercentrage
        );
    }

    function getMatchingRulesCommissionTypeAssertion(
        uint8 _expectPercentrage
    ) public {
        assertEq(filplus.getMatchingRulesCommissionType(), _expectPercentrage);
    }

    function getDatasetRuleMaxReplicasInCountryAssertion(
        bytes32 _countryCode,
        uint16 _expectCount
    ) public {
        assertEq(
            filplus.getDatasetRuleMaxReplicasInCountry(_countryCode),
            _expectCount
        );
    }
}
