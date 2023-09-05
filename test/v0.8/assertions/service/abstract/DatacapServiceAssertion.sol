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
import {ServiceAssertionBase} from "test/v0.8/assertions/service/abstract/base/ServiceAssertionBase.sol";

/// @title DatacapServiceAssertion
abstract contract DatacapServiceAssertion is ServiceAssertionBase {
    /// @notice Assertion function for requesting datacap allocation.
    /// @param caller The address of the caller.
    /// @param _matchingId The matching ID for which datacap allocation is requested.
    function requestAllocateDatacapAssertion(
        address caller,
        uint64 _matchingId
    ) external {
        datacapsAssertion.requestAllocateDatacapAssertion(caller, _matchingId);
    }

    /// @notice Assertion function for getting the available datacap for a matching ID.
    /// @param _matchingId The matching ID for which to get the available datacap.
    /// @param _expectSize The expected available datacap size.
    function getAvailableDatacapAssertion(
        uint64 _matchingId,
        uint64 _expectSize
    ) public {
        datacapsAssertion.getAvailableDatacapAssertion(
            _matchingId,
            _expectSize
        );
    }

    /// @notice Assertion function for getting the allocated datacap for a matching ID.
    /// @param _matchingId The matching ID for which to get the allocated datacap.
    /// @param _expectSize The expected allocated datacap size.
    function getAllocatedDatacapAssertion(
        uint64 _matchingId,
        uint64 _expectSize
    ) public {
        datacapsAssertion.getAllocatedDatacapAssertion(
            _matchingId,
            _expectSize
        );
    }

    /// @notice Assertion function for getting the total datacap allocation requirement for a matching ID.
    /// @param _matchingId The matching ID for which to get the total datacap allocation requirement.
    /// @param _expectSize The expected total datacap allocation requirement size.
    function getTotalDatacapAllocationRequirementAssertion(
        uint64 _matchingId,
        uint64 _expectSize
    ) public {
        datacapsAssertion.getTotalDatacapAllocationRequirementAssertion(
            _matchingId,
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
        datacapsAssertion.getRemainingUnallocatedDatacapAssertion(
            _matchingId,
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
        datacapsAssertion.isNextDatacapAllocationValidAssertion(
            _matchingId,
            _expectOK
        );
    }
}
