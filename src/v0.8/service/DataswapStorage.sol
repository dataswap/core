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

import {IDataswapStorage} from "../interfaces/service/IDataswapStorage.sol";
import {Roles} from "../core/access/Roles.sol";
import {Filplus} from "../core/filplus/Filplus.sol";
import {Filecoin} from "../core/filecoin/Filecoin.sol";
import {Carstore} from "../core/carstore/Carstore.sol";
import {Datasets} from "../module/dataset/Datasets.sol";
import {Matchings} from "../module/matching/Matchings.sol";
import {Datacaps} from "../module/datacap/Datacaps.sol";
import {Storages} from "../module/storage/Storages.sol";
import {FilecoinType} from "../types/FilecoinType.sol";

/// @title Dataswap
/// TODO:https://github.com/dataswap/core/issues/33
abstract contract DataswapStorage is IDataswapStorage {
    address private governanceAddress;
    Roles private roles = new Roles();
    Carstore private carstore;
    Filplus private filplus;
    Filecoin private filecoin;
    Datasets private datasets;
    Matchings private matchings;
    Storages private storages;
    Datacaps private datacaps;

    // solhint-disable-next-line
    constructor(address payable _governanceContractAddress) {
        filplus = new Filplus(_governanceContractAddress);
        filecoin = new Filecoin(FilecoinType.Network.CalibrationTestnet);
        carstore = new Carstore(roles, filplus, filecoin);
        datasets = new Datasets(
            _governanceContractAddress,
            roles,
            filplus,
            filecoin,
            carstore
        );
        matchings = new Matchings(
            _governanceContractAddress,
            roles,
            filplus,
            filecoin,
            carstore,
            datasets
        );
        storages = new Storages(
            _governanceContractAddress,
            roles,
            filplus,
            filecoin,
            carstore,
            datasets,
            matchings
        );
        datacaps = new Datacaps(
            _governanceContractAddress,
            roles,
            filplus,
            filecoin,
            carstore,
            datasets,
            matchings,
            storages
        );
    }
}
