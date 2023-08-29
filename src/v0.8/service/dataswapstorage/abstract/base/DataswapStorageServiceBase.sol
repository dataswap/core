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

import {IDataswapStorage} from "src/v0.8/interfaces/service/IDataswapStorage.sol";
import {Roles} from "src/v0.8/core/access/Roles.sol";
import {Filplus} from "src/v0.8/core/filplus/Filplus.sol";
import {Filecoin} from "src/v0.8/core/filecoin/Filecoin.sol";
import {Carstore} from "src/v0.8/core/carstore/Carstore.sol";
import {Datasets} from "src/v0.8/module/dataset/Datasets.sol";
import {Matchings} from "src/v0.8/module/matching/Matchings.sol";
import {Datacaps} from "src/v0.8/module/datacap/Datacaps.sol";
import {Storages} from "src/v0.8/module/storage/Storages.sol";
import {FilecoinType} from "src/v0.8/types/FilecoinType.sol";

/// @title DataswapStorageServiceBase
abstract contract DataswapStorageServiceBase is IDataswapStorage {
    address internal governanceContractAddress;
    Roles internal rolesInstance = new Roles();
    Carstore private carstoreInstance;
    Filplus internal filplusInstance;
    Filecoin internal filecoinInstance;
    Datasets internal datasetsInstance;
    Matchings internal matchingsInstance;
    Storages internal storagesInstance;
    Datacaps internal datacapsInstance;

    constructor(address payable _governanceContractAddress) {
        governanceContractAddress = _governanceContractAddress;
        filplusInstance = new Filplus(_governanceContractAddress);
        filecoinInstance = new Filecoin(
            FilecoinType.Network.CalibrationTestnet
        );
        carstoreInstance = new Carstore(
            rolesInstance,
            filplusInstance,
            filecoinInstance
        );
        datasetsInstance = new Datasets(
            _governanceContractAddress,
            rolesInstance,
            filplusInstance,
            filecoinInstance,
            carstoreInstance
        );
        matchingsInstance = new Matchings(
            _governanceContractAddress,
            rolesInstance,
            filplusInstance,
            filecoinInstance,
            carstoreInstance,
            datasetsInstance
        );
        storagesInstance = new Storages(
            _governanceContractAddress,
            rolesInstance,
            filplusInstance,
            filecoinInstance,
            carstoreInstance,
            datasetsInstance,
            matchingsInstance
        );
        datacapsInstance = new Datacaps(
            _governanceContractAddress,
            rolesInstance,
            filplusInstance,
            filecoinInstance,
            carstoreInstance,
            datasetsInstance,
            matchingsInstance,
            storagesInstance
        );
    }
}
