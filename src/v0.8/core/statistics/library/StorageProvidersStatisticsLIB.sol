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

/// @title StorageProvidersStatisticsLIB Library
/// @notice Library for managing statistics related to storage providers, including adding storaged sizes and retrieving an overview of storage providers
library StorageProvidersStatisticsLIB {
    /// @notice Adds storaged size for a specific storage provider.
    /// @param self StorageProvidersStatistics structure to modify.
    /// @param storageProvider ID of the storage provider.
    /// @param size Size to be added for the storage provider.
    function addStoraged(
        StatisticsType.StorageProvidersStatistics storage self,
        uint64 storageProvider,
        uint256 size
    ) external {
        require(size != 0, "invalid size to addStoraged");

        if (self.storageProviderInfos[storageProvider] == 0) {
            self.storageProviders.push(storageProvider);
            self.storageProviderInfos[storageProvider] = size;
        } else {
            self.storageProviderInfos[storageProvider] += size;
        }
    }

    /// @notice Retrieves an overview of storage providers.
    /// @param self StorageProvidersStatistics structure to query.
    /// @return storageProviders Array of storage providers.
    function getOverview(
        StatisticsType.StorageProvidersStatistics storage self
    ) external view returns (uint64[] memory storageProviders) {
        return (self.storageProviders);
    }
}
