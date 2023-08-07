// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity ^0.8.21;

import "../libraries/StorageDealLIB.sol";
import "../libraries/types/StorageDealType.sol";
import "../libraries/types/CarReplicaType.sol";

struct IDatasetsStorage {
    //dataset ID => (car id = > Car info)
    mapping(uint256 => mapping(uint256 => CarReplicaType.Car)) datasetsStorage;
}
