/*******************************************************************************
 *   (c) 2023 DataSwap
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

/// @notice Enum: Proposal Types
enum ProposalType {
    MetadataAudit, // Proposal for Metadata Audit
    MetadataDispute, // Proposal for Metadata Dispute
    DatasetAudit, // Proposal for Dataset Audit
    DatasetDispute, // Proposal for Dataset Dispute
    DatasetMappingFilesDisput // Proposal for Dataset MappingFiles Disputee
}

/// @notice Struct: Proposal
struct Proposal {
    uint256 datasetId; // ID of the dataset
    ProposalType proposalType; // Type of the proposal
}
