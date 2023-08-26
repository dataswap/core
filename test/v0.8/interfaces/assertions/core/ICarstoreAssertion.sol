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

// assert carstore action
// NOTE: view asserton functions must all be tested by the functions that will change state
interface ICarstoreAssertion {
    /// @dev assert addCar
    function addCarAssertion(
        bytes32 _cid,
        uint64 _datasetId,
        uint64 _size
    ) external;

    /// @dev assert addCars
    function addCarsAssertion(
        bytes32[] memory _cids,
        uint64 _datasetId,
        uint64[] memory _sizes
    ) external;

    /// @dev assert addCarReplica
    function addCarReplicaAssertion(bytes32 _cid, uint64 _matchingId) external;

    /// @dev assert reportCarReplicaExpired
    function reportCarReplicaExpiredAssertion(
        bytes32 _cid,
        uint64 _matchingId,
        uint64 _filecoinDealId
    ) external;

    /// @dev assert reportCarReplicaSlashed
    function reportCarReplicaSlashedAssertion(
        bytes32 _cid,
        uint64 _matchingId,
        uint64 _filecoinDealId
    ) external;

    /// @dev assert setCarReplicaFilecoinDealId
    function setCarReplicaFilecoinDealIdAssertion(
        bytes32 _cid,
        uint64 _matchingId,
        uint64 _filecoinDealId
    ) external;

    /// @dev assert getCarSize
    function getCarSizeAssertion(
        bytes32 _inputCid,
        uint64 _expectSize
    ) external;

    /// @dev assert getCarDatasetId
    function getCarDatasetIdAssertion(
        bytes32 _inputCid,
        uint64 _expectDatasetId
    ) external;

    /// @dev assert getCarReplica
    function getCarReplicaAssertion(
        bytes32 _inputCid,
        uint64 _inputmatchingId,
        CarReplicaType.State _expectState,
        uint64 _expectFilecoinDealId
    ) external;

    /// @dev assert getCarReplicasCount
    function getCarReplicasCountAssertion(
        bytes32 _inputCid,
        uint16 _expectCount
    ) external;

    /// @dev assert getCarReplicaFilecoinDealId
    function getCarReplicaFilecoinDealIdAssertion(
        bytes32 _inputCid,
        uint64 _inputMatchingId,
        uint64 _expectFilecoinDealId
    ) external;

    /// @dev assert getCarReplicaState
    function getCarReplicaStateAssertion(
        bytes32 _inputCid,
        uint64 _inputMatchingId,
        CarReplicaType.State _expectState
    ) external;

    /// @dev assert hasCar
    function hasCarAssertion(bytes32 _inputCid, bool _expectIfExist) external;

    /// @dev assert hasCarReplica
    function hasCarReplicaAssertion(
        bytes32 _inputCid,
        uint64 _inputMatchingId,
        bool _expectIfExist
    ) external;

    /// @dev assert hasCars
    function hasCarsAssertion(
        bytes32[] memory _inputCids,
        bool _expectIfExist
    ) external;

    /// @dev assert carsCount
    function carsCounAssertiont(uint64 _expectCout) external;
}
