// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity ^0.8.21;
import "./abstract/MatchingsBase.sol";

contract Matchings is MatchingsBase {
    constructor(
        address _rolesContract,
        address _carsStorageContract,
        address _datasetsContract
    ) MatchingsBase(_rolesContract, _carsStorageContract, _datasetsContract) {}

    function filPlusCheck(
        uint256 /*_matchingId*/
    ) internal pure override returns (bool) {
        return true;
    }
}
