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

import "../../../types/CarReplicaType.sol";
import "./CarReplicaLIB.sol";

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
    function addRepica(
        CarReplicaType.Car storage self,
        uint256 _matchingId
    ) internal {
        require(!(_matchingId == 0), "Invalid matching id for addReplica");
        (bool exists, ) = hasReplica(self, _matchingId);
        require(!exists, "Replica already exists");

        self.replicasCount++;
        CarReplicaType.Replica storage replica = self.replicas[
            self.replicasCount
        ];
        replica.setMatchingId(_matchingId);
        self.replicas[self.replicasCount] = replica;

        // Adding a replica indicates that the matching has been completed.
        postRepicaEventByMatchingId(
            self,
            _matchingId,
            CarReplicaType.Event.MatchingCompleted
        );
    }

    /// @notice Get the count of replicas associated with a car.
    /// @dev Retrieves the count of replicas associated with the car.
    /// @param self The reference to the car storage.
    /// @return The count of replicas.
    function getRepicasCount(
        CarReplicaType.Car storage self
    ) internal view returns (uint256) {
        return self.replicasCount;
    }

    /// @notice Check if a replica with a specific matching ID exists for a car.
    /// @dev Checks whether a replica with the given matching ID exists for the car.
    /// @param self The reference to the car storage.
    /// @param _matchingId The matching ID to check.
    /// @return exists Whether the replica exists or not.
    /// @return replicaIndex The index of the existing replica.
    function hasReplica(
        CarReplicaType.Car storage self,
        uint256 _matchingId
    ) internal view returns (bool exists, uint256 replicaIndex) {
        if (self.replicasCount == 0) return (false, 0);
        for (uint256 i = 1; i <= self.replicasCount; i++) {
            if (self.replicas[i].matchingId == _matchingId) return (true, i);
        }
        return (false, 0);
    }

    /// @notice Set the matching ID for a car's replica.
    /// @dev Requires a non-zero matching ID and that the replica already exists.
    ///      This should be called by an external matching contract after a successful matching process.
    /// @param self The reference to the car storage.
    /// @param _matchingId The new matching ID to set.
    function setMatchingId(
        CarReplicaType.Car storage self,
        uint256 _matchingId
    ) internal {
        require(!(_matchingId == 0), "Invalid matching id for setMatchingId");
        (bool exists, uint256 replicaIndex) = hasReplica(self, _matchingId);
        require(exists, "Replica is not exists");
        CarReplicaType.Replica storage replica = self.replicas[replicaIndex];
        require(
            (_matchingId != replica.matchingId),
            "Invalid set the same matching id for setMatchingId"
        );
        replica.setMatchingId(_matchingId);
    }

    /// @notice Set the Filecoin deal ID for a car's replica.
    /// @dev Requires non-zero matching ID and Filecoin deal ID, and that the replica exists.
    ///      This should be called by an external  storage deal contract after a successful storage deal process.
    /// @param self The reference to the car storage.
    /// @param _matchingId The matching ID of the replica.
    /// @param _filecoinDealId The new Filecoin deal ID to set.
    function setFilecoinDealId(
        CarReplicaType.Car storage self,
        uint256 _matchingId,
        uint256 _filecoinDealId
    ) internal {
        require(
            !(_matchingId == 0),
            "Invalid matching id for setFilecoinDealId"
        );
        require(
            !(_filecoinDealId == 0),
            "Invalid filecoin deal id for setFilecoinDealId"
        );
        (bool exists, uint256 replicaIndex) = hasReplica(self, _matchingId);
        require(exists, "Replica is not exists");
        CarReplicaType.Replica storage replica = self.replicas[replicaIndex];
        require(
            _filecoinDealId != replica.filecoinDealId,
            "Invalid set the same filecoin deal id for setFilecoinDealId"
        );
        replica.setFilecoinDealId(_filecoinDealId);

        // Set a replica filecoin deal id indicates that the storage has been completed.
        postRepicaEventByMatchingId(
            self,
            _matchingId,
            CarReplicaType.Event.StorageCompleted
        );
    }

    /// @notice Post an event for a car's replica, triggering state transitions.
    /// @dev The state transition is based on the event and the current state of the replica.
    /// @param self The reference to the car storage.
    /// @param _repicaIndex The index of the replica.
    /// @param _event The event to post.
    function postRepicaEventReplicaIndex(
        CarReplicaType.Car storage self,
        uint256 _repicaIndex,
        CarReplicaType.Event _event
    ) internal {
        require(
            _repicaIndex < self.replicasCount,
            "Invalid replica id for updateRepicaStateByIndex"
        );
        CarReplicaType.Replica storage replica = self.replicas[_repicaIndex];
        replica.postEvent(_event);
    }

    /// @notice Post an event for a car's replica based on the matching ID, triggering state transitions.
    /// @dev The state transition is based on the event and the current state of the replica.
    /// @param self The reference to the car storage.
    /// @param _matchingId The matching ID of the replica.
    /// @param _event The event to post.
    function postRepicaEventByMatchingId(
        CarReplicaType.Car storage self,
        uint256 _matchingId,
        CarReplicaType.Event _event
    ) internal {
        (bool exists, uint256 replicaIndex) = hasReplica(self, _matchingId);
        require(exists, "Replica is not exists");
        CarReplicaType.Replica storage replica = self.replicas[replicaIndex];
        replica.postEvent(_event);
    }
}
