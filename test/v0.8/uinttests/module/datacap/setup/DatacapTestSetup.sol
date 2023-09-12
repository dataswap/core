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

import {Roles} from "src/v0.8/core/access/Roles.sol";
import {Filplus} from "src/v0.8/core/filplus/Filplus.sol";
import {MockFilecoin} from "src/v0.8/mocks/core/filecoin/MockFilecoin.sol";
import {MockMerkleUtils} from "src/v0.8/mocks/utils/merkle/MockMerkleUtils.sol";
import {Carstore} from "src/v0.8/core/carstore/Carstore.sol";
import {Datasets} from "src/v0.8/module/dataset/Datasets.sol";
import {Matchings} from "src/v0.8/module/matching/Matchings.sol";
import {Storages} from "src/v0.8/module/storage/Storages.sol";
import {Datacaps} from "src/v0.8/module/datacap/Datacaps.sol";
import {MatchingsAssertion} from "test/v0.8/assertions/module/matching/MatchingsAssertion.sol";
import {DatacapsAssertion} from "test/v0.8/assertions/module/datacap/DatacapsAssertion.sol";
import {DatasetsHelpers} from "test/v0.8/helpers/module/dataset/DatasetsHelpers.sol";
import {Generator} from "test/v0.8/helpers/utils/Generator.sol";
import {MatchingsHelpers} from "test/v0.8/helpers/module/matching/MatchingsHelpers.sol";
import {DatasetsAssertion} from "test/v0.8/assertions/module/dataset/DatasetsAssertion.sol";
import {DatacapsHelpers} from "test/v0.8/helpers/module/datacap/DatacapsHelpers.sol";

/// @title DatacapTestSetup
/// @notice This contract is used for setting up the Datacaps contract for testing.
contract DatacapTestSetup {
    address payable public governanceContractAddresss;

    Datacaps datacaps;
    DatacapsAssertion assertion;
    DatacapsHelpers helpers;

    /// @dev Initialize the Datacaps and assertion contracts.
    function setup() internal {
        Roles role = new Roles();
        role.initialize();
        Filplus filplus = new Filplus();
        filplus.initialize(governanceContractAddresss, address(role));

        MockFilecoin filecoin = new MockFilecoin();
        filecoin.initialize(address(role));
        MockMerkleUtils merkleUtils = new MockMerkleUtils();
        merkleUtils.initialize(address(role));

        Carstore carstore = new Carstore();
        carstore.initialize(address(role), address(filplus), address(filecoin));
        Datasets datasets = new Datasets();
        datasets.initialize(
            governanceContractAddresss,
            address(role),
            address(filplus),
            address(filecoin),
            address(carstore),
            address(merkleUtils)
        );

        Matchings matchings = new Matchings();
        matchings.initialize(
            governanceContractAddresss,
            address(role),
            address(filplus),
            address(filecoin),
            address(carstore),
            address(datasets)
        );

        Storages storages = new Storages();
        storages.initialize(
            governanceContractAddresss,
            address(role),
            address(filplus),
            address(filecoin),
            address(carstore),
            address(datasets),
            address(matchings)
        );

        datacaps = new Datacaps();
        datacaps.initialize(
            governanceContractAddresss,
            address(role),
            address(filplus),
            address(filecoin),
            address(carstore),
            address(datasets),
            address(matchings),
            address(storages)
        );

        MatchingsAssertion machingsAssertion = new MatchingsAssertion(
            matchings
        );
        Generator generator = new Generator();
        DatasetsAssertion datasetAssertion = new DatasetsAssertion(datasets);
        DatasetsHelpers datasetsHelpers = new DatasetsHelpers(
            datasets,
            generator,
            datasetAssertion
        );
        MatchingsHelpers matchingsHelpers = new MatchingsHelpers(
            matchings,
            datasetsHelpers,
            machingsAssertion
        );

        helpers = new DatacapsHelpers(datacaps, matchingsHelpers);
        assertion = new DatacapsAssertion(datacaps);
    }
}
