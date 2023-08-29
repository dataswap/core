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

import {DataswapStorageServiceBase} from "src/v0.8/service/dataswapstorage/abstract/base/DataswapStorageServiceBase.sol";
import {RolesService} from "src/v0.8/service/dataswapstorage/abstract/RolesService.sol";
import {FilplusService} from "src/v0.8/service/dataswapstorage/abstract/FilplusService.sol";
import {DatasetsService} from "src/v0.8/service/dataswapstorage/abstract/DatasetsService.sol";
import {MatchingsService} from "src/v0.8/service/dataswapstorage/abstract/MatchingsService .sol";
import {StoragesService} from "src/v0.8/service/dataswapstorage/abstract/StoragesService .sol";
import {DatacapsService} from "src/v0.8/service/dataswapstorage/abstract/DatacapsService.sol";

/// @title DataswapStorage
/// @notice dataswap storage service
contract DataswapStorage is
    DataswapStorageServiceBase,
    RolesService,
    FilplusService,
    DatasetsService,
    MatchingsService,
    StoragesService,
    DatacapsService
{
    constructor(
        address payable _governanceContractAddress
    )
        DataswapStorageServiceBase(_governanceContractAddress)
    // solhint-disable-next-line
    {

    }
}
