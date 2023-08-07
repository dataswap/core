// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity ^0.8.21;

import "./types/CarReplicaType.sol";

library CarReplicaLIB {
    function create(
        uint256 _matchingId,
        uint256 _storageDealId,
        uint256 _filecoinDealId
    ) internal pure returns (CarReplicaType.Replica memory) {
        return
            CarReplicaType.Replica(
                _matchingId,
                _storageDealId,
                _filecoinDealId,
                CarReplicaType.State.Notverified
            );
    }

    function updateState(
        CarReplicaType.Replica memory self,
        CarReplicaType.Event _event
    ) internal pure {
        CarReplicaType.State currentState = self.state;
        CarReplicaType.State newState;

        // Apply the state transition based on the event
        if (_event == CarReplicaType.Event.DatasetAppoved) {
            if (currentState == CarReplicaType.State.Notverified) {
                newState = CarReplicaType.State.WaitingForDealMatching;
            }
        } else if (_event == CarReplicaType.Event.MatchingCompleted) {
            if (currentState == CarReplicaType.State.WaitingForDealMatching) {
                newState = CarReplicaType.State.DealMatched;
            }
        } else if (_event == CarReplicaType.Event.StorageCompleted) {
            if (currentState == CarReplicaType.State.DealMatched) {
                newState = CarReplicaType.State.Stored;
            }
        } else if (_event == CarReplicaType.Event.StorageFailed) {
            if (currentState == CarReplicaType.State.DealMatched) {
                newState = CarReplicaType.State.WaitingForDealMatching;
            }
        } else if (_event == CarReplicaType.Event.StorageDealExpired) {
            if (currentState == CarReplicaType.State.Stored) {
                newState = CarReplicaType.State.WaitingForDealMatching;
            }
        } else if (_event == CarReplicaType.Event.StorageSlashed) {
            if (currentState == CarReplicaType.State.Stored) {
                newState = CarReplicaType.State.WaitingForDealMatching;
            }
        } else if (_event == CarReplicaType.Event.RenewalDeal) {
            if (currentState == CarReplicaType.State.Stored) {
                newState = CarReplicaType.State.Stored;
            }
        }

        // Update the state if newState is not Notverified (i.e., a valid transition)
        if (newState != CarReplicaType.State.Notverified) {
            self.state = newState;
        }
    }
}
