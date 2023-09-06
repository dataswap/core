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

/// interface
import {IRoles} from "src/v0.8/interfaces/core/IRoles.sol";
import {IFilplus} from "src/v0.8/interfaces/core/IFilplus.sol";
import {IFilecoin} from "src/v0.8/interfaces/core/IFilecoin.sol";
import {ICarstore} from "src/v0.8/interfaces/core/ICarstore.sol";
import {IDatasets} from "src/v0.8/interfaces/module/IDatasets.sol";
import {IMatchings} from "src/v0.8/interfaces/module/IMatchings.sol";
import {IStorages} from "src/v0.8/interfaces/module/IStorages.sol";
import {IDatacaps} from "src/v0.8/interfaces/module/IDatacaps.sol";

/// shared
import {Errors} from "src/v0.8/shared/errors/Errors.sol";
import {DatacapsModifiers} from "src/v0.8/shared/modifiers/DatacapsModifiers.sol";
import {DatacapsEvents} from "src/v0.8/shared/events/DatacapsEvents.sol";

// TODO:version issue
// import {DataCapAPI} from "@zondax/filecoin-solidity/contracts/v0.8/DataCapAPI.sol";
// import {DataCapTypes} from "@zondax/filecoin-solidity/contracts/v0.8/types/DataCapTypes.sol";
// import {FilAddresses} from "@zondax/filecoin-solidity/contracts/v0.8/utils/FilAddresses.sol";
// import {BigInts} from "@zondax/filecoin-solidity/contracts/v0.8/utils/BigInts.sol";

/// @title Datacap
/// @dev Manages the allocation of datacap for matched data storage after successful matching with Filecoin storage deals.
/// Note:The removal of datacap is not necessary.
///     This design allocates datacap step by step according to chunks,
///     rather than allocating all at once.
contract Datacaps is IDatacaps, DatacapsModifiers {
    //(matchingID => allocated datacap size)
    mapping(uint64 => uint64) private allocatedDatacaps;
    address private governanceAddress;
    IRoles private roles;
    IFilplus private filplus;
    IFilecoin private filecoin;
    ICarstore private carstore;
    IDatasets private datasets;
    IMatchings private matchings;
    IStorages public storages;

    // solhint-disable-next-line
    constructor(
        address _governanceAddress,
        IRoles _roles,
        IFilplus _filplus,
        IFilecoin _filecoin,
        ICarstore _carstore,
        IDatasets _datasets,
        IMatchings _matchings,
        IStorages _storages
    )
        DatacapsModifiers(
            _roles,
            _filplus,
            _filecoin,
            _carstore,
            _datasets,
            _matchings,
            _storages,
            this
        )
    {
        governanceAddress = _governanceAddress;
        roles = _roles;
        filplus = _filplus;
        carstore = _carstore;
        datasets = _datasets;
        matchings = _matchings;
        storages = _storages;
    }

    /// @dev Internal function to allocate matched datacap.
    // solhint-disable-next-line
    function _allocateDatacap(
        uint64 /*_matchingId*/,
        uint64 /*_size*/ // solhint-disable-next-line
    ) internal {
        // DataCapTypes.TransferParams memory params = DataCapTypes.TransferParams(
        //     FilAddresses.fromEthAddress(_to),
        //     BigInts.fromUint256(_size),
        //     ""
        // );
        // DataCapAPI.transfer(params);
        //TODO: logic https://github.com/dataswap/core/issues/30
    }

    /// @dev Requests the allocation of matched datacap for a matching process.
    /// @param _matchingId The ID of the matching process.
    function requestAllocateDatacap(
        uint64 _matchingId
    )
        external
        onlyAddress(matchings.getMatchingInitiator(_matchingId))
        onlyNotZeroAddress(matchings.getMatchingInitiator(_matchingId))
        validNextDatacapAllocation(_matchingId)
        returns (uint64)
    {
        uint64 remainingUnallocatedDatacap = getRemainingUnallocatedDatacap(
            _matchingId
        );
        uint64 maxAllocateCapacityPreTime = filplus
            .datacapRulesMaxAllocatedSizePerTime();
        if (remainingUnallocatedDatacap <= maxAllocateCapacityPreTime) {
            allocatedDatacaps[_matchingId] =
                allocatedDatacaps[_matchingId] +
                remainingUnallocatedDatacap;
            _allocateDatacap(_matchingId, remainingUnallocatedDatacap);

            emit DatacapsEvents.DatacapAllocated(
                _matchingId,
                remainingUnallocatedDatacap
            );
            return remainingUnallocatedDatacap;
        } else {
            allocatedDatacaps[_matchingId] =
                allocatedDatacaps[_matchingId] +
                maxAllocateCapacityPreTime;
            _allocateDatacap(_matchingId, maxAllocateCapacityPreTime);

            emit DatacapsEvents.DatacapAllocated(
                _matchingId,
                maxAllocateCapacityPreTime
            );
            return maxAllocateCapacityPreTime;
        }
    }

    /// @dev Gets the allocated matched datacap for a matching process.
    /// @param _matchingId The ID of the matching process.
    /// @return The allocated datacap size.
    function getAllocatedDatacap(
        uint64 _matchingId
    ) public view returns (uint64) {
        return allocatedDatacaps[_matchingId];
    }

    /// @notice Gets the available datacap that can still be allocated for a matching process.
    /// @param _matchingId The ID of the matching process.
    /// @return The available datacap size.
    function getAvailableDatacap(
        uint64 _matchingId
    ) public view returns (uint64) {
        uint64 allocatedDatacap = getAllocatedDatacap(_matchingId);
        uint64 reallyStored = storages.getTotalStoredSize(_matchingId);
        return allocatedDatacap - reallyStored;
    }

    /// @dev Gets the total datacap size needed to be allocated for a matching process.
    /// @param _matchingId The ID of the matching process.
    /// @return The total datacap size needed.
    function getTotalDatacapAllocationRequirement(
        uint64 _matchingId
    ) public view returns (uint64) {
        return matchings.getMatchingSize(_matchingId);
    }

    /// @dev Gets the remaining datacap size needed to be allocated for a matching process.
    /// @param _matchingId The ID of the matching process.
    /// @return The remaining datacap size needed.
    function getRemainingUnallocatedDatacap(
        uint64 _matchingId
    ) public view returns (uint64) {
        uint64 allocatedDatacap = getAllocatedDatacap(_matchingId);
        uint64 totalDatacapAllocationRequirement = getTotalDatacapAllocationRequirement(
                _matchingId
            );
        return totalDatacapAllocationRequirement - allocatedDatacap;
    }

    /// @dev Checks if the next datacap allocation is allowed for a matching process.
    /// @param _matchingId The ID of the matching process.
    /// @return True if next allocation is allowed, otherwise false.
    function isNextDatacapAllocationValid(
        uint64 _matchingId
    ) public view returns (bool) {
        uint64 totalDatacapAllocationRequirement = getTotalDatacapAllocationRequirement(
                _matchingId
            );
        uint64 allocatedDatacap = getAllocatedDatacap(_matchingId);
        uint64 reallyStored = storages.getTotalStoredSize(_matchingId);
        uint64 availableDatacap = getAvailableDatacap(_matchingId);
        uint64 allocationThreshold = (filplus
            .datacapRulesMaxRemainingPercentageForNext() / 100) *
            filplus.datacapRulesMaxAllocatedSizePerTime();

        if (allocatedDatacap > totalDatacapAllocationRequirement) {
            revert Errors.AllocatedDatacapExceedsTotalRequirement(
                allocatedDatacap,
                totalDatacapAllocationRequirement
            );
        }

        if (reallyStored > allocatedDatacap) {
            revert Errors.StoredExceedsAllocatedDatacap(
                reallyStored,
                allocatedDatacap
            );
        }

        if (availableDatacap > allocationThreshold) {
            revert Errors.AvailableDatacapExceedAllocationThreshold(
                availableDatacap,
                allocationThreshold
            );
        }

        return true;
    }
}
