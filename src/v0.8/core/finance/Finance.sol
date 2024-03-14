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
import {FinanceType} from "src/v0.8/types/FinanceType.sol";

import {IRoles} from "src/v0.8/interfaces/core/IRoles.sol";
import {IEscrow} from "src/v0.8/interfaces/core/IEscrow.sol";
import {IFinance} from "src/v0.8/interfaces/core/IFinance.sol";

import {FinanceEvents} from "src/v0.8/shared/events/FinanceEvents.sol";
import {FinanceAccountLIB} from "src/v0.8/core/finance/library/FinanceAccountLIB.sol";
import {FinanceModifiers} from "src/v0.8/shared/modifiers/FinanceModifiers.sol";

import {BusinessFinanceStatistics} from "src/v0.8/core/statistics/BusinessFinanceStatistics.sol";

/// @title Finance
/// @dev Base finance contract, holds funds designated for a payee until they withdraw them.
contract Finance is
    Initializable,
    UUPSUpgradeable,
    RolesModifiers,
    FinanceModifiers,
    BusinessFinanceStatistics,
    IFinance
{
    using FinanceAccountLIB for FinanceType.Account;
    mapping(uint256 => mapping(uint256 => mapping(address => mapping(address => FinanceType.Account))))
        private financeAccount; // mapping(datasetId => mapping(matchingId => mapping(sc/sp/da/dp => mapping(tokentype=>Account))));

    IRoles public roles;
    /// @dev This empty reserved space is put in place to allow future versions to add new
    uint256[32] private __gap;

    /// @notice Initialize function to initialize the contract and grant the default admin role to the deployer.
    function initialize(address _roles) public initializer {
        roles = IRoles(_roles);
        businessFinanceStatisticsInitialize();
        __UUPSUpgradeable_init();
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

    /// @dev Records the deposited amount for a given dataset and matching ID.
    /// @param _datasetId The ID of the dataset.
    /// @param _matchingId The ID of the matching process.
    /// @param _token The type of token used for the deposit (e.g., FIL, ERC-20).
    function deposit(
        uint64 _datasetId,
        uint64 _matchingId,
        address _owner,
        address _token
    ) external payable onlySupportToken(_token) {
        financeAccount[_datasetId][_matchingId][_owner][_token]._deposit(
            msg.value
        );

        emit FinanceEvents.Deposit(
            _datasetId,
            _matchingId,
            _owner,
            _token,
            msg.value
        );
    }

    /// @dev Initiates a withdrawal of funds from the system.
    /// @param _datasetId The ID of the dataset.
    /// @param _matchingId The ID of the matching process.
    /// @param _owner The address of the account owner.
    /// @param _token The type of token for withdrawal (e.g., FIL, ERC-20).
    /// @param _amount The amount to be withdrawn.
    function withdraw(
        uint64 _datasetId,
        uint64 _matchingId,
        address payable _owner,
        address _token,
        uint256 _amount
    ) external onlySupportToken(_token) {
        financeAccount[_datasetId][_matchingId][_owner][_token]._withdraw(
            _amount
        );

        SendAPI.send(FilAddresses.fromEthAddress(_owner), _amount);

        emit FinanceEvents.Withdraw(
            _datasetId,
            _matchingId,
            _owner,
            _token,
            _amount
        );
    }

    /// @dev Initiates an escrow of funds for a given dataset, matching ID, and escrow type.
    /// @param _datasetId The ID of the dataset.
    /// @param _matchingId The ID of the matching process.
    /// @param _token The type of token for escrow (e.g., FIL, ERC-20).
    /// @param _type The type of escrow (e.g., deposit, payment).
    function escrow(
        uint64 _datasetId,
        uint64 _matchingId,
        address _token,
        FinanceType.Type _type
    ) external onlySupportToken(_token) {
        uint256 requirement = getEscrowRequirement(
            _datasetId,
            _matchingId,
            msg.sender,
            _token,
            _type
        );

        if (requirement > 0) {
            // Need to add escrow
            financeAccount[_datasetId][_matchingId][msg.sender][_token]._escrow(
                _type,
                requirement
            );

            _add(
                _getEscrowStatisticsType(_matchingId, _type),
                _token,
                requirement
            );

            emit FinanceEvents.Escrow(
                _datasetId,
                _matchingId,
                msg.sender,
                _token,
                _type,
                requirement
            );
        }
    }

    /// @dev Initiates an escrow of funds for a given dataset, matching ID, and escrow type.
    /// @param _datasetId The ID of the dataset.
    /// @param _matchingId The ID of the matching process.
    /// @param _owner The address of the account owner.
    /// @param _token The type of token for escrow (e.g., FIL, ERC-20).
    /// @param _type The type of escrow (e.g., deposit, payment).
    /// @param _amount The escrow amount for the specified dataset, matching process, and token type.
    function __escrow(
        uint64 _datasetId,
        uint64 _matchingId,
        address _owner,
        address _token,
        FinanceType.Type _type,
        uint256 _amount
    )
        external
        onlySupportToken(_token)
        onlyRole(roles, RolesType.DATASWAP_CONTRACT)
    {
        financeAccount[_datasetId][_matchingId][_owner][_token]._escrow(
            _type,
            _amount
        );

        _add(_getEscrowStatisticsType(_matchingId, _type), _token, _amount);

        emit FinanceEvents.Escrow(
            _datasetId,
            _matchingId,
            _owner,
            _token,
            _type,
            _amount
        );
    }

    /// @dev Handles an escrow, such as claiming or processing it.
    /// @param _datasetId The ID of the dataset.
    /// @param _matchingId The ID of the matching.
    /// @param _token The type of token for escrow handling (e.g., FIL, ERC-20).
    /// @param _type The type of escrow (e.g., deposit, payment).
    function claimEscrow(
        uint64 _datasetId,
        uint64 _matchingId,
        address _token,
        FinanceType.Type _type
    ) external onlySupportToken(_token) {
        FinanceType.PaymentInfo[] memory paymentsInfo = _getEscrowContract(
            _type
        ).__getPayeeInfo(_datasetId, _matchingId, _token);

        _paymentProcess(_datasetId, _matchingId, _token, _type, paymentsInfo);

        _executeStatisticsMatchedAmount(
            _datasetId,
            _matchingId,
            _type,
            _token,
            roles
        );
    }

    /// @dev Handles an escrow, move escrow to owner's destination account.
    /// @param _datasetId The ID of the dataset.
    /// @param _destMatchingId The ID of the matching.
    /// @param _token The type of token for escrow handling (e.g., FIL, ERC-20).
    /// @param _type The type of escrow (e.g., deposit, payment).
    function __claimMoveEscrow(
        uint64 _datasetId,
        uint64 _destMatchingId,
        address _token,
        FinanceType.Type _type
    )
        external
        onlySupportToken(_token)
        onlyRole(roles, RolesType.DATASWAP_CONTRACT)
    {
        FinanceType.PaymentInfo[] memory paymentsInfo = _getEscrowContract(
            _type
        ).__getMoveSourceAccountPayeeInfo(_datasetId, _destMatchingId, _token);
        _moveEscrowFundsProcess(
            _datasetId,
            _destMatchingId,
            _token,
            _type,
            paymentsInfo
        );
    }

    /// @dev Retrieves an account's overview, including deposit, withdraw, burned, balance, lock, escrow.
    /// @param _datasetId The ID of the dataset.
    /// @param _matchingId The ID of the matching process.
    /// @param _token The type of token for the account overview (e.g., FIL, ERC-20).
    /// @param _owner The address of the account owner.
    function getAccountOverview(
        uint64 _datasetId,
        uint64 _matchingId,
        address _owner,
        address _token
    )
        external
        view
        onlySupportToken(_token)
        returns (
            uint256 deposited,
            uint256 withdrawn,
            uint256 burned,
            uint256 balance,
            uint256 available,
            uint256 locks,
            uint256 escrows
        )
    {
        return
            financeAccount[_datasetId][_matchingId][_owner][_token]
                ._getAccountOverview();
    }

    /// @dev Retrieves trading income details for an account.
    /// @param _datasetId The ID of the dataset.
    /// @param _matchingId The ID of the matching process.
    /// @param _token The type of token for trading income details (e.g., FIL, ERC-20).
    /// @param _type The type of escrow (e.g., deposit, payment).
    /// @param _owner The address of the account owner.
    function getAccountIncome(
        uint64 _datasetId,
        uint64 _matchingId,
        address _owner,
        address _token,
        FinanceType.Type _type
    )
        external
        view
        onlySupportToken(_token)
        returns (uint256 total, uint256 lock)
    {
        return
            financeAccount[_datasetId][_matchingId][_owner][_token]
                ._getAccountIncome(_type);
    }

    /// @dev Retrieves escrowed amount for an account.
    /// @param _datasetId The ID of the dataset.
    /// @param _matchingId The ID of the matching process.
    /// @param _owner The address of the account owner.
    /// @param _token The type of token for the escrowed amount (e.g., FIL, ERC-20).
    /// @param _type The type of escrow (e.g., deposit, payment).
    function getAccountEscrow(
        uint64 _datasetId,
        uint64 _matchingId,
        address _owner,
        address _token,
        FinanceType.Type _type
    )
        external
        view
        onlySupportToken(_token)
        returns (
            uint64 latestHeight,
            uint256 expenditure,
            uint256 current,
            uint256 total
        )
    {
        return
            financeAccount[_datasetId][_matchingId][_owner][_token]
                ._getAccountEscrow(_type);
    }

    /// @dev Retrieves the escrow requirement for a specific dataset, matching process, and token type.
    /// @param _datasetId The ID of the dataset.
    /// @param _matchingId The ID of the matching process.
    /// @param _owner The address of the account owner.
    /// @param _token The type of token for the escrow requirement (e.g., FIL, ERC-20).
    /// @return amount The required escrow amount for the specified dataset, matching process, and token type.
    function getEscrowRequirement(
        uint64 _datasetId,
        uint64 _matchingId,
        address _owner,
        address _token,
        FinanceType.Type _type
    ) public view onlySupportToken(_token) returns (uint256 amount) {
        amount = _getEscrowContract(_type).__getRequirement(
            _datasetId,
            _matchingId,
            _owner,
            _token
        );
    }

    /// @notice Checks if the escrowed funds are sufficient for a given dataset, matching, token, and finance type.
    /// @dev This function returns true if the escrowed funds are enough, otherwise, it returns false.
    /// @param _datasetId The ID of the dataset.
    /// @param _matchingId The ID of the matching associated with the dataset.
    /// @param _owner The address of the account owner.
    /// @param _token The address of the token used for escrow.
    /// @param _type The finance type indicating the purpose of the escrow.
    /// @return enough A boolean indicating whether the escrowed funds are enough.
    function isEscrowEnough(
        uint64 _datasetId,
        uint64 _matchingId,
        address _owner,
        address _token,
        FinanceType.Type _type
    ) external view onlySupportToken(_token) returns (bool enough) {
        uint256 requirement = getEscrowRequirement(
            _datasetId,
            _matchingId,
            _owner,
            _token,
            _type
        );

        return (requirement == 0);
    }

    /// @dev Gets the escrow contract address associated with the specified FinanceType.Type.
    /// @param _type The FinanceType.Type specifying the escrow type.
    /// @return base The Base contract representing the escrow contract for the specified type.
    function _getEscrowContract(
        FinanceType.Type _type
    ) internal view returns (IEscrow base) {
        if (_type == FinanceType.Type.EscrowDataTradingFee) {
            base = roles.escrowDataTradingFee();
        } else if (_type == FinanceType.Type.EscrowDatacapChunkLandCollateral) {
            base = roles.escrowDatacapChunkLandCollateral();
        } else if (_type == FinanceType.Type.EscrowChallengeCommission) {
            base = roles.escrowChallengeCommission();
        } else if (_type == FinanceType.Type.EscrowDatacapCollateral) {
            base = roles.escrowDatacapCollateral();
        } else if (_type == FinanceType.Type.EscrowChallengeAuditCollateral) {
            base = roles.escrowChallengeAuditCollateral();
        } else if (_type == FinanceType.Type.EscrowDisputeAuditCollateral) {
            base = roles.escrowDisputeAuditCollateral();
        } else if (_type == FinanceType.Type.EscrowProofAuditCollateral) {
            base = roles.escrowProofAuditCollateral();
        }
    }

    /// @dev Internal function for processing payments.
    /// @param _datasetId The ID of the dataset.
    /// @param _matchingId The ID of the matching.
    /// @param _token The address of the token used for the payment.
    /// @param _type The FinanceType.Type specifying the type of payment.
    /// @param paymentsInfo An array of FinanceType.PaymentInfo containing payment details.
    function _paymentProcess(
        uint64 _datasetId,
        uint64 _matchingId,
        address _token,
        FinanceType.Type _type,
        FinanceType.PaymentInfo[] memory paymentsInfo
    ) internal onlySupportToken(_token) {
        for (uint256 i = 0; i < paymentsInfo.length; i++) {
            if (paymentsInfo[i].amount != 0) {
                // Payer account payment.
                financeAccount[_datasetId][_matchingId][paymentsInfo[i].payer][
                    _token
                ]._payment(_type, paymentsInfo[i].amount);

                for (uint256 j = 0; j < paymentsInfo[i].payees.length; j++) {
                    // Payee account income.
                    financeAccount[_datasetId][_matchingId][
                        paymentsInfo[i].payees[j].payee
                    ][_token]._income(_type, paymentsInfo[i].payees[j].amount);

                    _sub(
                        _getPayerStatisticsType(
                            _datasetId,
                            _type,
                            paymentsInfo[i].payer,
                            roles
                        ),
                        _token,
                        paymentsInfo[i].payees[j].amount
                    );

                    _add(
                        _getPayeeStatisticsType(
                            _datasetId,
                            paymentsInfo[i].payer,
                            paymentsInfo[i].payees[j].payee,
                            _type,
                            roles
                        ),
                        _token,
                        paymentsInfo[i].payees[j].amount
                    );

                    // Payee account is burnAddress, burn process.
                    if (
                        paymentsInfo[i].payees[j].payee ==
                        roles.filplus().getBurnAddress()
                    ) {
                        financeAccount[_datasetId][_matchingId][
                            paymentsInfo[i].payer
                        ][_token]._burn(paymentsInfo[i].payees[j].amount);

                        SendAPI.send(
                            FilAddresses.fromEthAddress(
                                roles.filplus().getBurnAddress()
                            ),
                            paymentsInfo[i].payees[j].amount
                        );
                    }
                }
            }
        }
    }

    /// @dev Internal function for processing move account escrow.
    /// @param _datasetId The ID of the dataset.
    /// @param _destMatchingId The ID of the matching.
    /// @param _token The address of the token used for the payment.
    /// @param _type The FinanceType.Type specifying the type of payment.
    /// @param paymentsInfo An array of FinanceType.PaymentInfo containing payment details.
    function _moveEscrowFundsProcess(
        uint64 _datasetId,
        uint64 _destMatchingId,
        address _token,
        FinanceType.Type _type,
        FinanceType.PaymentInfo[] memory paymentsInfo
    ) internal onlySupportToken(_token) {
        for (uint256 i = 0; i < paymentsInfo.length; i++) {
            if (paymentsInfo[i].amount != 0) {
                // Source account payment.
                financeAccount[_datasetId][0][paymentsInfo[i].payer][_token]
                    ._payment(_type, paymentsInfo[i].amount);

                for (uint256 j = 0; j < paymentsInfo[i].payees.length; j++) {
                    // Destination account income.
                    financeAccount[_datasetId][_destMatchingId][
                        paymentsInfo[i].payees[j].payee
                    ][_token]._income(_type, paymentsInfo[i].payees[j].amount);

                    // Destination account escrow.
                    financeAccount[_datasetId][_destMatchingId][
                        paymentsInfo[i].payees[j].payee
                    ][_token]._escrow(_type, paymentsInfo[i].payees[j].amount);
                }
            }
        }
    }
}
