/*******************************************************************************
 *   (c) 2023 Dataswap
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

import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

import {UUPSUpgradeable} from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import {OwnableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import {Ownable2StepUpgradeable} from "@openzeppelin/contracts-upgradeable/access/Ownable2StepUpgradeable.sol";
import {AccessControlEnumerableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/AccessControlEnumerableUpgradeable.sol";
import {RolesType} from "src/v0.8/types/RolesType.sol";
import {IRoles} from "src/v0.8/interfaces/core/IRoles.sol";

/// @title Role Contract
/// @notice This contract defines the role-based access control for various roles within the system.
contract Roles is
    Initializable,
    IRoles,
    UUPSUpgradeable,
    OwnableUpgradeable,
    Ownable2StepUpgradeable,
    AccessControlEnumerableUpgradeable
{
    /// @notice initialize function to initialize the contract and grant the default admin role to the deployer.
    function initialize() public initializer {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        __Ownable_init();
        __UUPSUpgradeable_init();
    }

    /// @notice UUPS Upgradeable function to update the roles implementation
    /// @dev Only triggered by contract admin
    function _authorizeUpgrade(
        address newImplementation
    )
        internal
        override
        onlyOwner // solhint-disable-next-line
    {}

    /// @notice Returns the implementation contract
    function getImplementation() external view returns (address) {
        return _getImplementation();
    }

    /// @notice grantDataswapContractRole function to grant the dataswap contract role for dataswap contract. TODO: Move to governance
    /// @dev After all the dataswap contracts are deployed, this function needs to be called manually!
    function grantDataswapContractRole(
        address[] calldata _contracts
    ) public onlyOwner {
        for (uint256 i = 0; i < _contracts.length; i++) {
            _grantRole(RolesType.DATASWAP_CONTRACT, _contracts[i]);
        }
    }

    ///@dev The new owner accepts the ownership transfer.
    function acceptOwnership()
        public
        override(IRoles, Ownable2StepUpgradeable)
    {
        return super.acceptOwnership();
    }

    ///@dev check msg.sender is admin role.
    function checkRole(bytes32 _role) public view {
        return super._checkRole(_role);
    }

    ///@dev Returns the address of the current owner.
    function owner()
        public
        view
        override(IRoles, OwnableUpgradeable)
        returns (address)
    {
        return super.owner();
    }

    ///@dev Returns the address of the pending owner.
    function pendingOwner()
        public
        view
        override(IRoles, Ownable2StepUpgradeable)
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
    function renounceOwnership() public override(IRoles, OwnableUpgradeable) {
        super.renounceOwnership();
    }

    /**
     * @dev Starts the ownership transfer of the contract to a new account. Replaces the pending transfer if there is one.
     * Can only be called by the current owner.
     */
    function transferOwnership(
        address _newOwner
    ) public override(IRoles, OwnableUpgradeable, Ownable2StepUpgradeable) {
        super.transferOwnership(_newOwner);
    }

    /// @dev start the ownership transfer
    function _transferOwnership(
        address _newOwner
    ) internal override(OwnableUpgradeable, Ownable2StepUpgradeable) {
        super._transferOwnership(_newOwner);
    }
}
