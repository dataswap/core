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

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Votes.sol";
import "@openzeppelin/contracts/access/Ownable2Step.sol";

/// @title DataswapBase Contract
/// @notice This contract serves as the base for the DataSwap token (DSWAP).
/// @dev This contract inherits from ERC20, ERC20Permit, ERC20Votes, and Ownable2Step contracts.
abstract contract Dswap is ERC20, ERC20Permit, ERC20Votes, Ownable2Step {
    constructor() ERC20("DataSwap", "DSWAP") ERC20Permit("DSWAP") {}

    /// @dev Overrides the _afterTokenTransfer function from ERC20Votes and ERC20.
    /// @param _from The address transferring tokens.
    /// @param _to The address receiving tokens.
    /// @param _amount The amount of tokens being transferred.
    function _afterTokenTransfer(
        address _from,
        address _to,
        uint256 _amount
    ) internal override(ERC20, ERC20Votes) {
        super._afterTokenTransfer(_from, _to, _amount);
    }

    /// @dev Overrides the _mint function from ERC20Votes and ERC20.
    /// @param _to The address receiving the minted tokens.
    /// @param _amount The amount of tokens being minted.
    function _mint(
        address _to,
        uint256 _amount
    ) internal override(ERC20, ERC20Votes) {
        super._mint(_to, _amount);
    }

    /// @dev Overrides the _burn function from ERC20Votes and ERC20.
    /// @param _account The address from which tokens are burned.
    /// @param _amount The amount of tokens being burned.
    function _burn(
        address _account,
        uint256 _amount
    ) internal override(ERC20, ERC20Votes) {
        super._burn(_account, _amount);
    }
}
