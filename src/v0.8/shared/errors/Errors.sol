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

library Errors {
    /// @notice commmon errors
    error ParamLengthMismatch(uint256 _expectedLength, uint256 _actualLength);

    /// @notice car errors
    error CarNotFound(uint256 _matchingId, bytes32 _cid);

    /// @notice storage errors
    error StorageDealNotSuccessful(uint256 _filecoinDealId);
    error StorageDealIdAlreadySet(
        uint256 _matchingId,
        bytes32 _cid,
        uint256 _filecoinDealId
    );

    /// @notice datacap errors
    error AllocatedDatacapExceedsTotalRequirement(
        uint256 _allocatedDatacap,
        uint256 _totalDatacapAllocationRequirement
    );
    error AvailableDatacapExceedAllocationThreshold(
        uint256 availableDatacap,
        uint256 allocationThreshold
    );
    error NextDatacapAllocationInvalid(uint256 _matchingId);
    error StoredExceedsAllocatedDatacap(
        uint256 reallyStored,
        uint256 allocatedDatacap
    );
}
