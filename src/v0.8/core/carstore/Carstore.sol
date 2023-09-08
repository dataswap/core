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

///shared
import {CarstoreEvents} from "src/v0.8/shared/events/CarstoreEvents.sol";
///library
import {CarLIB} from "src/v0.8/core/carstore/library/CarLIB.sol";
///abstract
import {CarstoreBase} from "src/v0.8/core/carstore/abstract/CarstoreBase.sol";
///type
import {RolesType} from "src/v0.8/types/RolesType.sol";
import {FilecoinType} from "src/v0.8/types/FilecoinType.sol";
import {CarReplicaType} from "src/v0.8/types/CarReplicaType.sol";

import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {UUPSUpgradeable} from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

/// @title CarsStorageBase
/// @notice This contract allows adding cars and managing their associated replicas.
/// @dev This contract provides functionality for managing car data and associated replicas.
contract Carstore is Initializable, UUPSUpgradeable, CarstoreBase {
    using CarLIB for CarReplicaType.Car;

    /// @notice initialize function to initialize the contract and grant the default admin role to the deployer.
    function initialize(
        address _roles,
        address _filplus,
        address _filecoin
    ) public initializer {
        CarstoreBase.carstoreBaseInitialize(_roles, _filplus, _filecoin);
        __UUPSUpgradeable_init();
    }

    /// @notice UUPS Upgradeable function to update the roles implementation
    /// @dev Only triggered by contract admin
    function _authorizeUpgrade(
        address newImplementation
    )
        internal
        override
        onlyRole(RolesType.DEFAULT_ADMIN_ROLE) // solhint-disable-next-line
    {}

    /// @notice Returns the implementation contract
    function getImplementation() external view returns (address) {
        return _getImplementation();
    }

    /// @dev Internal function to add a car based on its CID.
    ///      tips: diffent dataset has the same car is dones't matter,maybe need limit replicas count for a car.
    ///      filplus requires dataset replicas,but not limit for car replicas
    /// @param _cid Car CID to be added.
    /// @param _datasetId dataset index of approved dataset
    /// @param _size size of car
    /// @param _replicaCount count of car's replicas
    function addCar(
        bytes32 _cid,
        uint64 _datasetId,
        uint64 _size,
        uint16 _replicaCount
    ) public onlyCarNotExist(_cid) onlyNotZero(_datasetId) onlyNotZero(_size) {
        carsCount++;
        CarReplicaType.Car storage car = cars[_cid];
        car._setDatasetId(_datasetId);
        car._initRepicas(_replicaCount);
        car.size = _size;
    }

    /// @notice Add multiple cars to the storage.
    /// @dev This function allows the addition of multiple cars at once.
    /// @param _cids Array of car CIDs to be added.
    /// @param _datasetId dataset index of approved dataset
    /// @param _sizes car size array
    /// @param _replicaCount count of car's replicas
    function addCars(
        bytes32[] memory _cids,
        uint64 _datasetId,
        uint64[] memory _sizes,
        uint16 _replicaCount
    ) external onlyNotZero(_datasetId) {
        require(_cids.length == _sizes.length, "Invalid params");
        for (uint64 i; i < _cids.length; i++) {
            addCar(_cids[i], _datasetId, _sizes[i], _replicaCount);
        }

        emit CarstoreEvents.CarsAdded(_cids);
    }

    /// @notice Regist a replica to a car.
    /// @dev This function allows adding a replica to an existing car.
    /// @param _cid Car CID to which the replica will be added.
    /// @param _matchingId Matching ID for the new replica.
    /// @param _replicaIndex The index of the replica.
    function registCarReplica(
        bytes32 _cid,
        uint64 _matchingId,
        uint16 _replicaIndex
    )
        external
        onlyCarExist(_cid)
        onlyNotZero(_matchingId)
        onlyCarReplicaNotExist(_cid, _matchingId)
    {
        CarReplicaType.Car storage car = cars[_cid];
        require(
            _replicaIndex < car._getRepicasCount(),
            "Invalid replica index"
        );

        car._registRepica(_matchingId, _replicaIndex);

        emit CarstoreEvents.CarReplicaRegisted(
            _cid,
            _matchingId,
            _replicaIndex
        );
    }

    /// @notice Report that matching's state for a replica.
    /// @dev This function allows reporting that the matching for a replica is failed.
    /// @param _cid Car CID associated with the replica.
    /// @param _matchingId Matching ID of the replica.
    /// @param _matchingState Matching's state of the replica, true for success ,false for failed.
    function reportCarReplicaMatchingState(
        bytes32 _cid,
        uint64 _matchingId,
        bool _matchingState
    )
        external
        onlyCarExist(_cid)
        onlyNotZero(_matchingId)
        onlyCarReplicaExist(_cid, _matchingId)
    {
        if (_matchingState) {
            _emitRepicaEvent(
                _cid,
                _matchingId,
                CarReplicaType.Event.MatchingCompleted
            );
            emit CarstoreEvents.CarReplicaMatchingState(
                _cid,
                _matchingId,
                "success"
            );
        } else {
            _emitRepicaEvent(
                _cid,
                _matchingId,
                CarReplicaType.Event.MatchingFailed
            );
            emit CarstoreEvents.CarReplicaMatchingState(
                _cid,
                _matchingId,
                "failed"
            );
        }
    }

    /// @notice Report that storage deal for a replica has expired.
    /// @dev This function allows reporting that the storage deal for a replica has expired.
    /// @param _cid Car CID associated with the replica.
    /// @param _matchingId Matching ID of the replica.
    function reportCarReplicaExpired(
        bytes32 _cid,
        uint64 _matchingId,
        uint64 _claimId
    )
        external
        onlyCarExist(_cid)
        onlyNotZero(_matchingId)
        onlyCarReplicaExist(_cid, _matchingId)
        onlyCarReplicaState(_cid, _matchingId, CarReplicaType.State.Stored)
        onlyCarReplicaFilecoinDealState(
            _cid,
            _claimId,
            FilecoinType.DealState.Expired
        )
    {
        _emitRepicaEvent(
            _cid,
            _matchingId,
            CarReplicaType.Event.StorageDealExpired
        );
        emit CarstoreEvents.CarReplicaExpired(_cid, _matchingId);
    }

    /// @notice Report that storage of a replica has been slashed.
    /// @dev This function allows reporting that the storage of a replica has been slashed.
    /// @param _cid Car CID associated with the replica.
    /// @param _matchingId Matching ID of the replica.
    function reportCarReplicaSlashed(
        bytes32 _cid,
        uint64 _matchingId,
        uint64 _claimId
    )
        external
        onlyCarExist(_cid)
        onlyNotZero(_matchingId)
        onlyCarReplicaExist(_cid, _matchingId)
        onlyCarReplicaState(_cid, _matchingId, CarReplicaType.State.Stored)
        onlyCarReplicaFilecoinDealState(
            _cid,
            _claimId,
            FilecoinType.DealState.Slashed
        )
    {
        _emitRepicaEvent(
            _cid,
            _matchingId,
            CarReplicaType.Event.StorageSlashed
        );
        emit CarstoreEvents.CarReplicaSlashed(_cid, _matchingId);
    }

    /// @notice Set the Filecoin claim ID for a replica's storage.
    /// @dev This function allows setting the Filecoin claim ID for a specific replica's storage.
    /// @param _cid Car CID associated with the replica.
    /// @param _matchingId Matching ID of the replica.
    /// @param _claimId New Filecoin claim ID to set for the replica's storage.
    function setCarReplicaFilecoinClaimId(
        bytes32 _cid,
        uint64 _matchingId,
        uint64 _claimId
    )
        external
        onlyCarExist(_cid)
        onlyNotZero(_matchingId)
        onlyNotZero(_claimId)
        onlyCarReplicaExist(_cid, _matchingId)
        onlyCarReplicaState(_cid, _matchingId, CarReplicaType.State.Matched)
        onlyUnsetCarReplicaFilecoinClaimId(_cid, _matchingId)
    {
        CarReplicaType.Car storage car = cars[_cid];
        car._setReplicaFilecoinClaimId(_cid, _matchingId, _claimId, filecoin);

        emit CarstoreEvents.CarReplicaFilecoinClaimIdSet(
            _cid,
            _matchingId,
            _claimId
        );
    }

    /// @notice Get the dataset ID associated with a car.
    /// @param _cid Car CID to check.
    /// @return The car size of the car.
    function getCarSize(
        bytes32 _cid
    ) public view onlyCarExist(_cid) returns (uint64) {
        CarReplicaType.Car storage car = cars[_cid];
        return car.size;
    }

    /// @notice Get the total size of cars based on an array of car IDs.
    /// @param _cids An array of car IDs for which to calculate the size.
    /// @return The total size of cars.
    function getCarsSize(bytes32[] memory _cids) public view returns (uint64) {
        uint64 size = 0;
        for (uint64 i = 0; i < _cids.length; i++) {
            size += getCarSize(_cids[i]);
        }
        return size;
    }

    /// @notice Get the dataset ID associated with a car.
    /// @param _cid Car CID to check.
    /// @return The dataset ID of the car.
    function getCarDatasetId(bytes32 _cid) public view returns (uint64) {
        CarReplicaType.Car storage car = cars[_cid];
        return car._getDatasetId();
    }

    /// @notice Get the matching ids of a replica associated with a car.
    /// @param _cid Car CID associated with the replica.
    /// @return The matching ids of the car's replica.
    function getCarMatchingIds(
        bytes32 _cid
    ) public view onlyCarExist(_cid) returns (uint64[] memory) {
        CarReplicaType.Car storage car = cars[_cid];
        return car._getMatchingIds();
    }

    /// @notice Get the replica details associated with a car.
    /// @param _cid Car CID associated with the replica.
    /// @param _matchingId Matching ID of the replica.
    /// @return The dataset ID, state, and Filecoin claim ID of the replica.
    function getCarReplica(
        bytes32 _cid,
        uint64 _matchingId
    )
        public
        view
        onlyCarExist(_cid)
        onlyNotZero(_matchingId)
        onlyCarReplicaExist(_cid, _matchingId)
        returns (CarReplicaType.State, uint64)
    {
        CarReplicaType.Car storage car = cars[_cid];
        return (
            car._getReplicaState(_matchingId),
            car._getReplicaFilecoinClaimId(_matchingId)
        );
    }

    /// @notice Get the count of replicas associated with a car.
    /// @dev This function returns the number of replicas associated with a car.
    /// @param _cid Car CID for which to retrieve the replica count.
    /// @return The count of replicas associated with the car.
    function getCarReplicasCount(
        bytes32 _cid
    ) public view onlyCarExist(_cid) returns (uint16) {
        CarReplicaType.Car storage car = cars[_cid];
        return car._getRepicasCount();
    }

    /// @notice Get the Filecoin claim ID associated with a specific replica of a car.
    /// @param _cid Car CID associated with the replica.
    /// @param _matchingId Matching ID of the replica.
    /// @return The Filecoin claim ID of the replica.
    function getCarReplicaFilecoinClaimId(
        bytes32 _cid,
        uint64 _matchingId
    )
        public
        view
        onlyCarExist(_cid)
        onlyNotZero(_matchingId)
        onlyCarReplicaExist(_cid, _matchingId)
        returns (uint64)
    {
        CarReplicaType.Car storage car = cars[_cid];
        return car._getReplicaFilecoinClaimId(_matchingId);
    }

    /// @notice Get the state of a replica associated with a car.
    /// @param _cid Car CID associated with the replica.
    /// @param _matchingId Matching ID of the replica.
    /// @return The state of the replica.
    function getCarReplicaState(
        bytes32 _cid,
        uint64 _matchingId
    )
        public
        view
        onlyCarExist(_cid)
        onlyNotZero(_matchingId)
        returns (CarReplicaType.State)
    {
        CarReplicaType.Car storage car = cars[_cid];
        return car._getReplicaState(_matchingId);
    }

    /// @notice Check if a car exists based on its CID.
    /// @dev This function returns whether a car exists or not.
    /// @param _cid Car CID to check.
    /// @return True if the car exists, false otherwise.
    function hasCar(bytes32 _cid) public view returns (bool) {
        CarReplicaType.Car storage cid = cars[_cid];
        return cid.datasetId != 0;
    }

    /// @notice Check if a replica exists within a car based on its matching ID.
    /// @dev This function returns whether a replica with the specified matching ID exists within a car or not.
    /// @param _cid Car CID to check.
    /// @param _matchingId Matching ID of the replica to check.
    /// @return True if the replica exists, false otherwise.
    function hasCarReplica(
        bytes32 _cid,
        uint64 _matchingId
    ) public view onlyCarExist(_cid) returns (bool) {
        CarReplicaType.Car storage car = cars[_cid];
        return car._hasReplica(_matchingId);
    }

    /// @notice Check if multiple cars exist based on their CIDs.
    /// @dev This function returns whether all the specified cars exist or not.
    /// @param _cids Array of car CIDs to check.
    /// @return True if all specified cars exist, false if any one does not exist.
    function hasCars(bytes32[] memory _cids) public view returns (bool) {
        for (uint64 i; i < _cids.length; i++) {
            if (!hasCar(_cids[i])) return false;
        }
        return true;
    }
}
