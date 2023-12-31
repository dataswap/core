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

/// @title CarReplicaType Library
/// @notice This library defines data structures and enums related to car replicas and their states.
/// @dev This library provides enums for different states and events related to car replicas.
library CarReplicaType {
    /// @notice Enum representing the possible states of a car replica.
    enum State {
        None, //justify if Replica exsits
        Matched, // Replica has been matched for storage
        Stored, // Replica has been successfully stored
        StorageFailed, // The filecoin claim id's verification failed.
        Slashed, // The filecoin storage has been slashed.
        Expired // The filecoin storage has expired.
    }

    /// @notice Enum representing the events associated with car replicas.
    enum Event {
        MatchingFailed, // Matching for a replica has been failed
        MatchingCompleted, // Matching for a replica has been completed
        StorageCompleted, // Storage for a replica has been completed
        StorageFailed, // Storage for a replica has failed
        StorageDealExpired, // Storage for a replica has expired
        StorageSlashed // Storage for a replica has been slashed
    }

    /// @notice Struct representing a car replica.
    struct Replica {
        uint64 matchingId; // The matchingId associated with the replica.
        uint64 filecoinClaimId; // ID of the Filecoin claim associated with the replica's storage
        State state; // Current state of the replica
    }

    /// @notice Struct representing a car and its associated replicas.
    struct Car {
        uint64 id; // The id associated with the car.
        uint64 datasetId; // Index of approved dataset
        uint64 size; //car size
        mapping(uint64 => uint16) replicaIndex; // Mapping from matchingId => Replica index
        Replica[] replicas; // replicas associated with the car.
    }
}
