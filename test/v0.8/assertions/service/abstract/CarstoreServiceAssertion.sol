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
import {CarReplicaType} from "src/v0.8/types/CarReplicaType.sol";
import {FilecoinType} from "src/v0.8/types/FilecoinType.sol";

/// @title CarstoreServiceAssertion
abstract contract CarstoreServiceAssertion is ServiceAssertionBase {
    /// @notice Assertion for the `addCar` function.
    /// @param _cid The CID (Content Identifier) of the car.
    /// @param _datasetId The dataset ID associated with the car.
    /// @param _size The size of the car.
    function addCarAssertion(
        bytes32 _cid,
        uint64 _datasetId,
        uint64 _size
    ) public {
        carstoreAssertion.addCarAssertion(_cid, _datasetId, _size);
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
        carstoreAssertion.addCarsAssertion(_cids, _datasetId, _sizes);
    }

    /// @notice Assertion for the `addCarReplica` function.
    /// @param _cid The CID (Content Identifier) of the car.
    /// @param _matchingId The matching ID associated with the car replica.
    function addCarReplicaAssertion(bytes32 _cid, uint64 _matchingId) external {
        carstoreAssertion.addCarReplicaAssertion(_cid, _matchingId);
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
        carstoreAssertion.reportCarReplicaExpiredAssertion(
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
        carstoreAssertion.reportCarReplicaSlashedAssertion(
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
        carstoreAssertion.setCarReplicaFilecoinDealIdAssertion(
            _cid,
            _matchingId,
            _filecoinDealId
        );
    }

    /// @notice Assertion for getting the size of a car.
    /// @param _inputCid The CID (Content Identifier) of the car.
    /// @param _expectSize The expected size of the car.
    function getCarSizeAssertion(bytes32 _inputCid, uint64 _expectSize) public {
        carstoreAssertion.getCarSizeAssertion(_inputCid, _expectSize);
    }

    /// @notice Assertion for getting the size of cars.
    /// @param _inputCids The CIDs (Content Identifier) of the cars.
    /// @param _expectSize The expected size of the car.
    function getCarsSizeAssertion(
        bytes32[] memory _inputCids,
        uint256 _expectSize
    ) public {
        carstoreAssertion.getCarsSizeAssertion(_inputCids, _expectSize);
    }

    /// @notice Assertion for getting the dataset ID of a car.
    /// @param _inputCid The CID (Content Identifier) of the car.
    /// @param _expectDatasetId The expected dataset ID of the car.
    function getCarDatasetIdAssertion(
        bytes32 _inputCid,
        uint64 _expectDatasetId
    ) public {
        carstoreAssertion.getCarDatasetIdAssertion(_inputCid, _expectDatasetId);
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
        carstoreAssertion.getCarReplicaAssertion(
            _inputCid,
            _inputmatchingId,
            _expectState,
            _expectFilecoinDealId
        );
    }

    /// @notice Assertion for getting the count of car replicas for a car.
    /// @param _inputCid The CID (Content Identifier) of the car.
    /// @param _expectCount The expected count of car replicas.
    function getCarReplicasCountAssertion(
        bytes32 _inputCid,
        uint16 _expectCount
    ) public {
        carstoreAssertion.getCarReplicasCountAssertion(_inputCid, _expectCount);
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
        carstoreAssertion.getCarReplicaFilecoinDealIdAssertion(
            _inputCid,
            _inputMatchingId,
            _expectFilecoinDealId
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
        carstoreAssertion.getCarReplicaStateAssertion(
            _inputCid,
            _inputMatchingId,
            _expectState
        );
    }

    /// @notice Assertion for checking if a car exists.
    /// @param _inputCid The CID (Content Identifier) of the car.
    /// @param _expectIfExist A boolean indicating whether the car is expected to exist or not.
    function hasCarAssertion(bytes32 _inputCid, bool _expectIfExist) public {
        carstoreAssertion.hasCarAssertion(_inputCid, _expectIfExist);
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
        carstoreAssertion.hasCarReplicaAssertion(
            _inputCid,
            _inputMatchingId,
            _expectIfExist
        );
    }

    /// @notice Assertion for checking if multiple cars exist.
    /// @param _inputCids An array of CIDs (Content Identifiers) for the cars.
    /// @param _expectIfExist A boolean indicating whether the cars are expected to exist or not.
    function hasCarsAssertion(
        bytes32[] memory _inputCids,
        bool _expectIfExist
    ) public {
        carstoreAssertion.hasCarsAssertion(_inputCids, _expectIfExist);
    }

    /// @notice Assertion for getting the count of cars.
    /// @param _expectCount The expected count of cars.
    function carsCountAssertion(uint64 _expectCount) public {
        carstoreAssertion.carsCountAssertion(_expectCount);
    }
}
