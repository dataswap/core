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
import {IFinance} from "src/v0.8/interfaces/core/IFinance.sol";
import {DataTradingFeeLIB} from "src/v0.8/core/finance/library/DataTradingFeeLIB.sol";
import {DatacapChunkLandLIB} from "src/v0.8/core/finance/library/DatacapChunkLandLIB.sol";
import {ChallengeCommissionLIB} from "src/v0.8/core/finance/library/ChallengeCommissionLIB.sol";
import {DatacapCollateralLIB} from "src/v0.8/core/finance/library/DatacapCollateralLIB.sol";

import {IRoles} from "src/v0.8/interfaces/core/IRoles.sol";

/// @title Finance
/// @dev Base finance contract, holds funds designated for a payee until they withdraw them.
contract Finance is Initializable, UUPSUpgradeable, RolesModifiers, IFinance {
    mapping(uint256 => mapping(uint256 => mapping(address => mapping(address => FinanceType.Account))))
        private financeAccount; // mapping(datasetId => mapping(matchingId => mapping(sc/sp/da/dp => mapping(tokentype=>Account))));

    IRoles private roles;

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

    /// @dev Records the deposited amount for a given dataset and matching ID.
    /// @param _datasetId The ID of the dataset.
    /// @param _matchingId The ID of the matching process.
    /// @param _token The type of token used for the deposit (e.g., FIL, ERC-20).
    function deposit(
        uint64 _datasetId,
        uint64 _matchingId,
        address _owner,
        address _token
    ) external payable {}

    /// @dev Initiates a withdrawal of funds from the system.
    /// @param _datasetId The ID of the dataset.
    /// @param _matchingId The ID of the matching process.
    /// @param _token The type of token for withdrawal (e.g., FIL, ERC-20).
    /// @param _amount The amount to be withdrawn.
    function withdraw(
        uint64 _datasetId,
        uint64 _matchingId,
        address payable _owner,
        address _token,
        uint256 _amount
    ) external {}

    /// @dev Initiates an escrow of funds for a given dataset, matching ID, and escrow type.
    /// @param _datasetId The ID of the dataset.
    /// @param _matchingId The ID of the matching process.
    /// @param _token The type of token for escrow (e.g., FIL, ERC-20).
    /// @param _amount The amount to be escrowed.
    /// @param _type The type of escrow (e.g., deposit, payment).
    function escrow(
        uint64 _datasetId,
        uint64 _matchingId,
        address _token,
        uint256 _amount,
        FinanceType.Type _type
    ) external {}

    /// @dev Handles an escrow, such as claiming or processing it.
    /// @param _datasetId The ID of the dataset.
    /// @param _matchingId The ID of the matching process.
    /// @param _token The type of token for escrow handling (e.g., FIL, ERC-20).
    /// @param _type The type of escrow (e.g., deposit, payment).
    function claimEscrow(
        uint64 _datasetId,
        uint64 _matchingId,
        address _token,
        FinanceType.Type _type
    ) external view {
        if (_type == FinanceType.Type.DataTradingFee) {
            DataTradingFeeLIB.getPayeeInfo(
                _datasetId,
                _matchingId,
                _token,
                roles
            );
        } else if (_type == FinanceType.Type.DatacapChunkLandCollateral) {
            DatacapChunkLandLIB.getPayeeInfo(
                _datasetId,
                _matchingId,
                _token,
                roles
            );
        } else if (_type == FinanceType.Type.ChallengeCommission) {
            ChallengeCommissionLIB.getPayeeInfo(
                _datasetId,
                _matchingId,
                _token,
                roles
            );
        } else if (_type == FinanceType.Type.DatacapCollateral) {
            DatacapCollateralLIB.getPayeeInfo(
                _datasetId,
                _matchingId,
                _token,
                roles
            );
        }
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
        returns (
            uint256 deposited,
            uint256 withdrawn,
            uint256 burned,
            uint256 balance,
            uint256 available,
            uint256 locks,
            uint256 escrows
        )
    {}

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
    ) external view returns (uint256 total, uint256 lock) {}

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
        returns (uint64 latestHeight, uint256 expenditure, uint256 total)
    {}

    /// @dev Retrieves the escrow requirement for a specific dataset, matching process, and token type.
    /// @param _datasetId The ID of the dataset.
    /// @param _matchingId The ID of the matching process.
    /// @param _owner The address of the account owner.
    /// @param _token The type of token for the escrow requirement (e.g., FIL, ERC-20).
    /// @return amount The required escrow amount for the specified dataset, matching process, and token type.
    /// Note: TypeX_EscrowLibrary needs to include the following methods.
    /// .     function getRequirement(
    ///         uint64 _datasetId,
    ///         uint64 _matchingId,
    ///         address _token
    ///       ) public view returns (uint256 amount);
    function getEscrowRequirement(
        uint64 _datasetId,
        uint64 _matchingId,
        address _owner,
        address _token,
        FinanceType.Type _type
    ) external view returns (uint256 amount) {}

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
    ) external view returns (bool enough) {
        if (_type == FinanceType.Type.DataTradingFee) {
            enough = DataTradingFeeLIB.isEscrowEnough(
                _datasetId,
                _matchingId,
                _owner,
                _token,
                roles
            );
        } else if (_type == FinanceType.Type.DatacapChunkLandCollateral) {
            enough = DatacapChunkLandLIB.isEscrowEnough(
                _datasetId,
                _matchingId,
                _owner,
                _token,
                roles
            );
        } else if (_type == FinanceType.Type.ChallengeCommission) {
            enough = ChallengeCommissionLIB.isEscrowEnough(
                _datasetId,
                _matchingId,
                _owner,
                _token,
                roles
            );
        } else if (_type == FinanceType.Type.DatacapCollateral) {
            enough = DatacapCollateralLIB.isEscrowEnough(
                _datasetId,
                _matchingId,
                _owner,
                _token,
                roles
            );
        }
    }
}
