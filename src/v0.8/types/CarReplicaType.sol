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

/// @title CarReplicaType Library
/// @author waynewyang
/// @notice This library defines data structures and enums related to car replicas and their states.
/// @dev This library provides enums for different states and events related to car replicas.
library CarReplicaType {
    /// @notice Enum representing the possible states of a Filecoin storage deal.
    enum FilecoinDealState {
        VerificationSuccessed, // The filecoin deal's verification was successful.
        VerificationFailed, // The filecoin deal's verification failed.
        Slashed, // The filecoin deal has been slashed.
        Expired // The filecoin deal has expired.
    }

    /// @notice Enum representing the possible states of a car replica.
    /// @dev TODO: conside delete State and Event
    enum State {
        None, //justify if Replica exsits
        Matched, // Replica has been matched for storage
        Stored // Replica has been successfully stored
    }

    /// @notice Enum representing the events associated with car replicas.
    enum Event {
        MatchingCompleted, // Matching for a replica has been completed
        StorageCompleted, // Storage for a replica has been completed
        StorageFailed, // Storage for a replica has failed
        StorageDealExpired, // Storage deal for a replica has expired
        StorageSlashed // Storage for a replica has been slashed
    }

    /// @notice Struct representing a car replica.
    struct Replica {
        uint256 filecoinDealId; // ID of the Filecoin deal associated with the replica's storage
        State state; // Current state of the replica TODO:replcace with filecoin deal state
    }

    /// @notice Struct representing a car and its associated replicas.
    struct Car {
        uint256 datasetId; // Index of approved dataset
        uint256 replicasCount; // Number of replicas associated with the car
        mapping(uint256 => Replica) replicas; // Mapping from matchingId => Replica details
    }
}
