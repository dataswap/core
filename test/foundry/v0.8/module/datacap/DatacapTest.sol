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
import {DatacapTestHelpers} from "./helpers/DatacapTestHelpers.sol";

// Contract definition for test functions
contract DatacapTest is Test, DatacapTestHelpers {
    function testRequestAllocateDatacap() external {
        setupForDatacapTest();
        uint64 matchingId = matchings.matchingsCount();

        // before allcation
        assertEq(
            matchings.getMatchingSize(matchingId),
            datacaps.getTotalDatacapAllocationRequirement(matchingId)
        );

        assertTrue(datacaps.isNextDatacapAllocationValid(matchingId));

        assertEq(
            matchings.getMatchingSize(matchingId),
            datacaps.getRemainingUnallocatedDatacap(matchingId)
        );

        assertEq(0, datacaps.getAvailableDatacap(matchingId));

        vm.startPrank(matchings.getMatchingInitiator(matchingId));
        datacaps.requestAllocateDatacap(matchingId);
        vm.stopPrank();

        //after allocate
        assertTrue(
            matchings.getMatchingSize(matchingId) <
                filplus.datacapRulesMaxAllocatedSizePerTime()
        );
        assertEq(
            matchings.getMatchingSize(matchingId),
            datacaps.getAllocatedDatacap(matchingId)
        );

        vm.expectRevert();
        datacaps.isNextDatacapAllocationValid(matchingId);

        assertEq(0, datacaps.getRemainingUnallocatedDatacap(matchingId));

        assertEq(
            matchings.getMatchingSize(matchingId),
            datacaps.getAvailableDatacap(matchingId)
        );

        //after storage
        vm.startPrank(matchings.getMatchingWinner(matchingId));
        submitStorageDealIds(matchingId, matchings.getMatchingCars(matchingId));
        vm.stopPrank();

        assertEq(0, datacaps.getAvailableDatacap(matchingId));
    }
}
