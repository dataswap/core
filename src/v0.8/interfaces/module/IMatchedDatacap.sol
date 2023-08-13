/// SPDX-License-Identifier: GPL-3.0-or-later
/// (c) 2023 DataSwap
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

/// @title IMatchedDatacap
/// @dev Interface for managing the allocation of datacap for matched data storage.
interface IMatchedDatacap {
    /// @dev Requests the allocation of matched datacap for a matching process.
    /// @param _matchingId The ID of the matching process.
    function requestAllocateMatchedDatacap(uint256 _matchingId) external;

    /// @dev Gets the allocated matched datacap for a matching process.
    /// @param _matchingId The ID of the matching process.
    /// @return The allocated datacap size.
    function getMatchedDatacapAllocated(
        uint256 _matchingId
    ) external view returns (uint256);

    /// @dev Gets the total datacap size needed to be allocated for a matching process.
    /// @param _matchingId The ID of the matching process.
    /// @return The total datacap size needed.
    function getMatchedDatacapTotalNeedAllocated(
        uint256 _matchingId
    ) external view returns (uint256);

    /// @dev Gets the remaining datacap size needed to be allocated for a matching process.
    /// @param _matchingId The ID of the matching process.
    /// @return The remaining datacap size needed.
    function getMatchedDatacapTotalRemaining(
        uint256 _matchingId
    ) external view returns (uint256);

    /// @dev Checks if the next datacap allocation is allowed for a matching process.
    /// @param _matchingId The ID of the matching process.
    /// @return True if next allocation is allowed, otherwise false.
    function isMatchedDatacapNextAllocationValid(
        uint256 _matchingId
    ) external view returns (bool);
}
