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

import {FilecoinType} from "src/v0.8/types/FilecoinType.sol";

/// @title IFilplus
interface IFilecoin {
    /// @notice Internal function to get the state of a Filecoin storage deal for a replica.
    function getReplicaDealState(
        bytes32 _cid,
        uint64 _filecoinDealId
    ) external returns (FilecoinType.DealState);

    /// @dev do nothing,just for mock
    function setMockDealState(FilecoinType.DealState _state) external;
}
