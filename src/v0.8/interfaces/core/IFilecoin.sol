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

import {FilecoinType} from "src/v0.8/types/FilecoinType.sol";
import {IRoles} from "src/v0.8/interfaces/core/IRoles.sol";

/// @title IFilplus
interface IFilecoin {
    /// @notice The function to allocate the datacap of a storage deal.
    /// @dev This function is intended for use only by the 'dataswap' contract.
    function __allocateDatacap(uint64 client, uint256 _size) external;

    /// @notice The function to get the state of a Filecoin storage deal for a replica.
    function getReplicaDealState(
        bytes32 _cid,
        uint64 _claimId
    ) external returns (FilecoinType.DealState);

    /// @dev do nothing,just for mock
    function setMockDealState(FilecoinType.DealState _state) external;

    /// @notice The function to get the data of a claim for a replica.
    function getReplicaClaimData(
        uint64 _provider,
        uint64 _claimId
    ) external returns (bytes memory);

    /// @dev mock the filecoin claim data
    function setMockClaimData(uint64 claimId, bytes memory _data) external;

    /// @notice Set the Roles contract.
    function setRoles(address _roles) external ;

    /// @notice Get the Roles contract.
    /// @return Roles contract address.
    function roles() external view returns (IRoles);
}
