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

import {SendAPI} from "@zondax/filecoin-solidity/contracts/v0.8/SendAPI.sol";
import {FilAddresses} from "@zondax/filecoin-solidity/contracts/v0.8/utils/FilAddresses.sol";

// upgrade
import {RolesType} from "src/v0.8/types/RolesType.sol";
import {RolesModifiers} from "src/v0.8/shared/modifiers/RolesModifiers.sol";
import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {UUPSUpgradeable} from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

// type
import {EscrowType} from "src/v0.8/types/EscrowType.sol";
import {DatasetType} from "src/v0.8/types/DatasetType.sol";

// interface
import {IRoles} from "src/v0.8/interfaces/core/IRoles.sol";
import {IEscrow} from "src/v0.8/interfaces/core/IEscrow.sol";
import {IDatasets} from "src/v0.8/interfaces/module/IDatasets.sol";
import {IDatasetsProof} from "src/v0.8/interfaces/module/IDatasetsProof.sol";
import {IDatasetsRequirement} from "src/v0.8/interfaces/module/IDatasetsRequirement.sol";

// shared
import {EscrowEvents} from "src/v0.8/shared/events/EscrowEvents.sol";
import {EscrowLIB} from "src/v0.8/core/finance/library/EscrowLIB.sol";

/// @title Escrow
/// @dev Base escrow contract, holds funds designated for a payee until they withdraw them.
contract Escrow is Initializable, UUPSUpgradeable, RolesModifiers, IEscrow {
    using EscrowLIB for EscrowType.Escrow;

    mapping(EscrowType.Type => mapping(address => mapping(uint256 => EscrowType.Escrow)))
        private escrowAccount; // mapping(type, mapping(payee, mapping(id, Escrow)))

    IRoles private roles;
    IDatasets private datasets;
    IDatasetsProof private datasetsProof;
    IDatasetsRequirement private datasetsRequirement;
    uint256 public constant PER_DAY_BLOCKNUMBER = 2880;
    address payable public constant BURN_ADDRESS =
        payable(0xff00000000000000000000000000000000000063); // Filecoin burn address
    /// @dev This empty reserved space is put in place to allow future versions to add new
    uint256[32] private __gap;

    /// @notice Initialize function to initialize the contract and grant the default admin role to the deployer.
    function initialize(address _roles) public initializer {
        roles = IRoles(_roles);
        __UUPSUpgradeable_init();
    }

    /// @notice Set dependencies function to initialize the depend contract.
    /// @dev After the contract is deployed, this function needs to be called manually!
    function setDependencies(
        address _datasets,
        address _datasetsProof,
        address _datasetsRequirement
    ) public onlyRole(roles, RolesType.DEFAULT_ADMIN_ROLE) {
        datasets = IDatasets(_datasets);
        datasetsProof = IDatasetsProof(_datasetsProof);
        datasetsRequirement = IDatasetsRequirement(_datasetsRequirement);
    }

    /// @notice UUPS Upgradeable function to update the roles implementation
    /// @dev Only triggered by default admin role
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

    /// @dev Records the sent amount as credit for future withdrawals.
    /// Note Called by the payer to store the sent amount as credit to be pulled.
    /// Funds sent in this way are stored in an intermediate {Escrow} contract, so
    /// there is no danger of them being spent before withdrawal.
    /// @param _type The Escrow type for the credited funds.
    /// @param _owner The destination address for the credited funds.
    /// @param _id The business id associated with the credited funds.
    /// @param _amount The collateral funds.
    /// @notice Emits a {Collateral} event upon successful credit recording.
    function collateral(
        EscrowType.Type _type,
        address _owner,
        uint64 _id,
        uint256 _amount
    ) public payable {
        uint256 total = msg.value;
        escrowAccount[_type][_owner][_id].deposit(total);
        escrowAccount[_type][_owner][_id].collateral(_amount);

        emit EscrowEvents.Collateral(_type, _owner, _id, _amount);
    }

    /// @notice Withdraw funds authorized for an address.
    /// @dev This function allows the owner to initiate a withdrawal of authorized funds.
    /// @param _type The Escrow type for the credited funds.
    /// @param _owner The destination address for the credited funds.
    /// @param _id The business id associated with the credited funds.
    /// @notice Emits a {Withdrawn} event upon successful withdrawal.
    function withdraw(
        EscrowType.Type _type,
        address payable _owner,
        uint64 _id
    ) public {
        uint256 amount = escrowAccount[_type][_owner][_id].withdraw();
        SendAPI.send(FilAddresses.fromEthAddress(_owner), amount);

        emit EscrowEvents.Withdrawn(_type, _owner, _id, amount);
    }

    /// @dev Records the sent amount as credit for future payment withdraw.
    /// Note Called by the payer to store the sent amount as credit to be pulled.
    /// Funds sent in this way are stored in an intermediate {Escrow} contract, so
    /// there is no danger of them being spent before withdrawal.
    /// @param _type The Escrow type for the credited funds.
    /// @param _owner The destination address for the credited funds.
    /// @param _id The business id associated with the credited funds.
    /// @param _amount The collateral funds.
    /// @notice Emits a {PaymentCollateral} event upon successful credit recording.
    function paymentCollateral(
        EscrowType.Type _type,
        address _owner,
        uint64 _id,
        uint256 _amount
    ) public payable {
        uint256 total = msg.value;
        escrowAccount[_type][_owner][_id].deposit(total);
        escrowAccount[_type][_owner][_id].paymentCollateral(_amount);

        emit EscrowEvents.PaymentCollateral(_type, _owner, _id, _amount);
    }

    /// @dev Records the sent amount as credit for future payment withdraw.
    /// Note Called by the payer to store the sent amount as credit to be pulled.
    /// Funds sent in this way are stored in an intermediate {Escrow} contract, so
    /// there is no danger of them being spent before withdrawal.
    /// @param _type The Escrow type for the credited funds.
    /// @param _owner The destination address for the credited funds.
    /// @param _id The business id associated with the credited funds.
    /// @param _beneficiary The beneficiary address for the payment credited funds.
    /// @param _amount The collateral funds.
    /// @notice Emits a {PaymentSingleBeneficiaryCollateral} event upon successful credit recording.
    function paymentSingleBeneficiaryCollateral(
        EscrowType.Type _type,
        address _owner,
        uint64 _id,
        address _beneficiary,
        uint256 _amount
    ) public payable {
        uint256 total = msg.value;
        require(total >= _amount, "Exceeds the amount of payment");
        escrowAccount[_type][_owner][_id].deposit(total);
        escrowAccount[_type][_owner][_id].paymentCollateral(_amount);
        escrowAccount[_type][_owner][_id].paymentAddbeneficiary(
            _beneficiary,
            _amount
        );

        emit EscrowEvents.PaymentSingleBeneficiaryCollateral(
            _type,
            _owner,
            _id,
            _beneficiary,
            _amount
        );
    }

    /// @notice Payment withdraw funds authorized for an address.
    /// @param _type The Escrow type for the credited funds.
    /// @param _owner The destination address for the credited funds.
    /// @param _id The business id associated with the credited funds.
    /// @param _beneficiary The beneficiary address for the payment credited funds.
    /// @notice Emits a {PaymentWithdrawn} event upon successful credit recording.
    function paymentWithdraw(
        EscrowType.Type _type,
        address _owner,
        uint64 _id,
        address _beneficiary
    ) public {
        uint256 amount = escrowAccount[_type][_owner][_id].paymentWithdraw(
            _beneficiary
        );
        SendAPI.send(FilAddresses.fromEthAddress(_beneficiary), amount);

        emit EscrowEvents.PaymentWithdrawn(
            _type,
            _owner,
            _id,
            _beneficiary,
            amount
        );
    }

    /// @notice Post an event for collateral type.
    /// @param _type The Escrow type for the credited funds.
    /// @param _owner The destination address for the credited funds.
    /// @param _id The business id associated with the credited funds.
    function emitCollateralEvent(
        EscrowType.Type _type,
        address _owner,
        uint64 _id,
        EscrowType.CollateralEvent _event
    ) external {
        if (_event == EscrowType.CollateralEvent.SyncBurn) {
            uint256 amount = _syncBurn(_type, _owner, _id);
            _updateBurn(_type, payable(_owner), _id, amount);
        } else if (_event == EscrowType.CollateralEvent.SyncCollateral) {
            uint256 amount = _syncCollateral(_type, _owner, _id);
            _updateCollateral(_type, _owner, _id, amount);
        }
    }

    /// @notice Post an event for payment type.
    /// @param _type The Escrow type for the credited funds.
    /// @param _owner The destination address for the credited funds.
    /// @param _id The business id associated with the credited funds.
    /// @param _beneficiary The beneficiary address for the payment credited funds.
    function emitPaymentEvent(
        EscrowType.Type _type,
        address _owner,
        uint64 _id,
        address _beneficiary,
        EscrowType.PaymentEvent _event
    ) external {
        if (_event == EscrowType.PaymentEvent.SyncPaymentRefund) {
            uint256 amount = _syncPaymentRefund(
                _type,
                _owner,
                _id,
                _beneficiary
            );
            _updatePaymentRefund(_type, _owner, _id, _beneficiary, amount);
        } else if (_event == EscrowType.PaymentEvent.SyncPaymentCollateral) {
            uint256 amount = _syncPaymentCollateral(
                _type,
                _owner,
                _id,
                _beneficiary
            );
            _updatePaymentCollateral(_type, _owner, _id, _beneficiary, amount);
        } else if (_event == EscrowType.PaymentEvent.SyncPaymentBeneficiaries) {
            uint256 amount = _syncPaymentBeneficiary(
                _type,
                _owner,
                _id,
                _beneficiary
            );
            _updatePaymentBeneficiary(_type, _owner, _id, _beneficiary, amount);
        }
    }

    /// @notice Update collateral funds authorized for an address.
    /// @dev This function allows update collateral funds authorized for an address.
    /// @param _type The Escrow type for the credited funds.
    /// @param _owner The destination address for the credited funds.
    /// @param _id The business id associated with the credited funds.
    /// @param _amount The collateral funds.
    /// @notice Emits a {UpdateCollateral} event upon successful withdrawal.
    function _updateCollateral(
        EscrowType.Type _type,
        address _owner,
        uint64 _id,
        uint256 _amount
    ) internal {
        escrowAccount[_type][_owner][_id].updateCollateral(_amount);

        emit EscrowEvents.UpdateCollateral(_type, _owner, _id, _amount);
    }

    /// @notice Burn funds authorized for an address.
    /// @dev This function allows burn funds.Triggered by business conditions
    /// @param _type The Escrow type for the credited funds.
    /// @param _owner The destination address for the credited funds.
    /// @param _id The business id associated with the credited funds.
    /// @param _amount The burn funds.
    /// @notice Emits a {Burn} event upon successful withdrawal.
    function _updateBurn(
        EscrowType.Type _type,
        address payable _owner,
        uint64 _id,
        uint256 _amount
    ) internal {
        escrowAccount[_type][_owner][_id].burn(_amount);
        SendAPI.send(FilAddresses.fromEthAddress(BURN_ADDRESS), _amount);

        emit EscrowEvents.Burn(_type, _owner, _id, _amount);
    }

    /// @notice Burn funds authorized for an address.
    /// @dev This function allows burn funds.Triggered by business conditions
    /// @param _type The Escrow type for the credited funds.
    /// @param _owner The destination address for the credited funds.
    /// @param _id The business id associated with the credited funds.
    /// @param _amount The burn funds.
    /// @notice Emits a {Burn} event upon successful withdrawal.
    function _updatePaymentCollateral(
        EscrowType.Type _type,
        address _owner,
        uint64 _id,
        address _beneficiary,
        uint256 _amount
    ) internal {
        escrowAccount[_type][_owner][_id].updatePaymentCollateral(
            _beneficiary,
            _amount
        );

        emit EscrowEvents.UpdatePaymentCollateral(
            _type,
            _owner,
            _id,
            _beneficiary,
            _amount
        );
    }

    /// @notice Refund funds authorized for an address.
    /// @param _type The Escrow type for the credited funds.
    /// @param _owner The destination address for the credited funds.
    /// @param _id The business id associated with the credited funds.
    /// @param _beneficiary The beneficiary address for the payment credited funds.
    /// @param _amount The refund funds.
    /// @notice Emits a {PaymentRefund} event upon successful credit recording.
    function _updatePaymentRefund(
        EscrowType.Type _type,
        address _owner,
        uint64 _id,
        address _beneficiary,
        uint256 _amount
    ) internal {
        escrowAccount[_type][_owner][_id].paymentRefund(_beneficiary, _amount);

        emit EscrowEvents.PaymentRefund(
            _type,
            _owner,
            _id,
            _beneficiary,
            _amount
        );
    }

    /// @notice Update payment beneficiaries authorized for an address.
    /// @param _type The Escrow type for the credited funds.
    /// @param _owner The destination address for the credited funds.
    /// @param _id The business id associated with the credited funds.
    /// @param _beneficiary The beneficiary address for the payment credited funds.
    /// @param _amount The payment amount of beneficiaries.
    /// @notice Emits a {UpdatePaymentBeneficiaries} event upon successful credit recording.
    function _updatePaymentBeneficiary(
        EscrowType.Type _type,
        address _owner,
        uint64 _id,
        address _beneficiary,
        uint256 _amount
    ) internal {
        escrowAccount[_type][_owner][_id].paymentAddbeneficiary(
            _beneficiary,
            _amount
        );

        emit EscrowEvents.UpdatePaymentBeneficiary(
            _type,
            _owner,
            _id,
            _beneficiary,
            _amount
        );
    }

    /// @dev Determines the amount available for collateral based on escrow type, owner, and ID.
    /// @param _type The Escrow type for the credited funds.
    /// @param _owner The destination address for the credited funds.
    /// @param _id The business id associated with the credited funds.
    function _syncCollateral(
        EscrowType.Type _type,
        address _owner,
        uint64 _id
    ) internal view returns (uint256) {
        if (_type == EscrowType.Type.DatacapCollateral) {
            return _datacapCollateral(_owner, _id);
        } else if (_type == EscrowType.Type.DatacapChunkCollateral) {
            // TODO: Implement logic to retrieve allowed withdrawal funds from the datacap contract.
            return 0;
        } else {
            return 0;
        }
    }

    /// @dev Handles the logic for burning funds based on escrow type, owner, and ID.
    /// @param _type The Escrow type for the credited funds.
    /// @param _owner The destination address for the credited funds.
    /// @param _id The business id associated with the credited funds.
    function _syncBurn(
        EscrowType.Type _type,
        address _owner,
        uint64 _id
    ) internal view returns (uint256) {
        // TODO:
        return getOwnerCollateral(_type, _owner, _id); // Burn all collateral
    }

    /// @dev Handles the logic for collateral payments based on escrow type, owner, ID, and beneficiary.
    function _syncPaymentCollateral(
        EscrowType.Type /*_type*/,
        address /*_owner*/,
        uint64 /*_id*/,
        address /*_beneficiary*/
    ) internal pure returns (uint256) {
        // TODO:
        return 0; // Release all collateral
    }

    /// @dev Handles the logic for refunding payments based on escrow type, owner, ID, and beneficiary.
    /// @param _type The Escrow type for the credited funds.
    /// @param _owner The destination address for the credited funds.
    /// @param _id The business id associated with the credited funds.
    function _syncPaymentRefund(
        EscrowType.Type _type,
        address _owner,
        uint64 _id,
        address /*_beneficiary*/
    ) internal view returns (uint256) {
        // TODO:
        return getOwnerCollateral(_type, _owner, _id); // Refund all payment for test
    }

    /// @dev Handles the logic for synchronize payment beneficiary based on escrow type, owner, ID.
    function _syncPaymentBeneficiary(
        EscrowType.Type /*_type*/,
        address /*_owner*/,
        uint64 /*_id*/,
        address /*_beneficiary*/
    ) internal pure returns (uint256) {
        // TODO:
        return 0;
    }

    /// @dev Determines the amount available for collateral from a DatacapCollateral
    /// @param _owner The destination address for the credited funds.
    /// @param _id The business id associated with the credited funds.
    function _datacapCollateral(
        address _owner,
        uint64 _id
    ) internal view returns (uint256) {
        uint256 collateralFunds = 0;

        // Check the dataset's status:
        // - If it's in the 'MetadataRejected' status,
        // - or if it's not in the 'MetadataApproved' status and has been staked for over 180 days,
        // - or if it has been mortgaged for over 365 days, the funds are eligible for withdrawal.
        DatasetType.State datasetState = datasets.getDatasetState(_id);
        uint64 createBlockNumber = getOwnerCreatedBlockNumber(
            EscrowType.Type.DatacapCollateral,
            _owner,
            _id
        );

        if (
            (datasetState == DatasetType.State.MetadataRejected) ||
            (datasetState != DatasetType.State.DatasetApproved &&
                block.number >
                (createBlockNumber + PER_DAY_BLOCKNUMBER * 180)) ||
            block.number > (createBlockNumber + PER_DAY_BLOCKNUMBER * 365)
        ) {
            return collateralFunds; // Release all collateral funds
        }

        // Check the datasetProof's status:
        // - If it's in the 'allCompleted' status,
        // - it's all proof completed collateral funds
        if (
            datasetsProof.isDatasetProofallCompleted(
                _id,
                DatasetType.DataType.Source
            )
        ) {
            collateralFunds = datasetsProof.getDatasetCollateralRequirement(
                _id
            );
        } else {
            // Others are pre collateral funds
            collateralFunds = datasetsRequirement
                .getDatasetPreCollateralRequirements(_id);
        }

        uint256 total = getOwnerTotal(
            EscrowType.Type.DatacapCollateral,
            _owner,
            _id
        );
        require(total >= collateralFunds, "Insufficient collateral funds");
        return collateralFunds;
    }

    /// @notice Get owner created block number.
    /// @param _type The Escrow type for the credited funds.
    /// @param _owner The destination address for the credited funds.
    /// @param _id The business id associated with the credited funds.
    function getOwnerCreatedBlockNumber(
        EscrowType.Type _type,
        address _owner,
        uint64 _id
    ) public view returns (uint64) {
        return escrowAccount[_type][_owner][_id].owner.createdBlockNumber;
    }

    /// @notice Get owner collateral funds.
    /// @param _type The Escrow type for the credited funds.
    /// @param _owner The destination address for the credited funds.
    /// @param _id The business id associated with the credited funds.
    function getOwnerCollateral(
        EscrowType.Type _type,
        address _owner,
        uint64 _id
    ) public view returns (uint256) {
        return escrowAccount[_type][_owner][_id].owner.collateral;
    }

    /// @notice Get owner total funds.
    /// @param _type The Escrow type for the credited funds.
    /// @param _owner The destination address for the credited funds.
    /// @param _id The business id associated with the credited funds.
    function getOwnerTotal(
        EscrowType.Type _type,
        address _owner,
        uint64 _id
    ) public view returns (uint256) {
        return escrowAccount[_type][_owner][_id].owner.total;
    }

    /// @notice Get owner lock funds.
    /// @param _type The Escrow type for the credited funds.
    /// @param _owner The destination address for the credited funds.
    /// @param _id The business id associated with the credited funds.
    function getOwnerLock(
        EscrowType.Type _type,
        address _owner,
        uint64 _id
    ) public view returns (uint256) {
        return escrowAccount[_type][_owner][_id].owner.lock;
    }

    /// @notice Get owner burned funds.
    /// @param _type The Escrow type for the credited funds.
    /// @param _owner The destination address for the credited funds.
    /// @param _id The business id associated with the credited funds.
    function getOwnerBurned(
        EscrowType.Type _type,
        address _owner,
        uint64 _id
    ) public view returns (uint256) {
        return escrowAccount[_type][_owner][_id].owner.burned;
    }

    /// @notice Get beneficiariesList.
    /// @param _type The Escrow type for the credited funds.
    /// @param _owner The destination address for the credited funds.
    /// @param _id The business id associated with the credited funds.
    function getBeneficiariesList(
        EscrowType.Type _type,
        address _owner,
        uint64 _id
    ) public view returns (address[] memory) {
        return escrowAccount[_type][_owner][_id].beneficiariesList;
    }

    /// @notice Get beneficiary fund.
    /// @param _type The Escrow type for the credited funds.
    /// @param _owner The destination address for the credited funds.
    /// @param _id The business id associated with the credited funds.
    /// @param _beneficiary The beneficiary address for the payment credited funds.
    function getBeneficiaryFund(
        EscrowType.Type _type,
        address _owner,
        uint64 _id,
        address _beneficiary
    ) public view returns (uint256, uint256, uint256, uint256, uint64) {
        return (
            escrowAccount[_type][_owner][_id].beneficiaries[_beneficiary].total,
            escrowAccount[_type][_owner][_id].beneficiaries[_beneficiary].lock,
            escrowAccount[_type][_owner][_id]
                .beneficiaries[_beneficiary]
                .collateral,
            escrowAccount[_type][_owner][_id]
                .beneficiaries[_beneficiary]
                .burned,
            escrowAccount[_type][_owner][_id]
                .beneficiaries[_beneficiary]
                .createdBlockNumber
        );
    }
}
