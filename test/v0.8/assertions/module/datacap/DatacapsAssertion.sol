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
import {DatasetType} from "src/v0.8/types/DatasetType.sol";
import {MatchingType} from "src/v0.8/types/MatchingType.sol";
import {IDatacaps} from "src/v0.8/interfaces/module/IDatacaps.sol";
import {IDatacapsAssertion} from "test/v0.8/interfaces/assertions/module/IDatacapsAssertion.sol";

/// @notice This contract defines assertion functions for testing an IDatacaps contract.
/// @dev NOTE: All methods that do not change the state must be tested by methods that will change the state to ensure test coverage.
contract DatacapsAssertion is DSTest, Test, IDatacapsAssertion {
    IDatacaps public datacaps;

    /// @notice Constructor that sets the address of the IDatacaps contract.
    /// @param _datacaps The address of the IDatacaps contract.
    constructor(IDatacaps _datacaps) {
        datacaps = _datacaps;
    }

    /// @notice Assertion function for requesting datacap allocation.
    /// @param caller The address of the caller.
    /// @param _matchingId The matching ID for which datacap allocation is requested.
    function requestAllocateDatacapAssertion(
        address caller,
        uint64 _matchingId
    ) external {
        // Before the action, capture the initial state.
        uint64 oldAvailableDatacap = datacaps.getAvailableDatacap(_matchingId);
        isNextDatacapAllocationValidAssertion(_matchingId, true);
        uint64 oldAllocatedDatacap = datacaps.getAllocatedDatacap(_matchingId);
        uint64 oldRemainingUnallocatedDatacap = datacaps
            .getRemainingUnallocatedDatacap(_matchingId);
        getTotalDatacapAllocationRequirementAssertion(
            _matchingId,
            oldAllocatedDatacap + oldRemainingUnallocatedDatacap
        );

        // Perform the action.
        vm.prank(caller);
        uint64 addDatacap = datacaps.requestAllocateDatacap(_matchingId);

        // After the action, assert the updated state.
        getAvailableDatacapAssertion(
            _matchingId,
            oldAvailableDatacap + addDatacap
        );
        getAllocatedDatacapAssertion(
            _matchingId,
            oldAllocatedDatacap + addDatacap
        );
        getRemainingUnallocatedDatacapAssertion(
            _matchingId,
            oldRemainingUnallocatedDatacap - addDatacap
        );
        isNextDatacapAllocationValidAssertion(_matchingId, false);
    }

    /// @notice Assertion function for getting the available datacap for a matching ID.
    /// @param _matchingId The matching ID for which to get the available datacap.
    /// @param _expectSize The expected available datacap size.
    function getAvailableDatacapAssertion(
        uint64 _matchingId,
        uint64 _expectSize
    ) public {
        assertEq(datacaps.getAvailableDatacap(_matchingId), _expectSize);
    }

    /// @notice Assertion function for getting the allocated datacap for a matching ID.
    /// @param _matchingId The matching ID for which to get the allocated datacap.
    /// @param _expectSize The expected allocated datacap size.
    function getAllocatedDatacapAssertion(
        uint64 _matchingId,
        uint64 _expectSize
    ) public {
        assertEq(datacaps.getAllocatedDatacap(_matchingId), _expectSize);
    }

    /// @notice Assertion function for getting the total datacap allocation requirement for a matching ID.
    /// @param _matchingId The matching ID for which to get the total datacap allocation requirement.
    /// @param _expectSize The expected total datacap allocation requirement size.
    function getTotalDatacapAllocationRequirementAssertion(
        uint64 _matchingId,
        uint64 _expectSize
    ) public {
        assertEq(
            datacaps.getTotalDatacapAllocationRequirement(_matchingId),
            _expectSize
        );
    }

    /// @notice Assertion function for getting the remaining unallocated datacap for a matching ID.
    /// @param _matchingId The matching ID for which to get the remaining unallocated datacap.
    /// @param _expectSize The expected remaining unallocated datacap size.
    function getRemainingUnallocatedDatacapAssertion(
        uint64 _matchingId,
        uint64 _expectSize
    ) public {
        assertEq(
            datacaps.getRemainingUnallocatedDatacap(_matchingId),
            _expectSize
        );
    }

    /// @notice Assertion function for checking if the next datacap allocation is valid for a matching ID.
    /// @param _matchingId The matching ID for which to check datacap allocation validity.
    /// @param _expectOK The expected validity status (true or false).
    function isNextDatacapAllocationValidAssertion(
        uint64 _matchingId,
        bool _expectOK
    ) public {
        if (!_expectOK) {
            vm.expectRevert();
        }
        assertEq(datacaps.isNextDatacapAllocationValid(_matchingId), _expectOK);
    }
}
