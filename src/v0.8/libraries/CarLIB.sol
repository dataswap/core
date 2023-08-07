// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity ^0.8.21;

import "./types/CarReplicaType.sol";
import "./CarReplicaLIB.sol";

library CarLIB {
    using CarReplicaLIB for CarReplicaType.Replica;

    function submitRepica(
        CarReplicaType.Car memory self,
        uint256 _matchingId,
        uint256 _storageDealId,
        uint256 _filecoinDealId
    ) external pure {
        CarReplicaType.Replica memory replica = CarReplicaLIB.create(
            _matchingId,
            _storageDealId,
            _filecoinDealId
        );
        CarReplicaType.Replica[]
            memory newReplicas = new CarReplicaType.Replica[](
                self.replicas.length + 1
            );
        for (uint256 i = 0; i < self.replicas.length; i++) {
            newReplicas[i] = self.replicas[i];
        }
        newReplicas[self.replicas.length] = replica;

        self.replicas = newReplicas;
    }

    function updateRepicaState(
        CarReplicaType.Car memory self,
        uint256 _repicaId,
        CarReplicaType.Event _event
    ) internal pure {
        CarReplicaType.Replica memory replica = self.replicas[_repicaId];
        replica.updateState(_event);
    }
}
