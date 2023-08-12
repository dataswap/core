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

/// @title FilPlusType Library
/// @notice This library defines data structures for managing Fil+ rules and configurations.
library FilPlusType {
    /// @notice Struct representing the rules and configurations for Fil+.
    struct Rules {
        uint256 minRegionCount; // Minimum required number of regions (e.g., 3).
        uint256 defaultMaxReplicasPerCountry; // Default maximum replicas allowed per country.
        mapping(bytes2 => uint256) maxReplicasInCountry; // Maximum replicas allowed per country.
        uint256 maxReplicasPerCity; // Maximum replicas allowed per city (e.g., 1).
        uint256 minSPCount; // Minimum required number of storage providers (e.g., 5).
        uint256 maxReplicasPerSP; // Maximum replicas allowed per storage provider (e.g., 1).
        uint256 minTotalReplicas; // Minimum required total replicas (e.g., 5).
        uint256 maxTotalReplicas; // Maximum allowed total replicas (e.g., 10).
    }

    struct DatacapRules {
        uint256 maxAllocatedPerTime; // Maximum allocate datacap size per time.
    }
}
