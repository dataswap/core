/// SPDX-License-Identifier: GPL-3.0-or-later
/// (c) 2023 DataSwap
///
/// Licensed under the GNU General Public License, Version 3.0 or later (the "License");
/// you may not use this file except in compliance with the License.
/// You may obtain a copy of the License at
///     https://www.gnu.org/licenses/gpl-3.0.en.html
///
/// Unless required by applicable law or agreed to in writing, software
/// distributed under the License is distributed on an "AS IS" BASIS,
/// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
/// See the License for the specific language governing permissions and
/// limitations under the License.

pragma solidity ^0.8.21;

///interface
import {IRoles} from "src/v0.8/interfaces/core/IRoles.sol";
import {IFilplus} from "src/v0.8/interfaces/core/IFilplus.sol";
import {IFilecoin} from "src/v0.8/interfaces/core/IFilecoin.sol";
import {ICarstore} from "src/v0.8/interfaces/core/ICarstore.sol";
import {IDatasets} from "src/v0.8/interfaces/module/IDatasets.sol";
import {IMatchings} from "src/v0.8/interfaces/module/IMatchings.sol";
import {IStorages} from "src/v0.8/interfaces/module/IStorages.sol";
import {IDatacaps} from "src/v0.8/interfaces/module/IDatacaps.sol";
///shared
import {StoragesModifiers} from "src/v0.8/shared/modifiers/StoragesModifiers.sol";
import {Errors} from "src/v0.8/shared/errors/Errors.sol";

/// @title storages
/// @dev Manages the storage of matched data after successful matching with Filecoin storage deals.
contract DatacapsModifiers is StoragesModifiers {
    IRoles private roles;
    IFilplus private filplus;
    IFilecoin private filecoin;
    ICarstore private carstore;
    IDatasets private datasets;
    IMatchings private matchings;
    IStorages private storages;
    IDatacaps private datacaps;

    // solhint-disable-next-line
    constructor(
        IRoles _roles,
        IFilplus _filplus,
        IFilecoin _filecoin,
        ICarstore _carstore,
        IDatasets _datasets,
        IMatchings _matchings,
        IStorages _storages,
        IDatacaps _datacaps
    )
        StoragesModifiers(
            _roles,
            _filplus,
            _filecoin,
            _carstore,
            _datasets,
            _matchings,
            _storages
        )
    {
        roles = _roles;
        filplus = _filplus;
        carstore = _carstore;
        datasets = _datasets;
        matchings = _matchings;
        datacaps = _datacaps;
    }

    /// @notice  validNextDatacapAllocation
    modifier validNextDatacapAllocation(uint64 _matchingId) {
        if (!datacaps.isNextDatacapAllocationValid(_matchingId)) {
            revert Errors.NextDatacapAllocationInvalid(_matchingId);
        }
        _;
    }
}
