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
import {MatchingsAssertion} from "test/v0.8/assertions/module/matching/MatchingsAssertion.sol";
import {DatasetsHelpers} from "test/v0.8/helpers/module/dataset/DatasetsHelpers.sol";
import {Generator} from "test/v0.8/helpers/utils/Generator.sol";
import {MatchingsHelpers} from "test/v0.8/helpers/module/matching/MatchingsHelpers.sol";
import {DatasetsAssertion} from "test/v0.8/assertions/module/dataset/DatasetsAssertion.sol";

/// @title MatchingTestSetup
/// @notice This contract is used for setting up the matchings test setup contract for testing.
contract MatchingTestSetup {
    address payable public governanceContractAddresss;

    Matchings matchings;
    MatchingsTarget matchingsTarget;
    MatchingsBids matchingsBids;

    MatchingsAssertion assertion;
    MatchingsHelpers helpers;

    /// @dev Initialize the matchings and helpers,assertion contracts.
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
        datasets.initialize(governanceContractAddresss, address(role));
        DatasetsRequirement datasetsRequirement = new DatasetsRequirement();
        datasetsRequirement.initialize(
            governanceContractAddresss,
            address(role),
            address(filplus),
            address(datasets)
        );

        DatasetsProof datasetsProof = new DatasetsProof();
        datasetsProof.initialize(
            governanceContractAddresss,
            address(role),
            address(filplus),
            address(carstore),
            address(datasets),
            address(datasetsRequirement)
        );

        DatasetsChallenge datasetsChallenge = new DatasetsChallenge();
        datasetsChallenge.initialize(
            governanceContractAddresss,
            address(role),
            address(datasetsProof),
            address(merkleUtils)
        );

        matchings = new Matchings();
        matchings.initialize(
            governanceContractAddresss,
            address(role),
            address(datasetsRequirement)
        );

        matchingsTarget = new MatchingsTarget();
        matchingsTarget.initialize(
            governanceContractAddresss,
            address(role),
            address(filplus),
            address(carstore),
            address(datasets),
            address(datasetsRequirement),
            address(datasetsProof)
        );

        matchingsBids = new MatchingsBids();
        matchingsBids.initialize(
            governanceContractAddresss,
            address(role),
            address(filplus),
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

        assertion = new MatchingsAssertion(
            matchings,
            matchingsTarget,
            matchingsBids,
            carstore
        );

        Generator generator = new Generator();
        DatasetsAssertion datasetAssertion = new DatasetsAssertion(
            carstore,
            datasets,
            datasetsRequirement,
            datasetsProof,
            datasetsChallenge
        );

        DatasetsHelpers datasetsHelpers = new DatasetsHelpers(
            datasets,
            datasetsRequirement,
            datasetsProof,
            datasetsChallenge,
            generator,
            datasetAssertion
        );
        helpers = new MatchingsHelpers(
            carstore,
            datasets,
            datasetsProof,
            matchings,
            matchingsTarget,
            matchingsBids,
            datasetsHelpers,
            assertion
        );
    }
}
