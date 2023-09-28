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
import {MatchingsAssertion} from "test/v0.8/assertions/module/matching/MatchingsAssertion.sol";
import {StoragesAssertion} from "test/v0.8/assertions/module/storage/StoragesAssertion.sol";
import {DatasetsHelpers} from "test/v0.8/helpers/module/dataset/DatasetsHelpers.sol";
import {Generator} from "test/v0.8/helpers/utils/Generator.sol";
import {MatchingsHelpers} from "test/v0.8/helpers/module/matching/MatchingsHelpers.sol";
import {StoragesHelpers} from "test/v0.8/helpers/module/storage/StoragesHelpers.sol";
import {DatasetsAssertion} from "test/v0.8/assertions/module/dataset/DatasetsAssertion.sol";

/// @title StorageTestSetup
/// @notice This contract is used for setting up the storages test setup contract for testing.
contract StorageTestSetup {
    address payable public governanceContractAddresss;

    Storages internal storages;
    StoragesAssertion internal assertion;
    StoragesHelpers internal helpers;
    Generator internal generator = new Generator();
    Roles internal role;
    MockFilecoin internal filecoin;

    /// @dev Initialize the storages and helpers,assertion contracts.
    function setup() internal {
        role = new Roles();
        role.initialize();
        Filplus filplus = new Filplus();
        filplus.initialize(governanceContractAddresss, address(role));

        filecoin = new MockFilecoin();
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
        storages = new Storages();
        storages.initialize(
            governanceContractAddresss,
            address(role),
            address(filplus),
            address(filecoin),
            address(carstore),
            address(datasets),
            address(matchings)
        );

        MatchingsAssertion machingsAssertion = new MatchingsAssertion(
            matchings,
            carstore
        );
        assertion = new StoragesAssertion(storages);

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

        helpers = new StoragesHelpers(storages, generator, matchingsHelpers);
    }
}
