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
import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {IStorageStatistics} from "src/v0.8/interfaces/core/statistics/IStorageStatistics.sol";
import {StatisticsType} from "src/v0.8/types/StatisticsType.sol";
import {StorageStatisticsLIB} from "src/v0.8/core/statistics/library/StorageStatisticsLIB.sol";
import {StorageProvidersStatisticsLIB} from "src/v0.8/core/statistics/library/StorageProvidersStatisticsLIB.sol";
import {StatisticsBase} from "src/v0.8/core/statistics/StatisticsBase.sol";
import {IRoles} from "src/v0.8/interfaces/core/IRoles.sol";
import {RolesModifiers} from "src/v0.8/shared/modifiers/RolesModifiers.sol";
import {RolesType} from "src/v0.8/types/RolesType.sol";

contract StorageStatisticsBase is
    Initializable,
    StatisticsBase,
    IStorageStatistics,
    RolesModifiers
{
    using StorageStatisticsLIB for StatisticsType.StorageStatistics;
    using StorageProvidersStatisticsLIB for StatisticsType.StorageProvidersStatistics;

    mapping(uint64 => StatisticsType.StorageProvidersStatistics)
        internal matchingsStorageProvidersStatistics;

    mapping(uint64 => StatisticsType.StorageStatistics)
        internal matchingsStorageStatistics;

    mapping(bytes32 => StatisticsType.StorageStatistics)
        internal replicasStorageStatistics;

    mapping(uint64 => StatisticsType.StorageStatistics)
        internal datasetsStorageStatistics;

    StatisticsType.StorageStatistics internal storageOverview;

    uint256 internal dataswapTotalDatacap;

    IRoles public roles;

    /// @dev This empty reserved space is put in place to allow future versions to add new
    uint256[32] private __gap;

    /// @notice storageStatisticsBaseInitialize function to initialize the contract and grant the default admin role to the deployer.
    function storageStatisticsBaseInitialize(
        address _roles
    ) public virtual onlyInitializing {
        roles = IRoles(_roles);
    }

    /// @notice External function to register dataswap datacap with a specified size.
    /// @param size Size of the dataswap datacap to be registered.
    /// @dev Accessible only by the default admin role.
    function registDataswapDatacap(
        uint256 size
    ) external onlyRole(roles, RolesType.DEFAULT_ADMIN_ROLE) {
        dataswapTotalDatacap += size;
    }

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
    ) external onlyRole(roles, RolesType.DATASWAP_CONTRACT) {
        (uint256 total, , , , , ) = storageOverview.getOverview();
        require(
            (total + size) < dataswapTotalDatacap,
            "Datacap of Dataswap is insufficient"
        );
        _addCountTotal(1);
        _addSizeTotal(size);

        StatisticsType.StorageStatistics
            storage matchingStorageStatistics = matchingsStorageStatistics[
                matchingId
            ];

        matchingStorageStatistics.total = size;

        bytes32 key = _getReplicaKey(datasetId, replicaIndex);
        StatisticsType.StorageStatistics
            storage replicaStorageStatistics = replicasStorageStatistics[key];
        replicaStorageStatistics.total += size;

        StatisticsType.StorageStatistics
            storage datasetStorageStatistics = datasetsStorageStatistics[
                datasetId
            ];

        datasetStorageStatistics.total += size;

        storageOverview.total += size;
    }

    /// @notice Internal function to add storaged size for a specific replica, matching, and storage provider.
    /// @param datasetId Dataset ID associated with the replica.
    /// @param replicaIndex Index of the replica within the dataset.
    /// @param matchingId Matching ID of the replica.
    /// @param storageProvider ID of the storage provider.
    /// @param size Size to be added for the storage provider.
    function _addStoraged(
        uint64 datasetId,
        uint64 replicaIndex,
        uint64 matchingId,
        uint64 storageProvider,
        uint256 size
    ) internal {
        _addSizeSuccess(size);
        StatisticsType.StorageProvidersStatistics
            storage matchingStorageProvidersStatistics = matchingsStorageProvidersStatistics[
                matchingId
            ];

        matchingStorageProvidersStatistics.addStoraged(storageProvider, size);

        StatisticsType.StorageStatistics
            storage matchingStorageStatistics = matchingsStorageStatistics[
                matchingId
            ];

        matchingStorageStatistics.addStoraged(size);

        if (matchingStorageStatistics.isStorageCompleted()) {
            if (matchingStorageStatistics.isStorageSuccessful()) {
                _addCountSuccess(1);
            } else {
                _addCountFailed(1);
            }
        }

        bytes32 key = _getReplicaKey(datasetId, replicaIndex);
        StatisticsType.StorageStatistics
            storage replicaStorageStatistics = replicasStorageStatistics[key];

        replicaStorageStatistics.addStoraged(size);
        StatisticsType.StorageStatistics
            storage datasetStorageStatistics = datasetsStorageStatistics[
                datasetId
            ];

        datasetStorageStatistics.addStoraged(size);
        storageOverview.addStoraged(size);
    }

    /// @notice Add allocated datacap for a specific dataset and matching ID.
    /// @param datasetId Dataset ID for which to add allocated datacap.
    /// @param replicaIndex Replica index for which to add datacap information.
    /// @param matchingId Matching ID associated with the allocated datacap.
    /// @param size Size of the allocated datacap to be added.
    function _addAllocated(
        uint64 datasetId,
        uint64 replicaIndex,
        uint64 matchingId,
        uint256 size
    ) internal {
        StatisticsType.StorageStatistics
            storage matchingStorageStatistics = matchingsStorageStatistics[
                matchingId
            ];

        matchingStorageStatistics.addAllocated(size);
        bytes32 key = _getReplicaKey(datasetId, replicaIndex);
        StatisticsType.StorageStatistics
            storage replicaStorageStatistics = replicasStorageStatistics[key];

        replicaStorageStatistics.addAllocated(size);
        StatisticsType.StorageStatistics
            storage datasetStorageStatistics = datasetsStorageStatistics[
                datasetId
            ];

        datasetStorageStatistics.addAllocated(size);
        storageOverview.addAllocated(size);
    }

    /// @notice Add canceled datacap for a specific dataset and matching ID.
    /// @param datasetId Dataset ID for which to add canceled datacap.
    /// @param replicaIndex Replica index for which to add datacap information.
    /// @param matchingId Matching ID associated with the canceled datacap.
    /// @param size Size of the canceled datacap to be added.
    function _addCanceled(
        uint64 datasetId,
        uint64 replicaIndex,
        uint64 matchingId,
        uint256 size
    ) internal {
        _addSizeFailed(size);
        StatisticsType.StorageStatistics
            storage matchingStorageStatistics = matchingsStorageStatistics[
                matchingId
            ];

        matchingStorageStatistics.addCanceled(size);

        if (matchingStorageStatistics.isStorageCompleted()) {
            if (matchingStorageStatistics.isStorageSuccessful()) {
                _addCountSuccess(1);
            } else {
                _addCountFailed(1);
            }
        }

        bytes32 key = _getReplicaKey(datasetId, replicaIndex);
        StatisticsType.StorageStatistics
            storage replicaStorageStatistics = replicasStorageStatistics[key];

        replicaStorageStatistics.addCanceled(size);
        StatisticsType.StorageStatistics
            storage datasetStorageStatistics = datasetsStorageStatistics[
                datasetId
            ];

        datasetStorageStatistics.addCanceled(size);
        storageOverview.addCanceled(size);
    }

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
        )
    {
        (
            total,
            completed,
            usedDatacap,
            availableDatacap,
            canceled,
            unallocatedDatacap
        ) = storageOverview.getOverview();
        return (
            dataswapTotalDatacap,
            total,
            completed,
            usedDatacap,
            availableDatacap,
            canceled,
            unallocatedDatacap
        );
    }

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
        )
    {
        return datasetsStorageStatistics[datasetId].getOverview();
    }

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
        )
    {
        bytes32 key = _getReplicaKey(datasetId, replicaIndex);
        return replicasStorageStatistics[key].getOverview();
    }

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
        public
        view
        returns (
            uint256 total,
            uint256 completed,
            uint256 usedDatacap,
            uint256 availableDatacap,
            uint256 canceled,
            uint256 unallocatedDatacap,
            uint64[] memory storageProviders
        )
    {
        (
            total,
            completed,
            usedDatacap,
            availableDatacap,
            canceled,
            unallocatedDatacap
        ) = datasetsStorageStatistics[matchingId].getOverview();

        storageProviders = matchingsStorageProvidersStatistics[matchingId]
            .getOverview();

        return (
            total,
            completed,
            usedDatacap,
            availableDatacap,
            canceled,
            unallocatedDatacap,
            storageProviders
        );
    }

    /// @notice Internal function to get a unique replica key based on dataset ID and replica index.
    /// @param datasetId Dataset ID associated with the replica.
    /// @param replicaIndex Index of the replica within the dataset.
    /// @return replicaKey Unique key for identifying the replica.
    function _getReplicaKey(
        uint64 datasetId,
        uint64 replicaIndex
    ) internal pure returns (bytes32 replicaKey) {
        return keccak256(abi.encodePacked(datasetId, replicaIndex));
    }
}
