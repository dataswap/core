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

    /// @notice Emitted when a replica is registed to a car.
    event CarReplicaRegisted(
        uint64 indexed _id,
        uint64 _matchingId,
        uint16 _replicaIndex
    );

    /// @notice Report that matching for a replica has failed.
    /// @dev This function allows reporting that the matching for a replica has failed.
    /// @param _id Car ID associated with the replica.
    /// @param _matchingId Matching ID of the replica.
    /// @param _matchingState Matching state of the replica.
    event CarReplicaMatchingState(
        uint64 indexed _id,
        uint64 _matchingId,
        string _matchingState
    );

    /// @notice Report that storage deal for a replica has expired.
    /// @dev This function allows reporting that the storage deal for a replica has expired.
    /// @param _id Car ID associated with the replica.
    /// @param _matchingId Matching ID of the replica.
    event CarReplicaExpired(uint64 indexed _id, uint64 _matchingId);

    /// @notice Report that storage of a replica has failed.
    /// @dev This function allows reporting that the storage of a replica has failed.
    /// @param _id Car ID associated with the replica.
    /// @param _matchingId Matching ID of the replica.
    event CarReplicaFailed(uint64 indexed _id, uint64 _matchingId);

    /// @notice Emitted when the Filecoin claim ID is set for a replica's storage.
    event CarReplicaFilecoinClaimIdSet(
        uint64 indexed _id,
        uint64 _matchingId,
        uint64 _claimId
    );

    /// @notice Report that storage of a replica has been slashed.
    /// @dev This function allows reporting that the storage of a replica has been slashed.
    /// @param _id Car ID associated with the replica.
    /// @param _matchingId Matching ID of the replica.
    event CarReplicaSlashed(uint64 indexed _id, uint64 _matchingId);
}
