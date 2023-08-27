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

// assert carstore action
// NOTE: view asserton functions must all be tested by the functions that will change state
contract CarstoreAssertion is DSTest, Test, ICarstoreAssertion {
    ICarstore public carstore;

    constructor(ICarstore _carstore) {
        carstore = _carstore;
    }

    /// @dev assert addCar
    function addCarAssertion(
        bytes32 _cid,
        uint64 _datasetId,
        uint64 _size
    ) public {
        // before add
        uint64 beforeCount = carstore.carsCount();
        hasCarAssertion(_cid, false);

        // action
        carstore.addCar(_cid, _datasetId, _size);

        // after add
        getCarDatasetIdAssertion(_cid, _datasetId);
        getCarSizeAssertion(_cid, _size);
        hasCarAssertion(_cid, true);
        carsCounAssertiont(beforeCount + 1);
    }

    /// @dev assert addCars
    function addCarsAssertion(
        bytes32[] memory _cids,
        uint64 _datasetId,
        uint64[] memory _sizes
    ) external {
        // before add
        hasCarsAssertion(_cids, false);
        // action
        carstore.addCars(_cids, _datasetId, _sizes);
        // after add
        hasCarsAssertion(_cids, true);
    }

    /// @dev assert addCarReplica
    function addCarReplicaAssertion(bytes32 _cid, uint64 _matchingId) external {
        // before add
        uint16 beforeReplicasCount = carstore.getCarReplicasCount(_cid);
        hasCarReplicaAssertion(_cid, _matchingId, false);
        getCarReplicaStateAssertion(
            _cid,
            _matchingId,
            CarReplicaType.State.None
        );

        // action
        carstore.addCarReplica(_cid, _matchingId);

        // after add
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

    /// @dev assert reportCarReplicaExpired
    function reportCarReplicaExpiredAssertion(
        bytes32 _cid,
        uint64 _matchingId,
        uint64 _filecoinDealId
    ) external {
        // before report
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

        // action
        carstore.reportCarReplicaExpired(_cid, _matchingId, _filecoinDealId);

        // after report
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

    /// @dev assert reportCarReplicaSlashed
    function reportCarReplicaSlashedAssertion(
        bytes32 _cid,
        uint64 _matchingId,
        uint64 _filecoinDealId
    ) external {
        // before report
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

        // action
        carstore.reportCarReplicaSlashed(_cid, _matchingId, _filecoinDealId);

        // after report
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

    /// @dev assert setCarReplicaFilecoinDealId
    function setCarReplicaFilecoinDealIdAssertion(
        bytes32 _cid,
        uint64 _matchingId,
        uint64 _filecoinDealId
    ) external {
        // before set
        uint16 beforeReplicasCount = carstore.getCarReplicasCount(_cid);
        getCarReplicaFilecoinDealIdAssertion(_cid, _matchingId, 0);

        // action
        carstore.setCarReplicaFilecoinDealId(
            _cid,
            _matchingId,
            _filecoinDealId
        );

        // after set
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

    /// @dev assert getCarSize
    function getCarSizeAssertion(bytes32 _inputCid, uint64 _expectSize) public {
        assertEq(
            carstore.getCarSize(_inputCid),
            _expectSize,
            "car size not matched"
        );
    }

    /// @dev assert getCarDatasetId
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

    /// @dev assert getCarReplica
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

    /// @dev assert getCarReplicasCount
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

    /// @dev assert getCarReplicaFilecoinDealId
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

    /// @dev assert getCarReplicaState
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

    /// @dev assert hasCar
    function hasCarAssertion(bytes32 _inputCid, bool _expectIfExist) public {
        assertEq(
            carstore.hasCar(_inputCid),
            _expectIfExist,
            "has car not matched"
        );
    }

    /// @dev assert hasCarReplica
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

    /// @dev assert hasCars
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

    /// @dev assert carsCount
    function carsCounAssertiont(uint64 _expectCout) public {
        assertEq(carstore.carsCount(), _expectCout, "cars count not matched");
    }
}
