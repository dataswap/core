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

import {CarReplicaType} from "src/v0.8/types/CarReplicaType.sol";
import {CarReplicaLIB} from "src/v0.8/core/carstore/library/CarReplicaLIB.sol";
import {IFilecoin} from "src/v0.8/interfaces/core/IFilecoin.sol";
import {FilecoinType} from "src/v0.8/types/FilecoinType.sol";

/// @title CarLIB
/// @dev This library provides functions for managing the lifecycle and events of car and their replicas.
/// @notice Library for managing the state, events, and operations related to car and their replicas.
library CarLIB {
    using CarReplicaLIB for CarReplicaType.Replica;

    /// @notice Add a new replica to a car.
    /// @dev Requires a non-zero matching ID and that the replica does not already exist.
    ///      This should be called by an external dataset contract after a dataset be approved.
    /// @param self The reference to the car storage.
    /// @param _matchingId The matching ID for the new replica.
    /// @param _replicaIndex The index of the replica.
    function _registRepica(
        CarReplicaType.Car storage self,
        uint64 _matchingId,
        uint16 _replicaIndex
    ) internal {
        require(_matchingId != 0, "Invalid matching id");
        require(!_hasReplica(self, _matchingId), "Replica already exists");

        CarReplicaType.Replica storage replica = self.replicas[_replicaIndex];

        if (replica.matchingId == 0) {
            require(
                replica.state == CarReplicaType.State.None,
                "Invalid car state"
            );
        } else {
            require(!replica._isStateValid(), "Replica state not match");
        }

        replica._init(_matchingId);
        self.replicaIndex[_matchingId] = _replicaIndex;
    }

    /// @notice Initialize replica information for the car.
    /// @param self The reference to the car storage.
    /// @param _replicaCount The total number of storage replicas submitted by the client for the car.
    function _initRepicas(
        CarReplicaType.Car storage self,
        uint16 _replicaCount
    ) internal {
        if (self.replicas.length != 0) {
            delete self.replicas;
        }

        for (uint16 index = 0; index < _replicaCount; index++) {
            CarReplicaType.Replica memory newReplica;
            self.replicas.push(newReplica);
        }
    }

    /// @notice Post an event for a car's replica based on the matching ID, triggering state transitions.
    /// @dev The state transition is based on the event and the current state of the replica.
    /// @param self The reference to the car storage.
    /// @param _matchingId The matching ID of the replica.
    /// @param _event The event to post.
    function _emitRepicaEvent(
        CarReplicaType.Car storage self,
        uint64 _matchingId,
        CarReplicaType.Event _event
    ) internal {
        require(_hasReplica(self, _matchingId), "Replica is not exists");
        uint16 index = self.replicaIndex[_matchingId];
        CarReplicaType.Replica storage replica = self.replicas[index];

        replica._emitEvent(_event);
    }

    /// @notice Set the dataset ID for a car
    /// @dev Requires a non-zero matching ID and that the replica already exists.
    ///      This should be called by an external matching contract after a successful matching process.
    /// @param self The reference to the car storage.
    /// @param _datasetId The new dataset ID for car to set.
    function _setDatasetId(
        CarReplicaType.Car storage self,
        uint64 _datasetId
    ) internal {
        require(
            _datasetId != 0 && _datasetId != self.datasetId,
            "Invalid dataset id"
        );
        self.datasetId = _datasetId;
    }

    /// @notice Set the replica filecoin claim ID for a car's replica.
    /// @dev Requires non-zero matching ID and Filecoin claim ID, and that the replica exists.
    ///      This should be called by an external storage deal contract after a successful storage deal process.
    /// @param self The reference to the car storage.
    /// @param _matchingId The matching ID of the replica.
    /// @param _claimId The new Filecoin claim ID to set.
    function _setReplicaFilecoinClaimId(
        CarReplicaType.Car storage self,
        uint64 _matchingId,
        uint64 _claimId
    ) internal {
        require(_matchingId != 0, "Invalid matching id");
        require(_claimId != 0, "Invalid filecoin claim id");
        require(_hasReplica(self, _matchingId), "Replica is not exists");
        uint16 index = self.replicaIndex[_matchingId];
        CarReplicaType.Replica storage replica = self.replicas[index];

        replica._setFilecoinClaimId(_claimId);
        _emitRepicaEvent(
            self,
            _matchingId,
            CarReplicaType.Event.StorageCompleted
        );
    }

    /// @notice Get the dataset ID associated with a car.
    /// @dev Retrieves the dataset ID associated with the car.
    /// @param self The reference to the car storage.
    /// @return The dataset ID of the car.
    function _getDatasetId(
        CarReplicaType.Car storage self
    ) internal view returns (uint64) {
        return self.datasetId;
    }

    /// @notice Get the matching ids of a replica associated with a car.
    /// @param self The reference to the car storage.
    /// @return The matching ids of the car's replica.
    function _getMatchingIds(
        CarReplicaType.Car storage self
    ) internal view returns (uint64[] memory) {
        uint64[] memory matchings = new uint64[](self.replicas.length);
        for (uint64 i = 0; i < self.replicas.length; i++) {
            if (self.replicas[i]._isStateValid()) {
                matchings[i] = self.replicas[i].matchingId;
            }
        }
        return matchings;
    }

    /// @notice Get the count of replicas associated with a car.
    /// @dev Retrieves the count of replicas associated with the car.
    /// @param self The reference to the car storage.
    /// @return The count of replicas.
    function _getRepicasCount(
        CarReplicaType.Car storage self
    ) internal view returns (uint16) {
        return uint16(self.replicas.length);
    }

    /// @notice Get the count of valid replicas associated with a car.
    /// @dev Retrieves the count of replicas associated with the car.
    /// @param self The reference to the car storage.
    /// @return The count of replicas.
    function _getValidRepicasCount(
        CarReplicaType.Car storage self
    ) internal view returns (uint16) {
        uint16 count = 0;
        for (uint16 i = 0; i < self.replicas.length; i++) {
            if (
                self.replicas[i].state == CarReplicaType.State.None ||
                self.replicas[i].state == CarReplicaType.State.Matched ||
                self.replicas[i].state == CarReplicaType.State.Stored
            ) {
                count++;
            }
        }
        return count;
    }

    /// @notice Get the Filecoin claim ID associated with a specific replica of a car.
    /// @dev Retrieves the Filecoin claim ID associated with the given matching ID of a replica.
    /// @param self The reference to the car storage.
    /// @param _matchingId The matching ID of the replica.
    /// @return The Filecoin claim ID of the replica.
    function _getReplicaFilecoinClaimId(
        CarReplicaType.Car storage self,
        uint64 _matchingId
    ) internal view returns (uint64) {
        require(_matchingId != 0, "Invalid matching id");
        require(_hasReplica(self, _matchingId), "Replica is not exists");
        uint16 index = self.replicaIndex[_matchingId];
        CarReplicaType.Replica storage replica = self.replicas[index];
        require(replica._isMatchingValid(_matchingId), "Invalid matching id");

        return replica.filecoinClaimId;
    }

    /// @notice Get the state of a replica associated with a car.
    /// @dev Retrieves the state of a replica based on the provided matching ID.
    /// @param self The reference to the car storage.
    /// @param _matchingId The matching ID of the replica.
    /// @return The state of the replica.
    function _getReplicaState(
        CarReplicaType.Car storage self,
        uint64 _matchingId
    ) internal view returns (CarReplicaType.State) {
        require(_matchingId != 0, "Invalid matching id");
        uint16 index = self.replicaIndex[_matchingId];
        require(index < self.replicas.length, "Index out of bounds");
        CarReplicaType.Replica storage replica = self.replicas[index];
        require(replica._isMatchingValid(_matchingId), "Invalid matching id");
        return replica.state;
    }

    /// @notice Check if a replica with a specific matching ID exists for a car.
    /// @dev Checks whether a replica with the given matching ID exists for the car.
    /// @param self The reference to the car storage.
    /// @param _matchingId The matching ID to check.
    /// @return exists Whether the replica exists or not.
    function _hasReplica(
        CarReplicaType.Car storage self,
        uint64 _matchingId
    ) internal view returns (bool) {
        require(_matchingId != 0, "Invalid matching id");
        uint16 index = self.replicaIndex[_matchingId];
        if (self.replicas.length == 0 || index >= self.replicas.length) {
            return false;
        }

        CarReplicaType.Replica storage replica = self.replicas[index];
        if (!replica._isMatchingValid(_matchingId)) {
            return false;
        }
        return true;
    }
}
