/// SPDX-License-Identifier: GPL-3.0-or-later
/// (c) 2023 DataSwap
///
/// Licensed under the GNU General Public License, Version 3.0 or later (the "License");
/// you may not use this file except in compliance with the License.
/// You may obtain a copy of the License at
///     https://www.gnu.org/licenses/gpl-3.0.en.html
///
/// Unless required by applicable law or agreed to in writing, software
/// distributed under the License is distributed on an "AS IS" BASIS,
/// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
/// See the License for the specific language governing permissions and
/// limitations under the License.

pragma solidity ^0.8.21;

import {MatchingType} from "src/v0.8/types/MatchingType.sol";

library Errors {
    /// @notice commmon errors
    error ParamLengthMismatch(uint256 _expectedLength, uint256 _actualLength);

    /// @notice car errors
    error CarNotExist(bytes32 _cid);
    error CarAlreadyExists(bytes32 _cid);
    error ReplicaNotExist(bytes32 _cid, uint64 _matchingId);
    error ReplicaAlreadyExists(bytes32 _cid, uint64 _matchingId);
    error ReplicaFilecoinDealIdExists(bytes32 _cid, uint64 _matchingId);
    error InvalidReplicaState(bytes32 _cid, uint64 _matchingId);
    error InvalidReplicaFilecoinDealState(bytes32 _cid, uint64 _filecoinId);

    /// @notice Dataset errors
    error DatasetMetadataNotExist(string accessMethod);
    error DatasetMetadataAlreadyExist(string accessMethod);
    error InvalidDatasetState(uint64 datasetId);

    /// @notice matching errors
    error InvalidMatchingState(
        uint64 matchingId,
        MatchingType.State expectedState,
        MatchingType.State actualState
    );
    error NotMatchingInitiator(
        uint64 matchingId,
        address expectedInitiator,
        address actualInitiator
    );

    /// @notice storage errors
    error StorageDealNotSuccessful(uint64 _filecoinDealId);
    error StorageDealIdAlreadySet(
        uint64 _matchingId,
        bytes32 _cid,
        uint64 _filecoinDealId
    );

    /// @notice datacap errors
    error AllocatedDatacapExceedsTotalRequirement(
        uint64 _allocatedDatacap,
        uint64 _totalDatacapAllocationRequirement
    );
    error AvailableDatacapExceedAllocationThreshold(
        uint64 availableDatacap,
        uint64 allocationThreshold
    );
    error NextDatacapAllocationInvalid(uint64 _matchingId);
    error StoredExceedsAllocatedDatacap(
        uint64 reallyStored,
        uint64 allocatedDatacap
    );
}
