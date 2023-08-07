// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity ^0.8.21;

library CarReplicaType {
    enum State {
        Notverified,
        WaitingForDealMatching,
        DealMatched,
        Stored
    }

    enum Event {
        DatasetAppoved, //Condition_DatasetAppoved
        MatchingCompleted, //Condition_AuctionOrTenderCompleted
        StorageCompleted, //Condition_StorageCompleted
        StorageFailed, //Condition_StorageFailed
        RenewalDeal,
        StorageDealExpired, //Condition_StorageDealExpired_Or_Slashed,
        StorageSlashed //Condition_StorageDealExpired_Or_Slashed
    }

    struct Replica {
        uint256 matchingId;
        uint256 storageDealId;
        uint256 filecoinDealId;
        State state;
    }

    struct Car {
        bytes32 cid;
        Replica[] replicas;
    }
}
