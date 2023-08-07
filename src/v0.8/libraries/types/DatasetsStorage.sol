// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity ^0.8.21;

import "./CarType.sol";

struct DatasetsStorage {
    //dataset ID => (car id = > Car info)
    mapping(uint256 => mapping(uint256 => CarType.Car)) datasetsStorage;
}
