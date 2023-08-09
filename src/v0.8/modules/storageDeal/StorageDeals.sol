// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity ^0.8.21;

import "./abstract/StorageDealsBase.sol";

contract StorageDeals is StorageDealsBase {
    constructor(
        address _rolesContract,
        address _carsStorageContract,
        address _datasetsContract,
        address _matchingContract
    )
        StorageDealsBase(
            _rolesContract,
            _carsStorageContract,
            _datasetsContract,
            _matchingContract
        )
    {}
}
