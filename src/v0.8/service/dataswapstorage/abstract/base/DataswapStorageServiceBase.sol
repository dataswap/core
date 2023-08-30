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

import {IDataswapStorage} from "src/v0.8/interfaces/service/IDataswapStorage.sol";
import {Roles} from "src/v0.8/core/access/Roles.sol";
import {Filplus} from "src/v0.8/core/filplus/Filplus.sol";
import {Carstore} from "src/v0.8/core/carstore/Carstore.sol";
import {Datasets} from "src/v0.8/module/dataset/Datasets.sol";
import {Matchings} from "src/v0.8/module/matching/Matchings.sol";
import {Datacaps} from "src/v0.8/module/datacap/Datacaps.sol";
import {Storages} from "src/v0.8/module/storage/Storages.sol";
import {FilecoinType} from "src/v0.8/types/FilecoinType.sol";
import {DataswapStorageType} from "src/v0.8/types/DataswapStorageType.sol";
import {IFilecoin} from "src/v0.8/interfaces/core/IFilecoin.sol";
import {IMerkleUtils} from "src/v0.8/interfaces/utils/IMerkleUtils.sol";
import {Filecoin} from "src/v0.8/core/filecoin/Filecoin.sol";
import {MerkleUtils} from "src/v0.8/shared/utils/merkle/MerkleUtils.sol";
import {FilecoinType} from "src/v0.8/types/FilecoinType.sol";
import {MockMerkleUtils} from "src/v0.8/mocks/utils/merkle/MockMerkleUtils.sol";
import {MockFilecoin} from "src/v0.8/mocks/core/filecoin/MockFilecoin.sol";

/// @title DataswapStorageServiceBase
/// @notice Abstract contract that defines the base for Dataswap storage service.
abstract contract DataswapStorageServiceBase is IDataswapStorage {
    address internal governanceContractAddress;
    Roles internal rolesInstance = new Roles();
    Carstore internal carstoreInstance;
    Filplus internal filplusInstance;
    Datasets internal datasetsInstance;
    Matchings internal matchingsInstance;
    Storages internal storagesInstance;
    Datacaps internal datacapsInstance;
    IMerkleUtils internal merkleUtilsInstance;
    IFilecoin internal filecoinInstance;

    /// @notice Constructor to initialize contract instances and setup environment
    /// @param _governanceContractAddress Address of the governance contract
    /// @param _network Network identifier (1: Mainnet, etc.)
    /// @param _environment Environment identifier (0: Normal, 1: MockFilecoinAndMerkle, 2: MockFilecoin, 3: MockMerkle)
    constructor(
        address payable _governanceContractAddress,
        uint8 _network,
        uint8 _environment
    ) {
        _setupEnvironment(_network, _environment);
        governanceContractAddress = _governanceContractAddress;
        filplusInstance = new Filplus(_governanceContractAddress);
        carstoreInstance = new Carstore(
            rolesInstance,
            filplusInstance,
            filecoinInstance
        );
        datasetsInstance = new Datasets(
            _governanceContractAddress,
            rolesInstance,
            filplusInstance,
            filecoinInstance,
            carstoreInstance,
            merkleUtilsInstance
        );
        matchingsInstance = new Matchings(
            _governanceContractAddress,
            rolesInstance,
            filplusInstance,
            filecoinInstance,
            carstoreInstance,
            datasetsInstance
        );
        storagesInstance = new Storages(
            _governanceContractAddress,
            rolesInstance,
            filplusInstance,
            filecoinInstance,
            carstoreInstance,
            datasetsInstance,
            matchingsInstance
        );
        datacapsInstance = new Datacaps(
            _governanceContractAddress,
            rolesInstance,
            filplusInstance,
            filecoinInstance,
            carstoreInstance,
            datasetsInstance,
            matchingsInstance,
            storagesInstance
        );
    }

    /// @notice Internal function to set up contract environment based on provided parameters
    /// @param _network Network identifier
    /// @param _environment Environment identifier
    function _setupEnvironment(uint8 _network, uint8 _environment) internal {
        require(
            _network < uint8(FilecoinType.Network.EndIdentifier) &&
                _environment <
                uint8(DataswapStorageType.Environment.EndIdentifier),
            "Invalid params"
        );
        if (
            DataswapStorageType.Environment(_environment) ==
            DataswapStorageType.Environment.MockFilecoinAndMerkle ||
            DataswapStorageType.Environment(_environment) ==
            DataswapStorageType.Environment.MockFilecoin
        ) {
            filecoinInstance = new MockFilecoin();
        } else {
            filecoinInstance = new Filecoin(FilecoinType.Network(_network));
        }

        if (
            DataswapStorageType.Environment(_environment) ==
            DataswapStorageType.Environment.MockFilecoinAndMerkle ||
            DataswapStorageType.Environment(_environment) ==
            DataswapStorageType.Environment.MockMerkle
        ) {
            merkleUtilsInstance = new MockMerkleUtils();
        } else {
            merkleUtilsInstance = new MerkleUtils();
        }
    }
}
