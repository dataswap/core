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

import "../../../types/FilplusType.sol";

/// @title FilPlusLIB
/// @notice This library provides functions to set various parameters of the FilPlus system.
/// @dev This library is used to configure parameters such as maximum replica counts, region counts, and more.
library FilPlusLIB {
    /// @notice Set the minimum region count required for FilPlus.
    /// @param self The reference to the FilPlusType.Rules storage.
    /// @param _minRegionCount The new minimum region count.
    function setMinRegionCount(
        FilplusType.DatasetRules storage self,
        uint256 _minRegionCount
    ) external {
        self.minRegionCountPerDataset = _minRegionCount;
    }

    /// @notice Set the default maximum replicas allowed per country in FilPlus.
    /// @param self The reference to the FilPlusType.Rules storage.
    /// @param _defaultMaxReplicasPerCountry The new default maximum replicas per country.
    function setDefaultMaxReplicasPerCountry(
        FilplusType.DatasetRules storage self,
        uint256 _defaultMaxReplicasPerCountry
    ) external {
        self.defaultMaxReplicasPerCountry = _defaultMaxReplicasPerCountry;
    }

    /// @notice Add a maximum replicas limit for a specific city code in FilPlus.
    /// @param self The reference to the FilPlusType.Rules storage.
    /// @param cityCode The city code for which to set the maximum replicas.
    /// @param _maxReplicasInCountry The new maximum replicas per city code.
    function setMaxReplicasInCountry(
        FilplusType.DatasetRules storage self,
        bytes2 cityCode,
        uint256 _maxReplicasInCountry
    ) external {
        self.maxReplicasInCountry[cityCode] = _maxReplicasInCountry;
    }

    /// @notice Set the maximum replicas allowed per city in FilPlus.
    /// @param self The reference to the FilPlusType.Rules storage.
    /// @param _maxReplicasPerCity The new maximum replicas per city.
    function setMaxReplicasPerCity(
        FilplusType.DatasetRules storage self,
        uint256 _maxReplicasPerCity
    ) external {
        self.maxReplicasPerCity = _maxReplicasPerCity;
    }

    /// @notice Set the minimum storage provider count required for FilPlus.
    /// @param self The reference to the FilPlusType.Rules storage.
    /// @param _minSPCount The new minimum storage provider count.
    function setMinSPCount(
        FilplusType.DatasetRules storage self,
        uint256 _minSPCount
    ) external {
        self.minSPCountPerDataset = _minSPCount;
    }

    /// @notice Set the maximum replicas allowed per storage provider in FilPlus.
    /// @param self The reference to the FilPlusType.Rules storage.
    /// @param _maxReplicasPerSP The new maximum replicas per storage provider.
    function setMaxReplicasPerSP(
        FilplusType.DatasetRules storage self,
        uint256 _maxReplicasPerSP
    ) external {
        self.maxReplicasPerSP = _maxReplicasPerSP;
    }

    /// @notice Set the minimum total replicas required for FilPlus.
    /// @param self The reference to the FilPlusType.Rules storage.
    /// @param _minTotalReplicas The new minimum total replicas.
    function setMinTotalReplicas(
        FilplusType.DatasetRules storage self,
        uint256 _minTotalReplicas
    ) external {
        self.minTotalReplicasPerDataset = _minTotalReplicas;
    }

    /// @notice Set the maximum total replicas allowed for FilPlus.
    /// @param self The reference to the FilPlusType.Rules storage.
    /// @param _maxTotalReplicas The new maximum total replicas.
    function setMaxTotalReplicas(
        FilplusType.DatasetRules storage self,
        uint256 _maxTotalReplicas
    ) external {
        self.maxTotalReplicasPerDataset = _maxTotalReplicas;
    }
}
