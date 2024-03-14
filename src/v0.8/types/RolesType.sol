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

/// @title RolesType Library
/// @notice This library defines constants for different roles within the system.
library RolesType {
    /// @notice Default admin role
    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    /// @notice Bytes32 constant representing the role of a dataswap contract.
    bytes32 public constant DATASWAP_CONTRACT = keccak256("DATASWAP");

    /// @notice The dataswap contract type.
    enum ContractType {
        Filplus,
        Finance,
        Filecoin,
        Carstore,
        Storages,
        MerkleUtils,
        Datasets,
        DatasetsProof,
        DatasetsChallenge,
        DatasetsRequirement,
        Matchings,
        MatchingsBids,
        MatchingsTarget,
        EscrowDataTradingFee,
        EscrowDatacapChunkLandCollateral,
        EscrowDatacapCollateral,
        EscrowChallengeCommission,
        EscrowChallengeAuditCollateral,
        EscrowDisputeAuditCollateral,
        EscrowProofAuditCollateral
    }

    struct DataswapContracts {
        IFilplus filplus;
        IFinance finance;
        IFilecoin filecoin;
        ICarstore carstore;
        IStorages storages;
        IMerkleUtils merkleUtils;
        IDatasets datasets;
        IDatasetsProof datasetsProof;
        IDatasetsChallenge datasetsChallenge;
        IDatasetsRequirement datasetsRequirement;
        IMatchings matchings;
        IMatchingsBids matchingsBids;
        IMatchingsTarget matchingsTarget;
        IEscrow escrowDataTradingFee;
        IEscrow escrowDatacapCollateral;
        IEscrow escrowChallengeCommission;
        IEscrow escrowDatacapChunkLandCollateral;
        IEscrow escrowChallengeAuditCollateral;
        IEscrow escrowDisputeAuditCollateral;
        IEscrow escrowProofAuditCollateral;
    }
}
