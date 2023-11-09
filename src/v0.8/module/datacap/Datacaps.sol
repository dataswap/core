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
import {IEscrow} from "src/v0.8/interfaces/core/IEscrow.sol";
import {IFilplus} from "src/v0.8/interfaces/core/IFilplus.sol";
import {IFilecoin} from "src/v0.8/interfaces/core/IFilecoin.sol";
import {ICarstore} from "src/v0.8/interfaces/core/ICarstore.sol";
import {IMatchings} from "src/v0.8/interfaces/module/IMatchings.sol";
import {IMatchingsTarget} from "src/v0.8/interfaces/module/IMatchingsTarget.sol";
import {IMatchingsBids} from "src/v0.8/interfaces/module/IMatchingsBids.sol";
import {IStorages} from "src/v0.8/interfaces/module/IStorages.sol";
import {IDatacaps} from "src/v0.8/interfaces/module/IDatacaps.sol";

import {RolesType} from "src/v0.8/types/RolesType.sol";
import {EscrowType} from "src/v0.8/types/EscrowType.sol";

/// shared
import {Errors} from "src/v0.8/shared/errors/Errors.sol";
import {DatacapsModifiers} from "src/v0.8/shared/modifiers/DatacapsModifiers.sol";
import {DatacapsEvents} from "src/v0.8/shared/events/DatacapsEvents.sol";

import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {UUPSUpgradeable} from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

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
contract Datacaps is
    Initializable,
    UUPSUpgradeable,
    IDatacaps,
    DatacapsModifiers
{
    //(matchingID => allocated datacap size)
    mapping(uint64 => uint64) private allocatedDatacaps;
    address private governanceAddress;
    IRoles private roles;
    IEscrow private escrow;
    IFilplus private filplus;
    IFilecoin private filecoin;
    ICarstore private carstore;
    IMatchings private matchings;
    IMatchingsTarget private matchingsTarget;
    IMatchingsBids private matchingsBids;
    IStorages public storages;

    /// @dev This empty reserved space is put in place to allow future versions to add new
    uint256[32] private __gap;

    /// @notice initialize function to initialize the contract and grant the default admin role to the deployer.
    // solhint-disable-next-line
    function initialize(
        address _governanceAddress,
        address _roles,
        address _filplus,
        address _filecoin,
        address _carstore,
        address _matchings,
        address _matchingsTarget,
        address _matchingsBids,
        address _storages,
        address _escrow
    ) public initializer {
        governanceAddress = _governanceAddress;
        roles = IRoles(_roles);
        escrow = IEscrow(_escrow);
        filplus = IFilplus(_filplus);
        filecoin = IFilecoin(_filecoin);
        carstore = ICarstore(_carstore);
        matchings = IMatchings(_matchings);
        matchingsTarget = IMatchingsTarget(_matchingsTarget);
        matchingsBids = IMatchingsBids(_matchingsBids);
        storages = IStorages(_storages);
        __UUPSUpgradeable_init();
    }

    /// @notice UUPS Upgradeable function to update the roles implementation
    /// @dev Only triggered by contract admin
    function _authorizeUpgrade(
        address newImplementation
    )
        internal
        override
        onlyRole(roles, RolesType.DEFAULT_ADMIN_ROLE) // solhint-disable-next-line
    {}

    /// @notice Returns the implementation contract
    function getImplementation() external view returns (address) {
        return _getImplementation();
    }

    /// @notice Add collateral funds for allocating datacap chunk
    /// @param _matchingId The ID of the matching
    function addDatacapChunkCollateral(uint64 _matchingId) public payable {
        uint256 requirement = getCollateralRequirement();
        address winner = matchingsBids.getMatchingWinner(_matchingId);
        uint256 currentFunds = escrow.getOwnerCollateral(
            EscrowType.Type.DatacapChunkCollateral,
            winner,
            _matchingId
        );
        uint256 requiredFunds = requirement - currentFunds;
        require(msg.value >= requiredFunds, "Insufficient collateral funds");

        escrow.collateral{value: msg.value}(
            EscrowType.Type.DatacapChunkCollateral,
            winner,
            _matchingId,
            requiredFunds
        );

        emit DatacapsEvents.DatacapChunkCollateral(
            _matchingId,
            winner,
            msg.value,
            requiredFunds
        );
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
        validNextDatacapAllocation(this, _matchingId)
        returns (uint64)
    {
        uint256 currentFunds = escrow.getOwnerCollateral(
            EscrowType.Type.DatacapChunkCollateral,
            matchingsBids.getMatchingWinner(_matchingId),
            _matchingId
        );
        uint256 requirement = getCollateralRequirement();
        require(currentFunds >= requirement, "Insufficient collateral funds");

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

    /// @notice Get collateral funds requirement for allocate chunk datacap
    function getCollateralRequirement() public view returns (uint256) {
        // TODO: PRICE_PER_BYTE import from governance
        uint64 PER_TIB_BYTE = (1024 * 1024 * 1024 * 1024);
        uint256 PRICE_PER_BYTE = (1000000000000000000 / PER_TIB_BYTE);
        return filplus.datacapRulesMaxAllocatedSizePerTime() * PRICE_PER_BYTE;
    }

    /// @notice Get the updated collateral funds for datacap chunk based on real-time business data
    /// @param _matchingId The ID of the matching
    /// @return The updated collateral funds required
    function updatedDatacapChunkCollateralFunds(
        uint64 _matchingId
    ) public view returns (uint256) {
        uint256 availableFunds = escrow.getOwnerCollateral(
            EscrowType.Type.DatacapChunkCollateral,
            matchingsBids.getMatchingWinner(_matchingId),
            _matchingId
        );

        if (storages.isStorageExpiration(_matchingId) == true) {
            uint64 matchingSize = matchingsTarget.getMatchingSize(_matchingId);
            uint64 storedSize = storages.getTotalStoredSize(_matchingId);

            // TODO: PRICE_PER_BYTE import from governance
            uint64 PER_TIB_BYTE = (1024 * 1024 * 1024 * 1024);
            uint256 PRICE_PER_BYTE = (1000000000000000000 / PER_TIB_BYTE);
            uint256 requiredFunds = (matchingSize - storedSize) *
                PRICE_PER_BYTE;

            if (requiredFunds < availableFunds) return requiredFunds;
        }

        return availableFunds;
    }

    /// @notice Get the updated burn funds for datacap chunk based on real-time business data
    /// @param _matchingId The ID of the matching
    /// @return The updated burn funds required
    function updatedDatacapChunkBurnFunds(
        uint64 _matchingId
    ) public view returns (uint256) {
        if (storages.isStorageExpiration(_matchingId) == true) {
            uint64 matchingSize = matchingsTarget.getMatchingSize(_matchingId);
            uint64 storedSize = storages.getTotalStoredSize(_matchingId);

            // TODO: PRICE_PER_BYTE import from governance
            uint64 PER_TIB_BYTE = (1024 * 1024 * 1024 * 1024);
            uint256 PRICE_PER_BYTE = (1000000000000000000 / PER_TIB_BYTE);
            uint256 requiredFunds = (matchingSize - storedSize) *
                PRICE_PER_BYTE;

            uint256 availableFunds = escrow.getOwnerCollateral(
                EscrowType.Type.DatacapChunkCollateral,
                matchingsBids.getMatchingWinner(_matchingId),
                _matchingId
            );

            if (requiredFunds < availableFunds) {
                return requiredFunds;
            } else {
                return availableFunds;
            }
        }

        return 0;
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
        return matchingsTarget.getMatchingSize(_matchingId);
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
