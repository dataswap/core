/*******************************************************************************
 *   (c) 2023 DataSwap
 *
 *  Licensed under the GNU General Public License, Version 3.0 or later (the "License");
 *  you may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at
 *
 *      https://www.gnu.org/licenses/gpl-3.0.en.html
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 ********************************************************************************/

// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity ^0.8.21;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {Ownable2Step} from "@openzeppelin/contracts/access/Ownable2Step.sol";
import {AccessControlEnumerable} from "@openzeppelin/contracts/access/AccessControlEnumerable.sol";
import {IRoles} from "../../interfaces/core/IRoles.sol";

/// @title Role Contract
/// @notice This contract defines the role-based access control for various roles within the system.
contract Roles is IRoles, Ownable, Ownable2Step, AccessControlEnumerable {
    /// @notice Constructor function to initialize the contract and grant the default admin role to the deployer.
    // solhint-disable-next-line
    constructor() {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    ///@dev The new owner accepts the ownership transfer.
    function acceptOwnership() public override(IRoles, Ownable2Step) {
        return super.acceptOwnership();
    }

    function checkRole(bytes32 _role) public view {
        return super._checkRole(_role);
    }

    ///@dev Returns the address of the current owner.
    function owner() public view override(IRoles, Ownable) returns (address) {
        return super.owner();
    }

    ///@dev Returns the address of the pending owner.
    function pendingOwner()
        public
        view
        override(IRoles, Ownable2Step)
        returns (address)
    {
        return super.pendingOwner();
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby disabling any functionality that is only available to the owner.
     */
    function renounceOwnership() public override(IRoles, Ownable) {
        super.renounceOwnership();
    }

    /**
     * @dev Starts the ownership transfer of the contract to a new account. Replaces the pending transfer if there is one.
     * Can only be called by the current owner.
     */
    function transferOwnership(
        address _newOwner
    ) public override(IRoles, Ownable, Ownable2Step) {
        super.transferOwnership(_newOwner);
    }

    function _transferOwnership(
        address _newOwner
    ) internal override(Ownable, Ownable2Step) {
        super._transferOwnership(_newOwner);
    }
}
