/*******************************************************************************
 *   (c) 2024 dataswap
 *
 *  Licensed under either the MIT License (the "MIT License") or the Apache License, Version 2.0
 *  (the "Apache License"). You may not use this file except in compliance with one of these
 *  licenses. You may obtain a copy of the MIT License at
 *
 *      https://opensource.org/licenses/MIT
 *
 *  Or the Apache License, Version 2.0 at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the MIT License or the Apache License for the specific language governing permissions and
 *  limitations under the respective licenses.
 ********************************************************************************/

// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.21;

import {IStatistics} from "src/v0.8/interfaces/core/statistics/IStatistics.sol";

/// @title IStorageStatistics Interface
/// @notice Interface for handling datacap statistics operations, extending the IStatistics interface
/// @notice This interface defines the datacap-statistic-related functions within the system.
/// @notice instance example,type: mapping(uint256 => StorageStatistics);
///                       explain: mapping(matchingId => StorageStatistics);
///                       explain: mapping(replicaIndex => StorageStatistics);
///                       explain: mapping(datasetId => StorageStatistics);
///                       explain: StorageStatistics overview ;
interface IStorageStatistics is IStatistics {
    /// @notice External function to register dataswap datacap with a specified size.
    /// @param size Size of the dataswap datacap to be registered.
    /// @dev Accessible only by the default admin role.
    function registDataswapDatacap(uint256 size) external;

    /// @notice Regist datacap information for a specific dataset and matching ID.
    /// @param datasetId Dataset ID for which to add datacap information.
    /// @param replicaIndex Replica index for which to add datacap information.
    /// @param matchingId Matching ID associated with the datacap information.
    /// @param size Size of the datacap to be added.
    function __registMatched(
        uint64 datasetId,
        uint64 replicaIndex,
        uint64 matchingId,
        uint256 size
    ) external;

    /// @notice Get an overview of the storage statistics.
    /// @return dataswapTotal Total datacap from the dataswap platform.
    /// @return total Total datacap.
    /// @return completed Completed storage.
    /// @return usedDatacap Used datacap.
    /// @return availableDatacap Available datacap.
    /// @return canceled Canceled datacap.
    /// @return unallocatedDatacap Un allocated datacap.
    function getStorageOverview()
        external
        view
        returns (
            uint256 dataswapTotal,
            uint256 total,
            uint256 completed,
            uint256 usedDatacap,
            uint256 availableDatacap,
            uint256 canceled,
            uint256 unallocatedDatacap
        );

    /// @notice Get an overview of dataset-specific storage statistics for a dataset.
    /// @param datasetId Dataset ID for which to retrieve the overview.
    /// @return total Total datacap.
    /// @return completed Completed storage.
    /// @return usedDatacap Used datacap.
    /// @return availableDatacap Available datacap.
    /// @return canceled Canceled datacap.
    /// @return unallocatedDatacap Un allocated datacap.
    function getDatasetStorageOverview(
        uint64 datasetId
    )
        external
        view
        returns (
            uint256 total,
            uint256 completed,
            uint256 usedDatacap,
            uint256 availableDatacap,
            uint256 canceled,
            uint256 unallocatedDatacap
        );

    /// @notice Get an overview of replica-specific storage statistics for a dataset replica.
    /// @param datasetId Dataset ID associated with the replica.
    /// @param replicaIndex Index of the replica for which to retrieve the overview.
    /// @return total Total datacap.
    /// @return completed Completed storage.
    /// @return usedDatacap Used datacap.
    /// @return availableDatacap Available datacap.
    /// @return canceled Canceled datacap.
    /// @return unallocatedDatacap Un allocated datacap.
    function getReplicaStorageOverview(
        uint64 datasetId,
        uint64 replicaIndex
    )
        external
        view
        returns (
            uint256 total,
            uint256 completed,
            uint256 usedDatacap,
            uint256 availableDatacap,
            uint256 canceled,
            uint256 unallocatedDatacap
        );

    /// @notice Get an overview of matching-specific storage statistics for a matching.
    /// @param matchingId Matching ID for which to retrieve the overview.
    /// @return total Total datacap.
    /// @return completed Completed storage.
    /// @return usedDatacap Used datacap.
    /// @return availableDatacap Available datacap.
    /// @return canceled Canceled datacap.
    /// @return unallocatedDatacap Un allocated datacap.
    /// @return storageProviders Array of storage providers associated with the storage.
    function getMatchingStorageOverview(
        uint64 matchingId
    )
        external
        view
        returns (
            uint256 total,
            uint256 completed,
            uint256 usedDatacap,
            uint256 availableDatacap,
            uint256 canceled,
            uint256 unallocatedDatacap,
            uint64[] memory storageProviders
        );
}
