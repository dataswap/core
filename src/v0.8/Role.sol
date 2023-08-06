// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity ^0.8.21;

import "@openzeppelin/contracts/access/AccessControlEnumerable.sol";
import "./libraries/types/RoleType.sol";

contract Roles is AccessControlEnumerable {
    constructor(address admin) {
        _grantRole(DEFAULT_ADMIN_ROLE, admin);
    }
}
