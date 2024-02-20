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

import {MatchingType} from "src/v0.8/types/MatchingType.sol";

/// @title Matching Target Library
/// @notice This library provides functions for managing targets.
/// @dev This library is used to manage the targets of matchings.
library MatchingTargetLIB {
    /// @notice Get the cars of a matching.
    /// @return cars An array of CIDs representing the cars in the matching.
    function _getCars(
        MatchingType.MatchingTarget storage self
    ) internal view returns (uint64[] memory) {
        return self.cars;
    }

    /// @notice Get datasetId of matching.
    /// @dev This function is used to get dataset id of matching.
    function _getDatasetId(
        MatchingType.MatchingTarget storage self
    ) internal view returns (uint64) {
        return self.datasetId;
    }

    /// @notice Get replica index of matching.
    /// @dev This function is used to get dataset's replica index of matching.
    function _getDatasetReplicaIndex(
        MatchingType.MatchingTarget storage self
    ) internal view returns (uint64) {
        return self.replicaIndex;
    }

    /// @notice Push a car to matching.
    /// @dev This function is used to push a car to target of matching.
    function _pushCar(
        MatchingType.MatchingTarget storage self,
        uint64 _car
    ) internal {
        self.cars.push(_car);
    }

    /// @notice Update cars and size of a matching target.
    /// @dev This function is used to update cars and size of target of matching.
    function _updateTargetCars(
        MatchingType.MatchingTarget storage self,
        uint64[] memory _cars,
        uint64 _size
    ) internal {
        for (uint64 i = 0; i < _cars.length; i++) {
            _pushCar(self, _cars[i]);
        }
        self.size += _size;
    }
}
