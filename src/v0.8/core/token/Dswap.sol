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

import {IRoles} from "src/v0.8/interfaces/core/IRoles.sol";

import {RolesType} from "src/v0.8/types/RolesType.sol";
import {RolesModifiers} from "src/v0.8/shared/modifiers/RolesModifiers.sol";
import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {UUPSUpgradeable} from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import {ERC20Upgradeable} from "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import {ERC20PermitUpgradeable} from "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20PermitUpgradeable.sol";
import {ERC20VotesUpgradeable} from "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20VotesUpgradeable.sol";
import {Ownable2StepUpgradeable} from "@openzeppelin/contracts-upgradeable/access/Ownable2StepUpgradeable.sol";

/// @title DataswapBase Contract
/// @notice This contract serves as the base for the DataSwap token (DSWAP).
/// @dev This contract inherits from ERC20Upgradeable, ERC20PermitUpgradeable, ERC20VotesUpgradeable, and Ownable2StepUpgradeable contracts.
contract Dswap is
    Initializable,
    UUPSUpgradeable,
    ERC20Upgradeable,
    ERC20PermitUpgradeable,
    ERC20VotesUpgradeable,
    Ownable2StepUpgradeable,
    RolesModifiers
{
    IRoles private roles;

    /// @notice initialize function to initialize the contract and grant the default admin role to the deployer.
    function initialize(address _roles) public virtual onlyInitializing {
        ERC20Upgradeable.__ERC20_init("DataSwap", "DSWAP");
        ERC20PermitUpgradeable.__ERC20Permit_init("DSWAP");
        roles = IRoles(_roles);
        __UUPSUpgradeable_init();
    }

    /// @notice UUPS Upgradeable function to update the roles implementation
    /// @dev Only triggered by contract admin
    function _authorizeUpgrade(
        address newImplementation
    )
        internal
        override
        onlyRole(roles, RolesType.DEFAULT_ADMIN_ROLE) // solhint-disable-next-line
    {}

    /// @notice Returns the implementation contract
    function getImplementation() external view returns (address) {
        return _getImplementation();
    }

    /// @dev Overrides the _afterTokenTransfer function from ERC20VotesUpgradeable and ERC20Upgradeable.
    /// @param _from The address transferring tokens.
    /// @param _to The address receiving tokens.
    /// @param _amount The amount of tokens being transferred.
    function _afterTokenTransfer(
        address _from,
        address _to,
        uint256 _amount
    ) internal override(ERC20Upgradeable, ERC20VotesUpgradeable) {
        super._afterTokenTransfer(_from, _to, _amount);
    }

    /// @dev Overrides the _mint function from ERC20VotesUpgradeable and ERC20Upgradeable.
    /// @param _to The address receiving the minted tokens.
    /// @param _amount The amount of tokens being minted.
    function _mint(
        address _to,
        uint256 _amount
    ) internal override(ERC20Upgradeable, ERC20VotesUpgradeable) {
        super._mint(_to, _amount);
    }

    /// @dev Overrides the _burn function from ERC20VotesUpgradeable and ERC20Upgradeable.
    /// @param _account The address from which tokens are burned.
    /// @param _amount The amount of tokens being burned.
    function _burn(
        address _account,
        uint256 _amount
    ) internal override(ERC20Upgradeable, ERC20VotesUpgradeable) {
        super._burn(_account, _amount);
    }
}
