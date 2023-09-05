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

// Importing Solidity libraries and contracts
import {DSTest} from "ds-test/test.sol";
import {Test} from "forge-std/Test.sol";
import {DatasetType} from "src/v0.8/types/DatasetType.sol";
import {CarstoreServiceAssertion} from "test/v0.8/assertions/service/abstract/CarstoreServiceAssertion.sol";
import {FilplusServiceAssertion} from "test/v0.8/assertions/service/abstract/FilplusServiceAssertion.sol";
import {RoleServiceAssertion} from "test/v0.8/assertions/service/abstract/RoleServiceAssertion.sol";
import {DatacapServiceAssertion} from "test/v0.8/assertions/service/abstract/DatacapServiceAssertion.sol";
import {DatasetServiceAssertion} from "test/v0.8/assertions/service/abstract/DatasetServiceAssertion.sol";
import {MatchingServiceAssertion} from "test/v0.8/assertions/service/abstract/MatchingServiceAssertion.sol";
import {StorageServiceAssertion} from "test/v0.8/assertions/service/abstract/StorageServiceAssertion.sol";
import {ServiceAssertionBase} from "test/v0.8/assertions/service/abstract/base/ServiceAssertionBase.sol";
import {IStoragesAssertion} from "test/v0.8/interfaces/assertions/module/IStoragesAssertion.sol";
import {IMatchingsAssertion} from "test/v0.8/interfaces/assertions/module/IMatchingsAssertion.sol";
import {IDatasetsAssertion} from "test/v0.8/interfaces/assertions/module/IDatasetsAssertion.sol";
import {IDatacapsAssertion} from "test/v0.8/interfaces/assertions/module/IDatacapsAssertion.sol";
import {IRolesAssertion} from "test/v0.8/interfaces/assertions/core/IRolesAssertion.sol";
import {IFilplusAssertion} from "test/v0.8/interfaces/assertions/core/IFilplusAssertion.sol";
import {ICarstoreReadOnlyAssertion} from "test/v0.8/interfaces/assertions/core/ICarstoreAssertion.sol";

contract DataswapStorageAssertion is
    CarstoreServiceAssertion,
    FilplusServiceAssertion,
    RoleServiceAssertion,
    DatacapServiceAssertion,
    DatasetServiceAssertion,
    MatchingServiceAssertion,
    StorageServiceAssertion
{
    constructor(
        address _governanceContractAddress,
        ICarstoreReadOnlyAssertion _carstoreAssertion,
        IFilplusAssertion _filplusAssertion,
        IRolesAssertion _rolesAssertion,
        IDatacapsAssertion _datacapsAssertion,
        IDatasetsAssertion _datasetsAssertion,
        IMatchingsAssertion _matchingsAssertion,
        IStoragesAssertion _storageAssertion
    )
        ServiceAssertionBase(
            _governanceContractAddress,
            _carstoreAssertion,
            _filplusAssertion,
            _rolesAssertion,
            _datacapsAssertion,
            _datasetsAssertion,
            _matchingsAssertion,
            _storageAssertion
        )
    {}
}
