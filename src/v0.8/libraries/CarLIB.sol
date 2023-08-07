// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity ^0.8.21;

import "./types/CarReplicaType.sol";
import "./CarReplicaLIB.sol";

library CarLIB {
    using CarReplicaLIB for CarReplicaType.Replica;

    function submitRepica(
        CarReplicaType.Car storage self,
        uint256 _matchingId,
        uint256 _storageDealId
    ) external {
        self.replicaCount++;
        CarReplicaType.Replica storage newReplica = self.replicas[
            self.replicaCount
        ];
        newReplica.id = self.replicaCount;
        newReplica.matchingId = _matchingId;
        newReplica.storageDealId = _storageDealId;
        newReplica.state = CarReplicaType.State.Notverified;
    }

    function updateRepicaState(
        CarReplicaType.Car storage self,
        uint256 _repicaId,
        CarReplicaType.Event _event
    ) internal {
        CarReplicaType.Replica storage replica = self.replicas[_repicaId];
        replica.updateState(_event);
    }
}
