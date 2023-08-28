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

    /// @notice Assertion for the `addCar` function.
    /// @param _cid The CID (Content Identifier) of the car.
    /// @param _datasetId The dataset ID associated with the car.
    /// @param _size The size of the car.
    function addCarAssertion(
        bytes32 _cid,
        uint64 _datasetId,
        uint64 _size
    ) public {
        // Before adding, check car count and car existence.
        uint64 beforeCount = carstore.carsCount();
        hasCarAssertion(_cid, false);

        // Perform the action: add the car.
        carstore.addCar(_cid, _datasetId, _size);

        // After adding, check car attributes and existence.
        getCarDatasetIdAssertion(_cid, _datasetId);
        getCarSizeAssertion(_cid, _size);
        hasCarAssertion(_cid, true);
        carsCountAssertion(beforeCount + 1);
    }

    /// @notice Assertion for the `addCars` function.
    /// @param _cids An array of CIDs (Content Identifiers) for the cars.
    /// @param _datasetId The dataset ID associated with all the cars.
    /// @param _sizes An array of sizes corresponding to the cars.
    function addCarsAssertion(
        bytes32[] memory _cids,
        uint64 _datasetId,
        uint64[] memory _sizes
    ) external {
        // Before adding, check car existence.
        hasCarsAssertion(_cids, false);

        // Perform the action: add multiple cars.
        carstore.addCars(_cids, _datasetId, _sizes);

        // After adding, check car existence.
        hasCarsAssertion(_cids, true);
    }

    /// @notice Assertion for the `addCarReplica` function.
    /// @param _cid The CID (Content Identifier) of the car.
    /// @param _matchingId The matching ID associated with the car replica.
    function addCarReplicaAssertion(bytes32 _cid, uint64 _matchingId) external {
        // Before adding, check replica count, replica existence, and replica state.
        uint16 beforeReplicasCount = carstore.getCarReplicasCount(_cid);
        hasCarReplicaAssertion(_cid, _matchingId, false);
        getCarReplicaStateAssertion(
            _cid,
            _matchingId,
            CarReplicaType.State.None
        );

        // Perform the action: add a car replica.
        carstore.addCarReplica(_cid, _matchingId);

        // After adding, check replica count, replica state, and replica existence.
        getCarReplicasCountAssertion(_cid, beforeReplicasCount + 1);
        getCarReplicaStateAssertion(
            _cid,
            _matchingId,
            CarReplicaType.State.Matched
        );
        getCarReplicaAssertion(
            _cid,
            _matchingId,
            CarReplicaType.State.Matched,
            0
        );
        getCarReplicaFilecoinDealIdAssertion(_cid, _matchingId, 0);
        hasCarReplicaAssertion(_cid, _matchingId, true);
    }

    /// @notice Assertion for the `reportCarReplicaExpired` function.
    /// @param _cid The CID (Content Identifier) of the car.
    /// @param _matchingId The matching ID associated with the car replica.
    /// @param _filecoinDealId The Filecoin deal ID associated with the car replica.
    function reportCarReplicaExpiredAssertion(
        bytes32 _cid,
        uint64 _matchingId,
        uint64 _filecoinDealId
    ) external {
        // Before reporting, check replica count, replica state, and filecoin deal state.
        uint16 beforeReplicasCount = carstore.getCarReplicasCount(_cid);
        getCarReplicaAssertion(
            _cid,
            _matchingId,
            CarReplicaType.State.Stored,
            _filecoinDealId
        );
        getCarReplicaStateAssertion(
            _cid,
            _matchingId,
            CarReplicaType.State.Stored
        );

        // Perform the action: report an expired car replica.
        carstore.reportCarReplicaExpired(_cid, _matchingId, _filecoinDealId);

        // After reporting, check replica count, replica state, and filecoin deal state.
        getCarReplicasCountAssertion(_cid, beforeReplicasCount);
        hasCarReplicaAssertion(_cid, _matchingId, true);
        getCarReplicaAssertion(
            _cid,
            _matchingId,
            CarReplicaType.State.Expired,
            _filecoinDealId
        );
        getCarReplicaStateAssertion(
            _cid,
            _matchingId,
            CarReplicaType.State.Expired
        );
        getCarReplicaFilecoinDealIdAssertion(
            _cid,
            _matchingId,
            _filecoinDealId
        );
    }

    /// @notice Assertion for the `reportCarReplicaSlashed` function.
    /// @param _cid The CID (Content Identifier) of the car.
    /// @param _matchingId The matching ID associated with the car replica.
    /// @param _filecoinDealId The Filecoin deal ID associated with the car replica.
    function reportCarReplicaSlashedAssertion(
        bytes32 _cid,
        uint64 _matchingId,
        uint64 _filecoinDealId
    ) external {
        // Before reporting, check replica count, replica state, and filecoin deal state.
        uint16 beforeReplicasCount = carstore.getCarReplicasCount(_cid);
        getCarReplicaAssertion(
            _cid,
            _matchingId,
            CarReplicaType.State.Stored,
            _filecoinDealId
        );
        getCarReplicaStateAssertion(
            _cid,
            _matchingId,
            CarReplicaType.State.Stored
        );

        // Perform the action: report a slashed car replica.
        carstore.reportCarReplicaSlashed(_cid, _matchingId, _filecoinDealId);

        // After reporting, check replica count, replica state, and filecoin deal state.
        getCarReplicasCountAssertion(_cid, beforeReplicasCount);
        hasCarReplicaAssertion(_cid, _matchingId, true);
        getCarReplicaAssertion(
            _cid,
            _matchingId,
            CarReplicaType.State.Slashed,
            _filecoinDealId
        );
        getCarReplicaStateAssertion(
            _cid,
            _matchingId,
            CarReplicaType.State.Slashed
        );
        getCarReplicaFilecoinDealIdAssertion(
            _cid,
            _matchingId,
            _filecoinDealId
        );
    }

    /// @notice Assertion for the `setCarReplicaFilecoinDealId` function.
    /// @param _cid The CID (Content Identifier) of the car.
    /// @param _matchingId The matching ID associated with the car replica.
    /// @param _filecoinDealId The new Filecoin deal ID to set for the car replica.
    function setCarReplicaFilecoinDealIdAssertion(
        bytes32 _cid,
        uint64 _matchingId,
        uint64 _filecoinDealId
    ) external {
        // Before setting, check replica count and the existing filecoin deal ID.
        uint16 beforeReplicasCount = carstore.getCarReplicasCount(_cid);
        getCarReplicaFilecoinDealIdAssertion(_cid, _matchingId, 0);

        // Perform the action: set the filecoin deal ID of a car replica.
        carstore.setCarReplicaFilecoinDealId(
            _cid,
            _matchingId,
            _filecoinDealId
        );

        // After setting, check replica count, the new filecoin deal ID, and replica state.
        getCarReplicasCountAssertion(_cid, beforeReplicasCount);
        getCarReplicaFilecoinDealIdAssertion(
            _cid,
            _matchingId,
            _filecoinDealId
        );
        hasCarReplicaAssertion(_cid, _matchingId, true);

        if (
            FilecoinType.DealState.Stored ==
            carstore.filecoin().getReplicaDealState(_cid, _filecoinDealId)
        ) {
            getCarReplicaStateAssertion(
                _cid,
                _matchingId,
                CarReplicaType.State.Stored
            );
        } else if (
            FilecoinType.DealState.StorageFailed ==
            carstore.filecoin().getReplicaDealState(_cid, _filecoinDealId)
        ) {
            getCarReplicaStateAssertion(
                _cid,
                _matchingId,
                CarReplicaType.State.StorageFailed
            );
        } else {
            fail();
        }
    }

    /// @notice Assertion for getting the size of a car.
    /// @param _inputCid The CID (Content Identifier) of the car.
    /// @param _expectSize The expected size of the car.
    function getCarSizeAssertion(bytes32 _inputCid, uint64 _expectSize) public {
        assertEq(
            carstore.getCarSize(_inputCid),
            _expectSize,
            "car size not matched"
        );
    }

    /// @notice Assertion for getting the dataset ID of a car.
    /// @param _inputCid The CID (Content Identifier) of the car.
    /// @param _expectDatasetId The expected dataset ID of the car.
    function getCarDatasetIdAssertion(
        bytes32 _inputCid,
        uint64 _expectDatasetId
    ) public {
        assertEq(
            carstore.getCarDatasetId(_inputCid),
            _expectDatasetId,
            "car dataset id not matched"
        );
    }

    /// @notice Assertion for getting information about a car replica.
    /// @param _inputCid The CID (Content Identifier) of the car.
    /// @param _inputmatchingId The matching ID associated with the car replica.
    /// @param _expectState The expected state of the car replica.
    /// @param _expectFilecoinDealId The expected Filecoin deal ID of the car replica.
    function getCarReplicaAssertion(
        bytes32 _inputCid,
        uint64 _inputmatchingId,
        CarReplicaType.State _expectState,
        uint64 _expectFilecoinDealId
    ) public {
        (CarReplicaType.State state, uint64 filecoinDealId) = carstore
            .getCarReplica(_inputCid, _inputmatchingId);
        assertEq(
            uint8(state),
            uint8(_expectState),
            "car replica state not matched"
        );
        assertEq(
            filecoinDealId,
            _expectFilecoinDealId,
            "car replica filecoin deal id not matched"
        );
    }

    /// @notice Assertion for getting the count of car replicas for a car.
    /// @param _inputCid The CID (Content Identifier) of the car.
    /// @param _expectCount The expected count of car replicas.
    function getCarReplicasCountAssertion(
        bytes32 _inputCid,
        uint16 _expectCount
    ) public {
        assertEq(
            carstore.getCarReplicasCount(_inputCid),
            _expectCount,
            "car replicas count not matched"
        );
    }

    /// @notice Assertion for getting the Filecoin deal ID of a car replica.
    /// @param _inputCid The CID (Content Identifier) of the car.
    /// @param _inputMatchingId The matching ID associated with the car replica.
    /// @param _expectFilecoinDealId The expected Filecoin deal ID of the car replica.
    function getCarReplicaFilecoinDealIdAssertion(
        bytes32 _inputCid,
        uint64 _inputMatchingId,
        uint64 _expectFilecoinDealId
    ) public {
        assertEq(
            carstore.getCarReplicaFilecoinDealId(_inputCid, _inputMatchingId),
            _expectFilecoinDealId,
            "car replica filecoin deal id not matched"
        );
    }

    /// @notice Assertion for getting the state of a car replica.
    /// @param _inputCid The CID (Content Identifier) of the car.
    /// @param _inputMatchingId The matching ID associated with the car replica.
    /// @param _expectState The expected state of the car replica.
    function getCarReplicaStateAssertion(
        bytes32 _inputCid,
        uint64 _inputMatchingId,
        CarReplicaType.State _expectState
    ) public {
        assertEq(
            uint8(carstore.getCarReplicaState(_inputCid, _inputMatchingId)),
            uint8(_expectState),
            "car replica state not matched"
        );
    }

    /// @notice Assertion for checking if a car exists.
    /// @param _inputCid The CID (Content Identifier) of the car.
    /// @param _expectIfExist A boolean indicating whether the car is expected to exist or not.
    function hasCarAssertion(bytes32 _inputCid, bool _expectIfExist) public {
        assertEq(
            carstore.hasCar(_inputCid),
            _expectIfExist,
            "has car not matched"
        );
    }

    /// @notice Assertion for checking if a car replica exists.
    /// @param _inputCid The CID (Content Identifier) of the car.
    /// @param _inputMatchingId The matching ID associated with the car replica.
    /// @param _expectIfExist A boolean indicating whether the car replica is expected to exist or not.
    function hasCarReplicaAssertion(
        bytes32 _inputCid,
        uint64 _inputMatchingId,
        bool _expectIfExist
    ) public {
        assertEq(
            carstore.hasCarReplica(_inputCid, _inputMatchingId),
            _expectIfExist,
            "has car replica not matched"
        );
    }

    /// @notice Assertion for checking if multiple cars exist.
    /// @param _inputCids An array of CIDs (Content Identifiers) for the cars.
    /// @param _expectIfExist A boolean indicating whether the cars are expected to exist or not.
    function hasCarsAssertion(
        bytes32[] memory _inputCids,
        bool _expectIfExist
    ) public {
        assertEq(
            carstore.hasCars(_inputCids),
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
