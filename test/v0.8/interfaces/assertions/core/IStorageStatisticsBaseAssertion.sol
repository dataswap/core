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

interface IStorageStatisticsBaseAssertion {
    /// @notice External function to assert the registration of dataswap datacap.
    /// @param caller Address of the caller.
    /// @param size Size of the dataswap datacap to be registered.
    function registDataswapDatacapAssertion(
        address caller,
        uint256 size
    ) external;

    /// @notice External function to get an overview of storage statistics.
    /// @param expectDataswapTotal Expected total dataswap size.
    /// @param expectTotal Expected total size.
    /// @param expectCompleted Expected completed size.
    /// @param expectUsedDatacap Expected used datacap size.
    /// @param expectAvailableDatacap Expected available datacap size.
    /// @param expectCanceled Expected canceled datacap size.
    /// @param expectUnallocatedDatacap Expected unallocated datacap size.
    function getStorageOverviewAssertion(
        uint256 expectDataswapTotal,
        uint256 expectTotal,
        uint256 expectCompleted,
        uint256 expectUsedDatacap,
        uint256 expectAvailableDatacap,
        uint256 expectCanceled,
        uint256 expectUnallocatedDatacap
    ) external;

    /// @notice External function to get an overview of storage statistics for a specific dataset.
    /// @param datasetId Dataset ID for which to retrieve the overview.
    /// @param expectTotal Expected total size.
    /// @param expectCompleted Expected completed size.
    /// @param expectUsedDatacap Expected used datacap size.
    /// @param expectAvailableDatacap Expected available datacap size.
    /// @param expectCanceled Expected canceled datacap size.
    /// @param expectUnallocatedDatacap Expected unallocated datacap size.
    function getDatasetStorageOverviewAssertion(
        uint64 datasetId,
        uint256 expectTotal,
        uint256 expectCompleted,
        uint256 expectUsedDatacap,
        uint256 expectAvailableDatacap,
        uint256 expectCanceled,
        uint256 expectUnallocatedDatacap
    ) external;

    /// @notice External function to get an overview of storage statistics for a specific replica within a dataset.
    /// @param datasetId Dataset ID associated with the replica.
    /// @param replicaIndex Index of the replica within the dataset.
    /// @param expectTotal Expected total size.
    /// @param expectCompleted Expected completed size.
    /// @param expectUsedDatacap Expected used datacap size.
    /// @param expectAvailableDatacap Expected available datacap size.
    /// @param expectCanceled Expected canceled datacap size.
    /// @param expectUnallocatedDatacap Expected unallocated datacap size.
    function getReplicaStorageOverviewAssertion(
        uint64 datasetId,
        uint64 replicaIndex,
        uint256 expectTotal,
        uint256 expectCompleted,
        uint256 expectUsedDatacap,
        uint256 expectAvailableDatacap,
        uint256 expectCanceled,
        uint256 expectUnallocatedDatacap
    ) external;

    /// @notice External function to get an overview of storage statistics for a specific matching within a dataset.
    /// @param matchingId Matching ID for which to retrieve the overview.
    /// @param expectTotal Expected total size.
    /// @param expectCompleted Expected completed size.
    /// @param expectUsedDatacap Expected used datacap size.
    /// @param expectAvailableDatacap Expected available datacap size.
    /// @param expectCanceled Expected canceled datacap size.
    /// @param expectUnallocatedDatacap Expected unallocated datacap size.
    /// @param expectStorageProviders Expected array of storage providers associated with the matching.
    function getMatchingStorageOverviewAssertion(
        uint64 matchingId,
        uint256 expectTotal,
        uint256 expectCompleted,
        uint256 expectUsedDatacap,
        uint256 expectAvailableDatacap,
        uint256 expectCanceled,
        uint256 expectUnallocatedDatacap,
        uint64[] memory expectStorageProviders
    ) external;
}
