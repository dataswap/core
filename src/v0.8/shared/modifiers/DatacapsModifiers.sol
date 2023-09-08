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
import {IRoles} from "src/v0.8/interfaces/core/IRoles.sol";
import {IFilplus} from "src/v0.8/interfaces/core/IFilplus.sol";
import {IFilecoin} from "src/v0.8/interfaces/core/IFilecoin.sol";
import {ICarstore} from "src/v0.8/interfaces/core/ICarstore.sol";
import {IMatchings} from "src/v0.8/interfaces/module/IMatchings.sol";
import {IStorages} from "src/v0.8/interfaces/module/IStorages.sol";
import {IDatacaps} from "src/v0.8/interfaces/module/IDatacaps.sol";
///shared
import {StoragesModifiers} from "src/v0.8/shared/modifiers/StoragesModifiers.sol";
import {Errors} from "src/v0.8/shared/errors/Errors.sol";

import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

/// @title storages
/// @dev Manages the storage of matched data after successful matching with Filecoin storage deals.
contract DatacapsModifiers is Initializable, StoragesModifiers {
    IRoles private roles;
    IFilplus private filplus;
    IFilecoin private filecoin;
    ICarstore private carstore;
    IMatchings private matchings;
    IStorages private storages;
    IDatacaps private datacaps;

    function datacapsModifiersInitialize(
        address _roles,
        address _filplus,
        address _filecoin,
        address _carstore,
        address _matchings,
        address _storages,
        address _datacaps
    ) public onlyInitializing {
        StoragesModifiers.storagesModifiersInitialize(
            _roles,
            _filplus,
            _filecoin,
            _carstore,
            _matchings,
            _storages
        );
        roles = IRoles(_roles);
        filplus = IFilplus(_filplus);
        carstore = ICarstore(_carstore);
        matchings = IMatchings(_matchings);
        datacaps = IDatacaps(_datacaps);
    }

    /// @notice  validNextDatacapAllocation
    modifier validNextDatacapAllocation(uint64 _matchingId) {
        if (!datacaps.isNextDatacapAllocationValid(_matchingId)) {
            revert Errors.NextDatacapAllocationInvalid(_matchingId);
        }
        _;
    }
}
