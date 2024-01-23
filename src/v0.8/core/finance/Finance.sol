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
import {FinanceEvents} from "src/v0.8/shared/events/FinanceEvents.sol";
import {FinanceLIB} from "src/v0.8/core/finance/library/FinanceLIB.sol";
import {FinanceModifiers} from "src/v0.8/shared/modifiers/FinanceModifiers.sol";
import {DatacapCollateralLIB} from "src/v0.8/core/finance/library/DatacapCollateral_EscrowLibrary.sol";

// interface
import {IRoles} from "src/v0.8/interfaces/core/IRoles.sol";
import {IFilplus} from "src/v0.8/interfaces/core/IFilplus.sol";
import {IFinance} from "src/v0.8/interfaces/core/IFinance.sol";
import {IStorages} from "src/v0.8/interfaces/module/IStorages.sol";
import {IDatacaps} from "src/v0.8/interfaces/module/IDatacaps.sol";
import {IDatasets} from "src/v0.8/interfaces/module/IDatasets.sol";
import {IDatasetsProof} from "src/v0.8/interfaces/module/IDatasetsProof.sol";
import {IDatasetsRequirement} from "src/v0.8/interfaces/module/IDatasetsRequirement.sol";

/// @title Finance
/// @dev Base finance contract, holds funds designated for a payee until they withdraw them.
contract Finance is
    Initializable,
    UUPSUpgradeable,
    RolesModifiers,
    FinanceModifiers,
    IFinance
{
    using FinanceLIB for FinanceType.Account;

    mapping(uint256 => mapping(uint256 => mapping(address => mapping(address => FinanceType.Account))))
        private financeAccount; // mapping(datasetId => mapping(matchingId => mapping(sc/sp/da/dp => mapping(tokentype=>Account))));

    IRoles private roles;
    IFilplus public filplus;
    IStorages public storages;
    IDatacaps public datacaps;
    IDatasets public datasets;
    IDatasetsProof public datasetsProof;
    IDatasetsRequirement public datasetsRequirement;

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
        address _datacaps,
        address _filplus
    ) public onlyRole(roles, RolesType.DEFAULT_ADMIN_ROLE) {
        storages = IStorages(_storages);
        datacaps = IDatacaps(_datacaps);
        filplus = IFilplus(_filplus);
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
    /// @param _amount The amount to be escrowed.
    /// @param _type The type of escrow (e.g., deposit, payment).
    function escrow(
        uint64 _datasetId,
        uint64 _matchingId,
        address _token,
        uint256 _amount,
        FinanceType.Type _type
    ) external onlySupportToken(_token) {
        financeAccount[_datasetId][_matchingId][msg.sender][_token]._escrow(
            _type,
            _amount
        );

        emit FinanceEvents.Escrow(
            _datasetId,
            _matchingId,
            msg.sender,
            _token,
            _type,
            _amount
        );
    }

    /// @dev Handles an escrow, such as claiming or processing it.
    /// @param _datasetId The ID of the dataset.
    /// @param _matchingId The ID of the matching process.
    /// @param _token The type of token for escrow handling (e.g., FIL, ERC-20).
    /// @param _type The type of escrow (e.g., deposit, payment).
    function claimEscrow(
        uint64 _datasetId,
        uint64 _matchingId,
        address _owner,
        address _token,
        FinanceType.Type _type
    ) external onlySupportToken(_token) {
        (address[] memory payee, uint256[] memory amount) = getEscrowPayeeInfo(
            _datasetId,
            _matchingId,
            _owner,
            _token,
            _type
        );
        FinanceType.Account storage account = financeAccount[_datasetId][
            _matchingId
        ][_owner][_token];
        for (uint256 i = 0; i < payee.length; i++) {
            if (payee[i] == filplus.getBurnAddress()) {
                account._burn(_type, amount[i]);

                SendAPI.send(
                    FilAddresses.fromEthAddress(filplus.getBurnAddress()),
                    amount[i]
                );

                emit FinanceEvents.Burn(
                    _datasetId,
                    _matchingId,
                    _owner,
                    _token,
                    _type,
                    amount[i]
                );
            } else {
                account._payment(_type, amount[i]);

                financeAccount[_datasetId][_matchingId][payee[i]][_token]
                    ._income(_type, amount[i]);

                emit FinanceEvents.Payment(
                    _datasetId,
                    _matchingId,
                    _owner,
                    _token,
                    _type,
                    amount[i]
                );
                emit FinanceEvents.Income(
                    _datasetId,
                    _matchingId,
                    payee[i],
                    _token,
                    _type,
                    amount[i]
                );
            }
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
        onlySupportToken(_token)
        returns (
            uint256 deposited,
            uint256 withdrawn,
            uint256 burned,
            uint256 balance,
            uint256 available,
            uint256 lock,
            uint256 escrows
        )
    {
        FinanceType.Account storage account = financeAccount[_datasetId][
            _matchingId
        ][msg.sender][_token];
        deposited = account.statistics.deposited;
        withdrawn = account.statistics.withdrawn;
        burned = account.statistics.burned;
        balance = account.total;
        available =
            account.total -
            account._getValidEscrows() -
            account._getLocks();
        lock = account._getLocks();
        escrows = account._getValidEscrows();
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
        returns (
            uint64[] memory height,
            uint256[] memory amount,
            uint256[] memory lock
        )
    {
        return
            financeAccount[_datasetId][_matchingId][_owner][_token]
                ._getAccountIncome(_type);
    }

    /// @dev Retrieves escrowed amount for an account.
    /// @param _datasetId The ID of the dataset.
    /// @param _matchingId The ID of the matching process.
    /// @param _token The type of token for the escrowed amount (e.g., FIL, ERC-20).
    /// @param _type The type of escrow (e.g., deposit, payment).
    /// @param _owner The address of the account owner.
    /// @return amount The amount of escrowed funds for the specified account.
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
    {
        return
            financeAccount[_datasetId][_matchingId][_owner][_token]
                ._getAccountEscrow(_type);
    }

    /// @dev Retrieves the escrow requirement for a specific dataset, matching process, and token type.
    /// @param _datasetId The ID of the dataset.
    /// @param _matchingId The ID of the matching process.
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
        FinanceType.Type _type,
        FinanceType.Account storage _account,
        IFilplus _filplus,
        IDatasets _datasets,
        IDatasetsProof _datasetsProof,
        IDatasetsRequirement _datasetsRequirement
    ) external view onlySupportToken(_token) returns (uint256 amount) {
        switch(_type) {
            case FinanceType.Type.DatacapCollateral:
                return DatacapCollateralLIB.getRequirement(
                    _datasetId,
                    _matchingId,
                    _owner,
                    _account,
                    _filplus,
                    _datasets,
                    _datasetsProof,
                    _datasetsRequirement
                );
            case FinanceType.Type.ChallengeCommission:
            case FinanceType.Type.DataTradingCommission:
            case FinanceType.Type.DataTradingFee: 
            case FinanceType.Type.DatacapChunkLandCollateral:
            case FinanceType.Type.ProofAuditCollateral:
            case FinanceType.Type.ChallengeAuditCollateral:
            case FinanceType.Type.DisputeAuditCollateral:
            default:
                return 0;
        }
    }

    /// @dev Retrieves payee information for the escrow, including addresses and corresponding amounts.
    /// @param _datasetId The ID of the dataset.
    /// @param _matchingId The ID of the matching process.
    /// @param _token The type of token for the escrowed amount (e.g., FIL, ERC-20).
    /// @return payee An array of addresses representing the payees involved in the escrow.
    /// @return amount An array of uint256 representing the amounts corresponding to each payee.
    /// Note: TypeX_EscrowLibrary needs to include the following methods.
    /// .     function getPayeeInfo(
    ///         uint64 _datasetId,
    ///         uint64 _matchingId,
    ///         address _token
    ///       ) external view returns (address[] memory payee, uint256[] memory amount);
    function getEscrowPayeeInfo(
        uint64 _datasetId,
        uint64 _matchingId,
        address _owner,
        FinanceType.Type _type,
        FinanceType.Account storage _account,
        IStorages _storages,
        IFilplus _filplus
    )
        public
        view
        onlySupportToken(_token)
        returns (address[] memory payee, uint256[] memory amount)
    {
        switch(_type) {
            case FinanceType.Type.DatacapCollateral:
                return DatacapCollateralLIB.getPayeeInfo(_datasetId, _matchingId, _owner, _account, _storages, _filplus);
            case FinanceType.Type.ChallengeCommission:
            case FinanceType.Type.DataTradingCommission:
            case FinanceType.Type.DataTradingFee: 
            case FinanceType.Type.DatacapChunkLandCollateral:
            case FinanceType.Type.ProofAuditCollateral:
            case FinanceType.Type.ChallengeAuditCollateral:
            case FinanceType.Type.DisputeAuditCollateral:
            default:
                break;
        }
    }
}
