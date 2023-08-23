/*******************************************************************************
 *   (c) 2023 DataSwap
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

// Import required external contracts and interfaces
import {Test} from "forge-std/Test.sol";
import {CarReplicaType} from "../../../../../../src/v0.8/types/CarReplicaType.sol";
import {StorageTestSetupHelpers} from "./setup/StorageTestSetupHelpers.sol";

// Contract definition for test helper functions
contract StorageTestHelpers is Test, StorageTestSetupHelpers {
    uint64 private nonce;

    // Helper function to set up the initial environment
    function setupForStorages() internal {
        /// @dev step 1: setup the env for matching publish
        assertMatchingMappingFilesCloseExpectingSuccess();
    }

    /// @dev step 2: do submitStorageDealIds action,not decouple it if this function simple
    function submitStorageDealIds(
        uint64 _matchingId,
        bytes32[] memory _cids
    ) internal {
        for (uint64 i = 0; i < _cids.length; i++) {
            nonce++;
            storages.submitStorageDealId(_matchingId, _cids[i], nonce);
        }
    }

    /// @dev step 3: assert result after matching published
    function assertStorageDealIdSubmitted(uint64 _matchingId) internal {
        assertEq(
            storages.getStoredCarCount(_matchingId),
            matchings.getMatchingCars(_matchingId).length
        );

        assertEq(
            storages.getTotalStoredSize(_matchingId),
            matchings.getMatchingSize(_matchingId)
        );

        bytes32[] memory cars = storages.getStoredCars(_matchingId);
        assertTrue(matchings.isMatchingContainsCars(_matchingId, cars));
        assertEq(
            uint8(CarReplicaType.State.Stored),
            uint8(carstore.getCarReplicaState(cars[0], _matchingId))
        );

        assertTrue(storages.isAllStoredDone(_matchingId));
    }

    //1 assert datasetId valid
    function assertStorageDealIdSubmissionExpectingSuccess() internal {
        /// @dev step 1: setup the env for matching publish
        setupForStorages();

        /// @dev step 2: do submitStorageDealIds action,not decouple it if this function simple
        uint64 matchingId = matchings.matchingsCount();
        bytes32[] memory cids = matchings.getMatchingCars(matchingId);
        vm.startPrank(matchings.getMatchingWinner(matchingId));
        submitStorageDealIds(matchingId, cids);
        vm.stopPrank();
    }
}

// isAllStoredDone
