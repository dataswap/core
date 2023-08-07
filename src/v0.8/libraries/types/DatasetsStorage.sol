// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity ^0.8.21;

import "./CarReplicaType.sol";

struct DatasetsStorage {
    //dataset ID => (car id = > Car info)
    mapping(uint256 => mapping(uint256 => CarReplicaType.Car)) datasetsStorage;
}
