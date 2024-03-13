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
import {IStorageStatisticsBaseAssertion} from "test/v0.8/interfaces/assertions/core/IStorageStatisticsBaseAssertion.sol";

/// @title IStoragesAssertion
/// @dev This interface defines assertion methods for testing storage-related functionality.
/// All methods that do not change the state must be tested by methods that will change the state to ensure test coverage.
interface IStoragesAssertion is IStorageStatisticsBaseAssertion {
    /// @notice Asserts the submission of a storage claim ID for a car in a matching.
    /// @param caller The caller's address.
    /// @param _matchingId The ID of the matching associated with the storage deal.
    /// @param _provider The storage provider for which to submit the storage deal.
    /// @param _cid The car CID for which the storage claim ID is submitted.
    /// @param _claimId The Filecoin claim ID associated with the storage of the car.
    function submitStorageClaimIdAssertion(
        address caller,
        uint64 _matchingId,
        uint64 _provider,
        uint64 _cid,
        uint64 _claimId
    ) external;

    /// @notice Asserts the submission of multiple storage claim IDs for cars in a matching.
    /// @param caller The caller's address.
    /// @param _matchingId The ID of the matching associated with the storage deals.
    /// @param _provider The storage provider for which to submit the storage deal.
    /// @param _cids The array of car CIDs for which storage claim IDs are submitted.
    /// @param _claimIds The array of Filecoin claim IDs associated with the storage of the cars.
    function submitStorageClaimIdsAssertion(
        address caller,
        uint64 _matchingId,
        uint64 _provider,
        uint64[] memory _cids,
        uint64[] memory _claimIds
    ) external;

    /// @dev Completes the storage assertion process initiated by a specific caller for a given matching ID with multiple content identifiers.
    /// @param _matchingId The ID of the matching process for which the storage assertion is completed.
    /// @param _ids An array of content identifiers associated with the storage assertion process.
    function completeStorageAssersion(
        uint64 _matchingId,
        uint64[] memory _ids
    ) external;

    /// @notice Asserts the retrieval of stored car CIDs in a matching.
    /// @param _matchingId The ID of the matching.
    /// @param _expectCars The expected array of stored car CIDs.
    function getStoredCarsAssertion(
        uint64 _matchingId,
        uint64[] memory _expectCars
    ) external;

    /// @notice Asserts the retrieval of the count of stored cars in a matching.
    /// @param _matchingId The ID of the matching.
    /// @param _expectCount The expected count of stored cars.
    function getStoredCarCountAssertion(
        uint64 _matchingId,
        uint64 _expectCount
    ) external;

    /// @notice Asserts whether all storage deals for a matching are done.
    /// @param _matchingId The ID of the matching.
    /// @param _expectIsAllStoredDone The expected result indicating whether all storage deals are done for the matching.
    function isAllStoredDoneAssertion(
        uint64 _matchingId,
        bool _expectIsAllStoredDone
    ) external;

    /// @notice Asserts the request to allocate datacap.
    /// @param caller The caller's address.
    /// @param _matchingId The matching ID for which datacap is requested.
    function requestAllocateDatacapAssertion(
        address caller,
        uint64 _matchingId
    ) external;

    /// @notice Asserts whether the next datacap allocation is valid.
    /// @param _matchingId The matching ID for which the validity of the next datacap allocation is checked.
    /// @param _expectOK The expected result (true if the allocation is valid, false otherwise).
    function isNextDatacapAllocationValidAssertion(
        uint64 _matchingId,
        bool _expectOK
    ) external;
}
