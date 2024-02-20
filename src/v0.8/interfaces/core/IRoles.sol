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

import {RolesType} from "src/v0.8/types/RolesType.sol";

import {IAccessControlEnumerableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/IAccessControlEnumerableUpgradeable.sol";
import {IFilplus} from "src/v0.8/interfaces/core/IFilplus.sol";
import {IFilecoin} from "src/v0.8/interfaces/core/IFilecoin.sol";
import {ICarstore} from "src/v0.8/interfaces/core/ICarstore.sol";
import {IStorages} from "src/v0.8/interfaces/module/IStorages.sol";
import {IMerkleUtils} from "src/v0.8/interfaces/utils/IMerkleUtils.sol";
import {IDatasets} from "src/v0.8/interfaces/module/IDatasets.sol";
import {IDatasetsProof} from "src/v0.8/interfaces/module/IDatasetsProof.sol";
import {IDatasetsChallenge} from "src/v0.8/interfaces/module/IDatasetsChallenge.sol";
import {IDatasetsRequirement} from "src/v0.8/interfaces/module/IDatasetsRequirement.sol";
import {IMatchings} from "src/v0.8/interfaces/module/IMatchings.sol";
import {IMatchingsBids} from "src/v0.8/interfaces/module/IMatchingsBids.sol";
import {IMatchingsTarget} from "src/v0.8/interfaces/module/IMatchingsTarget.sol";

import {IFilplus} from "src/v0.8/interfaces/core/IFilplus.sol";
import {IFinance} from "src/v0.8/interfaces/core/IFinance.sol";
import {IFilecoin} from "src/v0.8/interfaces/core/IFilecoin.sol";
import {ICarstore} from "src/v0.8/interfaces/core/ICarstore.sol";
import {IStorages} from "src/v0.8/interfaces/module/IStorages.sol";
import {IMerkleUtils} from "src/v0.8/interfaces/utils/IMerkleUtils.sol";
import {IEscrow} from "src/v0.8/interfaces/core/IEscrow.sol";
import {IDatasets} from "src/v0.8/interfaces/module/IDatasets.sol";
import {IDatasetsProof} from "src/v0.8/interfaces/module/IDatasetsProof.sol";
import {IDatasetsChallenge} from "src/v0.8/interfaces/module/IDatasetsChallenge.sol";
import {IDatasetsRequirement} from "src/v0.8/interfaces/module/IDatasetsRequirement.sol";
import {IMatchings} from "src/v0.8/interfaces/module/IMatchings.sol";
import {IMatchingsBids} from "src/v0.8/interfaces/module/IMatchingsBids.sol";
import {IMatchingsTarget} from "src/v0.8/interfaces/module/IMatchingsTarget.sol";

/// @title IRoles Interface
/// @notice This interface defines the role-based access control for various roles within the system.
interface IRoles is IAccessControlEnumerableUpgradeable {
    ///@dev The new owner accepts the ownership transfer.
    function acceptOwnership() external;

    /**
     * @dev Revert with a standard message if `_msgSender()` is missing `role`.
     * Overriding this function changes the behavior of the {onlyRole} modifier.
     *
     * Format of the revert message is described in {_checkRole}.
     *
     * _Available since v4.6._
     */
    function checkRole(bytes32 _role) external view;

    ///@dev Returns the address of the current owner.
    function owner() external view returns (address);

    ///@dev Returns the address of the pending owner.
    function pendingOwner() external view returns (address);

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby disabling any functionality that is only available to the owner.
     */
    function renounceOwnership() external;

    /**
     * @dev Starts the ownership transfer of the contract to a new account. Replaces the pending transfer if there is one.
     * Can only be called by the current owner.
     */
    function transferOwnership(address _newOwner) external;

    /// @notice grantDataswapContractRole function to grant the dataswap contract role for dataswap contract. TODO: Move to governance
    function grantDataswapContractRole(address[] calldata _contracts) external;

    /// @notice Register contract function to manage the dataswap contract.
    /// @param _type The contract type.
    /// @param _contract The register contract address.
    function registerContract(
        RolesType.ContractType _type,
        address _contract
    ) external;

    /// @notice Get the Filplus contract.
    /// @return Filplus contract address.
    function filplus() external view returns (IFilplus);

    /// @notice Get the Finance contract.
    /// @return Finance contract address.
    function finance() external view returns (IFinance);

    /// @notice Get the Filecoin contract.
    /// @return Filecoin contract address.
    function filecoin() external view returns (IFilecoin);

    /// @notice Get the Carstore contract.
    /// @return Carstore contract address.
    function carstore() external view returns (ICarstore);

    /// @notice Get the Storages contract.
    /// @return Storages contract address.
    function storages() external view returns (IStorages);

    /// @notice Get the MerkleUtils contract.
    /// @return MerkleUtils contract address.
    function merkleUtils() external view returns (IMerkleUtils);

    /// @notice Get the Datasets contract.
    /// @return Datasets contract address.
    function datasets() external view returns (IDatasets);

    /// @notice Get the DatasetsProof contract.
    /// @return DatasetsProof contract address.
    function datasetsProof() external view returns (IDatasetsProof);

    /// @notice Get the DatasetsChallenge contract.
    /// @return DatasetsChallenge contract address.
    function datasetsChallenge() external view returns (IDatasetsChallenge);

    /// @notice Get the DatasetsRequirement contract.
    /// @return DatasetsRequirement contract address.
    function datasetsRequirement() external view returns (IDatasetsRequirement);

    /// @notice Get the Matchings contract.
    /// @return Matchings contract address.
    function matchings() external view returns (IMatchings);

    /// @notice Get the MatchingsBids contract.
    /// @return MatchingsBids contract address.
    function matchingsBids() external view returns (IMatchingsBids);

    /// @notice Get the MatchingsTarget contract.
    /// @return MatchingsTarget contract address.
    function matchingsTarget() external view returns (IMatchingsTarget);

    /// @notice Get the EscrowDataTradingFee contract.
    /// @return EscrowDataTradingFee contract address.
    function escrowDataTradingFee() external view returns (IEscrow);

    /// @notice Get the EscrowDatacapChunkLandCollateral contract.
    /// @return EscrowDatacapChunkLandCollateral contract address.
    function escrowDatacapChunkLandCollateral() external view returns (IEscrow);

    /// @notice Get the EscrowChallengeCommission contract.
    /// @return EscrowChallengeCommission contract address.
    function escrowChallengeCommission() external view returns (IEscrow);

    /// @notice Get the EscrowDatacapCollateral contract.
    /// @return EscrowDatacapCollateral contract address.
    function escrowDatacapCollateral() external view returns (IEscrow);
}
