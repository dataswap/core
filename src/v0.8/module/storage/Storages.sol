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
import {IDatasets} from "src/v0.8/interfaces/module/IDatasets.sol";
import {IMatchings} from "src/v0.8/interfaces/module/IMatchings.sol";
import {IMatchingsTarget} from "src/v0.8/interfaces/module/IMatchingsTarget.sol";
import {IMatchingsBids} from "src/v0.8/interfaces/module/IMatchingsBids.sol";
import {IStorages} from "src/v0.8/interfaces/module/IStorages.sol";
/// shared
import {Errors} from "src/v0.8/shared/errors/Errors.sol";
import {StoragesEvents} from "src/v0.8/shared/events/StoragesEvents.sol";
import {StoragesModifiers} from "src/v0.8/shared/modifiers/StoragesModifiers.sol";
import {CidUtils} from "src/v0.8/shared/utils/cid/CidUtils.sol";
import {StorageStatisticsBase} from "src/v0.8/core/statistics/StorageStatisticsBase.sol";

/// type
import {RolesType} from "src/v0.8/types/RolesType.sol";
import {EscrowType} from "src/v0.8/types/EscrowType.sol";
import {StorageType} from "src/v0.8/types/StorageType.sol";
import {MatchingType} from "src/v0.8/types/MatchingType.sol";
import {CarReplicaType} from "src/v0.8/types/CarReplicaType.sol";

import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {UUPSUpgradeable} from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

/// @title storages
/// @dev Manages the storage of matched data after successful matching with Filecoin storage deals.
contract Storages is
    Initializable,
    UUPSUpgradeable,
    IStorages,
    StorageStatisticsBase,
    StoragesModifiers
{
    mapping(uint64 => StorageType.Storage) private storages; //matchingId=>Matchedstore

    address private governanceAddress;
    IEscrow private escrow;
    IFilplus private filplus;
    IFilecoin private filecoin;
    IDatasets public datasets;
    ICarstore private carstore;
    IMatchings public matchings;
    IMatchingsTarget public matchingsTarget;
    IMatchingsBids public matchingsBids;
    /// @dev This empty reserved space is put in place to allow future versions to add new
    uint256[32] private __gap;

    /// @notice initialize function to initialize the contract and grant the default admin role to the deployer.
    function initialize(
        address _governanceAddress,
        address _roles,
        address _filplus,
        address _filecoin,
        address _carstore,
        address _matchings,
        address _matchingsTarget,
        address _matchingsBids,
        address _escrow,
        address _datasets
    ) public initializer {
        StorageStatisticsBase.storageStatisticsBaseInitialize(_roles);
        governanceAddress = _governanceAddress;
        escrow = IEscrow(_escrow);
        filplus = IFilplus(_filplus);
        filecoin = IFilecoin(_filecoin);
        datasets = IDatasets(_datasets);
        carstore = ICarstore(_carstore);
        matchings = IMatchings(_matchings);
        matchingsTarget = IMatchingsTarget(_matchingsTarget);
        matchingsBids = IMatchingsBids(_matchingsBids);
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

    /// @dev Submits a Filecoin claim Id for a matchedstore after successful matching.
    /// @param _matchingId The ID of the matching.
    /// @param _provider A provider of storage provider of matching.
    /// @param _id The car id of the matched data.
    /// @param _claimId The ID of the successful Filecoin storage deal.
    function _submitStorageClaimId(
        uint64 _matchingId,
        uint64 _provider,
        uint64 _id,
        uint64 _claimId
    )
        internal
        onlyAddress(matchingsBids.getMatchingWinner(_matchingId))
        onlyUnsetCarReplicaFilecoinClaimId(carstore, _id, _matchingId)
    {
        require(
            CarReplicaType.State.Matched ==
                carstore.getCarReplicaState(_id, _matchingId),
            "Invalid Replica State"
        );

        StorageType.Storage storage storage_ = storages[_matchingId];

        bytes memory dataCid = filecoin.getReplicaClaimData(
            _provider,
            _claimId
        );
        bytes32 _hash = carstore.getCarHash(_id);
        bytes memory cid = CidUtils.hashToCID(_hash);

        require(keccak256(dataCid) == keccak256(cid), "cid mismatch");

        storage_.doneCars.push(_id);

        /// Note:set claim id in carstore berfore submitClaimid
        carstore.__setCarReplicaFilecoinClaimId(_id, _matchingId, _claimId);

        emit StoragesEvents.StorageClaimIdSubmitted(_matchingId, _id, _claimId);
    }

    /// @dev Submits multiple Filecoin claim Ids for a matchedstore after successful matching.
    /// @param _matchingId The ID of the matching.
    /// @param _provider A provider of storage provider of matching.
    /// @param _ids An array of content identifiers of the matched data.
    /// @param _claimIds An array of IDs of successful Filecoin storage deals.
    function submitStorageClaimIds(
        uint64 _matchingId,
        uint64 _provider,
        uint64[] memory _ids,
        uint64[] memory _claimIds
    ) external {
        require(isStorageExpiration(_matchingId) != true, "Storage expiration");
        if (_ids.length != _claimIds.length) {
            revert Errors.ParamLengthMismatch(_ids.length, _claimIds.length);
        }
        for (uint64 i = 0; i < _ids.length; i++) {
            _submitStorageClaimId(
                _matchingId,
                _provider,
                _ids[i],
                _claimIds[i]
            );
        }

        // Notify the escrow contract to update the payment amount
        escrow.__emitPaymentUpdate(
            EscrowType.Type.DataPrepareFeeByProvider,
            matchingsBids.getMatchingWinner(_matchingId),
            _matchingId,
            matchings.getMatchingInitiator(_matchingId),
            EscrowType.PaymentEvent.SyncPaymentLock
        );

        (uint64 datasetId, , , , , , ) = matchingsTarget.getMatchingTarget(
            _matchingId
        );

        escrow.__emitPaymentUpdate(
            EscrowType.Type.DataPrepareFeeByClient,
            datasets.getDatasetMetadataSubmitter(datasetId),
            _matchingId,
            matchings.getMatchingInitiator(_matchingId),
            EscrowType.PaymentEvent.SyncPaymentLock
        );
    }

    /// @dev Gets the list of done cars in the matchedstore.
    function getStoredCars(
        uint64 _matchingId
    ) public view returns (uint64[] memory) {
        StorageType.Storage storage storage_ = storages[_matchingId];
        return storage_.doneCars;
    }

    /// @dev Gets the count of done cars in the matchedstore.
    function getStoredCarCount(
        uint64 _matchingId
    ) public view returns (uint64) {
        StorageType.Storage storage storage_ = storages[_matchingId];
        return uint64(storage_.doneCars.length);
    }

    /// @dev Gets the stored size in the matchedstore.
    function getTotalStoredSize(
        uint64 _matchingId
    ) public view returns (uint64) {
        StorageType.Storage storage storage_ = storages[_matchingId];
        uint64 size = 0;
        for (uint64 i = 0; i < storage_.doneCars.length; i++) {
            size += carstore.getCarSize(storage_.doneCars[i]);
        }
        return size;
    }

    /// @dev Gets the car size in the matchedstore.
    function getStoredCarSize(
        uint64 _matchingId,
        uint64 _id
    ) public view returns (uint64) {
        StorageType.Storage storage storage_ = storages[_matchingId];
        for (uint64 i = 0; i < storage_.doneCars.length; i++) {
            if (storage_.doneCars[i] == _id) {
                return carstore.getCarSize(_id);
            }
        }
        return 0;
    }

    /// @dev Get the provider allow payment amount
    function getProviderLockPayment(
        uint64 _matchingId
    ) public view returns (uint256) {
        uint64 storedSize = getTotalStoredSize(_matchingId);
        (, , uint64 totalSize, , , , ) = matchingsTarget.getMatchingTarget(
            _matchingId
        );
        uint256 totalPayment = matchingsBids.getMatchingBidAmount(
            _matchingId,
            matchingsBids.getMatchingWinner(_matchingId)
        );
        return (totalPayment / totalSize) * (totalSize - storedSize);
    }

    /// @dev Get the client allow payment amount
    function getClientLockPayment(
        uint64 _matchingId
    ) public view returns (uint256) {
        uint64 storedSize = getTotalStoredSize(_matchingId);
        (, , uint64 totalSize, , , , uint256 totalPayment) = matchingsTarget
            .getMatchingTarget(_matchingId);
        return (totalPayment / totalSize) * (totalSize - storedSize);
    }

    /// @dev Checks if all cars are done in the matchedstore.
    function isAllStoredDone(uint64 _matchingId) public view returns (bool) {
        StorageType.Storage storage storage_ = storages[_matchingId];
        (, uint64[] memory cars, , , , , ) = matchingsTarget.getMatchingTarget(
            _matchingId
        );
        return storage_.doneCars.length == cars.length;
    }

    /// @dev Checks if store expiration in the matchedstore.
    function isStorageExpiration(
        uint64 _matchingId
    ) public view returns (bool) {
        (
            ,
            ,
            ,
            uint64 storageCompletionPeriodBlocks,
            ,
            uint64 createdBlockNumber,
            ,
            ,

        ) = matchings.getMatchingMetadata(_matchingId);
        if (block.number > createdBlockNumber + storageCompletionPeriodBlocks) {
            return true;
        } else {
            return false;
        }
    }

    /// @notice Add collateral funds for allocating datacap chunk
    /// @param _matchingId The ID of the matching
    function addDatacapChunkCollateral(uint64 _matchingId) public payable {
        uint256 requirement = getCollateralRequirement();
        address winner = matchingsBids.getMatchingWinner(_matchingId);
        (, , uint256 currentFunds, , ) = escrow.getOwnerFund(
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

        emit StoragesEvents.DatacapChunkCollateral(
            _matchingId,
            winner,
            msg.value,
            requiredFunds
        );
    }

    /// @dev Internal function to allocate matched datacap.
    // solhint-disable-next-line
    function _allocateDatacap(
        uint64 _matchingId,
        uint64 _size // solhint-disable-next-line
    ) internal {
        (uint64 datasetId, , , , , , ) = matchingsTarget.getMatchingTarget(
            _matchingId
        );
        uint64 client = datasets.getDatasetMetadataClient(datasetId);
        filecoin.__allocateDatacap(client, uint256(_size));
    }

    /// @notice Retrieves information about the dataset associated with a matching process.
    /// @dev This internal view function returns details such as the dataset ID, client ID, and replica index
    ///      associated with a given matching ID.
    /// @param _matchingId The unique identifier of the matching process.
    /// @return datasetId The dataset ID associated with the matching process.
    /// @return client The client ID associated with the matching process.
    /// @return replicaIndex The index of the replica within the dataset.
    function _getDatasetInfo(
        uint64 _matchingId
    )
        internal
        view
        returns (uint64 datasetId, uint64 client, uint16 replicaIndex)
    {
        (datasetId, , , , , replicaIndex, ) = matchingsTarget.getMatchingTarget(
            _matchingId
        );
        client = datasets.getDatasetMetadataClient(datasetId);
        return (datasetId, client, replicaIndex);
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
        (, , uint256 currentFunds, , ) = escrow.getOwnerFund(
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
        (uint64 datasetId, , uint16 replicaIndex) = _getDatasetInfo(
            _matchingId
        );
        if (remainingUnallocatedDatacap <= maxAllocateCapacityPreTime) {
            _addAllocated(
                datasetId,
                replicaIndex,
                _matchingId,
                remainingUnallocatedDatacap
            );
            _allocateDatacap(_matchingId, remainingUnallocatedDatacap);

            emit StoragesEvents.DatacapAllocated(
                _matchingId,
                remainingUnallocatedDatacap
            );
            return remainingUnallocatedDatacap;
        } else {
            _addAllocated(
                datasetId,
                replicaIndex,
                _matchingId,
                maxAllocateCapacityPreTime
            );
            _allocateDatacap(_matchingId, maxAllocateCapacityPreTime);

            emit StoragesEvents.DatacapAllocated(
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
    function getDatacapChunkCollateralFunds(
        uint64 _matchingId
    ) public view returns (uint256) {
        (, , uint256 availableFunds, , ) = escrow.getOwnerFund(
            EscrowType.Type.DatacapChunkCollateral,
            matchingsBids.getMatchingWinner(_matchingId),
            _matchingId
        );

        if (isStorageExpiration(_matchingId) == true) {
            (, , uint64 matchingSize, , , , ) = matchingsTarget
                .getMatchingTarget(_matchingId);
            uint64 storedSize = getTotalStoredSize(_matchingId);

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
    function getDatacapChunkBurnFunds(
        uint64 _matchingId
    ) public view returns (uint256) {
        if (isStorageExpiration(_matchingId) == true) {
            (, , uint64 matchingSize, , , , ) = matchingsTarget
                .getMatchingTarget(_matchingId);

            uint64 storedSize = getTotalStoredSize(_matchingId);

            // TODO: PRICE_PER_BYTE import from governance
            uint64 PER_TIB_BYTE = (1024 * 1024 * 1024 * 1024);
            uint256 PRICE_PER_BYTE = (1000000000000000000 / PER_TIB_BYTE);
            uint256 requiredFunds = (matchingSize - storedSize) *
                PRICE_PER_BYTE;

            (, , uint256 availableFunds, , ) = escrow.getOwnerFund(
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
        (
            uint256 total,
            ,
            ,
            ,
            ,
            uint256 unallocatedDatacap,

        ) = getMatchingStorageOverview(_matchingId);
        return uint64(total - unallocatedDatacap);
    }

    /// @notice Gets the available datacap that can still be allocated for a matching process.
    /// @param _matchingId The ID of the matching process.
    /// @return The available datacap size.
    function getAvailableDatacap(
        uint64 _matchingId
    ) public view returns (uint64) {
        (, , , uint256 availableDatacap, , , ) = getMatchingStorageOverview(
            _matchingId
        );
        return uint64(availableDatacap);
    }

    /// @dev Gets the total datacap size needed to be allocated for a matching process.
    /// @param _matchingId The ID of the matching process.
    /// @return The total datacap size needed.
    function getTotalDatacapAllocationRequirement(
        uint64 _matchingId
    ) public view returns (uint64) {
        (uint256 total, , , , , , ) = getMatchingStorageOverview(_matchingId);
        return uint64(total);
    }

    /// @dev Gets the remaining datacap size needed to be allocated for a matching process.
    /// @param _matchingId The ID of the matching process.
    /// @return The remaining datacap size needed.
    function getRemainingUnallocatedDatacap(
        uint64 _matchingId
    ) public view returns (uint64) {
        (, , , , , uint256 unallocatedDatacap, ) = getMatchingStorageOverview(
            _matchingId
        );
        return uint64(unallocatedDatacap);
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
        uint64 reallyStored = getTotalStoredSize(_matchingId);
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
