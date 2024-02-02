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
import {IStorages} from "src/v0.8/interfaces/module/IStorages.sol";
/// shared
import {Errors} from "src/v0.8/shared/errors/Errors.sol";
import {StoragesEvents} from "src/v0.8/shared/events/StoragesEvents.sol";
import {StoragesModifiers} from "src/v0.8/shared/modifiers/StoragesModifiers.sol";
import {CidUtils} from "src/v0.8/shared/utils/cid/CidUtils.sol";
import {StorageStatisticsBase} from "src/v0.8/core/statistics/StorageStatisticsBase.sol";

/// type
import {RolesType} from "src/v0.8/types/RolesType.sol";
import {StorageType} from "src/v0.8/types/StorageType.sol";
import {FinanceType} from "src/v0.8/types/FinanceType.sol";
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
    /// @dev This empty reserved space is put in place to allow future versions to add new
    uint256[32] private __gap;

    /// @notice initialize function to initialize the contract and grant the default admin role to the deployer.
    function initialize(
        address _governanceAddress,
        address _roles
    ) public initializer {
        StorageStatisticsBase.storageStatisticsBaseInitialize(_roles);
        governanceAddress = _governanceAddress;
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
        onlyAddress(roles.matchingsBids().getMatchingWinner(_matchingId))
        onlyUnsetCarReplicaFilecoinClaimId(roles.carstore(), _id, _matchingId)
    {
        require(
            CarReplicaType.State.Matched ==
                roles.carstore().getCarReplicaState(_id, _matchingId),
            "Invalid Replica State"
        );

        StorageType.Storage storage storage_ = storages[_matchingId];

        bytes memory dataCid = roles.filecoin().getReplicaClaimData(
            _provider,
            _claimId
        );
        bytes32 _hash = roles.carstore().getCarHash(_id);
        bytes memory cid = CidUtils.hashToCID(_hash);

        require(keccak256(dataCid) == keccak256(cid), "cid mismatch");
        storage_.doneCars.push(_id);

        /// Note:set claim id in carstore berfore submitClaimid
        roles.carstore().__setCarReplicaFilecoinClaimId(
            _id,
            _matchingId,
            _claimId
        );

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

        (uint64 datasetId, , , , , uint16 replicaIndex, ) = roles
            .matchingsTarget()
            .getMatchingTarget(_matchingId);

        uint64 _size = roles.carstore().getCarsSize(_ids);
        _addStoraged(datasetId, replicaIndex, _matchingId, _provider, _size);

        // roles.finance().claimEscrow(/// TODO: https://github.com/dataswap/core/issues/245
        //     datasetId,
        //     _matchingId,
        //     FinanceType.FIL,
        //     FinanceType.Type.DataTradingFee
        // );
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

    /// @dev Checks if all cars are done in the matchedstore.
    function isAllStoredDone(uint64 _matchingId) public view returns (bool) {
        (
            uint256 total,
            uint256 completed,
            ,
            ,
            ,
            ,

        ) = getMatchingStorageOverview(_matchingId);
        return total == completed;
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

        ) = roles.matchings().getMatchingMetadata(_matchingId);
        if (block.number > createdBlockNumber + storageCompletionPeriodBlocks) {
            return true;
        } else {
            return false;
        }
    }

    /// @dev Internal function to allocate matched datacap.
    // solhint-disable-next-line
    function _allocateDatacap(
        uint64 _matchingId,
        uint64 _size // solhint-disable-next-line
    ) internal {
        (uint64 datasetId, , , , , , ) = roles
            .matchingsTarget()
            .getMatchingTarget(_matchingId);
        uint64 client = roles.datasets().getDatasetMetadataClient(datasetId);
        roles.filecoin().__allocateDatacap(client, uint256(_size));
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
        (datasetId, , , , , replicaIndex, ) = roles
            .matchingsTarget()
            .getMatchingTarget(_matchingId);
        client = roles.datasets().getDatasetMetadataClient(datasetId);
        return (datasetId, client, replicaIndex);
    }

    /// @dev Requests the allocation of matched datacap for a matching process.
    /// @param _matchingId The ID of the matching process.
    function requestAllocateDatacap(
        uint64 _matchingId
    )
        external
        onlyAddress(roles.matchings().getMatchingInitiator(_matchingId))
        onlyNotZeroAddress(roles.matchings().getMatchingInitiator(_matchingId))
        validNextDatacapAllocation(this, _matchingId)
        returns (uint64)
    {
        (
            ,
            ,
            ,
            ,
            ,
            uint256 remainingUnallocatedDatacap,

        ) = getMatchingStorageOverview(_matchingId);
        uint64 maxAllocateCapacityPreTime = roles
            .filplus()
            .datacapRulesMaxAllocatedSizePerTime();
        (uint64 datasetId, , uint16 replicaIndex) = _getDatasetInfo(
            _matchingId
        );

        // require( /// TODO: https://github.com/dataswap/core/issues/245
        //     roles.finance().isEscrowEnough(
        //         datasetId,
        //         _matchingId,
        //         roles.matchingsBids().getMatchingWinner(_matchingId),
        //         FinanceType.FIL,
        //         FinanceType.Type.DatacapChunkLandCollateral
        //     ),
        //     "DatacapChunkLandCollateral escrow not enough"
        // );

        if (remainingUnallocatedDatacap <= maxAllocateCapacityPreTime) {
            _allocateDatacap(_matchingId, uint64(remainingUnallocatedDatacap));
            _addAllocated(
                datasetId,
                replicaIndex,
                _matchingId,
                remainingUnallocatedDatacap
            );
            emit StoragesEvents.DatacapAllocated(
                _matchingId,
                uint64(remainingUnallocatedDatacap)
            );
            return uint64(remainingUnallocatedDatacap);
        } else {
            _allocateDatacap(_matchingId, maxAllocateCapacityPreTime);
            _addAllocated(
                datasetId,
                replicaIndex,
                _matchingId,
                maxAllocateCapacityPreTime
            );

            emit StoragesEvents.DatacapAllocated(
                _matchingId,
                maxAllocateCapacityPreTime
            );
            return maxAllocateCapacityPreTime;
        }
    }

    /// @dev Checks if the next datacap allocation is allowed for a matching process.
    /// @param _matchingId The ID of the matching process.
    /// @return True if next allocation is allowed, otherwise false.
    function isNextDatacapAllocationValid(
        uint64 _matchingId
    ) public view returns (bool) {
        (
            uint256 totalDatacapAllocationRequirement,
            uint256 reallyStored,
            ,
            uint256 availableDatacap,
            ,
            uint256 unallocatedDatacap,

        ) = getMatchingStorageOverview(_matchingId);
        uint64 allocatedDatacap = uint64(
            totalDatacapAllocationRequirement - unallocatedDatacap
        );
        uint64 allocationThreshold = (roles
            .filplus()
            .datacapRulesMaxRemainingPercentageForNext() / 100) *
            roles.filplus().datacapRulesMaxAllocatedSizePerTime();

        if (allocatedDatacap > totalDatacapAllocationRequirement) {
            revert Errors.AllocatedDatacapExceedsTotalRequirement(
                allocatedDatacap,
                uint64(totalDatacapAllocationRequirement)
            );
        }

        if (reallyStored > allocatedDatacap) {
            revert Errors.StoredExceedsAllocatedDatacap(
                uint64(reallyStored),
                allocatedDatacap
            );
        }

        if (availableDatacap > allocationThreshold) {
            revert Errors.AvailableDatacapExceedAllocationThreshold(
                uint64(availableDatacap),
                allocationThreshold
            );
        }

        return true;
    }
}
