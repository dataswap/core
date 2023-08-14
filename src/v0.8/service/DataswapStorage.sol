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
import {Carstore} from "../core/carstore/Carstore.sol";
import {Datasets} from "../module/dataset/Datasets.sol";
import {Matchings} from "../module/matching/Matchings.sol";
import {MatchedDatacap} from "../module/matcheddatacap/MatchedDatacap.sol";
import {MatchedStores} from "../module/matchedstore/MatchedStores.sol";

/// @title Dataswap
abstract contract DataswapStorage is IDataswapStorage {
    address private governanceAddress;
    Roles private roles = new Roles();
    Carstore private carstore = new Carstore();
    Filplus private filplus;
    Datasets private datasets;
    Matchings private matchings;
    MatchedStores private matchedstores;
    MatchedDatacap private matcheddatacap;

    constructor(address payable _governanceContractAddress) {
        filplus = new Filplus(_governanceContractAddress);
        datasets = new Datasets(
            _governanceContractAddress,
            roles,
            filplus,
            carstore
        );
        matchings = new Matchings(
            _governanceContractAddress,
            roles,
            filplus,
            carstore,
            datasets
        );
        matchedstores = new MatchedStores(
            _governanceContractAddress,
            roles,
            filplus,
            carstore,
            datasets,
            matchings
        );
        matcheddatacap = new MatchedDatacap(
            _governanceContractAddress,
            roles,
            filplus,
            carstore,
            datasets,
            matchings,
            matchedstores
        );
    }

    /*
    TODO: implements IDataswapStoarge
    */
}
