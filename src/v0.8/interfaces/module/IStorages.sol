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

import {IMatchings} from "src/v0.8/interfaces/module/IMatchings.sol";

/// @title Interface for Matchedstores contract
interface IStorages {
    /// @dev Submits a Filecoin claim Id for a matchedstore after successful matching.
    /// @param _matchingId The ID of the matching.
    /// @param _provider A provider of storage provider of matching.
    /// @param _cid The content identifier of the matched data.
    /// @param _claimId The ID of the successful Filecoin storage deal.
    function submitStorageClaimId(
        uint64 _matchingId,
        uint64 _provider,
        bytes32 _cid,
        uint64 _claimId
    ) external;

    /// @dev Submits multiple Filecoin claim Ids for a matchedstore after successful matching.
    /// @param _matchingId The ID of the matching.
    /// @param _provider A provider of storage provider of matching.
    /// @param _cids An array of content identifiers of the matched data.
    /// @param _claimIds An array of IDs of successful Filecoin storage deals.
    function submitStorageClaimIds(
        uint64 _matchingId,
        uint64 _provider,
        bytes32[] memory _cids,
        uint64[] memory _claimIds
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

    /// @notice get total stored size
    /// @param _matchingId The ID of the matching.
    /// @return The total size of the matching's stored cars.
    function getTotalStoredSize(
        uint64 _matchingId
    ) external view returns (uint64);

    ///@notice get car size
    /// @param _matchingId The ID of the matching.
    /// @param _cid The content identifier of the matched data.
    /// @return The size of the matching's stored cars.
    function getStoredCarSize(
        uint64 _matchingId,
        bytes32 _cid
    ) external view returns (uint64);

    /// @dev Checks if all cars are done in the matchedstore.
    /// @param _matchingId The ID of the matching.
    /// @return True if all cars are done in the matchedstore, otherwise false.
    function isAllStoredDone(uint64 _matchingId) external view returns (bool);

    ///@notice get matchings instance
    function matchings() external view returns (IMatchings);
}
