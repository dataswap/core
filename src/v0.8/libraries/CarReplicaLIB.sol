// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity ^0.8.21;

import "./types/CarReplicaType.sol";

library CarReplicaLIB {
    function setMatchingId(
        CarReplicaType.Replica storage self,
        uint256 _matchingId
    ) internal {
        require(_matchingId != 0 && self.matchingId != _matchingId);
        self.matchingId = _matchingId;
    }

    function setStorageDealId(
        CarReplicaType.Replica storage self,
        uint256 _storageDealId
    ) internal {
        require(_storageDealId != 0 && self.storageDealId != _storageDealId);
        self.storageDealId = _storageDealId;
    }

    function setFilecoinDealId(
        CarReplicaType.Replica storage self,
        uint256 _filecoinDealId
    ) internal {
        require(_filecoinDealId != 0 && self.filecoinDealId != _filecoinDealId);
        self.filecoinDealId = _filecoinDealId;
    }

    function updateState(
        CarReplicaType.Replica storage self,
        CarReplicaType.Event _event
    ) internal {
        CarReplicaType.State currentState = self.state;
        CarReplicaType.State newState;

        // Apply the state transition based on the event
        if (_event == CarReplicaType.Event.MatchingCompleted) {
            if (currentState == CarReplicaType.State.None) {
                newState = CarReplicaType.State.Matched;
            }
        } else if (_event == CarReplicaType.Event.StorageCompleted) {
            if (currentState == CarReplicaType.State.Matched) {
                newState = CarReplicaType.State.Stored;
            }
        } else if (_event == CarReplicaType.Event.StorageFailed) {
            if (currentState == CarReplicaType.State.Matched) {
                newState = CarReplicaType.State.None;
            }
        } else if (_event == CarReplicaType.Event.StorageDealExpired) {
            if (currentState == CarReplicaType.State.Stored) {
                newState = CarReplicaType.State.None;
            }
        } else if (_event == CarReplicaType.Event.StorageSlashed) {
            if (currentState == CarReplicaType.State.Stored) {
                newState = CarReplicaType.State.None;
            }
        }

        // Update the state if newState is not None (i.e., a valid transition)
        if (newState != CarReplicaType.State.None) {
            self.state = newState;
        }
    }
}
