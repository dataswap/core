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
import {Carstore} from "src/v0.8/core/carstore/Carstore.sol";
import {Datasets} from "src/v0.8/module/dataset/Datasets.sol";
import {DatasetsAssertion} from "test/v0.8/assertions/module/dataset/DatasetsAssertion.sol";
import {DatasetsHelpers} from "test/v0.8/helpers/module/dataset/DatasetsHelpers.sol";
import {Generator} from "test/v0.8/helpers/utils/Generator.sol";

contract DatasetTestSetup {
    address payable public governanceContractAddresss;
    Datasets datasets;
    DatasetsAssertion assertion;
    DatasetsHelpers helpers;

    function setup() internal {
        Roles role = new Roles();
        Filplus filplus = new Filplus(governanceContractAddresss);
        MockFilecoin filecoin = new MockFilecoin();
        Carstore carstore = new Carstore(role, filplus, filecoin);
        datasets = new Datasets(
            governanceContractAddresss,
            role,
            filplus,
            filecoin,
            carstore
        );
        assertion = new DatasetsAssertion(datasets);
        Generator generator = new Generator();
        helpers = new DatasetsHelpers(datasets, generator, assertion);
    }
}
