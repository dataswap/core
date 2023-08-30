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

import {CarReplicaType} from "src/v0.8/types/CarReplicaType.sol";
import {DataswapStorageServiceBase} from "src/v0.8/service/dataswapstorage/abstract/base/DataswapStorageServiceBase.sol";
import {IFilecoin} from "src/v0.8/interfaces/core/IFilecoin.sol";
import {IRoles} from "src/v0.8/interfaces/core/IRoles.sol";
import {IFilplus} from "src/v0.8/interfaces/core/IFilplus.sol";

/// @title FilplusService
abstract contract CarstoreService is DataswapStorageServiceBase {
    /// @notice Get the dataset ID associated with a car.
    /// @param _cid Car CID to check.
    /// @return The car size of the car.
    function getCarSize(bytes32 _cid) external view returns (uint64) {
        return carstoreInstance.getCarSize(_cid);
    }

    /// @notice Get the total size of cars based on an array of car IDs.
    /// @param _cids An array of car IDs for which to calculate the size.
    /// @return The total size of cars.
    function getCarsSize(
        bytes32[] memory _cids
    ) external view returns (uint64) {
        return carstoreInstance.getCarsSize(_cids);
    }

    /// @notice Get the dataset ID associated with a car.
    /// @param _cid Car CID to check.
    /// @return The dataset ID of the car.
    /// NOTE: a car only belongs a datasets
    function getCarDatasetId(bytes32 _cid) external view returns (uint64) {
        return carstoreInstance.getCarDatasetId(_cid);
    }

    /// @notice Get the replica details associated with a car.
    /// @param _cid Car CID associated with the replica.
    /// @param _matchingId Matching ID of the replica.
    /// @return The dataset ID, state, and Filecoin deal ID of the replica.
    function getCarReplica(
        bytes32 _cid,
        uint64 _matchingId
    ) external view returns (CarReplicaType.State, uint64) {
        return carstoreInstance.getCarReplica(_cid, _matchingId);
    }

    /// @notice Get the count of replicas associated with a car.
    /// @param _cid Car CID for which to retrieve the replica count.
    /// @return The count of replicas associated with the car.
    function getCarReplicasCount(bytes32 _cid) external view returns (uint16) {
        return carstoreInstance.getCarReplicasCount(_cid);
    }

    /// @notice Get the Filecoin deal ID associated with a specific replica of a car.
    /// @param _cid Car CID associated with the replica.
    /// @param _matchingId Matching ID of the replica.
    /// @return The Filecoin deal ID of the replica.
    function getCarReplicaFilecoinDealId(
        bytes32 _cid,
        uint64 _matchingId
    ) external view returns (uint64) {
        return carstoreInstance.getCarReplicaFilecoinDealId(_cid, _matchingId);
    }

    /// @notice Get the state of a replica associated with a car.
    /// @param _cid Car CID associated with the replica.
    /// @param _matchingId Matching ID of the replica.
    /// @return The state of the replica.
    function getCarReplicaState(
        bytes32 _cid,
        uint64 _matchingId
    ) external view returns (CarReplicaType.State) {
        return carstoreInstance.getCarReplicaState(_cid, _matchingId);
    }

    /// @notice Check if a car exists based on its CID.
    /// @param _cid Car CID to check.
    /// @return True if the car exists, false otherwise.
    function hasCar(bytes32 _cid) external view returns (bool) {
        return carstoreInstance.hasCar(_cid);
    }

    /// @notice Check if a replica exists within a car based on its matching ID.
    /// @param _cid Car CID to check.
    /// @param _matchingId Matching ID of the replica to check.
    /// @return True if the replica exists, false otherwise.
    function hasCarReplica(
        bytes32 _cid,
        uint64 _matchingId
    ) external view returns (bool) {
        return carstoreInstance.hasCarReplica(_cid, _matchingId);
    }

    /// @notice Check if multiple cars exist based on their CIDs.
    /// @param _cids Array of car CIDs to check.
    /// @return True if all specified cars exist, false if any one does not exist.
    function hasCars(bytes32[] memory _cids) external view returns (bool) {
        return carstoreInstance.hasCars(_cids);
    }

    // Default getter functions for public variables
    function carsCount() external view returns (uint64) {
        return carstoreInstance.carsCount();
    }

    /// @notice get filecoin object
    function filecoin() external view returns (IFilecoin) {
        return carstoreInstance.filecoin();
    }

    /// @notice get filplus object
    function filplus() external view returns (IFilplus) {
        return carstoreInstance.filplus();
    }
}
