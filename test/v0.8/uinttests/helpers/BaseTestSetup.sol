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

import {RolesType} from "src/v0.8/types/RolesType.sol";

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
import {Generator} from "test/v0.8/helpers/utils/Generator.sol";

/// @title BaseTestSetup
/// @notice This contract is used for setting up the base test setup contract for testing.
contract BaseTestSetup {
    address payable public governanceContractAddresss;

    Roles public role;
    Filplus public filplus;
    Carstore public carstore;
    Storages public storages;
    Generator public generator;

    MockFilecoin public filecoin;
    MockMerkleUtils public merkleUtils;

    Datasets public datasets;
    DatasetsProof public datasetsProof;
    DatasetsChallenge public datasetsChallenge;
    DatasetsRequirement public datasetsRequirement;

    Matchings public matchings;
    MatchingsTarget public matchingsTarget;
    MatchingsBids public matchingsBids;

    /// @dev Internal initialize the base contracts.
    function baseSetup() internal {
        generator = new Generator();
        role = new Roles();
        role.initialize();
        filplus = new Filplus();
        filplus.initialize(governanceContractAddresss, address(role));

        filecoin = new MockFilecoin();
        filecoin.initialize(address(role));

        merkleUtils = new MockMerkleUtils();
        merkleUtils.initialize(address(role));

        carstore = new Carstore();
        carstore.initialize(address(role));

        datasets = new Datasets();
        datasets.initialize(governanceContractAddresss, address(role));

        datasetsRequirement = new DatasetsRequirement();
        datasetsRequirement.initialize(
            governanceContractAddresss,
            address(role)
        );

        datasetsProof = new DatasetsProof();
        datasetsProof.initialize(governanceContractAddresss, address(role));

        datasetsChallenge = new DatasetsChallenge();
        datasetsChallenge.initialize(governanceContractAddresss, address(role));
    }

    /// @dev Initialize the enhance contracts.
    function enhanceSetup() internal {
        baseSetup();
        matchings = new Matchings();
        matchings.initialize(governanceContractAddresss, address(role));

        matchingsTarget = new MatchingsTarget();
        matchingsTarget.initialize(governanceContractAddresss, address(role));

        matchingsBids = new MatchingsBids();
        matchingsBids.initialize(governanceContractAddresss, address(role));

        storages = new Storages();
        storages.initialize(governanceContractAddresss, address(role));
        storages.registDataswapDatacap(100000000000000);

        address[] memory _contracts = new address[](14);
        _contracts[0] = address(0);
        _contracts[1] = address(role);
        _contracts[2] = address(filplus);
        _contracts[3] = address(carstore);
        _contracts[4] = address(storages);

        _contracts[5] = address(datasets);
        _contracts[6] = address(datasetsProof);
        _contracts[7] = address(datasetsChallenge);
        _contracts[8] = address(datasetsRequirement);
        _contracts[9] = address(matchings);
        _contracts[10] = address(matchingsTarget);
        _contracts[11] = address(matchingsBids);
        _contracts[12] = address(filecoin);
        _contracts[13] = address(merkleUtils);
        role.grantDataswapContractRole(_contracts);

        role.registerContract(RolesType.ContractType.Filplus, address(filplus));
        role.registerContract(
            RolesType.ContractType.Filecoin,
            address(filecoin)
        );
        role.registerContract(
            RolesType.ContractType.Carstore,
            address(carstore)
        );
        role.registerContract(
            RolesType.ContractType.Storages,
            address(storages)
        );
        role.registerContract(
            RolesType.ContractType.MerkleUtils,
            address(merkleUtils)
        );
        role.registerContract(
            RolesType.ContractType.Datasets,
            address(datasets)
        );
        role.registerContract(
            RolesType.ContractType.DatasetsProof,
            address(datasetsProof)
        );
        role.registerContract(
            RolesType.ContractType.DatasetsChallenge,
            address(datasetsChallenge)
        );
        role.registerContract(
            RolesType.ContractType.DatasetsRequirement,
            address(datasetsRequirement)
        );
        role.registerContract(
            RolesType.ContractType.Matchings,
            address(matchings)
        );
        role.registerContract(
            RolesType.ContractType.MatchingsBids,
            address(matchingsBids)
        );
        role.registerContract(
            RolesType.ContractType.MatchingsTarget,
            address(matchingsTarget)
        );
    }
}
