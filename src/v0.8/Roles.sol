// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity ^0.8.21;

import "@openzeppelin/contracts/access/Ownable2Step.sol";
import "@openzeppelin/contracts/access/AccessControlEnumerable.sol";
import "./interfaces/IRole.sol";

contract Role is Ownable2Step, AccessControlEnumerable, IRole {
    constructor(address admin) {
        _grantRole(DEFAULT_ADMIN_ROLE, admin);
    }
}
