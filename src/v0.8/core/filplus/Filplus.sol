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

import "@openzeppelin/contracts/access/Ownable2Step.sol";
import "../../types/FilPlusType.sol";
import "./library/FilPlusLIB.sol";
import "./IFilplus.sol";

/// @title FilPlus
/// @notice This contract implements the IFilPlus interface and allows configuring parameters for the FilPlus system.
/// @dev This contract provides functions to set various parameters such as region counts, maximum replica limits, and more.
contract Filplus is IFilplus, Ownable2Step {
    FilPlusType.Rules rules;

    using FilPlusLIB for FilPlusType.Rules;

    /// @notice Event emitted when the minimum region count required for FilPlus is set.
    event MinRegionCountSet(uint256 _newMinRegionCount);

    /// @notice Event emitted when the default maximum replicas allowed per country in FilPlus is set.
    event DefaultMaxReplicasPerCountrySet(
        uint256 _newDefaultMaxReplicasPerCountry
    );

    /// @notice Event emitted when the maximum replicas limit for a specific city code in FilPlus is set.
    event MaxReplicasInCountrySet(
        bytes2 indexed _cityCode,
        uint256 _newMaxReplicasInCountry
    );

    /// @notice Event emitted when the maximum replicas allowed per city in FilPlus is set.
    event MaxReplicasPerCitySet(uint256 _newMaxReplicasPerCity);

    /// @notice Event emitted when the minimum storage provider count required for FilPlus is set.
    event MinSPCountSet(uint256 _newMinSPCount);

    /// @notice Event emitted when the maximum replicas allowed per storage provider in FilPlus is set.
    event MaxReplicasPerSPSet(uint256 _newMaxReplicasPerSP);

    /// @notice Event emitted when the minimum total replicas required for FilPlus is set.
    event MinTotalReplicasSet(uint256 _newMinTotalReplicas);

    /// @notice Event emitted when the maximum total replicas allowed for FilPlus is set.
    event MaxTotalReplicasSet(uint256 _newMaxTotalReplicas);

    /// @notice Set the minimum region count required for FilPlus.
    /// @param _minRegionCount The new minimum region count.
    function setMinRegionCount(uint256 _minRegionCount) external override {
        rules.setMinRegionCount(_minRegionCount);
        emit MinRegionCountSet(_minRegionCount);
    }

    /// @notice Set the default maximum replicas allowed per country in FilPlus.
    /// @param _defaultMaxReplicasPerCountry The new default maximum replicas per country.
    function setDefaultMaxReplicasPerCountry(
        uint256 _defaultMaxReplicasPerCountry
    ) external override {
        rules.setDefaultMaxReplicasPerCountry(_defaultMaxReplicasPerCountry);
        emit DefaultMaxReplicasPerCountrySet(_defaultMaxReplicasPerCountry);
    }

    /// @notice Add a maximum replicas limit for a specific city code in FilPlus.
    /// @param cityCode The city code for which to set the maximum replicas.
    /// @param _maxReplicasInCountry The new maximum replicas per city code.
    function setMaxReplicasInCountry(
        bytes2 cityCode,
        uint256 _maxReplicasInCountry
    ) external override {
        rules.setMaxReplicasInCountry(cityCode, _maxReplicasInCountry);
        emit MaxReplicasInCountrySet(cityCode, _maxReplicasInCountry);
    }

    /// @notice Set the maximum replicas allowed per city in FilPlus.
    /// @param _maxReplicasPerCity The new maximum replicas per city.
    function setMaxReplicasPerCity(
        uint256 _maxReplicasPerCity
    ) external override {
        rules.setMaxReplicasPerCity(_maxReplicasPerCity);
        emit MaxReplicasPerCitySet(_maxReplicasPerCity);
    }

    /// @notice Set the minimum storage provider count required for FilPlus.
    /// @param _minSPCount The new minimum storage provider count.
    function setMinSPCount(uint256 _minSPCount) external override {
        rules.setMinSPCount(_minSPCount);
        emit MinSPCountSet(_minSPCount);
    }

    /// @notice Set the maximum replicas allowed per storage provider in FilPlus.
    /// @param _maxReplicasPerSP The new maximum replicas per storage provider.
    function setMaxReplicasPerSP(uint256 _maxReplicasPerSP) external override {
        rules.setMaxReplicasPerSP(_maxReplicasPerSP);
        emit MaxReplicasPerSPSet(_maxReplicasPerSP);
    }

    /// @notice Set the minimum total replicas required for FilPlus.
    /// @param _minTotalReplicas The new minimum total replicas.
    function setMinTotalReplicas(uint256 _minTotalReplicas) external override {
        rules.setMinTotalReplicas(_minTotalReplicas);
        emit MinTotalReplicasSet(_minTotalReplicas);
    }

    /// @notice Set the maximum total replicas allowed for FilPlus.
    /// @param _maxTotalReplicas The new maximum total replicas.
    function setMaxTotalReplicas(uint256 _maxTotalReplicas) external override {
        rules.setMaxTotalReplicas(_maxTotalReplicas);
        emit MaxTotalReplicasSet(_maxTotalReplicas);
    }

    function getFilplusMaxDatacapAllocatedPerTime()
        public
        pure
        returns (uint256)
    {
        //TODO
        return 0;
    }

    //if less the threshold ,can allocation
    function getFilplusDatacapAllocationThreshold()
        public
        pure
        returns (uint256)
    {
        //TODO
        return 0;
    }
}
