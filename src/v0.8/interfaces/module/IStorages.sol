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

import {IDatasets} from "src/v0.8/interfaces/module/IDatasets.sol";
import {IMatchings} from "src/v0.8/interfaces/module/IMatchings.sol";
import {IMatchingsTarget} from "src/v0.8/interfaces/module/IMatchingsTarget.sol";
import {IMatchingsBids} from "src/v0.8/interfaces/module/IMatchingsBids.sol";
import {IStorageStatistics} from "src/v0.8/interfaces/core/statistics/IStorageStatistics.sol";
import {ICarstore} from "src/v0.8/interfaces/core/ICarstore.sol";

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

    /// @notice get total stored size
    /// @param _matchingId The ID of the matching.
    /// @return The total size of the matching's stored cars.
    function getTotalStoredSize(
        uint64 _matchingId
    ) external view returns (uint64);

    ///@notice get car size
    /// @param _matchingId The ID of the matching.
    /// @param _id The content identifier of the matched data.
    /// @return The size of the matching's stored cars.
    function getStoredCarSize(
        uint64 _matchingId,
        uint64 _id
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

    ///@notice get carstore instance
    function carstore() external view returns (ICarstore);

    ///@notice get datasets instance
    function datasets() external view returns (IDatasets);

    ///@notice get matchings instance
    function matchings() external view returns (IMatchings);

    ///@notice get matchingsTarget instance
    function matchingsTarget() external view returns (IMatchingsTarget);

    ///@notice get matchingsBids instance
    function matchingsBids() external view returns (IMatchingsBids);
}
