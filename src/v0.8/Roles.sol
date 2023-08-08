// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity ^0.8.21;

import "@openzeppelin/contracts/access/Ownable2Step.sol";
import "@openzeppelin/contracts/access/AccessControlEnumerable.sol";
import "./interfaces/IRoles.sol";

contract Role is Ownable2Step, AccessControlEnumerable, IRoles {
    constructor() {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }
}
