// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity ^0.8.21;

import "../libraries/types/CarReplicaType.sol";
import "../libraries/CarReplicaLIB.sol";
import "../libraries/CarLIB.sol";

abstract contract ICarsStorage {
    uint256 public carsCount;
    //car cid => Car
    mapping(bytes32 => CarReplicaType.Car) public cars;

    // using CarReplicaLIB for CarReplicaType.Replica;
    using CarLIB for CarReplicaType.Car;

    modifier onlyCarExists(bytes32 _cid) {
        require(hasCar(_cid), "Car is not exists");
        _;
    }

    modifier onlyCarNotExists(bytes32 _cid) {
        require(!hasCar(_cid), "Car already exists");
        _;
    }

    function addCars(bytes32[] memory _cids) external {
        for (uint256 i; i < _cids.length; i++) {
            addCar(_cids[i]);
        }
    }

    function addCar(bytes32 _cid) internal onlyCarNotExists(_cid) {
        carsCount++;
        cars[_cid].cid = _cid;
    }

    function addReplica(
        bytes32 _cid,
        uint256 _matchingId
    ) external onlyCarExists(_cid) {
        require(_matchingId != 0, "Invalid matching id for addReplica");
        CarReplicaType.Car storage car = cars[_cid];
        car.addRepica(_matchingId);
    }

    function setReplicaFilecoinDealId(
        bytes32 _cid,
        uint256 _matchingId,
        uint256 _filecoinDealId
    ) external onlyCarExists(_cid) {
        CarReplicaType.Car storage car = cars[_cid];
        require(
            _matchingId != 0 && _filecoinDealId != 0,
            "Invalid matching id or filecoin deal id for setReplicaFilecoinDealId"
        );
        car.setFilecoinDealId(_matchingId, _filecoinDealId);
    }

    function getRepicasCount(
        bytes32 _cid
    ) public view onlyCarExists(_cid) returns (uint256) {
        CarReplicaType.Car storage car = cars[_cid];
        return car.getRepicasCount();
    }

    function hasCar(bytes32 _cid) public view returns (bool) {
        return cars[_cid].cid == _cid;
    }

    function hasCars(bytes32[] memory _cids) public view returns (bool) {
        for (uint256 i; i < _cids.length; i++) {
            if (!hasCar(_cids[i])) return false;
        }
        return true;
    }

    function hasReplica(
        bytes32 _cid,
        uint256 _matchingId
    ) public view onlyCarExists(_cid) returns (bool, uint256) {
        require(_matchingId != 0, "Invalid matching id for addReplica");
        CarReplicaType.Car storage car = cars[_cid];
        return car.hasReplica(_matchingId);
    }

    function reportReplicaStorageFailed(
        bytes32 _cid,
        uint256 _matchingId
    ) external onlyCarExists(_cid) {
        require(
            _matchingId != 0,
            "Invalid matching id for reportReplicaStorageFailed"
        );
        postRepicaEventByMatchingId(
            _cid,
            _matchingId,
            CarReplicaType.Event.StorageFailed
        );
    }

    function reportReplicaStorageDealExpired(
        bytes32 _cid,
        uint256 _matchingId
    ) external onlyCarExists(_cid) {
        require(
            _matchingId != 0,
            "Invalid matching id for reportReplicaStorageDealExpired"
        );
        postRepicaEventByMatchingId(
            _cid,
            _matchingId,
            CarReplicaType.Event.StorageDealExpired
        );
    }

    function reportReplicaStorageSlashed(
        bytes32 _cid,
        uint256 _matchingId
    ) external onlyCarExists(_cid) {
        require(
            _matchingId != 0,
            "Invalid matching id for reportReplicaStorageSlashed"
        );
        postRepicaEventByMatchingId(
            _cid,
            _matchingId,
            CarReplicaType.Event.StorageSlashed
        );
    }

    function postRepicaEventReplicaIndex(
        bytes32 _cid,
        uint256 _replicaIndex,
        CarReplicaType.Event _event
    ) internal onlyCarExists(_cid) {
        CarReplicaType.Car storage car = cars[_cid];
        require(
            _replicaIndex < car.replicasCount,
            "Invalid replica id for updateRepicaStateByIndex"
        );
        car.postRepicaEventReplicaIndex(_replicaIndex, _event);
    }

    function postRepicaEventByMatchingId(
        bytes32 _cid,
        uint256 _matchingId,
        CarReplicaType.Event _event
    ) internal onlyCarExists(_cid) {
        require(
            _matchingId != 0,
            "Invalid matching id for updateRepicaStateByMatchingId"
        );
        CarReplicaType.Car storage car = cars[_cid];
        car.postRepicaEventByMatchingId(_matchingId, _event);
    }
}
