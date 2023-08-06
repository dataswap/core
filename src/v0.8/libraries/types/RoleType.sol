// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity ^0.8.21;

library RoleType {
    bytes32 public constant STORAGE_PROVIDER = keccak256("SP");
    bytes32 public constant RETRIEVE_PROVIDER = keccak256("RP");
    bytes32 public constant COMPUTE_PROVIDER = keccak256("CP");
    bytes32 public constant METADATA_DATASET_PROVIDER = keccak256("MDP");
    bytes32 public constant DATASET_PROVIDER = keccak256("DP");
    bytes32 public constant METADATA_DATASET_AUDITOR = keccak256("MDA");
    bytes32 public constant DATASET_AUDITOR = keccak256("DA");
    bytes32 public constant REVIEWER_CLIENT = keccak256("RC");
    bytes32 public constant COMPUTE_CLIENT = keccak256("CC");
}
