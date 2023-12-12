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

import {SendAPI} from "src/v0.8/vendor/filecoin-solidity/contracts/v0.8/SendAPI.sol";
import {FilAddresses} from "src/v0.8/vendor/filecoin-solidity/contracts/v0.8/utils/FilAddresses.sol";

// upgrade
import {RolesType} from "src/v0.8/types/RolesType.sol";
import {RolesModifiers} from "src/v0.8/shared/modifiers/RolesModifiers.sol";
import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {UUPSUpgradeable} from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

// type
import {EscrowType} from "src/v0.8/types/EscrowType.sol";

// interface
import {IRoles} from "src/v0.8/interfaces/core/IRoles.sol";
import {IEscrow} from "src/v0.8/interfaces/core/IEscrow.sol";
import {IStorages} from "src/v0.8/interfaces/module/IStorages.sol";
import {IDatacaps} from "src/v0.8/interfaces/module/IDatacaps.sol";
import {IDatasetsProof} from "src/v0.8/interfaces/module/IDatasetsProof.sol";

// shared
import {Errors} from "src/v0.8/shared/errors/Errors.sol";
import {EscrowEvents} from "src/v0.8/shared/events/EscrowEvents.sol";
import {EscrowLIB} from "src/v0.8/core/finance/library/EscrowLIB.sol";
import {ConditionalEscrowLIB} from "src/v0.8/core/finance/library/ConditionalEscrowLIB.sol";

/// @title Escrow
/// @dev Base escrow contract, holds funds designated for a payee until they withdraw them.
contract Escrow is Initializable, UUPSUpgradeable, RolesModifiers, IEscrow {
    using EscrowLIB for EscrowType.Escrow;

    mapping(EscrowType.Type => mapping(address => mapping(uint256 => EscrowType.Escrow)))
        private escrowAccount; // mapping(type, mapping(payee, mapping(id, Escrow)))

    IRoles private roles;
    IStorages private storages;
    IDatacaps private datacaps;
    IDatasetsProof private datasetsProof;

    address payable public constant BURN_ADDRESS =
        payable(0xff00000000000000000000000000000000000063); // Filecoin burn address. TODO: BURN_ADDRESS import from governance
    /// @dev This empty reserved space is put in place to allow future versions to add new
    uint256[32] private __gap;

    /// @notice Initialize function to initialize the contract and grant the default admin role to the deployer.
    function initialize(address _roles) public initializer {
        roles = IRoles(_roles);
        __UUPSUpgradeable_init();
    }

    /// @notice Set dependencies function to initialize the depend contract.
    /// @dev After the contract is deployed, this function needs to be called manually!
    function initDependencies(
        address _datasetsProof,
        address _storages,
        address _datacaps
    ) public onlyRole(roles, RolesType.DEFAULT_ADMIN_ROLE) {
        storages = IStorages(_storages);
        datacaps = IDatacaps(_datacaps);
        datasetsProof = IDatasetsProof(_datasetsProof);
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

    /// @dev Records the sent amount as credit for future payment withdraw.
    /// Note Called by the payer to store the sent amount as credit to be pulled.
    /// Funds sent in this way are stored in an intermediate {Escrow} contract, so
    /// there is no danger of them being spent before withdrawal.
    /// @param _type The Escrow type for the credited funds.
    /// @param _owner The destination address for the credited funds.
    /// @param _id The business id associated with the credited funds.
    /// @param _amount The collateral funds.
    /// @notice Emits a {Payment} event upon successful credit recording.
    function payment(
        EscrowType.Type _type,
        address _owner,
        uint64 _id,
        uint256 _amount
    ) public payable {
        uint256 total = msg.value;
        escrowAccount[_type][_owner][_id].deposit(total);
        escrowAccount[_type][_owner][_id].payment(_amount);

        emit EscrowEvents.Payment(_type, _owner, _id, _amount);
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
    /// @notice Emits a {PaymentSingleBeneficiary} event upon successful credit recording.
    function paymentSingleBeneficiary(
        EscrowType.Type _type,
        address _owner,
        uint64 _id,
        address _beneficiary,
        uint256 _amount
    ) public payable {
        uint256 total = msg.value;
        if (total < _amount) {
            revert Errors.ExceedValidPaymentAmount(total, _amount);
        }

        escrowAccount[_type][_owner][_id].deposit(total);
        escrowAccount[_type][_owner][_id].payment(_amount);
        escrowAccount[_type][_owner][_id].paymentAddbeneficiary(
            _beneficiary,
            _amount
        );

        emit EscrowEvents.PaymentSingleBeneficiary(
            _type,
            _owner,
            _id,
            _beneficiary,
            _amount
        );
    }

    /// @notice Withdraw funds authorized for an address.
    /// @dev This function allows anyone to initiate a withdrawal of authorized funds.
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

    /// @notice Payment withdraw funds authorized for an address.
    /// @dev This function allows anyone to initiate a withdrawal of authorized funds.
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

    /// @notice Payment transfer funds from locked to unlocked.Only total data prepare fee allowed transfer.
    /// @param _type The Escrow type for the credited funds.
    /// @param _owner The destination address for the credited funds.
    /// @param _id The business id associated with the credited funds.
    /// @param _amount The payment transfer credited funds.
    /// @notice Emits a {PaymentTransfer} event upon successful credit recording.
    function paymentTransfer(
        EscrowType.Type _type,
        address _owner,
        uint64 _id,
        uint256 _amount
    ) external onlyAddress(_owner) {
        if (_type != EscrowType.Type.TotalDataPrepareFeeByClient) {
            revert Errors.OnlySpecifyTypeAllowedTransfer();
        }

        escrowAccount[_type][_owner][_id].paymentTransfer(_amount);

        emit EscrowEvents.PaymentTransfer(_type, _owner, _id, _amount);
    }

    /// @notice Refund funds authorized for an address.
    /// @param _type The Escrow type for the credited funds.
    /// @param _owner The destination address for the credited funds.
    /// @param _id The business id associated with the credited funds.
    /// @notice Emits a {PaymentRefund} event upon successful credit recording.
    function paymentRefund(
        EscrowType.Type _type,
        address _owner,
        uint64 _id
    ) external {
        if (
            ConditionalEscrowLIB.isPaymentAllowRefund(
                _type,
                _owner,
                _id,
                storages
            ) != true
        ) {
            revert Errors.NotRefundableAmount();
        }

        address[] storage beneficiaries = escrowAccount[_type][_owner][_id]
            .beneficiariesList;
        uint256 amount = 0;
        // Refund beneficiaries lock funds.
        for (uint i = 0; i < beneficiaries.length; i++) {
            amount = escrowAccount[_type][_owner][_id].paymentRefund(
                beneficiaries[i]
            );

            emit EscrowEvents.PaymentRefund(
                _type,
                _owner,
                _id,
                beneficiaries[i],
                amount
            );
        }

        // Refund without beneficiary lock funds.
        amount = escrowAccount[_type][_owner][_id]
            .paymentRefundWithoutBeneficiary();
        if (amount != 0) {
            emit EscrowEvents.PaymentRefund(
                _type,
                _owner,
                _id,
                address(0),
                amount
            );
        }
    }

    /// @notice Redeem funds authorized for an address.
    /// Redeem the collateral funds after the collateral expires.
    /// @param _type The Escrow type for the credited funds.
    /// @param _owner The destination address for the credited funds.
    /// @param _id The business id associated with the credited funds.
    /// @notice Emits a {UpdateCollateral} event upon successful credit recording.
    function collateralRedeem(
        EscrowType.Type _type,
        address _owner,
        uint64 _id
    ) external {
        // Update collateral funds
        uint256 amount = _syncCollateral(_type, _owner, _id);
        _updateCollateral(_type, _owner, _id, amount);
    }

    /// @notice Post an event for collateral type. Called by internal contract.
    /// @param _type The Escrow type for the credited funds.
    /// @param _owner The destination address for the credited funds.
    /// @param _id The business id associated with the credited funds.
    /// @param _event The collateral event type.
    function __emitCollateralUpdate(
        EscrowType.Type _type,
        address _owner,
        uint64 _id,
        EscrowType.CollateralEvent _event
    ) public onlyRole(roles, RolesType.DATASWAP_CONTRACT) {
        if (_event == EscrowType.CollateralEvent.SyncBurn) {
            uint256 amount = _syncBurn(_type, _owner, _id);
            _updateBurn(_type, payable(_owner), _id, amount);
        } else if (_event == EscrowType.CollateralEvent.SyncCollateral) {
            uint256 amount = _syncCollateral(_type, _owner, _id);
            _updateCollateral(_type, _owner, _id, amount);
        }
    }

    /// @notice Post an event for payment type. Called by internal contract.
    /// @param _type The Escrow type for the credited funds.
    /// @param _owner The destination address for the credited funds.
    /// @param _id The business id associated with the credited funds.
    /// @param _beneficiary The beneficiary address for the payment credited funds.
    /// @param _event The payment event type.
    function __emitPaymentUpdate(
        EscrowType.Type _type,
        address _owner,
        uint64 _id,
        address _beneficiary,
        EscrowType.PaymentEvent _event
    ) external onlyRole(roles, RolesType.DATASWAP_CONTRACT) {
        if (_event == EscrowType.PaymentEvent.SyncPaymentLock) {
            uint256 amount = _syncPaymentLock(_type, _owner, _id, _beneficiary);
            _updatePaymentLock(_type, _owner, _id, _beneficiary, amount);
        } else if (_event == EscrowType.PaymentEvent.SyncPaymentBeneficiary) {
            uint256 amount = _syncPaymentBeneficiary(
                _type,
                _owner,
                _id,
                _beneficiary
            );
            _updatePaymentBeneficiary(_type, _owner, _id, _beneficiary, amount);
        } else if (_event == EscrowType.PaymentEvent.AddPaymentSubAccount) {
            uint256 amount = _getPaymentSubAccountAmount(
                _type,
                _owner,
                _id,
                _beneficiary
            );
            _addPaymentSubAccount(
                _type,
                _owner,
                _id,
                _beneficiary,
                amount,
                EscrowType.Type.DataPrepareFeeByClient
            );
        }
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
        uint256 collateralAmount = escrowAccount[_type][_owner][_id]
            .owner
            .collateral;

        if (collateralAmount != 0) {
            if (_type == EscrowType.Type.DatacapCollateral) {
                collateralAmount = ConditionalEscrowLIB.datacapCollateral(
                    _id,
                    storages,
                    datasetsProof,
                    escrowAccount[_type][_owner][_id].owner.createdBlockNumber,
                    escrowAccount[_type][_owner][_id].owner.total
                );
            } else if (_type == EscrowType.Type.DatacapChunkCollateral) {
                collateralAmount =
                    ConditionalEscrowLIB.datacapChunkCollateral(_id, datacaps) -
                    escrowAccount[_type][_owner][_id].owner.burned;
            }
        }

        return collateralAmount;
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
        // Burns only once
        if (escrowAccount[_type][_owner][_id].owner.burned == 0) {
            if (_type == EscrowType.Type.DatacapChunkCollateral) {
                return ConditionalEscrowLIB.datacapChunkBurn(_id, datacaps);
            }
        }

        return 0;
    }

    /// @dev Handles the logic for payments based on escrow type, owner, ID, and beneficiary.
    /// @param _type The Escrow type for the credited funds.
    /// @param _owner The destination address for the credited funds.
    /// @param _id The business id associated with the credited funds.
    /// @param _beneficiary The beneficiary address for the payment credited funds.
    function _syncPaymentLock(
        EscrowType.Type _type,
        address _owner,
        uint64 _id,
        address _beneficiary
    ) internal view returns (uint256) {
        uint256 lockAmount = escrowAccount[_type][_owner][_id]
            .beneficiaries[_beneficiary]
            .lock;

        if (lockAmount != 0) {
            if (_type == EscrowType.Type.DataPrepareFeeByProvider) {
                lockAmount = ConditionalEscrowLIB.providerLockPayment(
                    _id,
                    storages
                );
            } else if (_type == EscrowType.Type.DataPrepareFeeByClient) {
                lockAmount = ConditionalEscrowLIB.clientLockPayment(
                    _id,
                    storages
                );
            } else if (_type == EscrowType.Type.DatasetAuditFee) {
                lockAmount = 0; // data audit fees needn't lock payment
            }
        }

        return lockAmount;
    }

    /// @dev Handles the logic for synchronize payment beneficiary based on escrow type, owner, ID.
    function _syncPaymentBeneficiary(
        EscrowType.Type _type,
        address _owner,
        uint64 _id,
        address _beneficiary
    ) internal view returns (uint256) {
        if (_type == EscrowType.Type.DataPrepareFeeByProvider) {
            return
                ConditionalEscrowLIB.paymentBeneficiaryAmountByProvider(
                    _owner,
                    _id,
                    _beneficiary,
                    escrowAccount[_type][_owner][_id].owner.lock,
                    storages
                );
        } else if (_type == EscrowType.Type.DatasetAuditFee) {
            return
                ConditionalEscrowLIB.paymentBeneficiaryAmountDataAuditFee(
                    _id,
                    datasetsProof
                );
        }

        return 0;
    }

    /// @dev Handles the logic for synchronize sub payment account based on escrow type, owner, ID.
    /// @param _type The Escrow type for the credited funds.
    /// @param _owner The destination address for the credited funds.
    /// @param _id The business id associated with the credited funds.
    /// @param _beneficiary The beneficiary address for the payment credited funds.
    function _getPaymentSubAccountAmount(
        EscrowType.Type _type,
        address _owner,
        uint64 _id, // matchingId
        address _beneficiary
    ) internal view returns (uint256) {
        if (_type == EscrowType.Type.TotalDataPrepareFeeByClient) {
            if (
                _beneficiary != storages.matchings().getMatchingInitiator(_id)
            ) {
                revert Errors.BeneficiaryIsInvalid(_beneficiary);
            }

            (uint64 datasetId, , , , , , ) = storages
                .matchingsTarget()
                .getMatchingTarget(_id);
            return
                ConditionalEscrowLIB.clientSubPaymentAccount(
                    _id,
                    datasetId,
                    escrowAccount[_type][_owner][datasetId].owner.lock,
                    datasetsProof,
                    storages
                );
        }

        return 0;
    }

    /// @notice Update collateral funds authorized for an address.
    /// @dev This function allows update collateral funds authorized for an address.
    /// @param _type The Escrow type for the credited funds.
    /// @param _owner The destination address for the credited funds.
    /// @param _id The business id associated with the credited funds.
    /// @param _amount The collateral funds.
    /// @notice Emits a {UpdateCollateral} event upon success.
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
    /// @notice Emits a {Burn} event upon success.
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

    /// @notice Update payment allow withdraw funds authorized for an address.
    /// @dev This function allows withdraw funds.Triggered by business conditions
    /// @param _type The Escrow type for the credited funds.
    /// @param _owner The destination address for the credited funds.
    /// @param _id The business id associated with the credited funds.
    /// @param _amount The burn funds.
    /// @notice Emits a {UpdatePaymentLock} event upon success.
    function _updatePaymentLock(
        EscrowType.Type _type,
        address _owner,
        uint64 _id,
        address _beneficiary,
        uint256 _amount
    ) internal {
        escrowAccount[_type][_owner][_id].updatePaymentLock(
            _beneficiary,
            _amount
        );

        emit EscrowEvents.UpdatePaymentLock(
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

    /// @notice Update payment sub-account authorized for an address.
    /// @param _type The Escrow type for the credited funds.
    /// @param _owner The destination address for the credited funds.
    /// @param _id The business id associated with the credited funds.
    /// @param _beneficiary The beneficiary address for the payment credited funds.
    /// @param _amount The payment amount of beneficiaries.
    /// @param _subAccountType The sub account type.
    /// @notice Emits a {UpdatePaymentSubAccount} event upon successful credit recording.
    function _addPaymentSubAccount(
        EscrowType.Type _type,
        address _owner,
        uint64 _id,
        address _beneficiary,
        uint256 _amount,
        EscrowType.Type _subAccountType
    ) internal {
        if (
            escrowAccount[_subAccountType][_owner][_id]
                .owner
                .createdBlockNumber != 0
        ) {
            revert Errors.SubAccountAlreadyExist(_owner);
        }

        (uint64 datasetId, , , , , , ) = storages
            .matchingsTarget()
            .getMatchingTarget(_id);
        EscrowType.Escrow storage escrow = escrowAccount[_type][_owner][
            datasetId
        ];
        if (escrow.owner.lock < _amount) {
            revert Errors.ExceedValidPaymentAmount(escrow.owner.lock, _amount);
        }
        escrow.owner.total -= _amount;
        escrow.owner.lock -= _amount;

        EscrowType.Escrow storage newEscrow = escrowAccount[_subAccountType][
            _owner
        ][_id];
        newEscrow.deposit(_amount);
        newEscrow.payment(_amount);
        newEscrow.paymentAddbeneficiary(_beneficiary, _amount);

        emit EscrowEvents.UpdatePaymentSubAccount(
            _type,
            _owner,
            _id,
            _beneficiary,
            _amount,
            _subAccountType
        );
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

    /// @notice Get owner fund.
    /// @param _type The Escrow type for the credited funds.
    /// @param _owner The destination address for the credited funds.
    /// @param _id The business id associated with the credited funds.
    function getOwnerFund(
        EscrowType.Type _type,
        address _owner,
        uint64 _id
    ) public view returns (uint256, uint256, uint256, uint256, uint64) {
        return (
            escrowAccount[_type][_owner][_id].owner.total,
            escrowAccount[_type][_owner][_id].owner.lock,
            escrowAccount[_type][_owner][_id].owner.collateral,
            escrowAccount[_type][_owner][_id].owner.burned,
            escrowAccount[_type][_owner][_id].owner.createdBlockNumber
        );
    }
}
