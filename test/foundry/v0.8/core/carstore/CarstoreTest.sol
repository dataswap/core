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

contract CarstoreTest is Test {
    Carstore carstore;
    address payable governanceContractAddresss;

    function setUp() public {
        Roles role = new Roles();
        Filplus filplus = new Filplus(governanceContractAddresss);
        MockFilecoin filecoin = new MockFilecoin();
        carstore = new Carstore(role, filplus, filecoin);
    }

    function testAddCar(bytes32 _cid, uint64 _datasetId, uint64 _size) public {
        vm.assume(_datasetId != 0);
        vm.assume(_size != 0);
        carstore.addCar(_cid, _datasetId, _size);

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
        assertEq(carstore.carsCount(), 1, "Replica count should be 0");
    }

    function testAddCarWhenCarIdInvalid(
        bytes32 _cid,
        uint64 _datasetId,
        uint64 _size
    ) public {
        vm.assume(_datasetId == 0 || _size == 0);
        vm.expectRevert(bytes("Invalid ID"));
        carstore.addCar(_cid, _datasetId, _size);
    }

    function testAddCarWhenCarAlreadyExists(
        bytes32 _cid,
        uint64 _datasetId,
        uint64 _size
    ) public {
        vm.assume(_datasetId != 0);
        vm.assume(_size != 0);
        carstore.addCar(_cid, _datasetId, _size);
        vm.expectRevert(
            abi.encodeWithSelector(Errors.CarAlreadyExists.selector, _cid)
        );
        carstore.addCar(_cid, _datasetId, _size);
    }

    function convertUint64ToBytes32(
        uint64 value
    ) public pure returns (bytes32) {
        bytes32 convertedValue;
        assembly {
            convertedValue := value
        }
        return convertedValue;
    }

    function testAddCars(uint64 _datasetId) public {
        uint64 carsCount = 100;
        bytes32[] memory cids = new bytes32[](carsCount);
        uint64[] memory sizes = new uint64[](carsCount);
        vm.assume(_datasetId != 0);
        for (uint64 i = 0; i < carsCount; i++) {
            sizes[i] = i + 1;
            cids[i] = convertUint64ToBytes32(i);
        }

        vm.expectEmit(true, false, false, true);
        emit CarstoreEvents.CarsAdded(cids);

        carstore.addCars(cids, _datasetId, sizes);

        for (uint64 i = 0; i < carsCount; i++) {
            assertTrue(carstore.hasCar(cids[i]), "Car should exist");
            assertEq(
                carstore.getCarDatasetId(cids[i]),
                _datasetId,
                "Dataset ID should match for Car"
            );
            assertEq(
                carstore.getCarSize(cids[i]),
                sizes[i],
                "Car size should match for Car"
            );
            assertEq(
                carstore.getCarReplicasCount(cids[i]),
                0,
                "Replica count should be 0"
            );
        }

        assertTrue(carstore.hasCars(cids), "Cars should exist");
    }

    function testAddCarsWhenIdInvalid(
        bytes32[] memory _cids,
        uint64 _datasetId,
        uint64[] memory _sizes
    ) public {
        vm.assume(_datasetId == 0);
        vm.expectRevert(bytes("Invalid ID"));
        carstore.addCars(_cids, _datasetId, _sizes);
    }

    function testAddCarReplica(bytes32 _cid, uint64 _matchingId) public {
        vm.assume(_matchingId != 0);
        carstore.addCar(_cid, 1, 32 * 1024 * 1024 * 1024);

        vm.expectEmit(true, true, false, true);
        emit CarstoreEvents.CarReplicaAdded(_cid, _matchingId);

        carstore.addCarReplica(_cid, _matchingId);

        assertTrue(
            carstore.hasCarReplica(_cid, _matchingId),
            "Car replica should exist"
        );
        assertEq(
            uint8(carstore.getCarReplicaState(_cid, _matchingId)),
            uint8(CarReplicaType.State.Matched),
            "Replica state should be Matched"
        );
        assertEq(
            carstore.getCarReplicasCount(_cid),
            1,
            "Replica count should be 1"
        );

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

    function testAddCarReplicaWhenInvalidId(
        bytes32 _cid,
        uint64 _matchingId
    ) public {
        vm.assume(_matchingId == 0);
        carstore.addCar(_cid, 1, 32 * 1024 * 1024 * 1024);
        vm.expectRevert(bytes("Invalid ID"));
        carstore.addCarReplica(_cid, _matchingId);
    }

    function testAddCarReplicaWhenCarNotExist(
        bytes32 _cid,
        uint64 _matchingId
    ) public {
        vm.assume(_matchingId != 0);

        vm.expectRevert(
            abi.encodeWithSelector(Errors.CarNotExist.selector, _cid)
        );
        carstore.addCarReplica(_cid, _matchingId);
    }

    function testAddCarReplicaWhenReplicaAlreadyExists(
        bytes32 _cid,
        uint64 _matchingId
    ) public {
        vm.assume(_matchingId != 0);
        carstore.addCar(_cid, 1, 32 * 1024 * 1024 * 1024);
        carstore.addCarReplica(_cid, _matchingId);

        vm.expectRevert(
            abi.encodeWithSelector(
                Errors.ReplicaAlreadyExists.selector,
                _cid,
                _matchingId
            )
        );
        carstore.addCarReplica(_cid, _matchingId);
    }

    function testSetCarReplicaFilecoinDealIdWhenStored(
        bytes32 _cid,
        uint64 _matchingId,
        uint64 _filecoinDealId
    ) public {
        vm.assume(_matchingId != 0 && _filecoinDealId != 0);
        carstore.addCar(_cid, 1, 32 * 1024 * 1024 * 1024);
        carstore.addCarReplica(_cid, _matchingId);

        carstore.getFilecoin().setMockDealState(FilecoinType.DealState.Stored);

        vm.expectEmit(true, true, true, true);
        emit CarstoreEvents.CarReplicaFilecoinDealIdSet(
            _cid,
            _matchingId,
            _filecoinDealId
        );
        carstore.setCarReplicaFilecoinDealId(
            _cid,
            _matchingId,
            _filecoinDealId
        );
        assertTrue(
            CarReplicaType.State.Stored ==
                carstore.getCarReplicaState(_cid, _matchingId),
            "Replica state should be Stored "
        );
        assertEq(
            carstore.getCarReplicaFilecoinDealId(_cid, _matchingId),
            _filecoinDealId,
            "Filecoin deal ID should match"
        );
    }

    function testSetCarReplicaFilecoinDealIdWhenStorageFailed(
        bytes32 _cid,
        uint64 _matchingId,
        uint64 _filecoinDealId
    ) public {
        vm.assume(_matchingId != 0 && _filecoinDealId != 0);
        carstore.addCar(_cid, 1, 32 * 1024 * 1024 * 1024);
        carstore.addCarReplica(_cid, _matchingId);

        carstore.getFilecoin().setMockDealState(
            FilecoinType.DealState.StorageFailed
        );

        vm.expectEmit(true, true, true, true);
        emit CarstoreEvents.CarReplicaFilecoinDealIdSet(
            _cid,
            _matchingId,
            _filecoinDealId
        );
        carstore.setCarReplicaFilecoinDealId(
            _cid,
            _matchingId,
            _filecoinDealId
        );
        assertTrue(
            CarReplicaType.State.StorageFailed ==
                carstore.getCarReplicaState(_cid, _matchingId),
            "Replica state should be StorageFailed"
        );
        assertEq(
            carstore.getCarReplicaFilecoinDealId(_cid, _matchingId),
            _filecoinDealId,
            "Filecoin deal ID should match"
        );
    }

    function testSetCarReplicaFilecoinDealIdWhenInvalidId(
        bytes32 _cid,
        uint64 _matchingId,
        uint64 _filecoinDealId
    ) public {
        vm.assume(_matchingId != 0 && _filecoinDealId == 0);
        carstore.addCar(_cid, 1, 32 * 1024 * 1024 * 1024);
        carstore.addCarReplica(_cid, _matchingId);

        vm.expectRevert(bytes("Invalid ID"));
        carstore.setCarReplicaFilecoinDealId(
            _cid,
            _matchingId,
            _filecoinDealId
        );
    }

    function testSetCarReplicaFilecoinDealIdWhenReplicaNotExist(
        bytes32 _cid,
        uint64 _matchingId,
        uint64 _filecoinDealId
    ) public {
        vm.assume(_matchingId != 0 && _filecoinDealId != 0);
        carstore.addCar(_cid, 1, 32 * 1024 * 1024 * 1024);

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

    function testSetCarReplicaFilecoinDealIdWhenReplicaFilecoinDealIdExists(
        bytes32 _cid,
        uint64 _matchingId,
        uint64 _filecoinDealId
    ) public {
        vm.assume(_matchingId != 0 && _filecoinDealId != 0);
        carstore.addCar(_cid, 1, 32 * 1024 * 1024 * 1024);
        carstore.addCarReplica(_cid, _matchingId);
        carstore.setCarReplicaFilecoinDealId(
            _cid,
            _matchingId,
            _filecoinDealId
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

    function testReportCarReplicaExpired(
        bytes32 _cid,
        uint64 _matchingId,
        uint64 _filecoinDealId
    ) public {
        testSetCarReplicaFilecoinDealIdWhenStored(
            _cid,
            _matchingId,
            _filecoinDealId
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

    function testReportCarReplicaExpiredWhenStored(
        bytes32 _cid,
        uint64 _matchingId,
        uint64 _filecoinDealId
    ) public {
        testSetCarReplicaFilecoinDealIdWhenStored(
            _cid,
            _matchingId,
            _filecoinDealId
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

    function testReportCarReplicaExpiredWhenStorageFailed(
        bytes32 _cid,
        uint64 _matchingId,
        uint64 _filecoinDealId
    ) public {
        testSetCarReplicaFilecoinDealIdWhenStored(
            _cid,
            _matchingId,
            _filecoinDealId
        );

        carstore.getFilecoin().setMockDealState(
            FilecoinType.DealState.StorageFailed
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

    function testReportCarReplicaExpiredWhenInvalidId(
        bytes32 _cid,
        uint64 _matchingId,
        uint64 _filecoinDealId
    ) public {
        vm.assume(_matchingId == 0 || _filecoinDealId == 0);
        carstore.addCar(_cid, 1, 32 * 1024 * 1024 * 1024);

        vm.expectRevert();
        carstore.reportCarReplicaExpired(_cid, _matchingId, _filecoinDealId);
    }

    function testReportCarReplicaExpiredWhenCarNotExist(
        bytes32 _cid,
        uint64 _matchingId,
        uint64 _filecoinDealId
    ) public {
        vm.expectRevert(
            abi.encodeWithSelector(Errors.CarNotExist.selector, _cid)
        );
        carstore.reportCarReplicaExpired(_cid, _matchingId, _filecoinDealId);
    }

    function testReportCarReplicaExpiredWhenReplicaNotExist(
        bytes32 _cid,
        uint64 _matchingId,
        uint64 _filecoinDealId
    ) public {
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

    function testReportCarReplicaSlashed(
        bytes32 _cid,
        uint64 _matchingId,
        uint64 _filecoinDealId
    ) public {
        testSetCarReplicaFilecoinDealIdWhenStored(
            _cid,
            _matchingId,
            _filecoinDealId
        );
        carstore.getFilecoin().setMockDealState(FilecoinType.DealState.Slashed);
        vm.expectEmit(true, true, false, true);
        emit CarstoreEvents.CarReplicaSlashed(_cid, _matchingId);
        carstore.reportCarReplicaSlashed(_cid, _matchingId, _filecoinDealId);
        assertTrue(
            CarReplicaType.State.Slashed ==
                carstore.getCarReplicaState(_cid, _matchingId),
            "Replica state should be Slashed"
        );
    }

    function testReportCarReplicaSlashedWhenStored(
        bytes32 _cid,
        uint64 _matchingId,
        uint64 _filecoinDealId
    ) public {
        testSetCarReplicaFilecoinDealIdWhenStored(
            _cid,
            _matchingId,
            _filecoinDealId
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

    function testReportCarReplicaSlashedWhenStorageFailed(
        bytes32 _cid,
        uint64 _matchingId,
        uint64 _filecoinDealId
    ) public {
        testSetCarReplicaFilecoinDealIdWhenStored(
            _cid,
            _matchingId,
            _filecoinDealId
        );

        carstore.getFilecoin().setMockDealState(
            FilecoinType.DealState.StorageFailed
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

    function testReportCarReplicaSlashedWhenInvalidId(
        bytes32 _cid,
        uint64 _matchingId,
        uint64 _filecoinDealId
    ) public {
        vm.assume(_matchingId == 0 || _filecoinDealId == 0);
        carstore.addCar(_cid, 1, 32 * 1024 * 1024 * 1024);

        vm.expectRevert();
        carstore.reportCarReplicaSlashed(_cid, _matchingId, _filecoinDealId);
    }

    function testReportCarReplicaSlashedWhenCarNotExist(
        bytes32 _cid,
        uint64 _matchingId,
        uint64 _filecoinDealId
    ) public {
        vm.expectRevert(
            abi.encodeWithSelector(Errors.CarNotExist.selector, _cid)
        );
        carstore.reportCarReplicaSlashed(_cid, _matchingId, _filecoinDealId);
    }

    function testReportCarReplicaSlashedWhenReplicaNotExist(
        bytes32 _cid,
        uint64 _matchingId,
        uint64 _filecoinDealId
    ) public {
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
