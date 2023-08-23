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

// Import required external contracts and interfaces
import {Test} from "forge-std/Test.sol";
import {Roles} from "src/v0.8/core/access/Roles.sol";
import {Filplus} from "src/v0.8/core/filplus/Filplus.sol";
import {MockFilecoin} from "src/v0.8/mocks/core/filecoin/MockFilecoin.sol";

// Import various shared modules, modifiers, events, and error definitions
import {CarstoreEvents} from "src/v0.8/shared/events/CarstoreEvents.sol";

// Import necessary custom types
import {CarReplicaType} from "src/v0.8/types/CarReplicaType.sol";
import {Carstore} from "src/v0.8/core/carstore/Carstore.sol";
import {FilecoinType} from "src/v0.8/types/FilecoinType.sol";

// Contract definition for test helper functions
contract CarstoreTestHelpers is Test {
    Carstore public carstore;
    address payable public governanceContractAddresss;

    // Helper function to set up the initial environment
    function setUp() public {
        Roles role = new Roles();
        Filplus filplus = new Filplus(governanceContractAddresss);
        MockFilecoin filecoin = new MockFilecoin();
        carstore = new Carstore(role, filplus, filecoin);
    }

    // Helper function: Add a Car and perform assertions
    function addCarAndAssert(
        bytes32 _cid,
        uint64 _datasetId,
        uint64 _size
    ) internal {
        // Add car
        carstore.addCar(_cid, _datasetId, _size);

        // Perform assertions
        assertCarAdded(_cid, _datasetId, _size);
    }

    // Helper function to assert the addition of a single car
    function assertCarAdded(
        bytes32 _cid,
        uint64 _datasetId,
        uint64 _size
    ) internal {
        assertTrue(carstore.hasCar(_cid), "Car should exist");
        assertEq(
            carstore.getCarDatasetId(_cid),
            _datasetId,
            "Dataset ID should match"
        );
        assertEq(carstore.getCarSize(_cid), _size, "Car size should match");
        assertEq(
            carstore.getCarReplicasCount(_cid),
            0,
            "Replica count should be 0"
        );
        assertEq(carstore.carsCount(), 1, "Cars count should be 1");
    }

    // Helper function: Add a batch of Cars and perform assertions
    function addCarsAndAssert(
        bytes32[] memory _cids,
        uint64 _datasetId,
        uint64[] memory _sizes
    ) internal {
        carstore.addCars(_cids, _datasetId, _sizes);

        for (uint64 i = 0; i < _cids.length; i++) {
            assertTrue(carstore.hasCar(_cids[i]), "Car should exist");
            assertEq(
                carstore.getCarDatasetId(_cids[i]),
                _datasetId,
                "Dataset ID should match"
            );
            assertEq(
                carstore.getCarSize(_cids[i]),
                _sizes[i],
                "Car size should match"
            );
            assertEq(
                carstore.getCarReplicasCount(_cids[i]),
                0,
                "Replica count should be 0"
            );
        }

        assertTrue(carstore.hasCars(_cids), "Cars should exist");
    }

    // Helper function to add a car replica and perform assertions
    function addReplicaAndAssert(bytes32 _cid, uint64 _matchingId) internal {
        carstore.addCarReplica(_cid, _matchingId);
        assertCarReplicaAdded(_cid, _matchingId);
    }

    // Helper function to assert the addition of a car replica
    function assertCarReplicaAdded(bytes32 _cid, uint64 _matchingId) internal {
        // Check if car replica exists
        assertTrue(
            carstore.hasCarReplica(_cid, _matchingId),
            "Car replica should exist"
        );

        // Check replica state
        assertEq(
            uint8(carstore.getCarReplicaState(_cid, _matchingId)),
            uint8(CarReplicaType.State.Matched),
            "Replica state should be Matched"
        );

        // Check replica count
        assertEq(
            carstore.getCarReplicasCount(_cid),
            1,
            "Replica count should be 1"
        );

        // Check replica state and filecoin deal id
        (CarReplicaType.State state, uint64 filecoinDealId) = carstore
            .getCarReplica(_cid, _matchingId);
        assertEq(
            uint8(state),
            uint8(CarReplicaType.State.Matched),
            "Replica state should be Matched"
        );
        assertEq(
            filecoinDealId,
            carstore.getCarReplicaFilecoinDealId(_cid, _matchingId),
            "Filecoin deal id should be Matched"
        );
    }

    // Helper function to assert car replica state and deal ID
    function assertCarReplicaStateAndDealId(
        bytes32 _cid,
        uint64 _matchingId,
        CarReplicaType.State expectedState,
        uint64 _expectedDealId
    ) internal {
        assertTrue(
            expectedState == carstore.getCarReplicaState(_cid, _matchingId),
            "Replica state should match"
        );
        assertEq(
            carstore.getCarReplicaFilecoinDealId(_cid, _matchingId),
            _expectedDealId,
            "Filecoin deal ID should match"
        );
    }

    // Helper function to set car replica Filecoin deal ID and perform assertions
    function setCarReplicaFilecoinDealIdAndAssert(
        bytes32 _cid,
        uint64 _matchingId,
        uint64 _filecoinDealId,
        FilecoinType.DealState _filecoinDealState,
        CarReplicaType.State _expectedState
    ) internal {
        // Add car and car replica
        addCarAndAssert(_cid, 1, 32 * 1024 * 1024 * 1024);
        addReplicaAndAssert(_cid, _matchingId);

        // Set mock deal state to Stored
        carstore.getFilecoin().setMockDealState(_filecoinDealState);
        // Expect emit event
        vm.expectEmit(true, true, true, true);
        emit CarstoreEvents.CarReplicaFilecoinDealIdSet(
            _cid,
            _matchingId,
            _filecoinDealId
        );
        // Set car replica Filecoin deal ID
        carstore.setCarReplicaFilecoinDealId(
            _cid,
            _matchingId,
            _filecoinDealId
        );
        // Assert replica state and deal ID
        assertCarReplicaStateAndDealId(
            _cid,
            _matchingId,
            _expectedState,
            _filecoinDealId
        );
    }
}
