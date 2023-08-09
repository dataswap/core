// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity ^0.8.21;

import "../../../types/CarReplicaType.sol";
import "./CarReplicaLIB.sol";

library CarLIB {
    using CarReplicaLIB for CarReplicaType.Replica;

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

        //Adding a replica indicates that the matching has been completed.
        postRepicaEventByMatchingId(
            self,
            _matchingId,
            CarReplicaType.Event.MatchingCompleted
        );
    }

    function getRepicasCount(
        CarReplicaType.Car storage self
    ) internal view returns (uint256) {
        return self.replicasCount;
    }

    function hasReplica(
        CarReplicaType.Car storage self,
        uint256 _matchingId
    ) internal view returns (bool, uint256) {
        if (self.replicasCount == 0) return (false, 0);
        for (uint256 i = 1; i <= self.replicasCount; i++) {
            if (self.replicas[i].matchingId == _matchingId) return (true, i);
        }
        return (false, 0);
    }

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

        //Set a replica filecoin deal id indicates that the storage has been completed.
        postRepicaEventByMatchingId(
            self,
            _matchingId,
            CarReplicaType.Event.StorageCompleted
        );
    }

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