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

import "../../shared/modifiers/CommonModifiers.sol";
import "../../shared/modifiers/RolesModifiers.sol";
import "../../interfaces/core/IRoles.sol";
import "../../interfaces/core/IFilplus.sol";
import "../../interfaces/core/ICarstore.sol";
import "../../interfaces/module/IDatasets.sol";
import "../../interfaces/module/IMatchings.sol";
import "../../interfaces/module/IMatchedStores.sol";
import "../../interfaces/module/IMatchedDatacap.sol";

/// @title MatchedDatacap
/// @dev Manages the allocation of datacap for matched data storage after successful matching with Filecoin storage deals.
/// Note:The removal of datacap is not necessary.
///     This design allocates datacap step by step according to chunks,
///     rather than allocating all at once.
contract MatchedDatacap is IMatchedDatacap, CommonModifiers, RolesModifiers {
    //(matchingID => allocated datacap size)
    mapping(uint256 => uint256) private datacapAllocates;
    address private governanceAddress;
    IRoles private roles;
    IFilplus private filplus;
    ICarstore private carstore;
    IDatasets private datasets;
    IMatchings private matchings;
    IMatchedStores private matchedstores;

    constructor(
        address _governanceAddress,
        IRoles _roles,
        IFilplus _filplus,
        ICarstore _carstore,
        IDatasets _datasets,
        IMatchings _matchings,
        IMatchedStores _matchedstores
    ) RolesModifiers(_roles) {
        governanceAddress = _governanceAddress;
        roles = _roles;
        filplus = _filplus;
        carstore = _carstore;
        datasets = _datasets;
        matchings = _matchings;
        matchedstores = _matchedstores;
    }

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
            isMatchedDatacapNextAllocationValid(_matchingId),
            "Not met allocate condition"
        );
        uint256 remainingSize = getMatchedDatacapTotalRemaining(_matchingId);
        if (remainingSize <= filplus.datacapRulesMaxAllocatedSizePerTime()) {
            datacapAllocates[_matchingId] =
                datacapAllocates[_matchingId] +
                remainingSize;
            _allocateMatchedDatacap(_matchingId, remainingSize);
        } else {
            datacapAllocates[_matchingId] =
                datacapAllocates[_matchingId] +
                filplus.datacapRulesMaxAllocatedSizePerTime();
            _allocateMatchedDatacap(
                _matchingId,
                filplus.datacapRulesMaxAllocatedSizePerTime()
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
        return matchings.getMatchingDataSize(_matchingId);
    }

    /// @dev Gets the remaining datacap size needed to be allocated for a matching process.
    /// @param _matchingId The ID of the matching process.
    /// @return The remaining datacap size needed.
    function getMatchedDatacapTotalRemaining(
        uint256 _matchingId
    ) public view returns (uint256) {
        uint256 allocatedDatacap = datacapAllocates[_matchingId];
        uint256 totalDatacapNeeded = matchings.getMatchingDataSize(_matchingId);
        require(
            totalDatacapNeeded >= allocatedDatacap,
            "Allocated datacap exceeds total needed datacap"
        );
        return totalDatacapNeeded - allocatedDatacap;
    }

    /// @dev Checks if the next datacap allocation is allowed for a matching process.
    /// @param _matchingId The ID of the matching process.
    /// @return True if next allocation is allowed, otherwise false.
    function isMatchedDatacapNextAllocationValid(
        uint256 _matchingId
    ) public view returns (bool) {
        uint256 totalDatacapNeeded = matchings.getMatchingDataSize(_matchingId);
        uint256 allocatedDatacap = datacapAllocates[_matchingId];
        uint256 reallyStored = matchedstores.getMatchedStoredTotalSize(
            _matchingId
        );
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
                (filplus.datacapRulesMaxRemainingPercentageForNext() / 100) *
                    filplus.datacapRulesMaxAllocatedSizePerTime(),
            "Remaining datacap is greater than allocationThreshold"
        );
        return true;
    }
}
