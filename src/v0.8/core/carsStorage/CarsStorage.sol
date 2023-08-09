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

import "./abstract/CarsStorageBase.sol";

/// @title CarsStorage
/// @notice This contract extends the CarsStorageBase contract to provide a concrete implementation of car and replica management.
/// @dev This contract inherits the functionality of CarsStorageBase and can be used to manage car data and associated replicas.
contract CarsStorage is CarsStorageBase {
    /// @notice Constructor function to create an instance of the CarsStorage contract.
    constructor() CarsStorageBase() {}
}
