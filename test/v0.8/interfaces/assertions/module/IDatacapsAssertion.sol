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

/// @title IDatacapsAssertion
/// @dev This interface defines assertion methods for testing datacap-related functionality.
/// All methods that do not change the state must be tested by methods that will change the state to ensure test coverage.
interface IDatacapsAssertion {
    /// @notice Asserts the request to allocate datacap.
    /// @param caller The caller's address.
    /// @param _matchingId The matching ID for which datacap is requested.
    function requestAllocateDatacapAssertion(
        address caller,
        uint64 _matchingId
    ) external;

    /// @notice Asserts the retrieval of available datacap.
    /// @param _matchingId The matching ID for which available datacap is retrieved.
    /// @param _expectSize The expected available datacap size.
    function getAvailableDatacapAssertion(
        uint64 _matchingId,
        uint64 _expectSize
    ) external;

    /// @notice Asserts the retrieval of allocated datacap.
    /// @param _matchingId The matching ID for which allocated datacap is retrieved.
    /// @param _expectSize The expected allocated datacap size.
    function getAllocatedDatacapAssertion(
        uint64 _matchingId,
        uint64 _expectSize
    ) external;

    /// @notice Asserts the retrieval of the total datacap allocation requirement.
    /// @param _matchingId The matching ID for which the total allocation requirement is retrieved.
    /// @param _expectSize The expected total allocation requirement size.
    function getTotalDatacapAllocationRequirementAssertion(
        uint64 _matchingId,
        uint64 _expectSize
    ) external;

    /// @notice Asserts the retrieval of the remaining unallocated datacap.
    /// @param _matchingId The matching ID for which the remaining unallocated datacap is retrieved.
    /// @param _expectSize The expected remaining unallocated datacap size.
    function getRemainingUnallocatedDatacapAssertion(
        uint64 _matchingId,
        uint64 _expectSize
    ) external;

    /// @notice Asserts whether the next datacap allocation is valid.
    /// @param _matchingId The matching ID for which the validity of the next datacap allocation is checked.
    /// @param _expectOK The expected result (true if the allocation is valid, false otherwise).
    function isNextDatacapAllocationValidAssertion(
        uint64 _matchingId,
        bool _expectOK
    ) external;
}
