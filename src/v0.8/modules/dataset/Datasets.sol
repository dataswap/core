// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity ^0.8.21;

import "./abstract/DatasetsBase.sol";

contract Datasets is DatasetsBase {
    constructor(
        address payable _governanceContract,
        address _rolesContract,
        address _carsStorageContract
    ) DatasetsBase(_governanceContract, _rolesContract, _carsStorageContract) {}
}
