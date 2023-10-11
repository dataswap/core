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
import {Carstore} from "src/v0.8/core/carstore/Carstore.sol";
import {Datasets} from "src/v0.8/module/dataset/Datasets.sol";
import {DatasetsProof} from "src/v0.8/module/dataset/DatasetsProof.sol";
import {MockFilecoin} from "src/v0.8/mocks/core/filecoin/MockFilecoin.sol";
import {MockMerkleUtils} from "src/v0.8/mocks/utils/merkle/MockMerkleUtils.sol";
import {DatasetsRequirement} from "src/v0.8/module/dataset/DatasetsRequirement.sol";

import {Escrow} from "src/v0.8/core/finance/Escrow.sol";
import {EscrowAssertion} from "test/v0.8/assertions/core/escrow/EscrowAssertion.sol";

/// @title EscrowTestSetup
/// @notice This contract is used for setting up the Escrow contract for testing.
contract EscrowTestSetup {
    Datasets internal datasets;
    Escrow internal escrow;
    EscrowAssertion internal assertion;
    address payable public governanceContractAddresss;

    /// @dev Initialize the escrow and assertion contracts.
    function setup() internal {
        Roles role = new Roles();
        role.initialize();
        Filplus filplus = new Filplus();
        filplus.initialize(governanceContractAddresss, address(role));

        MockFilecoin filecoin = new MockFilecoin();
        filecoin.initialize(address(role));

        Carstore carstore = new Carstore();
        carstore.initialize(address(role), address(filplus), address(filecoin));
        escrow = new Escrow();
        escrow.initialize(address(role));
        datasets = new Datasets();
        datasets.initialize(
            governanceContractAddresss,
            address(role),
            address(escrow)
        );
        DatasetsRequirement datasetsRequirement = new DatasetsRequirement();
        datasetsRequirement.initialize(
            governanceContractAddresss,
            address(role),
            address(filplus),
            address(datasets),
            address(escrow)
        );

        DatasetsProof datasetsProof = new DatasetsProof();
        datasetsProof.initialize(
            governanceContractAddresss,
            address(role),
            address(filplus),
            address(carstore),
            address(datasets),
            address(datasetsRequirement),
            address(escrow)
        );

        escrow.setDependencies(
            address(datasets),
            address(datasetsProof),
            address(datasetsRequirement)
        );
        assertion = new EscrowAssertion(escrow);
    }
}
