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
import {MockMerkleUtils} from "src/v0.8/mocks/utils/merkle/MockMerkleUtils.sol";
import {MockFilecoin} from "src/v0.8/mocks/core/filecoin/MockFilecoin.sol";
import {Carstore} from "src/v0.8/core/carstore/Carstore.sol";
import {Datasets} from "src/v0.8/module/dataset/Datasets.sol";
import {DatasetsRequirement} from "src/v0.8/module/dataset/DatasetsRequirement.sol";
import {DatasetsProof} from "src/v0.8/module/dataset/DatasetsProof.sol";
import {DatasetsChallenge} from "src/v0.8/module/dataset/DatasetsChallenge.sol";
import {DatasetsAssertion} from "test/v0.8/assertions/module/dataset/DatasetsAssertion.sol";
import {DatasetsHelpers} from "test/v0.8/helpers/module/dataset/DatasetsHelpers.sol";
import {Generator} from "test/v0.8/helpers/utils/Generator.sol";

/// @title DatasetTestSetup
/// @notice This contract is used for setting up the dataset contract for testing.
contract DatasetTestSetup {
    address payable public governanceContractAddresss;
    Datasets datasets;
    DatasetsRequirement datasetsRequirement;
    DatasetsProof datasetsProof;
    DatasetsChallenge datasetsChallenge;
    DatasetsAssertion assertion;
    DatasetsHelpers helpers;

    /// @dev Initialize the Datacaps and helpers,assertion contracts.
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
        datasets = new Datasets();
        datasets.initialize(
            governanceContractAddresss,
            address(role),
            address(filplus),
            address(filecoin),
            address(carstore)
        );

        datasetsRequirement = new DatasetsRequirement();
        datasetsRequirement.initialize(
            governanceContractAddresss,
            address(role),
            address(filplus),
            address(filecoin),
            address(carstore),
            address(datasets)
        );

        datasetsProof = new DatasetsProof();
        datasetsProof.initialize(
            governanceContractAddresss,
            address(role),
            address(filplus),
            address(filecoin),
            address(carstore),
            address(datasets),
            address(datasetsRequirement)
        );

        datasetsChallenge = new DatasetsChallenge();
        datasetsChallenge.initialize(
            governanceContractAddresss,
            address(role),
            address(filplus),
            address(filecoin),
            address(carstore),
            address(datasetsProof),
            address(merkleUtils)
        );

        assertion = new DatasetsAssertion(
            datasets,
            datasetsRequirement,
            datasetsProof,
            datasetsChallenge
        );
        Generator generator = new Generator();
        helpers = new DatasetsHelpers(
            datasets,
            datasetsRequirement,
            datasetsProof,
            datasetsChallenge,
            generator,
            assertion
        );
    }
}
