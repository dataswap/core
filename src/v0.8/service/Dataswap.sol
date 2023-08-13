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

import "../core/access/Roles.sol";
import "../core/filplus/Filplus.sol";
import "../core/carstore/Carstore.sol";
import "../module/dataset/Datasets.sol";
import "../module/matching/Matchings.sol";
import "../module/matcheddatacap/MatchedDatacap.sol";
import "../module/matchedstore/MatchedStores.sol";

/// @title Dataswap
contract Dataswap {
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
}
