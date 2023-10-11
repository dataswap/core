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
import {DatasetsRequirement} from "src/v0.8/module/dataset/DatasetsRequirement.sol";
import {DatasetsProof} from "src/v0.8/module/dataset/DatasetsProof.sol";
import {DatasetsChallenge} from "src/v0.8/module/dataset/DatasetsChallenge.sol";
import {Matchings} from "src/v0.8/module/matching/Matchings.sol";
import {MatchingsTarget} from "src/v0.8/module/matching/MatchingsTarget.sol";
import {MatchingsBids} from "src/v0.8/module/matching/MatchingsBids.sol";
import {Storages} from "src/v0.8/module/storage/Storages.sol";
import {Datacaps} from "src/v0.8/module/datacap/Datacaps.sol";
import {Escrow} from "src/v0.8/core/finance/Escrow.sol";
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

    struct LocalBaseData {
        Roles role;
        Filplus filplus;
        MockFilecoin filecoin;
        MockMerkleUtils merkleUtils;
        Escrow escrow;
    }

    struct LocalData {
        Carstore carstore;
        Datasets datasets;
        DatasetsRequirement datasetsRequirement;
        DatasetsProof datasetsProof;
        DatasetsChallenge datasetsChallenge;
        Matchings matchings;
        MatchingsTarget matchingsTarget;
        MatchingsBids matchingsBids;
        Storages storages;
    }

    function _setupBase() internal returns (LocalBaseData memory) {
        Roles role = new Roles();
        role.initialize();
        Filplus filplus = new Filplus();
        filplus.initialize(governanceContractAddresss, address(role));

        MockFilecoin filecoin = new MockFilecoin();
        filecoin.initialize(address(role));
        MockMerkleUtils merkleUtils = new MockMerkleUtils();
        merkleUtils.initialize(address(role));

        Escrow escrow = new Escrow();
        escrow.initialize(address(role));

        return LocalBaseData(role, filplus, filecoin, merkleUtils, escrow);
    }

    function _setup() internal returns (LocalData memory) {
        LocalBaseData memory baseData = _setupBase();
        Carstore carstore = new Carstore();
        carstore.initialize(
            address(baseData.role),
            address(baseData.filplus),
            address(baseData.filecoin)
        );
        Datasets datasets = new Datasets();
        datasets.initialize(
            governanceContractAddresss,
            address(baseData.role),
            address(baseData.escrow)
        );

        DatasetsRequirement datasetsRequirement = new DatasetsRequirement();
        datasetsRequirement.initialize(
            governanceContractAddresss,
            address(baseData.role),
            address(baseData.filplus),
            address(datasets),
            address(baseData.escrow)
        );

        DatasetsProof datasetsProof = new DatasetsProof();
        datasetsProof.initialize(
            governanceContractAddresss,
            address(baseData.role),
            address(baseData.filplus),
            address(carstore),
            address(datasets),
            address(datasetsRequirement),
            address(baseData.escrow)
        );

        DatasetsChallenge datasetsChallenge = new DatasetsChallenge();
        datasetsChallenge.initialize(
            governanceContractAddresss,
            address(baseData.role),
            address(datasetsProof),
            address(baseData.merkleUtils)
        );
        baseData.escrow.setDependencies(
            address(datasets),
            address(datasetsProof),
            address(datasetsRequirement)
        );
        datasets.setDatasetsProofAddress(address(datasetsProof));

        Matchings matchings = new Matchings();
        matchings.initialize(
            governanceContractAddresss,
            address(baseData.role),
            address(datasetsRequirement)
        );

        MatchingsTarget matchingsTarget = new MatchingsTarget();
        matchingsTarget.initialize(
            governanceContractAddresss,
            address(baseData.role),
            address(baseData.filplus),
            address(carstore),
            address(datasets),
            address(datasetsRequirement),
            address(datasetsProof)
        );

        MatchingsBids matchingsBids = new MatchingsBids();
        matchingsBids.initialize(
            governanceContractAddresss,
            address(baseData.role),
            address(baseData.filplus),
            address(carstore),
            address(datasets),
            address(datasetsRequirement),
            address(datasetsProof)
        );

        matchings.initMatchings(
            address(matchingsTarget),
            address(matchingsBids)
        );
        matchingsTarget.initMatchings(
            address(matchings),
            address(matchingsBids)
        );
        matchingsBids.initMatchings(
            address(matchings),
            address(matchingsTarget)
        );

        Storages storages = new Storages();
        storages.initialize(
            governanceContractAddresss,
            address(baseData.role),
            address(baseData.filplus),
            address(baseData.filecoin),
            address(carstore),
            address(matchings),
            address(matchingsTarget),
            address(matchingsBids)
        );

        datacaps = new Datacaps();
        datacaps.initialize(
            governanceContractAddresss,
            address(baseData.role),
            address(baseData.filplus),
            address(baseData.filecoin),
            address(carstore),
            address(matchings),
            address(matchingsTarget),
            address(matchingsBids),
            address(storages)
        );

        return
            LocalData(
                carstore,
                datasets,
                datasetsRequirement,
                datasetsProof,
                datasetsChallenge,
                matchings,
                matchingsTarget,
                matchingsBids,
                storages
            );
    }

    /// @dev Initialize the Datacaps and assertion contracts.
    function setup() internal {
        LocalData memory data = _setup();
        MatchingsAssertion machingsAssertion = new MatchingsAssertion(
            data.matchings,
            data.matchingsTarget,
            data.matchingsBids,
            data.carstore
        );
        Generator generator = new Generator();
        DatasetsAssertion datasetAssertion = new DatasetsAssertion(
            data.carstore,
            data.datasets,
            data.datasetsRequirement,
            data.datasetsProof,
            data.datasetsChallenge
        );
        DatasetsHelpers datasetsHelpers = new DatasetsHelpers(
            data.datasets,
            data.datasetsRequirement,
            data.datasetsProof,
            data.datasetsChallenge,
            generator,
            datasetAssertion
        );

        MatchingsHelpers matchingsHelpers = new MatchingsHelpers(
            data.carstore,
            data.datasets,
            data.datasetsProof,
            data.matchings,
            data.matchingsTarget,
            data.matchingsBids,
            datasetsHelpers,
            machingsAssertion
        );

        helpers = new DatacapsHelpers(datacaps, matchingsHelpers);
        assertion = new DatacapsAssertion(datacaps);
    }
}
