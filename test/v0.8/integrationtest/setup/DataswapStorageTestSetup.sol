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

import {Generator} from "test/v0.8/helpers/utils/Generator.sol";

import {DataswapStorage} from "src/v0.8/service/dataswapstorage/DataswapStorage.sol";
import {DataswapStorageAssertion} from "test/v0.8/assertions/service/DataswapStorageAssertion.sol";
import {DataswapStorageHelpers} from "test/v0.8/helpers/service/DataswapStorageHelpers.sol";
import {CarstoreReadOnlyAssertion} from "test/v0.8/assertions/core/carstore/CarstoreAssertion.sol";
import {FilplusAssertion} from "test/v0.8/assertions/core/filplus/FilplusAssertion.sol";
import {RolesAssertion} from "test/v0.8/assertions/core/access/RolesAssertion.sol";
import {DatacapsAssertion} from "test/v0.8/assertions/module/datacap/DatacapsAssertion.sol";
import {DatasetsAssertion} from "test/v0.8/assertions/module/dataset/DatasetsAssertion.sol";
import {MatchingsAssertion} from "test/v0.8/assertions/module/matching/MatchingsAssertion.sol";
import {StoragesAssertion} from "test/v0.8/assertions/module/storage/StoragesAssertion.sol";
import {DataswapStorageType} from "src/v0.8/types/DataswapStorageType.sol";
import {FilecoinType} from "src/v0.8/types/FilecoinType.sol";

/// @title DataswapStorageTestSetup
/// @notice This contract is used for setting up access control testing.
contract DataswapStorageTestSetup {
    address payable governanceContractAddress;
    uint8 network;
    uint8 environment;

    DataswapStorage public dataswapStorage;
    DataswapStorageAssertion assertion;
    DataswapStorageHelpers helper;

    /// @dev Initialize the dataswapstorage and assertion contracts.
    function setup() internal {
        network = uint8(FilecoinType.Network.CalibrationTestnet);
        environment = uint8(
            DataswapStorageType.Environment.MockFilecoinAndMerkle
        );

        Generator generater = new Generator();

        dataswapStorage = new DataswapStorage(
            governanceContractAddress,
            network,
            environment
        );
        CarstoreReadOnlyAssertion castoreAssertion = new CarstoreReadOnlyAssertion(
                dataswapStorage
            );
        FilplusAssertion filplusAssertion = new FilplusAssertion(
            dataswapStorage
        );
        RolesAssertion rolesAssertion = new RolesAssertion(dataswapStorage);
        DatacapsAssertion datacapsAssertion = new DatacapsAssertion(
            dataswapStorage
        );
        DatasetsAssertion datasetAssertion = new DatasetsAssertion(
            dataswapStorage
        );
        MatchingsAssertion matchingAssertion = new MatchingsAssertion(
            dataswapStorage
        );
        StoragesAssertion storageAssertion = new StoragesAssertion(
            dataswapStorage
        );
        assertion = new DataswapStorageAssertion(
            governanceContractAddress,
            castoreAssertion,
            filplusAssertion,
            rolesAssertion,
            datacapsAssertion,
            datasetAssertion,
            matchingAssertion,
            storageAssertion
        );
        helper = new DataswapStorageHelpers(
            dataswapStorage,
            generater,
            assertion
        );
    }
}
