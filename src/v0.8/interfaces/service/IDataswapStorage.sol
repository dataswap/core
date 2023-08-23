/*******************************************************************************
 *   (c) 2023 DataSwap
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

import {IRoles} from "../../interfaces/core/IRoles.sol";
import {IFilplus} from "../../interfaces/core/IFilplus.sol";
import {IDatasets} from "../../interfaces/module/IDatasets.sol";
import {IMatchings} from "../../interfaces/module/IMatchings.sol";
import {IStorages} from "../../interfaces/module/IStorages.sol";
import {IDatacaps} from "../../interfaces/module/IDatacaps.sol";

// solhint-disable-next-line
interface IDataswapStorage is
    IRoles,
    IFilplus,
    IDatasets,
    IMatchings,
    IStorages,
    IDatacaps
{

}
