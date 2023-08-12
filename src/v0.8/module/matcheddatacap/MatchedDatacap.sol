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

import "./IMatchedDatacap.sol";
import "../matchedstore/Matchedstores.sol";

/// @title MatchedDatacap
/// @author waynewyang
/// @dev Manages the allocation of datacap for matched data storage after successful matching with Filecoin storage deals.
abstract contract MatchedDatacap is IMatchedDatacap, Matchedstores {
    //(matchingID => allocated datacap size)
    mapping(uint256 => uint256) private datacapAllocates;

    /// @dev Internal function to allocate matched datacap.
    function _allocateMatchedDatacap(
        uint256 /*_matchingId*/,
        uint256 /*_size*/
    ) internal {
        //TODO: Need to implement the actual datacap allocation logic
    }

    /// @dev Requests the allocation of matched datacap for a matching process.
    /// @param _matchingId The ID of the matching process.
    function requestAllocateMatchedDatacap(uint256 _matchingId) external {
        require(
            isMatchedDatacapNextAllocationAllowed(_matchingId),
            "Not met allocate condition"
        );
        uint256 remainingSize = getMatchedDatacapTotalRemaining(_matchingId);
        if (remainingSize <= datacapRulesMaxAllocatedSizePerTime) {
            datacapAllocates[_matchingId] =
                datacapAllocates[_matchingId] +
                remainingSize;
            _allocateMatchedDatacap(_matchingId, remainingSize);
        } else {
            datacapAllocates[_matchingId] =
                datacapAllocates[_matchingId] +
                datacapRulesMaxAllocatedSizePerTime;
            _allocateMatchedDatacap(
                _matchingId,
                datacapRulesMaxAllocatedSizePerTime
            );
        }
    }

    /// @dev Gets the allocated matched datacap for a matching process.
    /// @param _matchingId The ID of the matching process.
    /// @return The allocated datacap size.
    function getMatchedDatacapAllocated(
        uint256 _matchingId
    ) public view returns (uint256) {
        return datacapAllocates[_matchingId];
    }

    /// @dev Gets the total datacap size needed to be allocated for a matching process.
    /// @param _matchingId The ID of the matching process.
    /// @return The total datacap size needed.
    function getMatchedDatacapTotalNeedAllocated(
        uint256 _matchingId
    ) public view returns (uint256) {
        return getMatchingDataSize(_matchingId);
    }

    /// @dev Gets the remaining datacap size needed to be allocated for a matching process.
    /// @param _matchingId The ID of the matching process.
    /// @return The remaining datacap size needed.
    function getMatchedDatacapTotalRemaining(
        uint256 _matchingId
    ) public view returns (uint256) {
        uint256 allocatedDatacap = datacapAllocates[_matchingId];
        uint256 totalDatacapNeeded = getMatchingDataSize(_matchingId);
        require(
            totalDatacapNeeded >= allocatedDatacap,
            "Allocated datacap exceeds total needed datacap"
        );
        return totalDatacapNeeded - allocatedDatacap;
    }

    /// @dev Checks if the next datacap allocation is allowed for a matching process.
    /// @param _matchingId The ID of the matching process.
    /// @return True if next allocation is allowed, otherwise false.
    function isMatchedDatacapNextAllocationAllowed(
        uint256 _matchingId
    ) public view returns (bool) {
        uint256 totalDatacapNeeded = getMatchingDataSize(_matchingId);
        uint256 allocatedDatacap = datacapAllocates[_matchingId];
        uint256 reallyStored = getMatchedsotreTotalSize(_matchingId);
        require(
            totalDatacapNeeded >= allocatedDatacap,
            "Allocated datacap exceeds total needed datacap"
        );
        require(
            allocatedDatacap >= reallyStored,
            "Really stored exceeds allocated datacap"
        );
        require(
            allocatedDatacap - reallyStored <=
                (datacapRulesMaxRemainingPercentageForNext / 100) *
                    datacapRulesMaxAllocatedSizePerTime,
            "Remaining datacap is greater than allocationThreshold"
        );
        return true;
    }
}
