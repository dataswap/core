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
import {Errors} from "src/v0.8/shared/errors/Errors.sol";
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
    function initialize(address _roles) public initializer {
        CarstoreBase.carstoreBaseInitialize(_roles);
        __UUPSUpgradeable_init();
    }

    /// @notice UUPS Upgradeable function to update the roles implementation
    /// @dev Only triggered by contract admin
    function _authorizeUpgrade(
        address newImplementation
    )
        internal
        override
        onlyRole(roles, RolesType.DEFAULT_ADMIN_ROLE) // solhint-disable-next-line
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
    function __addCar(
        bytes32 _cid,
        uint64 _datasetId,
        uint64 _size,
        uint16 _replicaCount
    )
        public
        onlyRole(roles, RolesType.DATASWAP_CONTRACT)
        onlyCarNotExist(this, _cid)
        onlyNotZero(_datasetId)
        onlyNotZero(_size)
        returns (uint64)
    {
        carsCount++;
        CarReplicaType.Car storage car = cars[_cid];
        car._setDatasetId(_datasetId);
        car._initRepicas(_replicaCount);
        car.id = carsCount;
        car.size = _size;
        carsIndexes[carsCount] = _cid;
        return car.id;
    }

    /// @notice Add multiple cars to the storage.
    /// @dev This function allows the addition of multiple cars at once.
    /// @param _cids Array of car CIDs to be added.
    /// @param _datasetId dataset index of approved dataset
    /// @param _sizes car size array
    /// @param _replicaCount count of car's replicas
    /// @return ids totalSize The ids of the cars and the size.
    function __addCars(
        bytes32[] memory _cids,
        uint64 _datasetId,
        uint64[] memory _sizes,
        uint16 _replicaCount
    )
        external
        onlyRole(roles, RolesType.DATASWAP_CONTRACT)
        onlyNotZero(_datasetId)
        returns (uint64[] memory ids, uint64 totalSize)
    {
        require(_cids.length == _sizes.length, "Invalid params");

        ids = new uint64[](_cids.length);
        for (uint64 i; i < _cids.length; i++) {
            ids[i] = __addCar(_cids[i], _datasetId, _sizes[i], _replicaCount);
            totalSize += _sizes[i];
        }

        emit CarstoreEvents.CarsAdded(_cids);
        return (ids, totalSize);
    }

    /// @notice Regist a replica to a car.
    /// @dev This function allows adding a replica to an existing car.
    /// @param _id Car ID to which the replica will be added.
    /// @param _matchingId Matching ID for the new replica.
    /// @param _replicaIndex The index of the replica.
    function __registCarReplica(
        uint64 _id,
        uint64 _matchingId,
        uint16 _replicaIndex
    )
        external
        onlyRole(roles, RolesType.DATASWAP_CONTRACT)
        onlyCarExist(this, _id)
        onlyNotZero(_matchingId)
        onlyCarReplicaNotExist(this, _id, _matchingId)
    {
        CarReplicaType.Car storage car = _getCar(_id);
        require(
            _replicaIndex < car._getRepicasCount(),
            "Invalid replica index"
        );

        car._registRepica(_matchingId, _replicaIndex);

        emit CarstoreEvents.CarReplicaRegisted(_id, _matchingId, _replicaIndex);
    }

    /// @notice Report that matching's state for a replica.
    /// @dev This function allows reporting that the matching for a replica is failed.
    /// @param _id Car ID associated with the replica.
    /// @param _matchingId Matching ID of the replica.
    /// @param _matchingState Matching's state of the replica, true for success ,false for failed.
    function __reportCarReplicaMatchingState(
        uint64 _id,
        uint64 _matchingId,
        bool _matchingState
    ) external onlyRole(roles, RolesType.DATASWAP_CONTRACT) {
        if (_matchingState) {
            _emitRepicaEvent(
                _id,
                _matchingId,
                CarReplicaType.Event.MatchingCompleted
            );
            emit CarstoreEvents.CarReplicaMatchingState(
                _id,
                _matchingId,
                "success"
            );
        } else {
            _emitRepicaEvent(
                _id,
                _matchingId,
                CarReplicaType.Event.MatchingFailed
            );
            emit CarstoreEvents.CarReplicaMatchingState(
                _id,
                _matchingId,
                "failed"
            );
        }
    }
    /// @dev Reports a failure in car replica storage.
    /// @param _id The ID associated with the car replica.
    /// @param _matchingId The ID of the matching process related to the storage failure.
    function __reportCarReplicaStorageFailed(
        uint64 _id,
        uint64 _matchingId
    )
        external
        onlyRole(roles, RolesType.DATASWAP_CONTRACT)
        onlyCarReplicaState(
            this,
            _id,
            _matchingId,
            CarReplicaType.State.Matched
        )
    {
        _emitRepicaEvent(_id, _matchingId, CarReplicaType.Event.StorageFailed);
    }

    function _checkCarReplicaDealState(
        uint64 _id,
        uint64 _claimId,
        FilecoinType.DealState _dealState
    ) internal {
        if (
            _dealState !=
            roles.filecoin().getReplicaDealState(getCarHash(_id), _claimId)
        ) {
            revert Errors.InvalidReplicaFilecoinDealState(_id, _claimId);
        }
    }

    /// @notice Report that storage deal for a replica has expired.
    /// @dev This function allows reporting that the storage deal for a replica has expired.
    /// @param _id Car ID associated with the replica.
    /// @param _matchingId Matching ID of the replica.
    function __reportCarReplicaExpired(
        uint64 _id,
        uint64 _matchingId,
        uint64 _claimId
    )
        external
        onlyRole(roles, RolesType.DATASWAP_CONTRACT)
        onlyCarReplicaState(this, _id, _matchingId, CarReplicaType.State.Stored)
    {
        _checkCarReplicaDealState(
            _id,
            _claimId,
            FilecoinType.DealState.Expired
        );
        _emitRepicaEvent(
            _id,
            _matchingId,
            CarReplicaType.Event.StorageDealExpired
        );
        emit CarstoreEvents.CarReplicaExpired(_id, _matchingId);
    }

    /// @notice Report that storage of a replica has been slashed.
    /// @dev This function allows reporting that the storage of a replica has been slashed.
    /// @param _id Car ID associated with the replica.
    /// @param _matchingId Matching ID of the replica.
    function __reportCarReplicaSlashed(
        uint64 _id,
        uint64 _matchingId,
        uint64 _claimId
    )
        external
        onlyRole(roles, RolesType.DATASWAP_CONTRACT)
        onlyCarReplicaState(this, _id, _matchingId, CarReplicaType.State.Stored)
    {
        _checkCarReplicaDealState(
            _id,
            _claimId,
            FilecoinType.DealState.Slashed
        );
        _emitRepicaEvent(_id, _matchingId, CarReplicaType.Event.StorageSlashed);
        emit CarstoreEvents.CarReplicaSlashed(_id, _matchingId);
    }

    /// @dev Modifier to ensure that a replica state before function do.
    function _checkCarReplicaState(
        uint64 _id,
        uint64 _matchingId,
        CarReplicaType.State _state
    ) internal view {
        if (_state != getCarReplicaState(_id, _matchingId)) {
            revert Errors.InvalidReplicaState(_id, _matchingId);
        }
    }

    /// @notice Set the Filecoin claim ID for a replica's storage.
    /// @dev This function allows setting the Filecoin claim ID for a specific replica's storage.
    /// @param _id Car ID associated with the replica.
    /// @param _matchingId Matching ID of the replica.
    /// @param _claimId New Filecoin claim ID to set for the replica's storage.
    function __setCarReplicaFilecoinClaimId(
        uint64 _id,
        uint64 _matchingId,
        uint64 _claimId
    )
        external
        onlyRole(roles, RolesType.DATASWAP_CONTRACT)
        onlyCarExist(this, _id)
        //onlyNotZero(_matchingId | _claimId)
        onlyCarReplicaExist(this, _id, _matchingId)
        onlyUnsetCarReplicaFilecoinClaimId(this, _id, _matchingId)
    {
        require(
            (_matchingId | _claimId) != 0,
            "Matching ID or Filecoin claim ID is 0"
        );
        _checkCarReplicaState(_id, _matchingId, CarReplicaType.State.Matched);
        bytes32 _hash = _getHash(_id);
        CarReplicaType.Car storage car = _getCar(_id);
        car._setReplicaFilecoinClaimId(
            _hash,
            _matchingId,
            _claimId,
            roles.filecoin()
        );

        emit CarstoreEvents.CarReplicaFilecoinClaimIdSet(
            _id,
            _matchingId,
            _claimId
        );
    }

    /// @notice Updates information for a car.
    /// @dev This function is intended to update various parameters associated with a car, such as its ID, dataset ID, and replica count.
    /// @param _id The ID of the car to be updated.
    /// @param _datasetId The dataset ID associated with the car.
    /// @param _replicaCount The count of replicas associated with the car.
    function __updateCar(
        uint64 _id,
        uint64 _datasetId,
        uint16 _replicaCount
    )
        public
        onlyRole(roles, RolesType.DATASWAP_CONTRACT)
        onlyCarExist(this, _id)
    {
        CarReplicaType.Car storage car = cars[getCarHash(_id)];
        require(
            roles.datasetsProof().isAssociatedDatasetContainsCar(
                _datasetId,
                _id
            ),
            "invalid associated datasetId"
        );

        car._setDatasetId(_datasetId);
        car._initRepicas(_replicaCount);
    }

    /// @notice Updates information for multiple cars and returns the total size of the updated cars.
    /// @dev This function is intended to update various parameters associated with multiple cars simultaneously, such as their IDs, dataset ID, and replica count, and then returns the total size of the updated cars.
    /// @param _ids An array containing the IDs of the cars to be updated.
    /// @param _datasetId The dataset ID associated with the cars.
    /// @param _replicaCount The count of replicas associated with each car.
    function __updateCars(
        uint64[] memory _ids,
        uint64 _datasetId,
        uint16 _replicaCount
    ) external onlyRole(roles, RolesType.DATASWAP_CONTRACT) {
        for (uint64 i; i < _ids.length; i++) {
            __updateCar(_ids[i], _datasetId, _replicaCount);
        }
    }

    /// @notice Get the car information associated with a car.
    /// @param _id Car ID to check.
    /// @return hash datasetId size replicasCount matchingIds, The car information.
    function getCar(
        uint64 _id
    )
        public
        view
        onlyCarExist(this, _id)
        returns (
            bytes32 hash,
            uint64 datasetId,
            uint64 size,
            uint16 replicasCount,
            uint64[] memory matchingIds
        )
    {
        CarReplicaType.Car storage car = _getCar(_id);

        return (
            _getHash(_id),
            car._getDatasetId(),
            car.size,
            car._getRepicasCount(),
            car._getMatchingIds()
        );
    }

    /// @notice Get the dataset ID associated with a car.
    /// @param _id Car ID to check.
    /// @return size The car size of the car.
    function getCarSize(
        uint64 _id
    ) public view onlyCarExist(this, _id) returns (uint64 size) {
        CarReplicaType.Car storage car = _getCar(_id);
        return car.size;
    }

    /// @notice Get the total size of cars based on an array of car IDs.
    /// @param _ids An array of car IDs for which to calculate the size.
    /// @return size The total size of cars.
    function getCarsSize(
        uint64[] memory _ids
    ) public view returns (uint64 size) {
        for (uint64 i = 0; i < _ids.length; i++) {
            size += getCarSize(_ids[i]);
        }
        return size;
    }

    /// @notice Get the dataset ID associated with a car.
    /// @param _id Car ID to check.
    /// @return datasetId The dataset ID of the car.
    function getCarDatasetId(
        uint64 _id
    ) public view returns (uint64 datasetId) {
        CarReplicaType.Car storage car = _getCar(_id);
        return car._getDatasetId();
    }

    /// @notice Get the matching ids of a replica associated with a car.
    /// @param _id Car ID associated with the replica.
    /// @return datasetIds The matching ids of the car's replica.
    function getCarMatchingIds(
        uint64 _id
    ) public view onlyCarExist(this, _id) returns (uint64[] memory datasetIds) {
        CarReplicaType.Car storage car = _getCar(_id);
        return car._getMatchingIds();
    }

    /// @notice Get the replica details associated with a car.
    /// @param _id Car ID associated with the replica.
    /// @param _matchingId Matching ID of the replica.
    /// @return state filecoinClaimId, The dataset ID, state, and Filecoin claim ID of the replica.
    function getCarReplica(
        uint64 _id,
        uint64 _matchingId
    )
        public
        view
        onlyCarExist(this, _id)
        onlyNotZero(_matchingId)
        onlyCarReplicaExist(this, _id, _matchingId)
        returns (CarReplicaType.State state, uint64 filecoinClaimId)
    {
        CarReplicaType.Car storage car = _getCar(_id);
        return (
            car._getReplicaState(_matchingId),
            car._getReplicaFilecoinClaimId(_matchingId)
        );
    }

    /// @notice Get the count of replicas associated with a car.
    /// @dev This function returns the number of replicas associated with a car.
    /// @param _id Car ID for which to retrieve the replica count.
    /// @return The count of replicas associated with the car.
    function getCarReplicasCount(
        uint64 _id
    ) public view onlyCarExist(this, _id) returns (uint16) {
        CarReplicaType.Car storage car = _getCar(_id);
        return car._getRepicasCount();
    }

    /// @notice Get the Filecoin claim ID associated with a specific replica of a car.
    /// @param _id Car ID associated with the replica.
    /// @param _matchingId Matching ID of the replica.
    /// @return The Filecoin claim ID of the replica.
    function getCarReplicaFilecoinClaimId(
        uint64 _id,
        uint64 _matchingId
    )
        public
        view
        onlyCarExist(this, _id)
        onlyNotZero(_matchingId)
        onlyCarReplicaExist(this, _id, _matchingId)
        returns (uint64)
    {
        CarReplicaType.Car storage car = _getCar(_id);
        return car._getReplicaFilecoinClaimId(_matchingId);
    }

    /// @notice Get the state of a replica associated with a car.
    /// @param _id Car ID associated with the replica.
    /// @param _matchingId Matching ID of the replica.
    /// @return The state of the replica.
    function getCarReplicaState(
        uint64 _id,
        uint64 _matchingId
    )
        public
        view
        onlyCarExist(this, _id)
        onlyNotZero(_matchingId)
        returns (CarReplicaType.State)
    {
        CarReplicaType.Car storage car = _getCar(_id);
        return car._getReplicaState(_matchingId);
    }

    /// @notice Get the hash of car based on the car id.
    /// @param _id Car ID which to get car hash.
    /// @return The hash of the car.
    function getCarHash(uint64 _id) public view returns (bytes32) {
        return _getHash(_id);
    }

    /// @notice Get the hashs of cars based on an array of car IDs.
    /// @param _ids An array of car IDs for which to get car hashs.
    /// @return The hashs of cars.
    function getCarsHashs(
        uint64[] memory _ids
    ) public view returns (bytes32[] memory) {
        bytes32[] memory hashs = new bytes32[](_ids.length);
        for (uint64 i = 0; i < _ids.length; i++) {
            hashs[i] = _getHash(_ids[i]);
        }
        return hashs;
    }

    /// @notice Get the car's id based on the car's hash.
    /// @param _hash The hash which to get car id.
    /// @return The id of the car.
    function getCarId(bytes32 _hash) public view returns (uint64) {
        return _getId(_hash);
    }

    /// @notice Get the ids of cars based on an array of car hashs.
    /// @param _hashs An array of car hashs for which to cat car hashs.
    /// @return The ids of cars.
    function getCarsIds(
        bytes32[] memory _hashs
    ) public view returns (uint64[] memory) {
        uint64[] memory ids = new uint64[](_hashs.length);
        for (uint64 i = 0; i < _hashs.length; i++) {
            ids[i] = _getId(_hashs[i]);
        }
        return ids;
    }

    /// @notice Check if a car exists based on its Hash.
    /// @dev This function returns whether a car exists or not.
    /// @param _hash Car Hash to check.
    /// @return True if the car exists, false otherwise.
    function hasCarHash(bytes32 _hash) public view returns (bool) {
        CarReplicaType.Car storage car = cars[_hash];
        return car.datasetId != 0;
    }

    /// @notice Check if a car exists based on its ID.
    /// @dev This function returns whether a car exists or not.
    /// @param _id Car ID to check.
    /// @return True if the car exists, false otherwise.
    function hasCar(uint64 _id) public view returns (bool) {
        require(_id != 0, "Invalid car id");
        CarReplicaType.Car storage car = _getCar(_id);
        return car.id == _id;
    }

    /// @notice Check if a replica exists within a car based on its matching ID.
    /// @dev This function returns whether a replica with the specified matching ID exists within a car or not.
    /// @param _id Car ID to check.
    /// @param _matchingId Matching ID of the replica to check.
    /// @return True if the replica exists, false otherwise.
    function hasCarReplica(
        uint64 _id,
        uint64 _matchingId
    ) public view onlyCarExist(this, _id) returns (bool) {
        CarReplicaType.Car storage car = _getCar(_id);
        return car._hasReplica(_matchingId);
    }

    /// @notice Check if a car exists based on its Hashs.
    /// @dev This function returns whether a car exists or not.
    /// @param _hashs  Array of car Hashs to check.
    /// @return True if the car exists, false otherwise.
    function hasCarsHashs(bytes32[] memory _hashs) public view returns (bool) {
        for (uint64 i; i < _hashs.length; i++) {
            if (!hasCarHash(_hashs[i])) return false;
        }
        return true;
    }

    /// @notice Check if multiple cars exist based on their IDs.
    /// @dev This function returns whether all the specified cars exist or not.
    /// @param _ids Array of car IDs to check.
    /// @return True if all specified cars exist, false if any one does not exist.
    function hasCars(uint64[] memory _ids) public view returns (bool) {
        for (uint64 i; i < _ids.length; i++) {
            if (!hasCar(_ids[i])) return false;
        }
        return true;
    }
}
