// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity ^0.8.21;

library CarReplicaType {
    enum State {
        None,
        Matched,
        Stored
    }

    enum Event {
        //Adding a replica indicates that the matching has been completed.
        MatchingCompleted,
        //Set a replica filecoin deal id indicates that the storage has been completed.
        StorageCompleted,
        StorageFailed,
        StorageDealExpired,
        StorageSlashed
    }

    struct Replica {
        uint256 matchingId;
        uint256 filecoinDealId;
        State state;
    }

    struct Car {
        bytes32 cid;
        uint256 replicasCount;
        mapping(uint256 => Replica) replicas;
    }
}
