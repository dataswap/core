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
import "./abstract/MatchingsBase.sol";

/// @title Matchings Contract
/// @notice This contract provides functionality for managing matchings, their states, and associated actions.
/// @dev This contract inherits from MatchingsBase and implements the filPlusCheck function.
contract Matchings is MatchingsBase {
    /// @notice Contract constructor.
    /// @dev Initializes the contract with the provided addresses for roles, cars storage, and datasets contracts.
    /// @param _rolesContract The address of the roles contract.
    /// @param _carsStorageContract The address of the cars storage contract.
    /// @param _datasetsContract The address of the datasets contract.
    constructor(
        address _rolesContract,
        address _carsStorageContract,
        address _datasetsContract
    ) MatchingsBase(_rolesContract, _carsStorageContract, _datasetsContract) {}

    /// @dev .TODO
    function filPlusCheck(
        uint256 /*_matchingId*/
    ) internal pure override returns (bool) {
        return true;
    }
}
