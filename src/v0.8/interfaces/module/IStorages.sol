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

/// @title Interface for Matchedstores contract
interface IStorages {
    /// @dev Submits a Filecoin deal Id for a matchedstore after successful matching.
    /// @param _matchingId The ID of the matching.
    /// @param _cid The content identifier of the matched data.
    /// @param _filecoinDealId The ID of the successful Filecoin storage deal.
    function submitStorageDealId(
        uint64 _matchingId,
        bytes32 _cid,
        uint64 _filecoinDealId
    ) external;

    /// @dev Submits multiple Filecoin deal Ids for a matchedstore after successful matching.
    /// @param _matchingId The ID of the matching.
    /// @param _cids An array of content identifiers of the matched data.
    /// @param _filecoinDealIds An array of IDs of successful Filecoin storage deals.
    function submitStorageDealIds(
        uint64 _matchingId,
        bytes32[] memory _cids,
        uint64[] memory _filecoinDealIds
    ) external;

    /// @dev Gets the list of done cars in the matchedstore.
    /// @param _matchingId The ID of the matching.
    /// @return An array of content identifiers of the done cars.
    function getStoredCars(
        uint64 _matchingId
    ) external view returns (bytes32[] memory);

    /// @dev Gets the count of done cars in the matchedstore.
    /// @param _matchingId The ID of the matching.
    /// @return The count of done cars in the matchedstore.
    function getStoredCarCount(
        uint64 _matchingId
    ) external view returns (uint64);

    function getTotalStoredSize(
        uint64 _matchingId
    ) external view returns (uint64);

    /// @dev Checks if all cars are done in the matchedstore.
    /// @param _matchingId The ID of the matching.
    /// @return True if all cars are done in the matchedstore, otherwise false.
    function isAllStoredDone(uint64 _matchingId) external view returns (bool);
}
