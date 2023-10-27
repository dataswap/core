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
import {IDatacaps} from "src/v0.8/interfaces/module/IDatacaps.sol";
///shared
import {StoragesModifiers} from "src/v0.8/shared/modifiers/StoragesModifiers.sol";
import {Errors} from "src/v0.8/shared/errors/Errors.sol";

/// @title storages
/// @dev Manages the storage of matched data after successful matching with Filecoin storage deals.
contract DatacapsModifiers is StoragesModifiers {
    /// @notice  validNextDatacapAllocation
    modifier validNextDatacapAllocation(
        IDatacaps _datacaps,
        uint64 _matchingId
    ) {
        if (!_datacaps.isNextDatacapAllocationValid(_matchingId)) {
            revert Errors.NextDatacapAllocationInvalid(_matchingId);
        }
        _;
    }
}
