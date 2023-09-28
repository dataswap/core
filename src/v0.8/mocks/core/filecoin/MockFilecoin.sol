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

import {IFilecoin} from "src/v0.8/interfaces/core/IFilecoin.sol";
import {FilecoinType} from "src/v0.8/types/FilecoinType.sol";
import {RolesType} from "src/v0.8/types/RolesType.sol";
import {RolesModifiers} from "src/v0.8/shared/modifiers/RolesModifiers.sol";

import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {UUPSUpgradeable} from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

contract MockFilecoin is
    Initializable,
    UUPSUpgradeable,
    IFilecoin,
    RolesModifiers
{
    FilecoinType.DealState private mockDealState;
    //bytes private mockClaimData;
    mapping(uint64 => bytes) private mockClaimData; //matchingId=>Matchedstore

    /// @notice initialize function to initialize the contract and grant the default admin role to the deployer.
    function initialize(address _roles) public initializer {
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

    /// @dev mock the filecoin storage state
    function setMockDealState(FilecoinType.DealState _state) external {
        mockDealState = _state;
    }

    /// @dev get replica filecoin storage state
    function getReplicaDealState(
        bytes32,
        uint64
    ) external view override returns (FilecoinType.DealState) {
        return mockDealState;
    }

    /// @dev mock the filecoin claim data
    function setMockClaimData(uint64 claimId, bytes memory _data) external {
        mockClaimData[claimId] = _data;
    }

    /// @notice The function to get the data of a claim for a replica.
    function getReplicaClaimData(
        uint64,
        uint64 claimId
    ) external view override returns (bytes memory) {
        return mockClaimData[claimId];
    }
}
