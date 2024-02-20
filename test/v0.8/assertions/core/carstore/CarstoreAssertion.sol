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
import {CarReplicaType} from "src/v0.8/types/CarReplicaType.sol";
import {FilecoinType} from "src/v0.8/types/FilecoinType.sol";
import {ICarstore} from "src/v0.8/interfaces/core/ICarstore.sol";
import {ICarstoreAssertion} from "test/v0.8/interfaces/assertions/core/ICarstoreAssertion.sol";

/// @title CarstoreAssertion
/// @notice This contract provides assertion methods for Carstore actions.
/// @dev All methods that do not change the state must be tested by methods that will change the state to ensure test coverage.

contract CarstoreAssertion is DSTest, Test, ICarstoreAssertion {
    ICarstore public carstore;

    constructor(ICarstore _carstore) {
        carstore = _carstore;
    }

    /// @notice Assertion for the `__addCar` function.
    /// @param _caller The address of the caller.
    /// @param _cid The CID (Content Identifier) of the car.
    /// @param _datasetId The dataset ID associated with the car.
    /// @param _size The size of the car.
    /// @param _replicaCount count of car's replicas
    function addCarAssertion(
        address _caller,
        bytes32 _cid,
        uint64 _datasetId,
        uint64 _size,
        uint16 _replicaCount
    ) public {
        // Before adding, check car count and car existence.
        uint64 beforeCount = carstore.carsCount();
        hasCarHashAssertion(_cid, false);
        vm.prank(_caller);
        // Perform the action: add the car.
        uint64 carId = carstore.__addCar(
            _cid,
            _datasetId,
            _size,
            _replicaCount
        );

        // After adding, check car attributes and existence.
        getCarDatasetIdAssertion(carId, _datasetId);
        getCarSizeAssertion(carId, _size);
        hasCarAssertion(carId, true);
        carsCountAssertion(beforeCount + 1);
        getCarReplicasCountAssertion(carId, _replicaCount);
        getCarHashAssertion(carId, _cid);
        getCarIdAssertion(_cid, carId);
    }

    /// @notice Assertion for the `__addCars` function.
    /// @param _caller The address of the caller.
    /// @param _cids An array of CIDs (Content Identifiers) for the cars.
    /// @param _datasetId The dataset ID associated with all the cars.
    /// @param _sizes An array of sizes corresponding to the cars.
    /// @param _replicaCount count of car's replicas
    function addCarsAssertion(
        address _caller,
        bytes32[] memory _cids,
        uint64 _datasetId,
        uint64[] memory _sizes,
        uint16 _replicaCount
    ) external {
        // Before adding, check car existence.
        hasCarsHashsAssertion(_cids, false);
        vm.prank(_caller);
        // Perform the action: add multiple cars.
        (uint64[] memory carIds, uint64 size) = carstore.__addCars(
            _cids,
            _datasetId,
            _sizes,
            _replicaCount
        );

        // After adding, check car existence.
        hasCarsAssertion(carIds, true);
        getCarsSizeAssertion(carIds, size);
        getCarReplicasCountAssertion(carIds[0], _replicaCount);
        getCarsHashsAssertion(carIds, _cids);
        getCarsIdsAssertion(_cids, carIds);
    }

    /// @notice Assertion for the `__registCarReplica` function.
    /// @param _caller The address of the caller.
    /// @param _id The ID (Content Identifier) of the car.
    /// @param _matchingId The matching ID associated with the car replica.
    /// @param _replicaIndex The index of the car's replica
    function registCarReplicaAssertion(
        address _caller,
        uint64 _id,
        uint64 _matchingId,
        uint16 _replicaIndex
    ) external {
        // Before adding, check replica count, replica existence, and replica state.
        uint16 beforeReplicasCount = carstore.getCarReplicasCount(_id);
        hasCarReplicaAssertion(_id, _matchingId, false);

        vm.prank(_caller);
        // Perform the action: regist a car replica.
        carstore.__registCarReplica(_id, _matchingId, _replicaIndex);

        // After adding, check replica count, replica state, and replica existence.
        getCarReplicasCountAssertion(_id, beforeReplicasCount);
        getCarReplicaStateAssertion(
            _id,
            _matchingId,
            CarReplicaType.State.None
        );
        getCarReplicaAssertion(_id, _matchingId, CarReplicaType.State.None, 0);
        getCarReplicaFilecoinClaimIdAssertion(_id, _matchingId, 0);
        hasCarReplicaAssertion(_id, _matchingId, true);
    }

    /// @notice Assertion for the `__reportCarReplicaMatchingState` function.
    /// @param _caller The address of the caller.
    /// @param _id The ID (Content Identifier) of the car.
    /// @param _matchingId The matching ID associated with the car replica.
    /// @param _matchingState Matching's state of the replica, true for success ,false for failed.
    function reportCarReplicaMatchingStateAssertion(
        address _caller,
        uint64 _id,
        uint64 _matchingId,
        bool _matchingState
    ) external {
        hasCarReplicaAssertion(_id, _matchingId, true);
        getCarReplicaStateAssertion(
            _id,
            _matchingId,
            CarReplicaType.State.None
        );

        vm.prank(_caller);
        // Perform the action: report an matching failed car replica.
        carstore.__reportCarReplicaMatchingState(
            _id,
            _matchingId,
            _matchingState
        );

        if (_matchingState) {
            getCarReplicaStateAssertion(
                _id,
                _matchingId,
                CarReplicaType.State.Matched
            );
        } else {
            getCarReplicaStateAssertion(
                _id,
                _matchingId,
                CarReplicaType.State.StorageFailed
            );
        }
    }

    /// @notice Assertion for the `__reportCarReplicaExpired` function.
    /// @param _caller The address of the caller.
    /// @param _id The ID (Content Identifier) of the car.
    /// @param _matchingId The matching ID associated with the car replica.
    /// @param _claimId The Filecoin claim ID associated with the car replica.
    function reportCarReplicaExpiredAssertion(
        address _caller,
        uint64 _id,
        uint64 _matchingId,
        uint64 _claimId
    ) external {
        // Before reporting, check replica count, replica state, and filecoin deal state.
        uint16 beforeReplicasCount = carstore.getCarReplicasCount(_id);
        getCarReplicaAssertion(
            _id,
            _matchingId,
            CarReplicaType.State.Stored,
            _claimId
        );
        getCarReplicaStateAssertion(
            _id,
            _matchingId,
            CarReplicaType.State.Stored
        );

        vm.prank(_caller);
        // Perform the action: report an expired car replica.
        carstore.__reportCarReplicaExpired(_id, _matchingId, _claimId);

        // After reporting, check replica count, replica state, and filecoin deal state.
        getCarReplicasCountAssertion(_id, beforeReplicasCount);
        hasCarReplicaAssertion(_id, _matchingId, true);
        getCarReplicaAssertion(
            _id,
            _matchingId,
            CarReplicaType.State.Expired,
            _claimId
        );
        getCarReplicaStateAssertion(
            _id,
            _matchingId,
            CarReplicaType.State.Expired
        );
        getCarReplicaFilecoinClaimIdAssertion(_id, _matchingId, _claimId);
    }

    /// @notice Assertion for the `__reportCarReplicaSlashed` function.
    /// @param _caller The address of the caller.
    /// @param _id The ID (Content Identifier) of the car.
    /// @param _matchingId The matching ID associated with the car replica.
    /// @param _claimId The Filecoin claim ID associated with the car replica.
    function reportCarReplicaSlashedAssertion(
        address _caller,
        uint64 _id,
        uint64 _matchingId,
        uint64 _claimId
    ) external {
        // Before reporting, check replica count, replica state, and filecoin deal state.
        uint16 beforeReplicasCount = carstore.getCarReplicasCount(_id);
        getCarReplicaAssertion(
            _id,
            _matchingId,
            CarReplicaType.State.Stored,
            _claimId
        );
        getCarReplicaStateAssertion(
            _id,
            _matchingId,
            CarReplicaType.State.Stored
        );

        vm.prank(_caller);
        // Perform the action: report a slashed car replica.
        carstore.__reportCarReplicaSlashed(_id, _matchingId, _claimId);

        // After reporting, check replica count, replica state, and filecoin deal state.
        getCarReplicasCountAssertion(_id, beforeReplicasCount);
        hasCarReplicaAssertion(_id, _matchingId, true);
        getCarReplicaAssertion(
            _id,
            _matchingId,
            CarReplicaType.State.Slashed,
            _claimId
        );
        getCarReplicaStateAssertion(
            _id,
            _matchingId,
            CarReplicaType.State.Slashed
        );
        getCarReplicaFilecoinClaimIdAssertion(_id, _matchingId, _claimId);
    }

    /// @notice Assertion for the `setCarReplicaClaimId` function.
    /// @param _caller The address of the caller.
    /// @param _id The ID (Content Identifier) of the car.
    /// @param _matchingId The matching ID associated with the car replica.
    /// @param _claimId The new Filecoin claim ID to set for the car replica.
    function setCarReplicaFilecoinClaimIdAssertion(
        address _caller,
        uint64 _id,
        uint64 _matchingId,
        uint64 _claimId
    ) external {
        // Before setting, check replica count and the existing filecoin claim ID.
        uint16 beforeReplicasCount = carstore.getCarReplicasCount(_id);
        getCarReplicaFilecoinClaimIdAssertion(_id, _matchingId, 0);

        vm.prank(_caller);
        // Perform the action: set the filecoin claim ID of a car replica.
        carstore.__setCarReplicaFilecoinClaimId(_id, _matchingId, _claimId);

        // After setting, check replica count, the new filecoin claim ID, and replica state.
        getCarReplicasCountAssertion(_id, beforeReplicasCount);
        getCarReplicaFilecoinClaimIdAssertion(_id, _matchingId, _claimId);
        hasCarReplicaAssertion(_id, _matchingId, true);

        if (
            FilecoinType.DealState.Stored ==
            carstore.roles().filecoin().getReplicaDealState(
                carstore.getCarHash(_id),
                _claimId
            )
        ) {
            getCarReplicaStateAssertion(
                _id,
                _matchingId,
                CarReplicaType.State.Stored
            );
        } else if (
            FilecoinType.DealState.StorageFailed ==
            carstore.roles().filecoin().getReplicaDealState(
                carstore.getCarHash(_id),
                _claimId
            )
        ) {
            getCarReplicaStateAssertion(
                _id,
                _matchingId,
                CarReplicaType.State.StorageFailed
            );
        } else {
            fail();
        }
    }

    /// @notice Assertion for getting the size of a car.
    /// @param _inputId The ID (Content Identifier) of the car.
    /// @param _expectSize The expected size of the car.
    function getCarSizeAssertion(uint64 _inputId, uint64 _expectSize) public {
        assertEq(
            carstore.getCarSize(_inputId),
            _expectSize,
            "car size not matched"
        );
    }

    /// @notice Assertion for getting the size of cars.
    /// @param _inputIds The IDs (Content Identifier) of the cars.
    /// @param _expectSize The expected size of the car.
    function getCarsSizeAssertion(
        uint64[] memory _inputIds,
        uint256 _expectSize
    ) public {
        assertEq(
            carstore.getCarsSize(_inputIds),
            _expectSize,
            "cars size not matched"
        );
    }

    /// @notice Assertion for getting the dataset ID of a car.
    /// @param _inputId The ID (Content Identifier) of the car.
    /// @param _expectDatasetId The expected dataset ID of the car.
    function getCarDatasetIdAssertion(
        uint64 _inputId,
        uint64 _expectDatasetId
    ) public {
        assertEq(
            carstore.getCarDatasetId(_inputId),
            _expectDatasetId,
            "car dataset id not matched"
        );
    }

    /// @notice Assertion for getting information about a car replica.
    /// @param _inputId The ID (Content Identifier) of the car.
    /// @param _inputmatchingId The matching ID associated with the car replica.
    /// @param _expectState The expected state of the car replica.
    /// @param _expectFilecoinClaimId The expected Filecoin claim ID of the car replica.
    function getCarReplicaAssertion(
        uint64 _inputId,
        uint64 _inputmatchingId,
        CarReplicaType.State _expectState,
        uint64 _expectFilecoinClaimId
    ) public {
        (CarReplicaType.State state, uint64 claimId) = carstore.getCarReplica(
            _inputId,
            _inputmatchingId
        );
        assertEq(
            uint8(state),
            uint8(_expectState),
            "car replica state not matched"
        );
        assertEq(
            claimId,
            _expectFilecoinClaimId,
            "car replica filecoin claim id not matched"
        );
    }

    /// @notice Assertion for getting the count of car replicas for a car.
    /// @param _inputId The ID (Content Identifier) of the car.
    /// @param _expectCount The expected count of car replicas.
    function getCarReplicasCountAssertion(
        uint64 _inputId,
        uint16 _expectCount
    ) public {
        assertEq(
            carstore.getCarReplicasCount(_inputId),
            _expectCount,
            "car replicas count not matched"
        );
    }

    /// @notice Assertion for getting the Filecoin claim ID of a car replica.
    /// @param _inputId The ID (Content Identifier) of the car.
    /// @param _inputMatchingId The matching ID associated with the car replica.
    /// @param _expectFilecoinClaimId The expected Filecoin claim ID of the car replica.
    function getCarReplicaFilecoinClaimIdAssertion(
        uint64 _inputId,
        uint64 _inputMatchingId,
        uint64 _expectFilecoinClaimId
    ) public {
        assertEq(
            carstore.getCarReplicaFilecoinClaimId(_inputId, _inputMatchingId),
            _expectFilecoinClaimId,
            "car replica filecoin claim id not matched"
        );
    }

    /// @notice Assertion for getting the state of a car replica.
    /// @param _inputId The ID (Content Identifier) of the car.
    /// @param _inputMatchingId The matching ID associated with the car replica.
    /// @param _expectState The expected state of the car replica.
    function getCarReplicaStateAssertion(
        uint64 _inputId,
        uint64 _inputMatchingId,
        CarReplicaType.State _expectState
    ) public {
        assertEq(
            uint8(carstore.getCarReplicaState(_inputId, _inputMatchingId)),
            uint8(_expectState),
            "car replica state not matched"
        );
    }

    /// @notice Assertion for getting the hash of car based on the car id.
    /// @param _id Car ID which to get car hash.
    /// @param _expectHash The expected hash of the car.
    function getCarHashAssertion(uint64 _id, bytes32 _expectHash) public {
        assertEq(carstore.getCarHash(_id), _expectHash);
    }

    /// @notice Assertion for getting the hash of car based on the car ids.
    /// @param _ids Car IDs which to get car hashs.
    /// @param _expectHashs The expected hashs of the cars.
    function getCarsHashsAssertion(
        uint64[] memory _ids,
        bytes32[] memory _expectHashs
    ) public {
        bytes32[] memory hashs = carstore.getCarsHashs(_ids);
        for (uint64 i = 0; i < hashs.length; i++) {
            assertEq(hashs[i], _expectHashs[i]);
        }
    }

    ///// @notice Assertion for getting the car's id based on the car's hash.
    ///// @param _hash The hash which to get car id.
    ///// @param _expectId The expected which to get car hash.
    function getCarIdAssertion(bytes32 _hash, uint64 _expectId) public {
        assertEq(carstore.getCarId(_hash), _expectId);
    }

    ///// @notice Assertion for getting the ids of cars based on an array of car hashs.
    ///// @param _hashs An array of car hashs for which to cat car hashs.
    ///// @param _expectIds The expected which to get car hash.
    function getCarsIdsAssertion(
        bytes32[] memory _hashs,
        uint64[] memory _expectIds
    ) public {
        uint64[] memory ids = carstore.getCarsIds(_hashs);
        for (uint64 i = 0; i < ids.length; i++) {
            assertEq(ids[i], _expectIds[i]);
        }
    }

    /// @notice Assertion for checking if a car exists.
    /// @param _inputId The ID (Content Identifier) of the car.
    /// @param _expectIfExist A boolean indicating whether the car is expected to exist or not.
    function hasCarAssertion(uint64 _inputId, bool _expectIfExist) public {
        assertEq(
            carstore.hasCar(_inputId),
            _expectIfExist,
            "has car not matched"
        );
    }

    /// @notice Assertion for checking if a car exists.
    /// @param _inputHash The Hash (Content Identifier) of the car.
    /// @param _expectIfExist A boolean indicating whether the car is expected to exist or not.
    function hasCarHashAssertion(
        bytes32 _inputHash,
        bool _expectIfExist
    ) public {
        assertEq(
            carstore.hasCarHash(_inputHash),
            _expectIfExist,
            "has car not matched"
        );
    }

    /// @notice Assertion for checking if a car replica exists.
    /// @param _inputId The ID (Content Identifier) of the car.
    /// @param _inputMatchingId The matching ID associated with the car replica.
    /// @param _expectIfExist A boolean indicating whether the car replica is expected to exist or not.
    function hasCarReplicaAssertion(
        uint64 _inputId,
        uint64 _inputMatchingId,
        bool _expectIfExist
    ) public {
        assertEq(
            carstore.hasCarReplica(_inputId, _inputMatchingId),
            _expectIfExist,
            "has car replica not matched"
        );
    }

    /// @notice Assertion for checking if multiple cars exist.
    /// @param _inputIds An array of IDs (Content Identifiers) for the cars.
    /// @param _expectIfExist A boolean indicating whether the cars are expected to exist or not.
    function hasCarsAssertion(
        uint64[] memory _inputIds,
        bool _expectIfExist
    ) public {
        assertEq(
            carstore.hasCars(_inputIds),
            _expectIfExist,
            "has cars not matched"
        );
    }

    /// @notice Assertion for checking if multiple cars exist.
    /// @param _inputCids An array of Hashs (Content Identifiers) for the cars.
    /// @param _expectIfExist A boolean indicating whether the cars are expected to exist or not.
    function hasCarsHashsAssertion(
        bytes32[] memory _inputCids,
        bool _expectIfExist
    ) public {
        assertEq(
            carstore.hasCarsHashs(_inputCids),
            _expectIfExist,
            "has cars not matched"
        );
    }

    /// @notice Assertion for getting the count of cars.
    /// @param _expectCount The expected count of cars.
    function carsCountAssertion(uint64 _expectCount) public {
        assertEq(carstore.carsCount(), _expectCount, "cars count not matched");
    }
}
