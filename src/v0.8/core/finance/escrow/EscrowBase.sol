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

// upgrade
import {RolesType} from "src/v0.8/types/RolesType.sol";
import {RolesModifiers} from "src/v0.8/shared/modifiers/RolesModifiers.sol";
import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {UUPSUpgradeable} from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

import {DatasetType} from "src/v0.8/types/DatasetType.sol";
import {FinanceType} from "src/v0.8/types/FinanceType.sol";
import {IRoles} from "src/v0.8/interfaces/core/IRoles.sol";
import {MatchingType} from "src/v0.8/types/MatchingType.sol";
import {IEscrow} from "src/v0.8/interfaces/core/IEscrow.sol";
import {ArraysPaymentInfoLIB} from "src/v0.8/shared/utils/array/ArrayLIB.sol";

/// @title EscrowBase
/// @dev This EscrowBase provides functions for managing Escrow-related operations.
abstract contract EscrowBase is
    Initializable,
    UUPSUpgradeable,
    RolesModifiers,
    IEscrow
{
    using ArraysPaymentInfoLIB for FinanceType.PaymentInfo[];

    IRoles public roles;

    /// @dev This empty reserved space is put in place to allow future versions to add new
    uint256[32] private __gap;

    /// @notice Initialize function to initialize the contract and grant the default admin role to the deployer.
    function initialize(address _roles) public initializer {
        roles = IRoles(_roles);
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

    /// @dev Retrieves payee information.
    /// @param _datasetId The ID of the dataset.
    /// @param _matchingId The ID of the matching process.
    /// @param _token The type of token for escrow handling (e.g., FIL, ERC-20).
    /// @return paymentsInfo An array containing the payees's address.
    function __getPayeeInfo(
        uint64 _datasetId,
        uint64 _matchingId,
        address _token
    )
        external
        view
        virtual
        onlyRole(roles, RolesType.DATASWAP_CONTRACT)
        returns (FinanceType.PaymentInfo[] memory paymentsInfo)
    {
        // 1. Get payers
        address[] memory payers = _getPayers(_datasetId, _matchingId);
        paymentsInfo = new FinanceType.PaymentInfo[](0);

        if (_isRefund(_datasetId, _matchingId)) {
            // 2.1 Get refund info
            FinanceType.PaymentInfo[] memory refundInfo = _getRefundInfo(
                _datasetId,
                _matchingId,
                payers,
                _token
            );
            paymentsInfo = paymentsInfo.appendArrays(refundInfo);
        }

        if (_isBurn(_datasetId, _matchingId)) {
            // 2.2 Get burn info
            FinanceType.PaymentInfo[] memory burnInfo = _getBurnInfo(
                _datasetId,
                _matchingId,
                payers,
                _token
            );
            paymentsInfo = paymentsInfo.appendArrays(burnInfo);
        }

        if (_isPayment(_datasetId, _matchingId)) {
            // 2.3 Get payment payees
            address[] memory payees = _getPayees(_datasetId, _matchingId);
            // 2.4 Get payment info
            FinanceType.PaymentInfo[] memory paymentInfo = _getPaymentInfo(
                _datasetId,
                _matchingId,
                payers,
                payees,
                _token
            );
            paymentsInfo = paymentsInfo.appendArrays(paymentInfo);
        }
    }

    /// @dev Retrieves move source account payee information.
    /// @param _datasetId The ID of the dataset.
    /// @param _destMatchingId The ID of the matching process.
    /// @param _token The type of token for escrow handling (e.g., FIL, ERC-20).
    /// @return paymentsInfo An array containing the payees's address.
    function __getMoveSourceAccountPayeeInfo(
        uint64 _datasetId,
        uint64 _destMatchingId,
        address _token
    )
        external
        view
        virtual
        onlyRole(roles, RolesType.DATASWAP_CONTRACT)
        returns (FinanceType.PaymentInfo[] memory paymentsInfo)
    {
        paymentsInfo = _getMoveSourceAccountInfo(
            _datasetId,
            _destMatchingId,
            _token
        );
    }

    /// @notice Get dataset pre-conditional collateral requirement.
    /// @return amount The collateral requirement amount.
    function __getRequirement(
        uint64 /*_datasetId*/,
        uint64 /*_matchingId*/,
        address /*_payer*/,
        address /*_token*/
    )
        public
        view
        virtual
        onlyRole(roles, RolesType.DATASWAP_CONTRACT)
        returns (
            uint256 amount // solhint-disable-next-line
        )
    {}

    /// @dev Internal function to get refund information.
    /// @param _datasetId The ID of the dataset.
    /// @param _matchingId The ID of the matching process.
    /// @param _payers An array containing the addresses of the dataset and matching process payers.
    /// @param _token The type of token for escrow handling (e.g., FIL, ERC-20).
    /// @return refunds An array containing payment information for refund.
    function _getRefundInfo(
        uint64 _datasetId,
        uint64 _matchingId,
        address[] memory _payers,
        address _token
    ) internal view virtual returns (FinanceType.PaymentInfo[] memory refunds) {
        uint256 payersLen = _payers.length;
        refunds = new FinanceType.PaymentInfo[](payersLen);
        for (uint256 i = 0; i < payersLen; i++) {
            uint256 amount = _getRefundAmount(
                _datasetId,
                _matchingId,
                _payers[i],
                _token
            );
            if (amount != 0) {
                FinanceType.PayeeInfo[]
                    memory payees = new FinanceType.PayeeInfo[](1);
                payees[0] = FinanceType.PayeeInfo(_payers[i], amount);
                refunds[i] = FinanceType.PaymentInfo(
                    _payers[i],
                    amount,
                    payees
                );
            }
        }
    }

    /// @dev Internal function to get burn information.
    /// @param _datasetId The ID of the dataset.
    /// @param _matchingId The ID of the matching process.
    /// @param _payers An array containing the addresses of the dataset and matching process payers.
    /// @param _token The type of token for escrow handling (e.g., FIL, ERC-20).
    /// @return burns An array containing payment information for burn.
    function _getBurnInfo(
        uint64 _datasetId,
        uint64 _matchingId,
        address[] memory _payers,
        address _token
    ) internal view virtual returns (FinanceType.PaymentInfo[] memory burns) {
        uint256 payersLen = _payers.length;
        burns = new FinanceType.PaymentInfo[](payersLen);
        for (uint256 i = 0; i < payersLen; i++) {
            uint256 amount = _getBurnAmount(
                _datasetId,
                _matchingId,
                _payers[i],
                _token
            );
            if (amount != 0) {
                FinanceType.PayeeInfo[]
                    memory payees = new FinanceType.PayeeInfo[](1);
                payees[0] = FinanceType.PayeeInfo(
                    roles.filplus().getBurnAddress(),
                    amount
                );
                burns[i] = FinanceType.PaymentInfo(_payers[i], amount, payees);
            }
        }
    }

    /// @dev Internal function to get payment information.
    /// @param _datasetId The ID of the dataset.
    /// @param _matchingId The ID of the matching process.
    /// @param _payers An array containing the addresses of the dataset and matching process payers.
    /// @param _payees An array containing the address of the matching process initiator.
    /// @param _token The type of token for escrow handling (e.g., FIL, ERC-20).
    /// @return payments An array containing payment information.
    function _getPaymentInfo(
        uint64 _datasetId,
        uint64 _matchingId,
        address[] memory _payers,
        address[] memory _payees,
        address _token
    )
        internal
        view
        virtual
        returns (FinanceType.PaymentInfo[] memory payments)
    {
        uint256 payersLen = _payers.length;
        uint256 payeesLen = _payees.length;
        payments = new FinanceType.PaymentInfo[](payersLen);
        for (uint256 i = 0; i < payersLen; i++) {
            uint256 amount = _getPaymentAmount(
                _datasetId,
                _matchingId,
                _payers[i],
                _token
            );
            if (amount != 0) {
                FinanceType.PayeeInfo[]
                    memory payees = new FinanceType.PayeeInfo[](payeesLen);
                for (uint256 j = 0; j < payeesLen; j++) {
                    payees[j] = FinanceType.PayeeInfo(
                        _payees[j],
                        amount / payeesLen
                    );
                }

                payments[i] = FinanceType.PaymentInfo(
                    _payers[i],
                    amount,
                    payees
                );
            }
        }
    }

    /// @dev Internal function to get move source account information.
    /// @return refunds An array containing payment information.
    function _getMoveSourceAccountInfo(
        uint64 /*_datasetId*/,
        uint64 /*_destMatchingId*/,
        address /*_token*/
    )
        internal
        view
        virtual
        returns (
            FinanceType.PaymentInfo[] memory // solhint-disable-next-line
        )
    {}

    /// @dev Internal function to get payers associated with a dataset and matching process.
    /// @return payers An array containing the addresses of the dataset and matching process payers.
    function _getPayers(
        uint64 /*_datasetId*/,
        uint64 /*_matchingId*/
    )
        internal
        view
        virtual
        returns (
            address[] memory payers // solhint-disable-next-line
        )
    {}

    /// @dev Internal function to get payees associated with a dataset and matching process.
    /// @return payees An array containing the address of the matching process initiator.
    function _getPayees(
        uint64 /*_datasetId*/,
        uint64 /*_matchingId*/
    )
        internal
        view
        virtual
        returns (
            address[] memory payees // solhint-disable-next-line
        )
    {}

    /// @dev Internal function to get refund amount.
    /// @return amount The refund amount.
    function _getRefundAmount(
        uint64 /*_datasetId*/,
        uint64 /*_matchingId*/,
        address /*_payer*/,
        address /*_token*/
    )
        internal
        view
        virtual
        returns (
            uint256 amount // solhint-disable-next-line
        )
    {}

    /// @dev Internal function to get burn amount.
    /// @return amount The burn amount.
    function _getBurnAmount(
        uint64 /*_datasetId*/,
        uint64 /*_matchingId*/,
        address /*_payer*/,
        address /*_token*/
    )
        internal
        view
        virtual
        returns (
            uint256 amount // solhint-disable-next-line
        )
    {}

    /// @dev Internal function to get payment amount.
    /// @return amount The payment amount.
    function _getPaymentAmount(
        uint64 /*_datasetId*/,
        uint64 /*_matchingId*/,
        address /*_payer*/,
        address /*_token*/
    )
        internal
        view
        virtual
        returns (
            uint256 amount // solhint-disable-next-line
        )
    {}

    /// @dev Internal function to check if a refund is applicable.
    /// @return refund A boolean indicating whether a refund is applicable.
    function _isRefund(
        uint64 /*_datasetId*/,
        uint64 /*_matchingId*/
    ) internal view virtual returns (bool refund) {
        return false;
    }

    /// @dev Internal function to check if a burn is applicable.
    /// @return burn A boolean indicating whether a burn is applicable.
    function _isBurn(
        uint64 /*_datasetId*/,
        uint64 /*_matchingId*/
    ) internal view virtual returns (bool burn) {
        return false;
    }

    /// @dev Internal function to check if a payment is applicable.
    /// @return payment A boolean indicating whether a payment is applicable.
    function _isPayment(
        uint64 /*_datasetId*/,
        uint64 /*_matchingId*/
    ) internal view virtual returns (bool payment) {
        return false;
    }
}
