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

import {IRoles} from "src/v0.8/interfaces/core/IRoles.sol";
import {IStorageStatistics} from "src/v0.8/interfaces/core/statistics/IStorageStatistics.sol";

/// @title Interface for Matchedstores contract
interface IStorages is IStorageStatistics {
    /// @dev Submits multiple Filecoin claim Ids for a matchedstore after successful matching.
    /// @param _matchingId The ID of the matching.
    /// @param _provider A provider of storage provider of matching.
    /// @param _ids An array of content identifiers of the matched data.
    /// @param _claimIds An array of IDs of successful Filecoin storage deals.
    function submitStorageClaimIds(
        uint64 _matchingId,
        uint64 _provider,
        uint64[] memory _ids,
        uint64[] memory _claimIds
    ) external;

    /// @dev Gets the list of done cars in the matchedstore.
    /// @param _matchingId The ID of the matching.
    /// @return An array of content identifiers of the done cars.
    function getStoredCars(
        uint64 _matchingId
    ) external view returns (uint64[] memory);

    /// @dev Gets the count of done cars in the matchedstore.
    /// @param _matchingId The ID of the matching.
    /// @return The count of done cars in the matchedstore.
    function getStoredCarCount(
        uint64 _matchingId
    ) external view returns (uint64);

    /// @dev Get the collateral amount
    function getProviderLockPayment(
        uint64 _matchingId
    ) external view returns (uint256);

    /// @dev Get the client allow payment amount
    function getClientLockPayment(
        uint64 _matchingId
    ) external view returns (uint256);

    /// @dev Checks if all cars are done in the matchedstore.
    /// @param _matchingId The ID of the matching.
    /// @return True if all cars are done in the matchedstore, otherwise false.
    function isAllStoredDone(uint64 _matchingId) external view returns (bool);

    /// @dev Checks if store expiration in the matchedstore.
    function isStorageExpiration(
        uint64 _matchingId
    ) external view returns (bool);

    /// @notice Add collateral funds for allocating datacap chunk
    /// @param _matchingId The ID of the matching
    function addDatacapChunkCollateral(uint64 _matchingId) external payable;

    /// @dev Requests the allocation of matched datacap for a matching process.
    /// @param _matchingId The ID of the matching process.
    function requestAllocateDatacap(
        uint64 _matchingId
    ) external returns (uint64);

    /// @notice Get the updated collateral funds for datacap chunk based on real-time business data
    /// @param _matchingId The ID of the matching
    /// @return The updated collateral funds required
    function getDatacapChunkCollateralFunds(
        uint64 _matchingId
    ) external view returns (uint256);

    /// @notice Get the updated burn funds for datacap chunk based on real-time business data
    /// @param _matchingId The ID of the matching
    /// @return The updated burn funds required
    function getDatacapChunkBurnFunds(
        uint64 _matchingId
    ) external view returns (uint256);

    /// @notice Get collateral funds requirement for allocate chunk datacap
    function getCollateralRequirement() external returns (uint256);

    /// @dev Checks if the next datacap allocation is allowed for a matching process.
    /// @param _matchingId The ID of the matching process.
    /// @return True if next allocation is allowed, otherwise false.
    function isNextDatacapAllocationValid(
        uint64 _matchingId
    ) external view returns (bool);
}
