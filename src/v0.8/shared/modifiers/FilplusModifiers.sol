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

///interface
import {IFilplus} from "src/v0.8/interfaces/core/IFilplus.sol";
///shared
import {CommonModifiers} from "src/v0.8/shared/modifiers/CommonModifiers.sol";

import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

/// @title storages
/// @dev Manages the storage of matched data after successful matching with Filecoin storage deals.
contract FilplusModifiers is Initializable, CommonModifiers {
    IFilplus private filplus;

    /// @notice filplusModifiersInitialize function to initialize the contract and grant the default admin role to the deployer.
    function filplusModifiersInitialize(address _filplus) public onlyInitializing {
        filplus = IFilplus(_filplus);
    }
}
