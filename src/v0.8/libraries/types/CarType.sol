// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity ^0.8.21;

library CarType {
    enum State {
        Notverified,
        WaitingForDealMatching,
        DealMatched,
        Stored
    }

    struct Replica {
        uint256 id;
        uint256 matchingId;
        State state;
        uint256 dealId;
    }

    struct Car {
        uint256 id;
        uint256 replicaCount;
        // replica number => CarReplica
        mapping(uint256 => Replica) storageInfo;
    }
}
