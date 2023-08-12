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

import "../../types/FilPlusType.sol";

/// @title IFilPlus
/// @notice This interface defines the functions for configuring parameters of the FilPlus system.
/// @dev This interface provides functions to set various parameters for the FilPlus system, such as maximum replica counts, region counts, and more.
interface IFilplus {
    /// @notice Set the minimum region count required for FilPlus.
    /// @param _minRegionCount The new minimum region count.
    function setMinRegionCount(uint256 _minRegionCount) external;

    /// @notice Set the default maximum replicas allowed per country in FilPlus.
    /// @param _defaultMaxReplicasPerCountry The new default maximum replicas per country.
    function setDefaultMaxReplicasPerCountry(
        uint256 _defaultMaxReplicasPerCountry
    ) external;

    /// @notice Add a maximum replicas limit for a specific city code in FilPlus.
    /// @param cityCode The city code for which to set the maximum replicas.
    /// @param _maxReplicasInCountry The new maximum replicas per city code.
    function setMaxReplicasInCountry(
        bytes2 cityCode,
        uint256 _maxReplicasInCountry
    ) external;

    /// @notice Set the maximum replicas allowed per city in FilPlus.
    /// @param _maxReplicasPerCity The new maximum replicas per city.
    function setMaxReplicasPerCity(uint256 _maxReplicasPerCity) external;

    /// @notice Set the minimum  storage provider count required for FilPlus.
    /// @param _minSPCount The new minimum storage provider count.
    function setMinSPCount(uint256 _minSPCount) external;

    /// @notice Set the maximum replicas allowed per storage provider in FilPlus.
    /// @param _maxReplicasPerSP The new maximum replicas per storage provider.
    function setMaxReplicasPerSP(uint256 _maxReplicasPerSP) external;

    /// @notice Set the minimum total replicas required for FilPlus.
    /// @param _minTotalReplicas The new minimum total replicas.
    function setMinTotalReplicas(uint256 _minTotalReplicas) external;

    /// @notice Set the maximum total replicas allowed for FilPlus.
    /// @param _maxTotalReplicas The new maximum total replicas.
    function setMaxTotalReplicas(uint256 _maxTotalReplicas) external;
}
