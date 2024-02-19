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

import {MatchingType} from "src/v0.8/types/MatchingType.sol";

library Errors {
    /// @notice commmon errors
    error ParamLengthMismatch(uint256 _expectedLength, uint256 _actualLength);
    error InvalidGrantRole(bytes32 _role, address _account);

    /// @notice car errors
    error CarNotExist(uint64 _id);
    error CarAlreadyExists(uint64 _id, bytes32 _hash);
    error ReplicaNotExist(uint64 _id, uint64 _matchingId);
    error ReplicaAlreadyExists(uint64 _id, uint64 _matchingId);
    error ReplicaFilecoinClaimIdExists(uint64 _id, uint64 _matchingId);
    error InvalidReplicaState(uint64 _id, uint64 _matchingId);
    error InvalidReplicaFilecoinDealState(uint64 _id, uint64 _filecoinId);

    /// @notice Dataset errors
    error DatasetMetadataNotExist(string accessMethod);
    error DatasetMetadataAlreadyExist(string accessMethod);
    error InvalidDatasetState(uint64 datasetId);
    error InvalidDatasetProofsSubmitter(uint64 datasetId, address submitter);

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
    error StorageDealNotSuccessful(uint64 _claimId);
    error StorageClaimIdAlreadySet(
        uint64 _matchingId,
        bytes32 _cid,
        uint64 _claimId
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
    error NotCompliantRuleMaxReplicasPerSP(address winner, bytes32 cid);
    error NotCompliantRuleMatchingTargetMeetsFilPlusRequirements(
        uint64 matchingId,
        address winner
    );

    /// @notice finance errors
    error ExceedValidAmount(uint256 valid, uint256 expectedAmount);
    error ExceedValidEscrowAmount(uint256 valid, uint256 expectedAmount);
    error NotSupportToken(address token);
}
