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

/// @title ICarsStorageBase
/// @notice Interface for the CarsStorageBase contract, which allows adding cars and managing their associated replicas.
interface ICarsStorage {
    /// @notice Add multiple cars to the storage.
    /// @param _cids Array of car CIDs to be added.
    function addCars(bytes32[] memory _cids) external;

    /// @notice Add a replica to a car.
    /// @param _cid Car CID to which the replica will be added.
    /// @param _matchingId Matching ID for the new replica.
    function addReplica(bytes32 _cid, uint256 _matchingId) external;

    /// @notice Set the Filecoin deal ID for a replica's storage.
    /// @param _cid Car CID associated with the replica.
    /// @param _matchingId Matching ID of the replica.
    /// @param _filecoinDealId New Filecoin deal ID to set for the replica's storage.
    function setReplicaFilecoinDealId(
        bytes32 _cid,
        uint256 _matchingId,
        uint256 _filecoinDealId
    ) external;

    /// @notice Get the count of replicas associated with a car.
    /// @param _cid Car CID for which to retrieve the replica count.
    /// @return The count of replicas associated with the car.
    function getRepicasCount(bytes32 _cid) external view returns (uint256);

    /// @notice Check if a car exists based on its CID.
    /// @param _cid Car CID to check.
    /// @return True if the car exists, false otherwise.
    function hasCar(bytes32 _cid) external view returns (bool);

    /// @notice Check if multiple cars exist based on their CIDs.
    /// @param _cids Array of car CIDs to check.
    /// @return True if all specified cars exist, false if any one does not exist.
    function hasCars(bytes32[] memory _cids) external view returns (bool);

    /// @notice Check if a replica exists within a car based on its matching ID.
    /// @param _cid Car CID to check.
    /// @param _matchingId Matching ID of the replica to check.
    /// @return True if the replica exists, false otherwise.
    function hasReplica(
        bytes32 _cid,
        uint256 _matchingId
    ) external view returns (bool, uint256);

    /// @notice Report that storage of a replica has failed.
    /// @param _cid Car CID associated with the replica.
    /// @param _matchingId Matching ID of the replica.
    function reportReplicaStorageFailed(
        bytes32 _cid,
        uint256 _matchingId
    ) external;

    /// @notice Report that storage deal for a replica has expired.
    /// @param _cid Car CID associated with the replica.
    /// @param _matchingId Matching ID of the replica.
    function reportReplicaStorageDealExpired(
        bytes32 _cid,
        uint256 _matchingId
    ) external;

    /// @notice Report that storage of a replica has been slashed.
    /// @param _cid Car CID associated with the replica.
    /// @param _matchingId Matching ID of the replica.
    function reportReplicaStorageSlashed(
        bytes32 _cid,
        uint256 _matchingId
    ) external;
}
