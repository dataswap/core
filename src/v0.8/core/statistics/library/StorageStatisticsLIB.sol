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

import {StatisticsType} from "src/v0.8/types/StatisticsType.sol";

/// @title StorageStatisticsLIB Library
/// @notice Library for handling storage statistics operations
library StorageStatisticsLIB {
    /// @notice Adds to the allocated in the datacap statistics data
    function addAllocated(
        StatisticsType.StorageStatistics storage self,
        uint256 size
    ) internal {
        uint256 unAllocated = self.total - self.allocatedDatacap;
        //solhint-disable-next-line
        require(unAllocated >= size, "invalid size to addAllocated");
        self.allocatedDatacap += size;
    }

    /// @notice Adds to the canceled in the datacap statistics data
    function addCanceled(
        StatisticsType.StorageStatistics storage self,
        uint256 size
    ) internal {
        uint256 available = self.allocatedDatacap -
            self.completed -
            self.canceled;
        //solhint-disable-next-line
        require(available >= size, "invalid size to addCanceledDatacap");
        self.canceled += size;
    }

    /// @notice Adds storage provider size information to the storage statistics data
    function addStoraged(
        StatisticsType.StorageStatistics storage self,
        uint256 size
    ) internal {
        uint256 available = self.allocatedDatacap -
            self.completed -
            self.canceled;
        //solhint-disable-next-line
        require(
            available >= size,
            "invalid size to addStorageProviderStoraged"
        );
        self.completed += size;
    }

    /// @notice Checks whether the storage statistics indicate completion.
    /// @dev This function determines whether the storage statistics represent a completed state.
    /// @param self Storage statistics to be checked for completion.
    /// @return A boolean indicating whether the storage statistics represent a completed state.
    function isStorageCompleted(
        StatisticsType.StorageStatistics storage self
    ) internal view returns (bool) {
        if ((self.completed + self.canceled) == self.total) {
            return true;
        }
        return false;
    }

    /// @notice Checks whether the storage is successful.
    /// @dev This function determines whether the storage is considered successful.
    /// @param self Storage statistics to be checked for success.
    /// @return A boolean indicating whether the storage is considered successful.
    function isStorageSuccessful(
        StatisticsType.StorageStatistics storage self
    ) internal view returns (bool) {
        if (self.completed == self.total) {
            return true;
        }
        return false;
    }

    /// @notice Retrieves size details from the storage statistics data
    /// @return total Total datacap.
    /// @return completed Completed storage.
    /// @return usedDatacap Used datacap.
    /// @return availableDatacap Available datacap.
    /// @return canceled Canceled datacap.
    /// @return unallocatedDatacap Un allocated datacap.
    function getOverview(
        StatisticsType.StorageStatistics storage self
    )
        internal
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
        return (
            self.total,
            self.completed,
            self.completed,
            self.allocatedDatacap - self.completed - self.canceled,
            self.canceled,
            self.total - self.allocatedDatacap
        );
    }
}
