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

// Importing Solidity libraries and contracts
import {DSTest} from "ds-test/test.sol";
import {Test} from "forge-std/Test.sol";
import {IStorageStatistics} from "src/v0.8/interfaces/core/statistics/IStorageStatistics.sol";
import {IStorageStatisticsBaseAssertion} from "test/v0.8/interfaces/assertions/core/IStorageStatisticsBaseAssertion.sol";

abstract contract StorageStatisticsBaseAssertion is
    DSTest,
    Test,
    IStorageStatisticsBaseAssertion
{
    IStorageStatistics public storageStatistics;
    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    constructor(IStorageStatistics _storageStatistics) {
        storageStatistics = _storageStatistics;
    }

    /// @notice External function to assert the registration of dataswap datacap.
    /// @param caller Address of the caller.
    /// @param size Size of the dataswap datacap to be registered.
    function registDataswapDatacapAssertion(
        address caller,
        uint256 size
    ) external {
        (
            uint256 dataswapTotal,
            uint256 total,
            uint256 completed,
            uint256 usedDatacap,
            uint256 availableDatacap,
            uint256 canceled,
            uint256 unallocatedDatacap
        ) = storageStatistics.getStorageOverview();
        vm.prank(caller);
        storageStatistics.registDataswapDatacap(size);
        getStorageOverviewAssertion(
            size + dataswapTotal,
            total,
            completed,
            usedDatacap,
            availableDatacap,
            canceled,
            unallocatedDatacap
        );
    }

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
    ) public {
        (
            uint256 dataswapTotal,
            uint256 total,
            uint256 completed,
            uint256 usedDatacap,
            uint256 availableDatacap,
            uint256 canceled,
            uint256 unallocatedDatacap
        ) = storageStatistics.getStorageOverview();
        assertEq(dataswapTotal, expectDataswapTotal);
        assertEq(total, expectTotal);
        assertEq(completed, expectCompleted);
        assertEq(usedDatacap, expectUsedDatacap);
        assertEq(availableDatacap, expectAvailableDatacap);
        assertEq(canceled, expectCanceled);
        assertEq(unallocatedDatacap, expectUnallocatedDatacap);
    }

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
    ) public {
        (
            uint256 total,
            uint256 completed,
            uint256 usedDatacap,
            uint256 availableDatacap,
            uint256 canceled,
            uint256 unallocatedDatacap
        ) = storageStatistics.getDatasetStorageOverview(datasetId);
        assertEq(total, expectTotal);
        assertEq(completed, expectCompleted);
        assertEq(usedDatacap, expectUsedDatacap);
        assertEq(availableDatacap, expectAvailableDatacap);
        assertEq(canceled, expectCanceled);
        assertEq(unallocatedDatacap, expectUnallocatedDatacap);
    }

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
    ) public {
        (
            uint256 total,
            uint256 completed,
            uint256 usedDatacap,
            uint256 availableDatacap,
            uint256 canceled,
            uint256 unallocatedDatacap
        ) = storageStatistics.getReplicaStorageOverview(
                datasetId,
                replicaIndex
            );
        assertEq(total, expectTotal);
        assertEq(completed, expectCompleted);
        assertEq(usedDatacap, expectUsedDatacap);
        assertEq(availableDatacap, expectAvailableDatacap);
        assertEq(canceled, expectCanceled);
        assertEq(unallocatedDatacap, expectUnallocatedDatacap);
    }

    /// @notice External function to get an overview of storage statistics for a specific matching within a dataset.
    /// @param matchingId Matching ID for which to retrieve the overview.
    /// @param expectTotal Expected total size.
    /// @param expectCompleted Expected completed size.
    /// @param expectUsedDatacap Expected used datacap size.
    /// @param expectAvailableDatacap Expected available datacap size.
    /// @param expectCanceled Expected canceled datacap size.
    /// @param expectUnallocatedDatacap Expected unallocated datacap size.
    function _getMatchingStorageOverviewDatacapAssertion(
        uint64 matchingId,
        uint256 expectTotal,
        uint256 expectCompleted,
        uint256 expectUsedDatacap,
        uint256 expectAvailableDatacap,
        uint256 expectCanceled,
        uint256 expectUnallocatedDatacap
    ) internal {
        (
            uint256 total,
            uint256 completed,
            uint256 usedDatacap,
            uint256 availableDatacap,
            uint256 canceled,
            uint256 unallocatedDatacap,

        ) = storageStatistics.getMatchingStorageOverview(matchingId);
        assertEq(total, expectTotal);
        assertEq(completed, expectCompleted);
        assertEq(usedDatacap, expectUsedDatacap);
        assertEq(availableDatacap, expectAvailableDatacap);
        assertEq(canceled, expectCanceled);
        assertEq(unallocatedDatacap, expectUnallocatedDatacap);
    }

    /// @notice External function to get an overview of storage statistics for a specific matching within a dataset.
    /// @param matchingId Matching ID for which to retrieve the overview.
    /// @param expectStorageProviders Expected array of storage providers associated with the matching.
    function _getMatchingStorageOverviewStorageProviderAssertion(
        uint64 matchingId,
        uint64[] memory expectStorageProviders
    ) internal {
        (, , , , , , uint64[] memory storageProviders) = storageStatistics
            .getMatchingStorageOverview(matchingId);
        assertEq(storageProviders.length, expectStorageProviders.length);
        for (uint256 i = 0; i < storageProviders.length; i++) {
            assertEq(storageProviders[i], expectStorageProviders[i]);
        }
    }

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
    ) public {
        _getMatchingStorageOverviewDatacapAssertion(
            matchingId,
            expectTotal,
            expectCompleted,
            expectUsedDatacap,
            expectAvailableDatacap,
            expectCanceled,
            expectUnallocatedDatacap
        );
        _getMatchingStorageOverviewStorageProviderAssertion(
            matchingId,
            expectStorageProviders
        );
    }
}
