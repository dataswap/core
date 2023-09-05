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
import {DatasetType} from "src/v0.8/types/DatasetType.sol";
import {MatchingType} from "src/v0.8/types/MatchingType.sol";
import {IStorages} from "src/v0.8/interfaces/module/IStorages.sol";
import {IStoragesAssertion} from "test/v0.8/interfaces/assertions/module/IStoragesAssertion.sol";

/// @dev NOTE: All methods that do not change the state must be tested by methods that will change the state to ensure test coverage.
contract StoragesAssertion is DSTest, Test, IStoragesAssertion {
    IStorages public storages;

    /// @notice Constructor to initialize the StoragesAssertion contract.
    /// @param _storages The address of the IStorages contract to be tested.
    constructor(IStorages _storages) {
        storages = _storages;
    }

    /// @notice Assertion function to test the submission of a storage deal ID.
    /// @param caller The address of the caller.
    /// @param _matchingId The matching ID for which to submit the storage deal.
    /// @param _cid The Content ID (CID) of the stored data.
    /// @param _filecoinDealId The Filecoin deal ID associated with the storage transaction.
    function submitStorageDealIdAssertion(
        address caller,
        uint64 _matchingId,
        bytes32 _cid,
        uint64 _filecoinDealId
    ) external {
        // Record the count of stored cars before the action.
        uint64 oldDoneCount = storages.getStoredCarCount(_matchingId);
        uint64 oldtotalStoredSize = storages.getTotalStoredSize(_matchingId);

        // Perform the action (submitting a storage deal ID).
        vm.prank(caller);
        storages.submitStorageDealId(_matchingId, _cid, _filecoinDealId);

        // Assert that the count of stored cars has increased by one after the action.
        getStoredCarCountAssertion(_matchingId, oldDoneCount + 1);
        uint64 carSize = storages.getStoredCarSize(_matchingId, _cid);
        getTotalStoredSizeAssertion(_matchingId, oldtotalStoredSize + carSize);
    }

    /// @notice Assertion function to test the submission of multiple storage deal IDs.
    /// @param caller The address of the caller.
    /// @param _matchingId The matching ID for which to submit the storage deals.
    /// @param _cids An array of Content IDs (CIDs) of the stored data.
    /// @param _filecoinDealIds An array of Filecoin deal IDs associated with the storage transactions.
    function submitStorageDealIdsAssertion(
        address caller,
        uint64 _matchingId,
        bytes32[] memory _cids,
        uint64[] memory _filecoinDealIds
    ) external {
        // Perform the action (submitting multiple storage deal IDs).
        vm.prank(caller);
        storages.submitStorageDealIds(_matchingId, _cids, _filecoinDealIds);

        // After the action, assert the stored cars.
        getStoredCarsAssertion(_matchingId, _cids);
    }

    /// @notice Assertion function to get the stored cars for a matching.
    /// @param _matchingId The matching ID for which to retrieve stored cars.
    /// @param _expectCars An array of expected stored cars.
    function getStoredCarsAssertion(
        uint64 _matchingId,
        bytes32[] memory _expectCars
    ) public {
        bytes32[] memory cars = storages.getStoredCars(_matchingId);
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

    /// @notice Assertion function to get the total stored size for a matching.
    /// @param _matchingId The matching ID for which to retrieve the total stored size.
    /// @param _expectSize The expected total stored size.
    function getTotalStoredSizeAssertion(
        uint64 _matchingId,
        uint64 _expectSize
    ) public {
        assertEq(storages.getTotalStoredSize(_matchingId), _expectSize);
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
}
