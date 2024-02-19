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

import {DatasetType} from "src/v0.8/types/DatasetType.sol";
import {GeolocationType} from "src/v0.8/types/GeolocationType.sol";

/// @title DatasetReplicaRequirementLIB Library,include add,get,verify.
/// @notice This library provides functions for storage replica requirement of datasets.
library DatasetReplicaRequirementLIB {
    /// @notice Submits replica requirement for a dataset.
    /// @dev This function allows submitting replica requirement for a dataset.
    function submitDatasetRequirements(
        DatasetType.DatasetReplicasRequirement storage self,
        address[][] memory _dataPreparers,
        address[][] memory _storageProviders,
        uint16[] memory _regions,
        uint16[] memory _countrys,
        uint32[][] memory _citys
    ) internal {
        for (uint32 i = 0; i < _regions.length; i++) {
            self.replicasRequirement.push(
                DatasetType.ReplicaRequirement(
                    _dataPreparers[i],
                    _storageProviders[i],
                    GeolocationType.Geolocation(
                        _regions[i],
                        _countrys[i],
                        _citys[i]
                    )
                )
            );
        }
        self.completedHeight = uint64(block.number);
    }

    ///@notice Get dataset replica requirement info
    function getDatasetReplicaRequirement(
        DatasetType.DatasetReplicasRequirement storage self,
        uint64 _index
    )
        internal
        view
        returns (
            address[] memory dataPreparers,
            address[] memory storageProviders,
            uint16 regionCode,
            uint16 countryCode,
            uint32[] memory cityCodes
        )
    {
        require(_index < self.replicasRequirement.length, "Invalid index");
        return (
            self.replicasRequirement[_index].dataPreparers,
            self.replicasRequirement[_index].storageProviders,
            self.replicasRequirement[_index].geolocations.regionCode,
            self.replicasRequirement[_index].geolocations.countryCode,
            self.replicasRequirement[_index].geolocations.cityCodes
        );
    }

    ///@notice Get dataset replica's count
    function getDatasetReplicasCount(
        DatasetType.DatasetReplicasRequirement storage self
    ) internal view returns (uint16) {
        return (uint16(self.replicasRequirement.length));
    }
}
