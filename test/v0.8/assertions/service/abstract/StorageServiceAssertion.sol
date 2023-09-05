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

import {ServiceAssertionBase} from "test/v0.8/assertions/service/abstract/base/ServiceAssertionBase.sol";

/// @title StorageServiceAssertion
abstract contract StorageServiceAssertion is ServiceAssertionBase {
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
        storagesAssertion.submitStorageDealIdAssertion(
            caller,
            _matchingId,
            _cid,
            _filecoinDealId
        );
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
        storagesAssertion.submitStorageDealIdsAssertion(
            caller,
            _matchingId,
            _cids,
            _filecoinDealIds
        );
    }

    /// @notice Assertion function to get the stored cars for a matching.
    /// @param _matchingId The matching ID for which to retrieve stored cars.
    /// @param _expectCars An array of expected stored cars.
    function getStoredCarsAssertion(
        uint64 _matchingId,
        bytes32[] memory _expectCars
    ) public {
        storagesAssertion.getStoredCarsAssertion(_matchingId, _expectCars);
    }

    /// @notice Assertion function to get the count of stored cars for a matching.
    /// @param _matchingId The matching ID for which to retrieve the count of stored cars.
    /// @param _expectCount The expected count of stored cars.
    function getStoredCarCountAssertion(
        uint64 _matchingId,
        uint64 _expectCount
    ) public {
        storagesAssertion.getStoredCarCountAssertion(_matchingId, _expectCount);
    }

    /// @notice Assertion function to get the total stored size for a matching.
    /// @param _matchingId The matching ID for which to retrieve the total stored size.
    /// @param _expectSize The expected total stored size.
    function getTotalStoredSizeAssertion(
        uint64 _matchingId,
        uint64 _expectSize
    ) public {
        storagesAssertion.getTotalStoredSizeAssertion(_matchingId, _expectSize);
    }

    // TODO: To be tested once available: https://github.com/dataswap/core/issues/73
    /// @notice Assertion function to check if all storage is done for a matching.
    /// @param _matchingId The matching ID to check.
    /// @param _expectIsAllStoredDone The expected result indicating if all storage is done.
    function isAllStoredDoneAssertion(
        uint64 _matchingId,
        bool _expectIsAllStoredDone
    ) public {
        storagesAssertion.isAllStoredDoneAssertion(
            _matchingId,
            _expectIsAllStoredDone
        );
    }
}
