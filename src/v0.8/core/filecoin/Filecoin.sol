/*******************************************************************************
 *   (c) 2023 Dataswap
 *
 *  Licensed under the GNU General Public License, Version 3.0 or later (the "License");
 *  you may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at
 *
 *      https://www.gnu.org/licenses/gpl-3.0.en.html *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 ********************************************************************************/

// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity ^0.8.21;

import {MarketAPI} from "filecoin-solidity-api/contracts/v0.8/MarketAPI.sol";
import {VerifRegAPI} from "filecoin-solidity-api/contracts/v0.8/VerifRegAPI.sol";
import {FilAddresses} from "filecoin-solidity-api/contracts/v0.8/utils/FilAddresses.sol";
import {BigInts} from "filecoin-solidity-api/contracts/v0.8/utils/BigInts.sol";
import {MarketTypes} from "filecoin-solidity-api/contracts/v0.8/types/MarketTypes.sol";
import {VerifRegTypes} from "filecoin-solidity-api/contracts/v0.8/types/VerifRegTypes.sol";
import {CommonTypes} from "filecoin-solidity-api/contracts/v0.8/types/CommonTypes.sol";
///interface
import {IRoles} from "src/v0.8/interfaces/core/IRoles.sol";
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
    IRoles public roles;
    /// @dev This empty reserved space is put in place to allow future versions to add new
    uint256[32] private __gap;

    /// @notice initialize function to initialize the contract and grant the default admin role to the deployer.
    function initialize(
        FilecoinType.Network _network,
        address _roles
    ) public initializer {
        network = _network;
        roles = IRoles(_roles);
        __UUPSUpgradeable_init();
    }

    /// @notice UUPS Upgradeable function to update the roles implementation
    /// @dev Only triggered by contract admin
    function _authorizeUpgrade(
        address newImplementation
    )
        internal
        override
        onlyRole(roles, RolesType.DEFAULT_ADMIN_ROLE) // solhint-disable-next-line
    {}

    /// @notice Returns the implementation contract
    function getImplementation() external view returns (address) {
        return _getImplementation();
    }

    /// @notice The function to allocate the datacap of a storage deal.
    /// @dev This function is intended for use only by the 'dataswap' contract.
    function __allocateDatacap(
        uint64 client,
        uint256 _size
    ) external onlyRole(roles, RolesType.DATASWAP_CONTRACT) {
        VerifRegTypes.AddVerifiedClientParams memory params = VerifRegTypes
            .AddVerifiedClientParams(
                FilAddresses.fromActorID(client),
                BigInts.fromUint256(_size)
            );
        VerifRegAPI.addVerifiedClient(params);
    }

    /// @notice Internal function to get the state of a Filecoin storage deal for a replica.
    function getReplicaDealState(
        uint64 _dealId
    ) external view returns (FilecoinType.DealState) {
        //get expired info
        (, MarketTypes.GetDealTermReturn memory dealTerm) = MarketAPI
            .getDealTerm(_dealId);
        if (
            CommonTypes.ChainEpoch.unwrap(dealTerm.start) +
                CommonTypes.ChainEpoch.unwrap(dealTerm.duration) <
            int256(block.number)
        ) {
            return FilecoinType.DealState.Expired;
        }

        //get slashed info
        // solhint-disable-next-line
        (
            ,
            MarketTypes.GetDealActivationReturn memory dealActivation
        ) = MarketAPI.getDealActivation(_dealId);
        if (CommonTypes.ChainEpoch.unwrap(dealActivation.terminated) > 0) {
            return FilecoinType.DealState.Slashed;
        }

        return FilecoinType.DealState.Stored;
    }

    /// @dev do nothing,just for mock
    // solhint-disable-next-line
    function setMockDealState(FilecoinType.DealState _state) external {}

    /// @notice Retrieves claim data on provider and claim ID.
    /// @dev This function is for internal use only and is view-only.
    /// @param _provider The ID of the provider.
    /// @param _claimId The ID of the claim.
    /// @return A memory struct containing the claim data.
    function _getClaim(
        uint64 _provider,
        uint64 _claimId
    ) internal view returns (VerifRegTypes.Claim memory) {
        CommonTypes.FilActorId[] memory actorIds = new CommonTypes.FilActorId[](
            1
        );

        actorIds[0] = CommonTypes.FilActorId.wrap(_claimId);

        VerifRegTypes.GetClaimsParams memory params = VerifRegTypes
            .GetClaimsParams(CommonTypes.FilActorId.wrap(_provider), actorIds);

        (, VerifRegTypes.GetClaimsReturn memory claims) = VerifRegAPI.getClaims(
            params
        );

        require(claims.claims.length > 0, "length mast greater than 0");

        return claims.claims[0];
    }

    /// @notice Internal function to get the claim of a Filecoin storage for a replica.
    function getReplicaClaimData(
        uint64 _provider,
        uint64 _claimId
    ) external view returns (bytes memory cid) {
        VerifRegTypes.Claim memory claim = _getClaim(_provider, _claimId);
        cid = claim.data;
    }

    /// @dev mock the filecoin claim data
    // solhint-disable-next-line
    function setMockClaimData(uint64 claimId, bytes memory _data) external {}

    /// @notice Set the Roles contract.
    function setRoles(
        address _roles
    ) external onlyRole(roles, RolesType.DEFAULT_ADMIN_ROLE) {
        roles = IRoles(_roles);
    }
}
