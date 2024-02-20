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

import {IRoles} from "src/v0.8/interfaces/core/IRoles.sol";
import {DatasetType} from "src/v0.8/types/DatasetType.sol";
import {MatchingType} from "src/v0.8/types/MatchingType.sol";

/// @title IMatchingsTarget
interface IMatchingsTarget {
    /// @notice Function for create a new matching target.
    /// @param _matchingId The matching id to publish cars.
    /// @param _datasetId The dataset id to create matching.
    /// @param _dataType Identify the data type of "cars", which can be either "Source" or "MappingFiles".
    /// @param _associatedMappingFilesMatchingID The matching ID that associated with mapping files of dataset of _datasetId
    /// @param _replicaIndex The index of the replica in dataset.
    function createTarget(
        uint64 _matchingId,
        uint64 _datasetId,
        DatasetType.DataType _dataType,
        uint64 _associatedMappingFilesMatchingID,
        uint16 _replicaIndex
    ) external;

    /// @notice  Function for publishing a matching
    /// @param _matchingId The matching id to publish cars.
    /// @param _datasetId The dataset id of matching.
    /// @param _carsStarts The cars to publish.
    /// @param _carsEnds The cars to publish.
    /// @param complete If the publish is complete.
    function publishMatching(
        uint64 _matchingId,
        uint64 _datasetId,
        uint64[] memory _carsStarts,
        uint64[] memory _carsEnds,
        bool complete
    ) external;

    /// @notice Get the target information of a matching.
    /// @param _matchingId The ID of the matching.
    /// @return datasetID The ID of the associated dataset.
    /// @return cars An array of CIDs representing the cars in the matching.
    /// @return size The size of the matching.
    /// @return dataType The data type of the matching.
    /// @return associatedMappingFilesMatchingID The ID of the associated mapping files matching.
    /// @return replicaIndex The index of dataset's replica
    function getMatchingTarget(
        uint64 _matchingId
    )
        external
        view
        returns (
            uint64 datasetID,
            uint64[] memory cars,
            uint64 size,
            DatasetType.DataType dataType,
            uint64 associatedMappingFilesMatchingID,
            uint16 replicaIndex
        );

    /// @notice Check if a matching with the given matching ID contains a specific CID.
    /// @param _matchingId The ID of the matching to check.
    /// @param _cid The CID (Content Identifier) to check for.
    /// @return True if the matching contains the specified CID, otherwise false.
    function isMatchingContainsCar(
        uint64 _matchingId,
        uint64 _cid
    ) external view returns (bool);

    /// @notice Check if a matching with the given matching ID contains multiple CIDs.
    /// @param _matchingId The ID of the matching to check.
    /// @param _cids An array of CIDs (Content Identifiers) to check for.
    /// @return True if the matching contains all the specified CIDs, otherwise false.
    function isMatchingContainsCars(
        uint64 _matchingId,
        uint64[] memory _cids
    ) external view returns (bool);

    /// @notice check is matching targe valid
    function isMatchingTargetValid(
        uint64 _datasetId,
        uint64[] memory _cars,
        uint64 _size,
        DatasetType.DataType _dataType,
        uint64 _associatedMappingFilesMatchingID
    ) external view returns (bool);

    /// @notice Check if a matching meets the requirements of Fil+.
    function isMatchingTargetMeetsFilPlusRequirements(
        uint64 _matchingId,
        address candidate
    ) external view returns (bool);

    /// @notice Get the Roles contract.
    /// @return Roles contract address.
    function roles() external view returns (IRoles);
}
