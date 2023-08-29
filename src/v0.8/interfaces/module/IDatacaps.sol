/// SPDX-License-Identifier: GPL-3.0-or-later
/// (c) 2023 Dataswap
///
/// Licensed under the GNU General Public License, Version 3.0 or later (the "License");
/// you may not use this file except in compliance with the License.
/// You may obtain a copy of the License at
///     https://www.gnu.org/licenses/gpl-3.0.en.html
///
/// Unless required by applicable law or agreed to in writing, software
/// distributed under the License is distributed on an "AS IS" BASIS,
/// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
/// See the License for the specific language governing permissions and
/// limitations under the License.

pragma solidity ^0.8.21;
import {IStorages} from "src/v0.8/interfaces/module/IStorages.sol";

/// @title IDatacap
/// @dev Interface for managing the allocation of datacap for matched data storage.
interface IDatacaps {
    /// @dev Requests the allocation of matched datacap for a matching process.
    /// @param _matchingId The ID of the matching process.
    function requestAllocateDatacap(
        uint64 _matchingId
    ) external returns (uint64);

    /// @dev Gets the allocated matched datacap for a storage.
    /// @param _matchingId The ID of the matching process.
    /// @return The allocated datacap size.
    function getAvailableDatacap(
        uint64 _matchingId
    ) external view returns (uint64);

    /// @dev Gets the allocated matched datacap for a matching process.
    /// @param _matchingId The ID of the matching process.
    /// @return The allocated datacap size.
    function getAllocatedDatacap(
        uint64 _matchingId
    ) external view returns (uint64);

    /// @dev Gets the total datacap size needed to be allocated for a matching process.
    /// @param _matchingId The ID of the matching process.
    /// @return The total datacap size needed.
    function getTotalDatacapAllocationRequirement(
        uint64 _matchingId
    ) external view returns (uint64);

    /// @dev Gets the remaining datacap size needed to be allocated for a matching process.
    /// @param _matchingId The ID of the matching process.
    /// @return The remaining datacap size needed.
    function getRemainingUnallocatedDatacap(
        uint64 _matchingId
    ) external view returns (uint64);

    /// @dev Checks if the next datacap allocation is allowed for a matching process.
    /// @param _matchingId The ID of the matching process.
    /// @return True if next allocation is allowed, otherwise false.
    function isNextDatacapAllocationValid(
        uint64 _matchingId
    ) external view returns (bool);

    function storages() external view returns (IStorages);
}
