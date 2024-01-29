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

/// @title RolesType Library
/// @notice This library defines constants for different roles within the system.
library RolesType {
    /// @notice Default admin role
    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    /// @notice Bytes32 constant representing the role of a storage provider.
    bytes32 public constant STORAGE_PROVIDER = keccak256("SP");

    /// @notice Bytes32 constant representing the role of a retrieve provider.
    bytes32 public constant RETRIEVE_PROVIDER = keccak256("RP");

    /// @notice Bytes32 constant representing the role of a compute provider.
    bytes32 public constant COMPUTE_PROVIDER = keccak256("CP");

    /// @notice Bytes32 constant representing the role of a metadata dataset provider.
    bytes32 public constant METADATA_DATASET_PROVIDER = keccak256("MDP");

    /// @notice Bytes32 constant representing the role of a dataset provider.
    bytes32 public constant DATASET_PROVIDER = keccak256("DP");

    /// @notice Bytes32 constant representing the role of a metadata dataset auditor.
    bytes32 public constant METADATA_DATASET_AUDITOR = keccak256("MDA");

    /// @notice Bytes32 constant representing the role of a dataset auditor.
    bytes32 public constant DATASET_AUDITOR = keccak256("DA");

    /// @notice Bytes32 constant representing the role of a reviewer client.
    bytes32 public constant REVIEWER_CLIENT = keccak256("RC");

    /// @notice Bytes32 constant representing the role of a compute client.
    bytes32 public constant COMPUTE_CLIENT = keccak256("CC");

    /// @notice Bytes32 constant representing the role of a dataswap contract.
    bytes32 public constant DATASWAP_CONTRACT = keccak256("DATASWAP");

    /// @notice The dataswap contract type.
    enum ContractType {
        Escrow,
        Filplus,
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
        MatchingsTarget
    }
}
