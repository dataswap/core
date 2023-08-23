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

// Import required external contracts and interfaces
import {Test} from "forge-std/Test.sol";
import {Filplus} from "src/v0.8/core/filplus/Filplus.sol";

// Import various shared modules, modifiers, events, and error definitions
import {FilplusEvents} from "src/v0.8/shared/events/FilplusEvents.sol";

// Import necessary custom types
import {FilplusType} from "src/v0.8/types/FilplusType.sol";

// Contract definition for test helper functions
contract FilplusTest is Test {
    Filplus public filplus;
    address payable public governanceContractAddresss;

    // Setting up the test environment
    function setUp() public {
        filplus = new Filplus(governanceContractAddresss);
    }

    // Test function for setting the maximum car replicas rule
    function testSetCarRuleMaxCarReplicas(uint16 _newValue) external {
        vm.expectRevert(bytes("Only allowed address can call"));
        filplus.setCarRuleMaxCarReplicas(_newValue);

        vm.prank(governanceContractAddresss);
        vm.expectEmit(true, false, false, true);
        emit FilplusEvents.SetCarRuleMaxCarReplicas(_newValue);
        filplus.setCarRuleMaxCarReplicas(_newValue);
        assertEq(_newValue, filplus.carRuleMaxCarReplicas());
    }

    // Test function for setting the minimum regions per dataset rule
    function testSetDatasetRuleMinRegionsPerDataset(uint16 _newValue) external {
        vm.expectRevert(bytes("Only allowed address can call"));
        filplus.setDatasetRuleMinRegionsPerDataset(_newValue);

        vm.prank(governanceContractAddresss);
        vm.expectEmit(true, false, false, true);
        emit FilplusEvents.SetDatasetRuleMinRegionsPerDataset(_newValue);
        filplus.setDatasetRuleMinRegionsPerDataset(_newValue);
        assertEq(_newValue, filplus.datasetRuleMinRegionsPerDataset());
    }

    // Test function for setting the default maximum replicas per country rule
    function testSetDatasetRuleDefaultMaxReplicasPerCountry(
        uint16 _newValue
    ) external {
        vm.expectRevert(bytes("Only allowed address can call"));
        filplus.setDatasetRuleDefaultMaxReplicasPerCountry(_newValue);

        vm.prank(governanceContractAddresss);
        vm.expectEmit(true, false, false, true);
        emit FilplusEvents.SetDatasetRuleDefaultMaxReplicasPerCountry(
            _newValue
        );
        filplus.setDatasetRuleDefaultMaxReplicasPerCountry(_newValue);
        assertEq(_newValue, filplus.datasetRuleDefaultMaxReplicasPerCountry());
    }

    // Test function for setting the maximum replicas per country rule
    function testSetDatasetRuleMaxReplicasInCountry(
        bytes32 _countryCode,
        uint16 _newValue
    ) external {
        vm.assume(_newValue != 0);
        vm.expectRevert(bytes("Only allowed address can call"));
        filplus.setDatasetRuleMaxReplicasInCountry(_countryCode, _newValue);
        vm.prank(governanceContractAddresss);
        vm.expectEmit(true, true, false, true);
        emit FilplusEvents.SetDatasetRuleMaxReplicasInCountry(
            _countryCode,
            _newValue
        );
        filplus.setDatasetRuleMaxReplicasInCountry(_countryCode, _newValue);
        assertEq(
            _newValue,
            filplus.getDatasetRuleMaxReplicasInCountry(_countryCode)
        );
    }

    // Test function for setting the maximum replicas per city rule
    function testSetDatasetRuleMaxReplicasPerCity(uint16 _newValue) external {
        vm.expectRevert(bytes("Only allowed address can call"));
        filplus.setDatasetRuleMaxReplicasPerCity(_newValue);

        vm.prank(governanceContractAddresss);
        vm.expectEmit(true, false, false, true);
        emit FilplusEvents.SetDatasetRuleMaxReplicasPerCity(_newValue);
        filplus.setDatasetRuleMaxReplicasPerCity(_newValue);
        assertEq(_newValue, filplus.datasetRuleMaxReplicasPerCity());
    }

    // Test function for setting the minimum storage providers per dataset rule
    function testSetDatasetRuleMinSPsPerDataset(uint16 _newValue) external {
        vm.expectRevert(bytes("Only allowed address can call"));
        filplus.setDatasetRuleMinSPsPerDataset(_newValue);

        vm.prank(governanceContractAddresss);
        vm.expectEmit(true, false, false, true);
        emit FilplusEvents.SetDatasetRuleMinSPsPerDataset(_newValue);
        filplus.setDatasetRuleMinSPsPerDataset(_newValue);
        assertEq(_newValue, filplus.datasetRuleMinSPsPerDataset());
    }

    // Test function for setting the maximum replicas per storage provider rule
    function testSetDatasetRuleMaxReplicasPerSP(uint16 _newValue) external {
        vm.expectRevert(bytes("Only allowed address can call"));
        filplus.setDatasetRuleMaxReplicasPerSP(_newValue);

        vm.prank(governanceContractAddresss);
        vm.expectEmit(true, false, false, true);
        emit FilplusEvents.SetDatasetRuleMaxReplicasPerSP(_newValue);
        filplus.setDatasetRuleMaxReplicasPerSP(_newValue);
        assertEq(_newValue, filplus.datasetRuleMaxReplicasPerSP());
    }

    // Test function for setting the minimum total replicas per dataset rule
    function testSetDatasetRuleMinTotalReplicasPerDataset(
        uint16 _newValue
    ) external {
        vm.expectRevert(bytes("Only allowed address can call"));
        filplus.setDatasetRuleMinTotalReplicasPerDataset(_newValue);

        vm.prank(governanceContractAddresss);
        vm.expectEmit(true, false, false, true);
        emit FilplusEvents.SetDatasetRuleMinTotalReplicasPerDataset(_newValue);
        filplus.setDatasetRuleMinTotalReplicasPerDataset(_newValue);
        assertEq(_newValue, filplus.datasetRuleMinTotalReplicasPerDataset());
    }

    // Test function for setting the maximum total replicas per dataset rule
    function testSetDatasetRuleMaxTotalReplicasPerDataset(
        uint16 _newValue
    ) external {
        vm.expectRevert(bytes("Only allowed address can call"));
        filplus.setDatasetRuleMaxTotalReplicasPerDataset(_newValue);

        vm.prank(governanceContractAddresss);
        vm.expectEmit(true, false, false, true);
        emit FilplusEvents.SetDatasetRuleMaxTotalReplicasPerDataset(_newValue);
        filplus.setDatasetRuleMaxTotalReplicasPerDataset(_newValue);
        assertEq(_newValue, filplus.datasetRuleMaxTotalReplicasPerDataset());
    }

    // Test function for setting the maximum allocated datacap size per time rule
    function testSetDatacapRulesMaxAllocatedSizePerTime(
        uint64 _newValue
    ) external {
        vm.expectRevert(bytes("Only allowed address can call"));
        filplus.setDatacapRulesMaxAllocatedSizePerTime(_newValue);

        vm.prank(governanceContractAddresss);
        vm.expectEmit(true, false, false, true);
        emit FilplusEvents.SetDatacapRulesMaxAllocatedSizePerTime(_newValue);
        filplus.setDatacapRulesMaxAllocatedSizePerTime(_newValue);
        assertEq(_newValue, filplus.datacapRulesMaxAllocatedSizePerTime());
    }

    // Test function for setting the maximum remaining percentage for next allocation rule
    function testSetDatacapRulesMaxRemainingPercentageForNext(
        uint8 _newValue
    ) external {
        vm.expectRevert(bytes("Only allowed address can call"));
        filplus.setDatacapRulesMaxRemainingPercentageForNext(_newValue);

        vm.prank(governanceContractAddresss);
        vm.expectEmit(true, false, false, true);
        emit FilplusEvents.SetDatacapRulesMaxRemainingPercentageForNext(
            _newValue
        );
        filplus.setDatacapRulesMaxRemainingPercentageForNext(_newValue);
        assertEq(
            _newValue,
            filplus.datacapRulesMaxRemainingPercentageForNext()
        );
    }

    // Test function for setting the dataswap commission percentage rule
    function testSetMatchingRulesDataswapCommissionPercentage(
        uint8 _newValue
    ) external {
        vm.expectRevert(bytes("Only allowed address can call"));
        filplus.setMatchingRulesDataswapCommissionPercentage(_newValue);

        vm.prank(governanceContractAddresss);
        vm.expectEmit(true, false, false, true);
        emit FilplusEvents.SetMatchingRulesDataswapCommissionPercentage(
            _newValue
        );
        filplus.setMatchingRulesDataswapCommissionPercentage(_newValue);
        assertEq(
            _newValue,
            filplus.matchingRulesDataswapCommissionPercentage()
        );
    }

    // Test function for setting the matching rules commission type
    function testSetMatchingRulesCommissionType(uint8 _newType) external {
        vm.assume(_newType < uint8(FilplusType.MatchingRuleCommissionType.Max));
        vm.expectRevert(bytes("Only allowed address can call"));
        filplus.setMatchingRulesCommissionType(_newType);

        vm.prank(governanceContractAddresss);
        vm.expectEmit(true, false, false, true);
        emit FilplusEvents.SetMatchingRulesCommissionType(
            FilplusType.MatchingRuleCommissionType(_newType)
        );
        filplus.setMatchingRulesCommissionType(_newType);
        assertEq(_newType, filplus.getMatchingRulesCommissionType());
    }
}
