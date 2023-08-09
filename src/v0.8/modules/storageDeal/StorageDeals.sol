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

import "./abstract/StorageDealsBase.sol";

/// @title StorageDeals Contract
/// @notice This contract manages storage deals, their states, and associated actions.
/// @dev This contract inherits from `StorageDealsBase` and is the main contract to interact with.
contract StorageDeals is StorageDealsBase {
    /// @notice Constructor function to initialize the contract.
    /// @param _rolesContract Address of the roles contract used for access control.
    /// @param _carsStorageContract Address of the contract managing car storage.
    /// @param _datasetsContract Address of the contract managing datasets.
    /// @param _matchingContract Address of the matching contract.
    constructor(
        address _rolesContract,
        address _carsStorageContract,
        address _datasetsContract,
        address _matchingContract
    )
        StorageDealsBase(
            _rolesContract,
            _carsStorageContract,
            _datasetsContract,
            _matchingContract
        )
    {}
}
