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

/// @title Filplus
library CarstoreEvents {
    /// @notice Emitted when multiple cars are added to the storage.
    event CarsAdded(bytes32[] _cids);

    /// @notice Emitted when a replica is added to a car.
    event CarReplicaAdded(bytes32 indexed _cid, uint64 _matchingId);

    /// @notice Report that storage deal for a replica has expired.
    /// @dev This function allows reporting that the storage deal for a replica has expired.
    /// @param _cid Car CID associated with the replica.
    /// @param _matchingId Matching ID of the replica.
    event CarReplicaExpired(bytes32 indexed _cid, uint64 _matchingId);

    /// @notice Report that storage of a replica has failed.
    /// @dev This function allows reporting that the storage of a replica has failed.
    /// @param _cid Car CID associated with the replica.
    /// @param _matchingId Matching ID of the replica.
    event CarReplicaFailed(bytes32 indexed _cid, uint64 _matchingId);

    /// @notice Emitted when the Filecoin deal ID is set for a replica's storage.
    event CarReplicaFilecoinDealIdSet(
        bytes32 indexed _cid,
        uint64 _matchingId,
        uint64 _filecoinDealId
    );

    /// @notice Report that storage of a replica has been slashed.
    /// @dev This function allows reporting that the storage of a replica has been slashed.
    /// @param _cid Car CID associated with the replica.
    /// @param _matchingId Matching ID of the replica.
    event CarReplicaSlashed(bytes32 indexed _cid, uint64 _matchingId);
}
