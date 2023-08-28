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

/// @title IStoragesAssertion
/// @dev This interface defines assertion methods for testing storage-related functionality.
/// All methods that do not change the state must be tested by methods that will change the state to ensure test coverage.
interface IStoragesAssertion {
    /// @notice Asserts the submission of a storage deal ID for a car in a matching.
    /// @param caller The caller's address.
    /// @param _matchingId The ID of the matching associated with the storage deal.
    /// @param _cid The car CID for which the storage deal ID is submitted.
    /// @param _filecoinDealId The Filecoin deal ID associated with the storage of the car.
    function submitStorageDealIdAssertion(
        address caller,
        uint64 _matchingId,
        bytes32 _cid,
        uint64 _filecoinDealId
    ) external;

    /// @notice Asserts the submission of multiple storage deal IDs for cars in a matching.
    /// @param caller The caller's address.
    /// @param _matchingId The ID of the matching associated with the storage deals.
    /// @param _cids The array of car CIDs for which storage deal IDs are submitted.
    /// @param _filecoinDealIds The array of Filecoin deal IDs associated with the storage of the cars.
    function submitStorageDealIdsAssertion(
        address caller,
        uint64 _matchingId,
        bytes32[] memory _cids,
        uint64[] memory _filecoinDealIds
    ) external;

    /// @notice Asserts the retrieval of stored car CIDs in a matching.
    /// @param _matchingId The ID of the matching.
    /// @param _expectCars The expected array of stored car CIDs.
    function getStoredCarsAssertion(
        uint64 _matchingId,
        bytes32[] memory _expectCars
    ) external;

    /// @notice Asserts the retrieval of the count of stored cars in a matching.
    /// @param _matchingId The ID of the matching.
    /// @param _expectCount The expected count of stored cars.
    function getStoredCarCountAssertion(
        uint64 _matchingId,
        uint64 _expectCount
    ) external;

    /// @notice Asserts the retrieval of the total stored size in a matching.
    /// @param _matchingId The ID of the matching.
    /// @param _expectSize The expected total stored size.
    function getTotalStoredSizeAssertion(
        uint64 _matchingId,
        uint64 _expectSize
    ) external;

    /// @notice Asserts whether all storage deals for a matching are done.
    /// @param _matchingId The ID of the matching.
    /// @param _expectIsAllStoredDone The expected result indicating whether all storage deals are done for the matching.
    function isAllStoredDoneAssertion(
        uint64 _matchingId,
        bool _expectIsAllStoredDone
    ) external;
}
