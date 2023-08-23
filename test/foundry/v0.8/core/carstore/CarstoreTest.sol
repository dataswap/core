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

import "forge-std/Test.sol";
/// interface
import {ICarstore} from "../../../../../src/v0.8/interfaces/core/ICarstore.sol";
import {IRoles} from "../../../../../src/v0.8/interfaces/core/IRoles.sol";
import {IFilplus} from "../../../../../src/v0.8/interfaces/core/IFilplus.sol";
import {IFilecoin} from "../../../../../src/v0.8/interfaces/core/IFilecoin.sol";
import {Roles} from "../../../../../src/v0.8/core/access/Roles.sol";
import {Filplus} from "../../../../../src/v0.8/core/filplus/Filplus.sol";
import {MockFilecoin} from "../../../../../src/v0.8/mocks/core/filecoin/MockFilecoin.sol";
///shared
import {CarstoreModifiers} from "../../../../../src/v0.8/shared/modifiers/CarstoreModifiers.sol";
import {CarstoreEvents} from "../../../../../src/v0.8/shared/events/CarstoreEvents.sol";
import {Errors} from "../../../../../src/v0.8/shared/errors/Errors.sol";
///type
import {CarReplicaType} from "../../../../../src/v0.8/types/CarReplicaType.sol";
import {Carstore} from "../../../../../src/v0.8/core/carstore/Carstore.sol";
import {FilecoinType} from "../../../../../src/v0.8/types/FilecoinType.sol";
import {CarstoreTestHelpers} from "./CarstoreTestHelpers.sol";

// Main test contract inheriting from Test and CarstoreTestHelpers
contract CarstoreTest is Test, CarstoreTestHelpers {
    // Test function to add a car
    function testAddCar(
        bytes32 _cid,
        uint64 _datasetId,
        uint64 _size
    ) external {
        vm.assume(_datasetId != 0 && _size != 0);
        addCarAndAssert(_cid, _datasetId, _size);
    }

    // Test function to add a car with invalid ID
    function testAddCarWithIdInvalid(
        bytes32 _cid,
        uint64 _datasetId,
        uint64 _size
    ) external {
        vm.assume(_datasetId == 0 || _size == 0);
        vm.expectRevert(bytes("Value must not be zero"));
        carstore.addCar(_cid, _datasetId, _size);
    }

    // Test function to add a car with car already exists
    function testAddCarWithCarAlreadyExists(
        bytes32 _cid,
        uint64 _datasetId,
        uint64 _size
    ) external {
        vm.assume(_datasetId != 0 && _size != 0);
        addCarAndAssert(_cid, _datasetId, _size);
        vm.expectRevert(
            abi.encodeWithSelector(Errors.CarAlreadyExists.selector, _cid)
        );
        carstore.addCar(_cid, _datasetId, _size);
    }

    // Test function to add cars
    function testAddCars(uint64 _datasetId) external {
        vm.assume(_datasetId != 0);

        uint64 carsCount = 100;
        bytes32[] memory cids = new bytes32[](carsCount);
        uint64[] memory sizes = new uint64[](carsCount);
        for (uint64 i = 0; i < carsCount; i++) {
            sizes[i] = i + 1;
            cids[i] = convertUint64ToBytes32(i);
        }

        vm.expectEmit(true, false, false, true);
        emit CarstoreEvents.CarsAdded(cids);
        addCarsAndAssert(cids, _datasetId, sizes);
    }

    // Test function to add cars with invalid id
    function testAddCarsWithIdInvalid(
        bytes32[] memory _cids,
        uint64 _datasetId,
        uint64[] memory _sizes
    ) external {
        vm.assume(_datasetId == 0);
        vm.expectRevert(bytes("Value must not be zero"));
        carstore.addCars(_cids, _datasetId, _sizes);
    }

    // Test function to add car replica
    function testAddCarReplica(bytes32 _cid, uint64 _matchingId) external {
        // Assume valid _matchingId
        vm.assume(_matchingId != 0);

        // Add a car to the carstore
        addCarAndAssert(_cid, 1, 32 * 1024 * 1024 * 1024);

        // Expect and emit CarReplicaAdded event
        vm.expectEmit(true, true, false, true);
        emit CarstoreEvents.CarReplicaAdded(_cid, _matchingId);

        // Add car replica and assertions
        addReplicaAndAssert(_cid, _matchingId);
    }

    // Test function to add car replica with invalid id
    function testAddCarReplicaWithInvalidId(
        bytes32 _cid,
        uint64 _matchingId
    ) external {
        vm.assume(_matchingId == 0);
        addCarAndAssert(_cid, 1, 32 * 1024 * 1024 * 1024);
        vm.expectRevert(bytes("Value must not be zero"));
        carstore.addCarReplica(_cid, _matchingId);
    }

    // Test function to add car replica with car not exist
    function testAddCarReplicaWithCarNotExist(
        bytes32 _cid,
        uint64 _matchingId
    ) external {
        vm.assume(_matchingId != 0);
        vm.expectRevert(
            abi.encodeWithSelector(Errors.CarNotExist.selector, _cid)
        );
        carstore.addCarReplica(_cid, _matchingId);
    }

    // Test function to add car replica with replica alreay exist
    function testAddCarReplicaWithReplicaAlreadyExists(
        bytes32 _cid,
        uint64 _matchingId
    ) external {
        vm.assume(_matchingId != 0);
        addCarAndAssert(_cid, 1, 32 * 1024 * 1024 * 1024);
        carstore.addCarReplica(_cid, _matchingId);
        assertCarReplicaAdded(_cid, _matchingId);

        vm.expectRevert(
            abi.encodeWithSelector(
                Errors.ReplicaAlreadyExists.selector,
                _cid,
                _matchingId
            )
        );
        carstore.addCarReplica(_cid, _matchingId);
    }

    // Test function to set car replica filecoin deal id
    function testSetCarReplicaFilecoinDealId(
        bytes32 _cid,
        uint64 _matchingId,
        uint64 _filecoinDealId,
        uint8 _filecoinDealState,
        uint8 _replicaState
    ) external {
        vm.assume(_matchingId != 0 && _filecoinDealId != 0);
        vm.assume(
            (_filecoinDealState == uint8(FilecoinType.DealState.Stored) &&
                _replicaState == uint8(CarReplicaType.State.Stored)) ||
                (_filecoinDealState ==
                    uint8(FilecoinType.DealState.StorageFailed) &&
                    _replicaState == uint8(CarReplicaType.State.StorageFailed))
        );
        setCarReplicaFilecoinDealIdAndAssert(
            _cid,
            _matchingId,
            _filecoinDealId,
            FilecoinType.DealState(_filecoinDealState),
            CarReplicaType.State(_replicaState)
        );
    }

    // Test function to set car replica filecoin deal id with invalid id
    function testSetCarReplicaFilecoinDealIdWithInvalidId(
        bytes32 _cid,
        uint64 _matchingId,
        uint64 _filecoinDealId
    ) external {
        vm.assume(_matchingId != 0 && _filecoinDealId == 0);
        addCarAndAssert(_cid, 1, 32 * 1024 * 1024 * 1024);
        addReplicaAndAssert(_cid, _matchingId);
        vm.expectRevert(bytes("Value must not be zero"));
        carstore.setCarReplicaFilecoinDealId(
            _cid,
            _matchingId,
            _filecoinDealId
        );
    }

    // Test function to set car replica filecoin deal id with replica not exsit
    function testSetCarReplicaFilecoinDealIdWithReplicaNotExist(
        bytes32 _cid,
        uint64 _matchingId,
        uint64 _filecoinDealId
    ) external {
        vm.assume(_matchingId != 0 && _filecoinDealId != 0);
        addCarAndAssert(_cid, 1, 32 * 1024 * 1024 * 1024);

        vm.expectRevert(
            abi.encodeWithSelector(
                Errors.ReplicaNotExist.selector,
                _cid,
                _matchingId
            )
        );
        carstore.setCarReplicaFilecoinDealId(
            _cid,
            _matchingId,
            _filecoinDealId
        );
    }

    // Test function to set car replica filecoin deal id with deal id already set
    function testSetCarReplicaFilecoinDealIdWithReplicaFilecoinDealIdExists(
        bytes32 _cid,
        uint64 _matchingId,
        uint64 _filecoinDealId,
        uint8 _filecoinDealState,
        uint8 _replicaState
    ) external {
        vm.assume(_matchingId != 0 && _filecoinDealId != 0);
        vm.assume(
            (_filecoinDealState == uint8(FilecoinType.DealState.Stored) &&
                _replicaState == uint8(CarReplicaType.State.Stored)) ||
                (_filecoinDealState ==
                    uint8(FilecoinType.DealState.StorageFailed) &&
                    _replicaState == uint8(CarReplicaType.State.StorageFailed))
        );
        setCarReplicaFilecoinDealIdAndAssert(
            _cid,
            _matchingId,
            _filecoinDealId,
            FilecoinType.DealState(_filecoinDealState),
            CarReplicaType.State(_replicaState)
        );

        vm.expectRevert(
            abi.encodeWithSelector(
                Errors.InvalidReplicaState.selector,
                _cid,
                _matchingId
            )
        );
        carstore.setCarReplicaFilecoinDealId(
            _cid,
            _matchingId,
            _filecoinDealId
        );
    }

    // Test function to report replica expired
    function testReportCarReplicaExpired(
        bytes32 _cid,
        uint64 _matchingId,
        uint64 _filecoinDealId
    ) external {
        vm.assume(_matchingId != 0 && _filecoinDealId != 0);
        setCarReplicaFilecoinDealIdAndAssert(
            _cid,
            _matchingId,
            _filecoinDealId,
            FilecoinType.DealState.Stored,
            CarReplicaType.State.Stored
        );

        carstore.getFilecoin().setMockDealState(FilecoinType.DealState.Expired);
        vm.expectEmit(true, true, false, true);
        emit CarstoreEvents.CarReplicaExpired(_cid, _matchingId);
        carstore.reportCarReplicaExpired(_cid, _matchingId, _filecoinDealId);
        assertTrue(
            CarReplicaType.State.Expired ==
                carstore.getCarReplicaState(_cid, _matchingId),
            "Replica state should be Expired"
        );
    }

    // Test function to report replica expired with invalid deal state
    function testReportCarReplicaExpiredWithInvalidDealState(
        bytes32 _cid,
        uint64 _matchingId,
        uint64 _filecoinDealId,
        uint8 _filecoinDealState
    ) external {
        vm.assume(_matchingId != 0 && _filecoinDealId != 0);
        setCarReplicaFilecoinDealIdAndAssert(
            _cid,
            _matchingId,
            _filecoinDealId,
            FilecoinType.DealState.Stored,
            CarReplicaType.State.Stored
        );

        vm.assume(
            _filecoinDealState == uint8(FilecoinType.DealState.Stored) ||
                _filecoinDealState ==
                uint8(FilecoinType.DealState.StorageFailed) ||
                _filecoinDealState == uint8(FilecoinType.DealState.Slashed)
        );
        carstore.getFilecoin().setMockDealState(
            FilecoinType.DealState(_filecoinDealState)
        );
        vm.expectRevert(
            abi.encodeWithSelector(
                Errors.InvalidReplicaFilecoinDealState.selector,
                _cid,
                _filecoinDealId
            )
        );
        carstore.reportCarReplicaExpired(_cid, _matchingId, _filecoinDealId);
    }

    // Test function to report replica expired with invalid id
    function testReportCarReplicaExpiredWithInvalidId(
        bytes32 _cid,
        uint64 _matchingId,
        uint64 _filecoinDealId
    ) external {
        vm.assume(_matchingId == 0 || _filecoinDealId == 0);
        vm.expectRevert();
        carstore.reportCarReplicaExpired(_cid, _matchingId, _filecoinDealId);
    }

    // Test function to report replica expired with car not exist
    function testReportCarReplicaExpiredWithCarNotExist(
        bytes32 _cid,
        uint64 _matchingId,
        uint64 _filecoinDealId
    ) external {
        vm.expectRevert(
            abi.encodeWithSelector(Errors.CarNotExist.selector, _cid)
        );
        carstore.reportCarReplicaExpired(_cid, _matchingId, _filecoinDealId);
    }

    // Test function to report replica expired with car replica not exist
    function testReportCarReplicaExpiredWithReplicaNotExist(
        bytes32 _cid,
        uint64 _matchingId,
        uint64 _filecoinDealId
    ) external {
        vm.assume(_matchingId != 0 && _filecoinDealId != 0);
        carstore.addCar(_cid, 1, 32 * 1024 * 1024 * 1024);

        vm.expectRevert(
            abi.encodeWithSelector(
                Errors.ReplicaNotExist.selector,
                _cid,
                _matchingId
            )
        );
        carstore.reportCarReplicaExpired(_cid, _matchingId, _filecoinDealId);
    }

    // Test function to report replica slashed
    function testReportCarReplicaSlashed(
        bytes32 _cid,
        uint64 _matchingId,
        uint64 _filecoinDealId
    ) external {
        vm.assume(_matchingId != 0 && _filecoinDealId != 0);
        setCarReplicaFilecoinDealIdAndAssert(
            _cid,
            _matchingId,
            _filecoinDealId,
            FilecoinType.DealState.Stored,
            CarReplicaType.State.Stored
        );

        carstore.getFilecoin().setMockDealState(FilecoinType.DealState.Slashed);
        vm.expectEmit(true, true, false, true);
        emit CarstoreEvents.CarReplicaSlashed(_cid, _matchingId);
        carstore.reportCarReplicaSlashed(_cid, _matchingId, _filecoinDealId);
        assertTrue(
            CarReplicaType.State.Slashed ==
                carstore.getCarReplicaState(_cid, _matchingId),
            "Replica state should be Expired"
        );
    }

    // Test function to report replica slashed with invalid deal state
    function testReportCarReplicaSlashedWithInvalidDealState(
        bytes32 _cid,
        uint64 _matchingId,
        uint64 _filecoinDealId,
        uint8 _filecoinDealState
    ) external {
        vm.assume(_matchingId != 0 && _filecoinDealId != 0);
        setCarReplicaFilecoinDealIdAndAssert(
            _cid,
            _matchingId,
            _filecoinDealId,
            FilecoinType.DealState.Stored,
            CarReplicaType.State.Stored
        );

        vm.assume(
            _filecoinDealState == uint8(FilecoinType.DealState.Stored) ||
                _filecoinDealState ==
                uint8(FilecoinType.DealState.StorageFailed) ||
                _filecoinDealState == uint8(FilecoinType.DealState.Expired)
        );
        carstore.getFilecoin().setMockDealState(
            FilecoinType.DealState(_filecoinDealState)
        );
        vm.expectRevert(
            abi.encodeWithSelector(
                Errors.InvalidReplicaFilecoinDealState.selector,
                _cid,
                _filecoinDealId
            )
        );
        carstore.reportCarReplicaSlashed(_cid, _matchingId, _filecoinDealId);
    }

    // Test function to report replica slashed with invalid id
    function testReportCarReplicaSlashedWithInvalidId(
        bytes32 _cid,
        uint64 _matchingId,
        uint64 _filecoinDealId
    ) external {
        vm.assume(_matchingId == 0 || _filecoinDealId == 0);
        vm.expectRevert();
        carstore.reportCarReplicaSlashed(_cid, _matchingId, _filecoinDealId);
    }

    // Test function to report replica slashed with car not exist
    function testReportCarReplicaSlashedWithCarNotExist(
        bytes32 _cid,
        uint64 _matchingId,
        uint64 _filecoinDealId
    ) external {
        vm.expectRevert(
            abi.encodeWithSelector(Errors.CarNotExist.selector, _cid)
        );
        carstore.reportCarReplicaSlashed(_cid, _matchingId, _filecoinDealId);
    }

    // Test function to report replica slashed with car replica not exist
    function testReportCarReplicaSlashedWithReplicaNotExist(
        bytes32 _cid,
        uint64 _matchingId,
        uint64 _filecoinDealId
    ) external {
        vm.assume(_matchingId != 0 && _filecoinDealId != 0);
        carstore.addCar(_cid, 1, 32 * 1024 * 1024 * 1024);

        vm.expectRevert(
            abi.encodeWithSelector(
                Errors.ReplicaNotExist.selector,
                _cid,
                _matchingId
            )
        );
        carstore.reportCarReplicaSlashed(_cid, _matchingId, _filecoinDealId);
    }
}
