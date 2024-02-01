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

import {DSTest} from "ds-test/test.sol";
import {Test} from "forge-std/Test.sol";
import {IStorages} from "src/v0.8/interfaces/module/IStorages.sol";
import {IStoragesAssertion} from "test/v0.8/interfaces/assertions/module/IStoragesAssertion.sol";
import {StorageStatisticsBaseAssertion} from "test/v0.8/assertions/core/statistics/StorageStatisticsBaseAssertion.sol";
import {ArrayUint64LIB} from "src/v0.8/shared/utils/array/ArrayLIB.sol";

/// @dev NOTE: All methods that do not change the state must be tested by methods that will change the state to ensure test coverage.
contract StoragesAssertion is
    DSTest,
    Test,
    IStoragesAssertion,
    StorageStatisticsBaseAssertion
{
    using ArrayUint64LIB for uint64[];
    IStorages public storages;

    /// @notice Constructor to initialize the StoragesAssertion contract.
    /// @param _storages The address of the IStorages contract to be tested.
    constructor(IStorages _storages) StorageStatisticsBaseAssertion(_storages) {
        storages = _storages;
    }

    /// @notice Retrieves an array of storage providers excluding a specific provider.
    /// @dev This internal pure function is used to get an array of storage providers excluding a specified provider.
    /// @param storageProviders The array of storage providers.
    /// @param _provider The storage provider to exclude from the result.
    /// @return An array of storage providers excluding the specified provider.
    function _getStorageProviders(
        uint64[] memory storageProviders,
        uint64 _provider
    ) internal pure returns (uint64[] memory) {
        if (storageProviders.isContains(_provider)) {
            return storageProviders;
        }
        uint64[] memory ret = new uint64[](storageProviders.length + 1);
        for (uint256 i = 0; i < storageProviders.length; i++) {
            ret[i] = storageProviders[i];
        }
        ret[storageProviders.length] = _provider;
        return ret;
    }

    /// @notice Submits an overview of storage claim IDs for statistical analysis within a dataset matching.
    /// @dev This internal function is used to submit an overview of storage claim IDs associated with a specific matching process and dataset.
    /// @param caller The address initiating the submission.
    /// @param _matchingId The unique identifier of the matching process.
    /// @param _provider The storage provider's identifier.
    /// @param _cids An array of unique content identifiers (CIDs) associated with the storage claims.
    /// @param _claimIds An array of storage claim IDs corresponding to the submitted CIDs.
    function _submitStorageClaimIdsMatchingStatistcsOverviewAssertion(
        address caller,
        uint64 _matchingId,
        uint64 _provider,
        uint64[] memory _cids,
        uint64[] memory _claimIds
    ) internal {
        (
            uint256 total,
            uint256 completed,
            uint256 usedDatacap,
            uint256 availableDatacap,
            uint256 canceled,
            uint256 unallocatedDatacap,
            uint64[] memory storageProviders
        ) = storages.getMatchingStorageOverview(_matchingId);
        // Perform the action (submitting a storage claim ID).
        vm.prank(caller);
        storages.submitStorageClaimIds(
            _matchingId,
            _provider,
            _cids,
            _claimIds
        );
        uint64 size = storages.roles().carstore().getCarsSize(_cids);
        uint64[] memory sps = _getStorageProviders(storageProviders, _provider);
        getMatchingStorageOverviewAssertion(
            _matchingId,
            total,
            completed + uint256(size),
            usedDatacap + uint256(size),
            availableDatacap - uint256(size),
            canceled,
            unallocatedDatacap,
            sps
        );
    }

    /// @notice Submits an overview of storage claim IDs for statistical analysis within a dataset replica.
    /// @dev This internal function is used to submit an overview of storage claim IDs associated with a specific matching process and dataset.
    /// @param caller The address initiating the submission.
    /// @param _matchingId The unique identifier of the matching process.
    /// @param _provider The storage provider's identifier.
    /// @param _cids An array of unique content identifiers (CIDs) associated with the storage claims.
    /// @param _claimIds An array of storage claim IDs corresponding to the submitted CIDs.
    function _submitStorageClaimIdsReplicaStatistcsOverviewAssertion(
        address caller,
        uint64 _matchingId,
        uint64 _provider,
        uint64[] memory _cids,
        uint64[] memory _claimIds
    ) internal {
        (uint64 datasetId, , , , , uint16 replicaIndex, ) = storages
            .roles()
            .matchingsTarget()
            .getMatchingTarget(_matchingId);
        (
            uint256 total,
            uint256 completed,
            uint256 usedDatacap,
            uint256 availableDatacap,
            uint256 canceled,
            uint256 unallocatedDatacap
        ) = storages.getReplicaStorageOverview(datasetId, replicaIndex);
        // Perform the action (submitting a storage claim ID).
        _submitStorageClaimIdsMatchingStatistcsOverviewAssertion(
            caller,
            _matchingId,
            _provider,
            _cids,
            _claimIds
        );
        uint64 size = storages.roles().carstore().getCarsSize(_cids);
        getReplicaStorageOverviewAssertion(
            datasetId,
            replicaIndex,
            total,
            completed + uint256(size),
            usedDatacap + uint256(size),
            availableDatacap - uint256(size),
            canceled,
            unallocatedDatacap
        );
    }

    /// @notice Submits an overview of storage claim IDs for statistical analysis within a dataset.
    /// @dev This internal function is used to submit an overview of storage claim IDs associated with a specific matching process and dataset.
    /// @param caller The address initiating the submission.
    /// @param _matchingId The unique identifier of the matching process.
    /// @param _provider The storage provider's identifier.
    /// @param _cids An array of unique content identifiers (CIDs) associated with the storage claims.
    /// @param _claimIds An array of storage claim IDs corresponding to the submitted CIDs.
    function _submitStorageClaimIdsDatasetStatistcsOverviewAssertion(
        address caller,
        uint64 _matchingId,
        uint64 _provider,
        uint64[] memory _cids,
        uint64[] memory _claimIds
    ) internal {
        (uint64 datasetId, , , , , , ) = storages
            .roles()
            .matchingsTarget()
            .getMatchingTarget(_matchingId);
        (
            uint256 total,
            uint256 completed,
            uint256 usedDatacap,
            uint256 availableDatacap,
            uint256 canceled,
            uint256 unallocatedDatacap
        ) = storages.getDatasetStorageOverview(datasetId);
        // Perform the action (submitting a storage claim ID).
        _submitStorageClaimIdsReplicaStatistcsOverviewAssertion(
            caller,
            _matchingId,
            _provider,
            _cids,
            _claimIds
        );
        uint64 size = storages.roles().carstore().getCarsSize(_cids);

        getDatasetStorageOverviewAssertion(
            datasetId,
            total,
            completed + uint256(size),
            usedDatacap + uint256(size),
            availableDatacap - uint256(size),
            canceled,
            unallocatedDatacap
        );
    }

    /// @notice Submits an overview of storage claim IDs for statistical analysis.
    /// @dev This internal function is used to submit an overview of storage claim IDs associated with a specific matching process.
    /// @param caller The address initiating the submission.
    /// @param _matchingId The unique identifier of the matching process.
    /// @param _provider The storage provider's identifier.
    /// @param _cids An array of unique content identifiers (CIDs) associated with the storage claims.
    /// @param _claimIds An array of storage claim IDs corresponding to the submitted CIDs.
    function _submitStorageClaimIdsStatistcsOverviewAssertion(
        address caller,
        uint64 _matchingId,
        uint64 _provider,
        uint64[] memory _cids,
        uint64[] memory _claimIds
    ) internal {
        (
            uint256 dataswapTotal,
            uint256 total,
            uint256 completed,
            uint256 usedDatacap,
            uint256 availableDatacap,
            uint256 canceled,
            uint256 unallocatedDatacap
        ) = storages.getStorageOverview();
        // Perform the action (submitting a storage claim ID).
        _submitStorageClaimIdsDatasetStatistcsOverviewAssertion(
            caller,
            _matchingId,
            _provider,
            _cids,
            _claimIds
        );
        uint64 size = storages.roles().carstore().getCarsSize(_cids);
        getStorageOverviewAssertion(
            dataswapTotal,
            total,
            completed + uint256(size),
            usedDatacap + uint256(size),
            availableDatacap - uint256(size),
            canceled,
            unallocatedDatacap
        );
    }

    /// @notice Assertion function to test the submission of a storage claim ID.
    /// @param caller The address of the caller.
    /// @param _matchingId The matching ID for which to submit the storage deal.
    /// @param _provider The storage provider for which to submit the storage deal.
    /// @param _cid The Content ID (CID) of the stored data.
    /// @param _claimId The Filecoin claim ID associated with the storage transaction.
    function submitStorageClaimIdAssertion(
        address caller,
        uint64 _matchingId,
        uint64 _provider,
        uint64 _cid,
        uint64 _claimId
    ) external {
        // Record the count of stored cars before the action.
        uint64 oldDoneCount = storages.getStoredCarCount(_matchingId);
        uint64[] memory cid = new uint64[](1);
        uint64[] memory claimId = new uint64[](1);
        cid[0] = _cid;
        claimId[0] = _claimId;

        // Perform the action (submitting a storage claim ID).
        _submitStorageClaimIdsStatistcsOverviewAssertion(
            caller,
            _matchingId,
            _provider,
            cid,
            claimId
        );

        // Assert that the count of stored cars has increased by one after the action.
        getStoredCarCountAssertion(_matchingId, oldDoneCount + 1);
    }

    /// @notice Assertion function to test the submission of multiple storage claim IDs.
    /// @param caller The address of the caller.
    /// @param _matchingId The matching ID for which to submit the storage deals.
    /// @param _provider The storage provider for which to submit the storage deal.
    /// @param _cids An array of Content IDs (CIDs) of the stored data.
    /// @param _claimIds An array of Filecoin claim IDs associated with the storage transactions.
    function submitStorageClaimIdsAssertion(
        address caller,
        uint64 _matchingId,
        uint64 _provider,
        uint64[] memory _cids,
        uint64[] memory _claimIds
    ) external {
        // Perform the action (submitting multiple storage claim IDs).
        _submitStorageClaimIdsStatistcsOverviewAssertion(
            caller,
            _matchingId,
            _provider,
            _cids,
            _claimIds
        );
        // After the action, assert the stored cars.
        getStoredCarsAssertion(_matchingId, _cids);
    }

    /// @notice Assertion function to get the stored cars for a matching.
    /// @param _matchingId The matching ID for which to retrieve stored cars.
    /// @param _expectCars An array of expected stored cars.
    function getStoredCarsAssertion(
        uint64 _matchingId,
        uint64[] memory _expectCars
    ) public {
        uint64[] memory cars = storages.getStoredCars(_matchingId);
        assertEq(cars.length, _expectCars.length);
        for (uint64 i = 0; i < cars.length; i++) {
            assertEq(cars[i], _expectCars[i]);
        }
    }

    /// @notice Assertion function to get the count of stored cars for a matching.
    /// @param _matchingId The matching ID for which to retrieve the count of stored cars.
    /// @param _expectCount The expected count of stored cars.
    function getStoredCarCountAssertion(
        uint64 _matchingId,
        uint64 _expectCount
    ) public {
        assertEq(storages.getStoredCarCount(_matchingId), _expectCount);
    }

    /// @notice Assertion function to check if all storage is done for a matching.
    /// @param _matchingId The matching ID to check.
    /// @param _expectIsAllStoredDone The expected result indicating if all storage is done.
    function isAllStoredDoneAssertion(
        uint64 _matchingId,
        bool _expectIsAllStoredDone
    ) public {
        assertEq(storages.isAllStoredDone(_matchingId), _expectIsAllStoredDone);
    }

    /// @notice Requests an overview of allocated datacap matching statistics for a specific matching process.
    /// @dev This internal function is used to request and retrieve an overview of allocated datacap matching statistics.
    /// @param caller The address initiating the request.
    /// @param _matchingId The unique identifier of the matching process.
    /// @return The result or identifier associated with the requested datacap matching statistics overview.
    function _requestAllocateDatacapMatchingStatisticsOverviewAssertion(
        address caller,
        uint64 _matchingId
    ) internal returns (uint64) {
        (
            uint256 total,
            uint256 completed,
            uint256 usedDatacap,
            uint256 availableDatacap,
            uint256 canceled,
            uint256 unallocatedDatacap,
            uint64[] memory storageProviders
        ) = storages.getMatchingStorageOverview(_matchingId);
        // Perform the action.
        vm.prank(caller);
        uint64 addDatacap = storages.requestAllocateDatacap(_matchingId);
        getMatchingStorageOverviewAssertion(
            _matchingId,
            total,
            completed,
            usedDatacap,
            availableDatacap + uint256(addDatacap),
            canceled,
            unallocatedDatacap - uint256(addDatacap),
            storageProviders
        );
        return addDatacap;
    }

    /// @notice Requests an overview of allocated datacap replica statistics for a specific matching process.
    /// @dev This internal function is used to request and retrieve an overview of allocated datacap replica statistics.
    /// @param caller The address initiating the request.
    /// @param _matchingId The unique identifier of the matching process.
    /// @return The result or identifier associated with the requested datacap replica statistics overview.
    function _requestAllocateDatacapReplicaStatisticsOverviewAssertion(
        address caller,
        uint64 _matchingId
    ) internal returns (uint64) {
        (uint64 datasetId, , , , , uint16 replicaIndex, ) = storages
            .roles()
            .matchingsTarget()
            .getMatchingTarget(_matchingId);
        (
            uint256 total,
            uint256 completed,
            uint256 usedDatacap,
            uint256 availableDatacap,
            uint256 canceled,
            uint256 unallocatedDatacap
        ) = storages.getReplicaStorageOverview(datasetId, replicaIndex);
        // Perform the action.
        uint64 addDatacap = _requestAllocateDatacapMatchingStatisticsOverviewAssertion(
                caller,
                _matchingId
            );
        getReplicaStorageOverviewAssertion(
            datasetId,
            replicaIndex,
            total,
            completed,
            usedDatacap,
            availableDatacap + uint256(addDatacap),
            canceled,
            unallocatedDatacap - uint256(addDatacap)
        );
        return addDatacap;
    }

    /// @notice Requests an overview of allocated datacap dataset statistics for a specific matching process.
    /// @dev This internal function is used to request and retrieve an overview of allocated datacap dataset statistics.
    /// @param caller The address initiating the request.
    /// @param _matchingId The unique identifier of the matching process.
    /// @return The result or identifier associated with the requested datacap dataset statistics overview.
    function _requestAllocateDatacapDatasetStatisticsOverviewAssertion(
        address caller,
        uint64 _matchingId
    ) internal returns (uint64) {
        (uint64 datasetId, , , , , , ) = storages
            .roles()
            .matchingsTarget()
            .getMatchingTarget(_matchingId);
        (
            uint256 total,
            uint256 completed,
            uint256 usedDatacap,
            uint256 availableDatacap,
            uint256 canceled,
            uint256 unallocatedDatacap
        ) = storages.getDatasetStorageOverview(datasetId);
        // Perform the action.
        uint64 addDatacap = _requestAllocateDatacapReplicaStatisticsOverviewAssertion(
                caller,
                _matchingId
            );
        getDatasetStorageOverviewAssertion(
            datasetId,
            total,
            completed,
            usedDatacap,
            availableDatacap + uint256(addDatacap),
            canceled,
            unallocatedDatacap - uint256(addDatacap)
        );
        return addDatacap;
    }

    /// @notice Requests an overview of allocated datacap statistics for a specific matching process.
    /// @dev This internal function is used to request and retrieve an overview of allocated datacap statistics.
    /// @param caller The address initiating the request.
    /// @param _matchingId The unique identifier of the matching process.
    /// @return The result or identifier associated with the requested datacap statistics overview.
    function _requestAllocateDatacapStatisticsOverviewAssertion(
        address caller,
        uint64 _matchingId
    ) internal returns (uint64) {
        (
            uint256 dataswapTotal,
            uint256 total,
            uint256 completed,
            uint256 usedDatacap,
            uint256 availableDatacap,
            uint256 canceled,
            uint256 unallocatedDatacap
        ) = storages.getStorageOverview();
        // Perform the action.
        uint64 addDatacap = _requestAllocateDatacapDatasetStatisticsOverviewAssertion(
                caller,
                _matchingId
            );
        getStorageOverviewAssertion(
            dataswapTotal,
            total,
            completed,
            usedDatacap,
            availableDatacap + uint256(addDatacap),
            canceled,
            unallocatedDatacap - uint256(addDatacap)
        );
        return addDatacap;
    }

    /// @notice Assertion function for requesting datacap allocation.
    /// @param caller The address of the caller.
    /// @param _matchingId The matching ID for which datacap allocation is requested.
    function requestAllocateDatacapAssertion(
        address caller,
        uint64 _matchingId
    ) external {
        // Before the action, capture the initial state.
        isNextDatacapAllocationValidAssertion(_matchingId, true);

        // Perform the action.
        _requestAllocateDatacapStatisticsOverviewAssertion(caller, _matchingId);

        isNextDatacapAllocationValidAssertion(_matchingId, false);
    }

    /// @notice Assertion function for checking if the next datacap allocation is valid for a matching ID.
    /// @param _matchingId The matching ID for which to check datacap allocation validity.
    /// @param _expectOK The expected validity status (true or false).
    function isNextDatacapAllocationValidAssertion(
        uint64 _matchingId,
        bool _expectOK
    ) public {
        if (!_expectOK) {
            vm.expectRevert();
        }
        assertEq(storages.isNextDatacapAllocationValid(_matchingId), _expectOK);
    }
}
