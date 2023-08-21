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

import {MarketAPI} from "@zondax/filecoin-solidity/contracts/v0.8/MarketAPI.sol";
import {MarketTypes} from "@zondax/filecoin-solidity/contracts/v0.8/types/MarketTypes.sol";
import {CommonTypes} from "@zondax/filecoin-solidity/contracts/v0.8/types/CommonTypes.sol";
///interface
import {IFilecoin} from "../../interfaces/core/IFilecoin.sol";
///type
import {FilecoinType} from "../../types/FilecoinType.sol";

/// @title Filecoin
contract Filecoin is IFilecoin {
    FilecoinType.Network public network;

    constructor(FilecoinType.Network _network) {
        network = _network;
    }

    /// @notice Internal function to get the state of a Filecoin storage deal for a replica.
    /// @dev TODO:check _filecoinDealId belongs to the _cid, now filecoin-solidity is not support
    ///           https://github.com/dataswap/core/issues/41
    function getReplicaDealState(
        bytes32 /*_cid*/,
        uint64 _filecoinDealId
    ) external returns (FilecoinType.DealState) {
        //get expired info
        MarketTypes.GetDealTermReturn memory dealTerm = MarketAPI.getDealTerm(
            _filecoinDealId
        );
        if (
            CommonTypes.ChainEpoch.unwrap(dealTerm.end) < int256(block.number)
        ) {
            return FilecoinType.DealState.Expired;
        }

        //get slashed info
        MarketTypes.GetDealActivationReturn memory DealActivation = MarketAPI
            .getDealActivation(_filecoinDealId);
        if (
            CommonTypes.ChainEpoch.unwrap(DealActivation.terminated) <
            int256(block.number)
        ) {
            return FilecoinType.DealState.Slashed;
        }

        return FilecoinType.DealState.Stored;
    }

    /// @dev do nothing,just for mock
    function setMockDealState(FilecoinType.DealState _state) external {}
}
