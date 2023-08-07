// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity ^0.8.21;

import "../libraries/CarLIB.sol";
import "../libraries/CarReplicaLIB.sol";
import "../libraries/StorageDealLIB.sol";
import "../libraries/StorageDealLIB.sol";
import "../libraries/types/StorageDealType.sol";
import "../libraries/types/CarReplicaType.sol";
import "../libraries/utils/ArrayUtils.sol";

abstract contract IStorageDeals {
    uint256 private storageDealsCount;
    mapping(uint256 => StorageDealType.StorageDeal) storageDeals;
    //TODO:delete
    CarReplicaType.Car[] cars;

    using StorageDealLIB for StorageDealType.StorageDeal;
    using ArrayUtil for bytes32[];
    using CarLIB for CarReplicaType.Car;
    using CarReplicaLIB for CarReplicaType.Replica;

    //TODO:require matching contract
    function submitMatchingCompletedEvent(uint256 _matchingId) external {
        storageDealsCount++;
        StorageDealType.StorageDeal storage storageDeal = storageDeals[
            storageDealsCount
        ];
        storageDeal.matchingId = _matchingId;
        storageDeal.submitMatchingCompletedEvent();
    }

    function reportSubmitPreviousDataCapProofExpired(
        uint256 storageDealId
    ) external {
        StorageDealType.StorageDeal storage storageDeal = storageDeals[
            storageDealId
        ];
        storageDeal.reportSubmitPreviousDataCapProofExpired();
    }

    function submitPreviousDataCapProof(
        uint256 storageDealId,
        bytes32[] memory _carCids,
        uint256[] memory /*_filecoinDealIds*/
    ) external {
        StorageDealType.StorageDeal storage storageDeal = storageDeals[
            storageDealId
        ];

        //TODO
        for (uint256 i; i < _carCids.length; i++) {
            // storageDeal.carCount++;
            // CarReplicaType.Replica memory replica = CarReplicaType.Replica(
            //     storageDeal.matchingId,
            //     storageDealId,
            //     _filecoinDealIds[i],
            //     CarReplicaType.State.Notverified
            // );
            // CarReplicaType.Replica[1] memory replicas = [replica];
            // storageDeal.cars[storageDeal.carCount] = CarReplicaType.Car(
            //     _carCids[i],
            // );
            // cars.push(CarReplicaType.Car(_carCids[i], []));
        }

        // bytes32[] storage cids = storageDeal.proof.cids;
        // bytes32[] storage filecoinDealIds = storageDeal.proof.filecoinDealIds;
        // cids.appendArrayBytes32(_proof.cids);
        // filecoinDealIds.appendArrayBytes32(_proof.filecoinDealIds);

        storageDeal.submitPreviousDataCapProof(cars);
    }

    function getState(
        uint256 storageDealId
    ) public view returns (StorageDealType.State) {
        StorageDealType.StorageDeal storage storageDeal = storageDeals[
            storageDealId
        ];
        return storageDeal.getState();
    }
}
