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

import {MarketAPI} from "@zondax/filecoin-solidity/contracts/v0.8/MarketAPI.sol";
import {MarketTypes} from "@zondax/filecoin-solidity/contracts/v0.8/types/MarketTypes.sol";
import {CommonTypes} from "@zondax/filecoin-solidity/contracts/v0.8/types/CommonTypes.sol";
///interface
import {IFilecoin} from "src/v0.8/interfaces/core/IFilecoin.sol";
///type
import {RolesType} from "src/v0.8/types/RolesType.sol";
import {FilecoinType} from "src/v0.8/types/FilecoinType.sol";

import {RolesModifiers} from "src/v0.8/shared/modifiers/RolesModifiers.sol";
import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {UUPSUpgradeable} from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

/// @title Filecoin
contract Filecoin is Initializable, UUPSUpgradeable, IFilecoin, RolesModifiers {
    FilecoinType.Network public network;
    /// @dev This empty reserved space is put in place to allow future versions to add new
    uint256[32] private __gap;

    /// @notice initialize function to initialize the contract and grant the default admin role to the deployer.
    function initialize(
        FilecoinType.Network _network,
        address _roles
    ) public initializer {
        network = _network;
        RolesModifiers.rolesModifiersInitialize(_roles);
        __UUPSUpgradeable_init();
    }

    /// @notice UUPS Upgradeable function to update the roles implementation
    /// @dev Only triggered by contract admin
    function _authorizeUpgrade(
        address newImplementation
    )
        internal
        override
        onlyRole(RolesType.DEFAULT_ADMIN_ROLE) // solhint-disable-next-line
    {}

    /// @notice Returns the implementation contract
    function getImplementation() external view returns (address) {
        return _getImplementation();
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
        // solhint-disable-next-line
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
    // solhint-disable-next-line
    function setMockDealState(FilecoinType.DealState _state) external {}
}
