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

import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

import {UUPSUpgradeable} from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import {OwnableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import {Ownable2StepUpgradeable} from "@openzeppelin/contracts-upgradeable/access/Ownable2StepUpgradeable.sol";
import {AccessControlEnumerableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/AccessControlEnumerableUpgradeable.sol";
import {RolesType} from "src/v0.8/types/RolesType.sol";
import {Errors} from "src/v0.8/shared/errors/Errors.sol";

import {IRoles} from "src/v0.8/interfaces/core/IRoles.sol";
import {IEscrow} from "src/v0.8/interfaces/core/IEscrow.sol";
import {IFilplus} from "src/v0.8/interfaces/core/IFilplus.sol";
import {IFinance} from "src/v0.8/interfaces/core/IFinance.sol";
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

/// @title Role Contract
/// @notice This contract defines the role-based access control for various roles within the system.
contract Roles is
    Initializable,
    IRoles,
    UUPSUpgradeable,
    OwnableUpgradeable,
    Ownable2StepUpgradeable,
    AccessControlEnumerableUpgradeable
{
    RolesType.DataswapContracts private dataswapContracts;

    /// @notice initialize function to initialize the contract and grant the default admin role to the deployer.
    function initialize() public initializer {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        __Ownable_init();
        __UUPSUpgradeable_init();
    }

    /// @notice UUPS Upgradeable function to update the roles implementation
    /// @dev Only triggered by contract admin
    function _authorizeUpgrade(
        address newImplementation
    )
        internal
        override
        onlyOwner // solhint-disable-next-line
    {}

    /// @notice Returns the implementation contract
    function getImplementation() external view returns (address) {
        return _getImplementation();
    }

    /// @notice Register contract function to manage the dataswap contract.
    /// @param _type The contract type.
    /// @param _contract The register contract address.
    function registerContract(
        RolesType.ContractType _type,
        address _contract
    ) public onlyOwner {
        if (_type == RolesType.ContractType.Filplus) {
            dataswapContracts.filplus = IFilplus(_contract);
        } else if (_type == RolesType.ContractType.Finance) {
            dataswapContracts.finance = IFinance(_contract);
        } else if (_type == RolesType.ContractType.Filecoin) {
            dataswapContracts.filecoin = IFilecoin(_contract);
        } else if (_type == RolesType.ContractType.Carstore) {
            dataswapContracts.carstore = ICarstore(_contract);
        } else if (_type == RolesType.ContractType.Storages) {
            dataswapContracts.storages = IStorages(_contract);
        } else if (_type == RolesType.ContractType.MerkleUtils) {
            dataswapContracts.merkleUtils = IMerkleUtils(_contract);
        } else if (_type == RolesType.ContractType.Datasets) {
            dataswapContracts.datasets = IDatasets(_contract);
        } else if (_type == RolesType.ContractType.DatasetsProof) {
            dataswapContracts.datasetsProof = IDatasetsProof(_contract);
        } else if (_type == RolesType.ContractType.DatasetsChallenge) {
            dataswapContracts.datasetsChallenge = IDatasetsChallenge(_contract);
        } else if (_type == RolesType.ContractType.DatasetsRequirement) {
            dataswapContracts.datasetsRequirement = IDatasetsRequirement(
                _contract
            );
        } else if (_type == RolesType.ContractType.Matchings) {
            dataswapContracts.matchings = IMatchings(_contract);
        } else if (_type == RolesType.ContractType.MatchingsBids) {
            dataswapContracts.matchingsBids = IMatchingsBids(_contract);
        } else if (_type == RolesType.ContractType.MatchingsTarget) {
            dataswapContracts.matchingsTarget = IMatchingsTarget(_contract);
        } else if (_type == RolesType.ContractType.EscrowDataTradingFee) {
            dataswapContracts.escrowDataTradingFee = IEscrow(_contract);
        } else if (
            _type == RolesType.ContractType.EscrowDatacapChunkLandCollateral
        ) {
            dataswapContracts.escrowDatacapChunkLandCollateral = IEscrow(
                _contract
            );
        } else if (_type == RolesType.ContractType.EscrowDatacapCollateral) {
            dataswapContracts.escrowDatacapCollateral = IEscrow(_contract);
        } else if (_type == RolesType.ContractType.EscrowChallengeCommission) {
            dataswapContracts.escrowChallengeCommission = IEscrow(_contract);
        } else if (
            _type == RolesType.ContractType.EscrowChallengeAuditCollateral
        ) {
            dataswapContracts.escrowChallengeAuditCollateral = IEscrow(
                _contract
            );
        } else if (
            _type == RolesType.ContractType.EscrowDisputeAuditCollateral
        ) {
            dataswapContracts.escrowDisputeAuditCollateral = IEscrow(_contract);
        } else if (_type == RolesType.ContractType.EscrowProofAuditCollateral) {
            dataswapContracts.escrowProofAuditCollateral = IEscrow(_contract);
        } else {
            require(false, "Invalid RolesType.ContractType");
        }
    }

    /// @notice grantDataswapContractRole function to grant the dataswap contract role for dataswap contract. TODO: Move to governance
    /// @dev After all the dataswap contracts are deployed, this function needs to be called manually!
    function grantDataswapContractRole(
        address[] calldata _contracts
    ) public onlyOwner {
        for (uint256 i = 0; i < _contracts.length; i++) {
            _grantRole(RolesType.DATASWAP_CONTRACT, _contracts[i]);
        }
    }

    ///@dev The new owner accepts the ownership transfer.
    function acceptOwnership()
        public
        override(IRoles, Ownable2StepUpgradeable)
    {
        return super.acceptOwnership();
    }

    ///@dev check msg.sender is admin role.
    function checkRole(bytes32 _role) public view {
        return super._checkRole(_role);
    }

    ///@dev Returns the address of the current owner.
    function owner()
        public
        view
        override(IRoles, OwnableUpgradeable)
        returns (address)
    {
        return super.owner();
    }

    ///@dev Returns the address of the pending owner.
    function pendingOwner()
        public
        view
        override(IRoles, Ownable2StepUpgradeable)
        returns (address)
    {
        return super.pendingOwner();
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby disabling any functionality that is only available to the owner.
     */
    function renounceOwnership() public override(IRoles, OwnableUpgradeable) {
        super.renounceOwnership();
    }

    /**
     * @dev Starts the ownership transfer of the contract to a new account. Replaces the pending transfer if there is one.
     * Can only be called by the current owner.
     */
    function transferOwnership(
        address _newOwner
    ) public override(IRoles, OwnableUpgradeable, Ownable2StepUpgradeable) {
        super.transferOwnership(_newOwner);
    }

    /// @dev start the ownership transfer
    function _transferOwnership(
        address _newOwner
    ) internal override(OwnableUpgradeable, Ownable2StepUpgradeable) {
        super._transferOwnership(_newOwner);
    }

    /// @notice Get the Filplus contract.
    /// @return Filplus contract address.
    function filplus() external view returns (IFilplus) {
        return dataswapContracts.filplus;
    }

    /// @notice Get the Finance contract.
    /// @return Finance contract address.
    function finance() external view returns (IFinance) {
        return dataswapContracts.finance;
    }

    /// @notice Get the Filecoin contract.
    /// @return Filecoin contract address.
    function filecoin() external view returns (IFilecoin) {
        return dataswapContracts.filecoin;
    }

    /// @notice Get the Carstore contract.
    /// @return Carstore contract address.
    function carstore() external view returns (ICarstore) {
        return dataswapContracts.carstore;
    }

    /// @notice Get the Storages contract.
    /// @return Storages contract address.
    function storages() external view returns (IStorages) {
        return dataswapContracts.storages;
    }

    /// @notice Get the MerkleUtils contract.
    /// @return MerkleUtils contract address.
    function merkleUtils() external view returns (IMerkleUtils) {
        return dataswapContracts.merkleUtils;
    }

    /// @notice Get the Datasets contract.
    /// @return Datasets contract address.
    function datasets() external view returns (IDatasets) {
        return dataswapContracts.datasets;
    }

    /// @notice Get the DatasetsProof contract.
    /// @return DatasetsProof contract address.
    function datasetsProof() external view returns (IDatasetsProof) {
        return dataswapContracts.datasetsProof;
    }

    /// @notice Get the DatasetsChallenge contract.
    /// @return DatasetsChallenge contract address.
    function datasetsChallenge() external view returns (IDatasetsChallenge) {
        return dataswapContracts.datasetsChallenge;
    }

    /// @notice Get the DatasetsRequirement contract.
    /// @return DatasetsRequirement contract address.
    function datasetsRequirement()
        external
        view
        returns (IDatasetsRequirement)
    {
        return dataswapContracts.datasetsRequirement;
    }

    /// @notice Get the Matchings contract.
    /// @return Matchings contract address.
    function matchings() external view returns (IMatchings) {
        return dataswapContracts.matchings;
    }

    /// @notice Get the MatchingsBids contract.
    /// @return MatchingsBids contract address.
    function matchingsBids() external view returns (IMatchingsBids) {
        return dataswapContracts.matchingsBids;
    }

    /// @notice Get the MatchingsTarget contract.
    /// @return MatchingsTarget contract address.
    function matchingsTarget() external view returns (IMatchingsTarget) {
        return dataswapContracts.matchingsTarget;
    }

    /// @notice Get the EscrowDataTradingFee contract.
    /// @return EscrowDataTradingFee contract address.
    function escrowDataTradingFee() external view returns (IEscrow) {
        return dataswapContracts.escrowDataTradingFee;
    }

    /// @notice Get the EscrowDatacapChunkLandCollateral contract.
    /// @return EscrowDatacapChunkLandCollateral contract address.
    function escrowDatacapChunkLandCollateral()
        external
        view
        returns (IEscrow)
    {
        return dataswapContracts.escrowDatacapChunkLandCollateral;
    }

    /// @notice Get the EscrowChallengeCommission contract.
    /// @return EscrowChallengeCommission contract address.
    function escrowChallengeCommission() external view returns (IEscrow) {
        return dataswapContracts.escrowChallengeCommission;
    }

    /// @notice Get the EscrowDatacapCollateral contract.
    /// @return EscrowDatacapCollateral contract address.
    function escrowDatacapCollateral() external view returns (IEscrow) {
        return dataswapContracts.escrowDatacapCollateral;
    }

    /// @notice Get the EscrowChallengeAuditCollateral contract.
    /// @return EscrowChallengeAuditCollateral contract address.
    function escrowChallengeAuditCollateral() external view returns (IEscrow) {
        return dataswapContracts.escrowChallengeAuditCollateral;
    }

    /// @notice Get the EscrowDisputeAuditCollateral contract.
    /// @return EscrowDisputeAuditCollateral contract address.
    function escrowDisputeAuditCollateral() external view returns (IEscrow) {
        return dataswapContracts.escrowDisputeAuditCollateral;
    }

    /// @notice Get the EscrowProofAuditCollateral contract.
    /// @return EscrowProofAuditCollateral contract address.
    function escrowProofAuditCollateral() external view returns (IEscrow) {
        return dataswapContracts.escrowProofAuditCollateral;
    }
}
