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

import {Test} from "forge-std/Test.sol";
import {CarstoreTestBase} from "test/v0.8/testcases/core/carstore/abstract/CarstoreTestBase.sol";

import {ICarstore} from "src/v0.8/interfaces/core/ICarstore.sol";
import {ICarstoreAssertion} from "test/v0.8/interfaces/assertions/core/ICarstoreAssertion.sol";

/// @title AddCarTestSuiteBase
/// @dev Base contract for test suites related to adding a single car to the carstore.
abstract contract AddCarTestSuiteBase is CarstoreTestBase, Test {
    constructor(
        ICarstore _carstore,
        ICarstoreAssertion _assertion
    ) CarstoreTestBase(_carstore, _assertion) {}

    /// @dev Called before running the test to set up the test scenario.
    /// @param _hash The content hash of the car to be added.
    /// @param _datasetId The dataset ID for the car.
    /// @param _size The size of the car.
    /// @param _replicaCount count of car's replicas
    function before(
        bytes32 _hash,
        uint64 _datasetId,
        uint64 _size,
        uint16 _replicaCount
    ) internal virtual;

    /// @dev The main action of the test, where the car is added to the carstore.
    /// @param _hash The content hash of the car to be added.
    /// @param _datasetId The dataset ID for the car.
    /// @param _size The size of the car.
    /// @param _replicaCount count of car's replicas
    function action(
        bytes32 _hash,
        uint64 _datasetId,
        uint64 _size,
        uint16 _replicaCount
    ) internal virtual {
        assertion.addCarAssertion(_hash, _datasetId, _size, _replicaCount);
    }

    /// @dev Called after running the test to perform any necessary cleanup or validation.
    /// @param _hash The content ID of the car that was added.
    /// @param _datasetId The dataset ID for the car.
    /// @param _size The size of the car.
    /// @param _replicaCount count of car's replicas
    function after_(
        bytes32 _hash,
        uint64 _datasetId,
        uint64 _size,
        uint16 _replicaCount
    ) internal virtual {}

    /// @dev Runs the test to add a car to the carstore.
    /// @param _hash The content hash of the car to be added.
    /// @param _datasetId The dataset ID for the car.
    /// @param _size The size of the car.
    /// @param _replicaCount count of car's replicas
    function run(
        bytes32 _hash,
        uint64 _datasetId,
        uint64 _size,
        uint16 _replicaCount
    ) public {
        before(_hash, _datasetId, _size, _replicaCount);
        action(_hash, _datasetId, _size, _replicaCount);
        after_(_hash, _datasetId, _size, _replicaCount);
    }
}

/// @title AddCarsTestSuiteBase
/// @dev Base contract for test suites related to adding multiple cars to the carstore.
abstract contract AddCarsTestSuiteBase is CarstoreTestBase, Test {
    constructor(
        ICarstore _carstore,
        ICarstoreAssertion _assertion
    ) CarstoreTestBase(_carstore, _assertion) {}

    /// @dev Called before running the test to set up the test scenario.
    /// @param _hashs The content hashs of the cars to be added.
    /// @param _datasetId The dataset ID for the cars.
    /// @param _sizes The sizes of the cars.
    /// @param _replicaCount count of car's replicas
    function before(
        bytes32[] memory _hashs,
        uint64 _datasetId,
        uint64[] memory _sizes,
        uint16 _replicaCount
    ) internal virtual;

    /// @dev The main action of the test, where the cars are added to the carstore.
    /// @param _hashs The content hashs of the cars to be added.
    /// @param _datasetId The dataset ID for the cars.
    /// @param _sizes The sizes of the cars.
    /// @param _replicaCount count of car's replicas
    function action(
        bytes32[] memory _hashs,
        uint64 _datasetId,
        uint64[] memory _sizes,
        uint16 _replicaCount
    ) internal virtual {
        assertion.addCarsAssertion(_hashs, _datasetId, _sizes, _replicaCount);
    }

    /// @dev Called after running the test to perform any necessary cleanup or validation.
    /// @param _hashs The content hashs of the cars that were added.
    /// @param _datasetId The dataset ID for the cars.
    /// @param _sizes The sizes of the cars.
    /// @param _replicaCount count of car's replicas
    function after_(
        bytes32[] memory _hashs,
        uint64 _datasetId,
        uint64[] memory _sizes,
        uint16 _replicaCount
    ) internal virtual {}

    /// @dev Runs the test to add multiple cars to the carstore.
    /// @param _hashs The content hashs of the cars to be added.
    /// @param _datasetId The dataset ID for the cars.
    /// @param _sizes The sizes of the cars.
    /// @param _replicaCount count of car's replicas
    function run(
        bytes32[] memory _hashs,
        uint64 _datasetId,
        uint64[] memory _sizes,
        uint16 _replicaCount
    ) public {
        before(_hashs, _datasetId, _sizes, _replicaCount);
        action(_hashs, _datasetId, _sizes, _replicaCount);
        after_(_hashs, _datasetId, _sizes, _replicaCount);
    }
}

/// @title RegistCarReplicaTestSuiteBase
/// @dev Base contract for test suites related to adding a car replica to the carstore.
abstract contract RegistCarReplicaTestSuiteBase is CarstoreTestBase, Test {
    constructor(
        ICarstore _carstore,
        ICarstoreAssertion _assertion
    ) CarstoreTestBase(_carstore, _assertion) {}

    /// @dev Called before running the test to set up the test scenario.
    /// @param _hash The content ID of the car replica to be added.
    /// @param _matchingId The matching ID of the car replica.
    /// @param _replicaIndex The index of the replica.
    function before(
        bytes32 _hash,
        uint64 _matchingId,
        uint16 _replicaIndex
    ) internal virtual returns (uint64);

    /// @dev The main action of the test, where the car replica is added to the carstore.
    /// @param _id The content ID of the car replica to be added.
    /// @param _matchingId The matching ID of the car replica.
    /// @param _replicaIndex The index of the replica.
    function action(
        uint64 _id,
        uint64 _matchingId,
        uint16 _replicaIndex
    ) internal virtual {
        assertion.registCarReplicaAssertion(_id, _matchingId, _replicaIndex);
    }

    /// @dev Called after running the test to perform any necessary cleanup or validation.
    /// @param _id The content ID of the car replica that was added.
    /// @param _matchingId The matching ID of the car replica.
    /// @param _replicaIndex The index of the replica.
    function after_(
        uint64 _id,
        uint64 _matchingId,
        uint16 _replicaIndex // solhint-disable-next-line
    ) internal virtual {}

    /// @dev Runs the test to add a car replica to the carstore.
    /// @param _hash The content ID of the car replica to be added.
    /// @param _matchingId The matching ID of the car replica.
    /// @param _replicaIndex The index of the replica.
    function run(
        bytes32 _hash,
        uint64 _matchingId,
        uint16 _replicaIndex
    ) public {
        uint64 _id = before(_hash, _matchingId, _replicaIndex);
        action(_id, _matchingId, _replicaIndex);
        after_(_id, _matchingId, _replicaIndex);
    }
}

/// @title AddCarReplicaTestSuiteBase
/// @dev Base contract for test suites related to adding a car replica to the carstore.
abstract contract ReportCarReplicaMatchingStateTestSuiteBase is
    CarstoreTestBase,
    Test
{
    constructor(
        ICarstore _carstore,
        ICarstoreAssertion _assertion
    ) CarstoreTestBase(_carstore, _assertion) {}

    /// @dev Called before running the test to set up the test scenario.
    /// @param _hash The content hash of the car replica to be added.
    /// @param _datasetId The dataset ID of the car replica.
    /// @param _size The size of the car replica.
    /// @param _matchingId The matching ID of the car replica.
    /// @param _replicaIndex The index of the replica.
    function before(
        bytes32 _hash,
        uint64 _datasetId,
        uint64 _size,
        uint64 _matchingId,
        uint16 _replicaIndex
    ) internal virtual returns (uint64);

    /// @dev The main action of the test, where the car replica is added to the carstore.
    /// @param _id The content ID of the car replica to be added.
    /// @param _matchingId The matching ID of the car replica.
    /// @param _matchingState The state of the matching.
    function action(
        uint64 _id,
        uint64 _matchingId,
        bool _matchingState
    ) internal virtual {
        assertion.reportCarReplicaMatchingStateAssertion(
            _id,
            _matchingId,
            _matchingState
        );
    }

    /// @dev Called after running the test to perform any necessary cleanup or validation.
    /// @param _id The content ID of the car replica that was added.
    /// @param _matchingId The matching ID of the car replica.
    /// @param _replicaIndex The index of the replica.
    /// @param _matchingState The state of the matching.
    function after_(
        uint64 _id,
        uint64 _matchingId,
        uint16 _replicaIndex,
        bool _matchingState
    ) internal virtual {}

    /// @dev Runs the test to add a car replica to the carstore.
    /// @param _hash The content hash of the car replica to be added.
    /// @param _datasetId The dataset ID of the car replica.
    /// @param _size The size of the car replica.
    /// @param _matchingId The matching ID of the car replica.
    /// @param _replicaIndex The index of the replica.
    /// @param _matchingState The state of the matching.
    function run(
        bytes32 _hash,
        uint64 _datasetId,
        uint64 _size,
        uint64 _matchingId,
        uint16 _replicaIndex,
        bool _matchingState
    ) public {
        uint64 _id = before(
            _hash,
            _datasetId,
            _size,
            _matchingId,
            _replicaIndex
        );
        action(_id, _matchingId, _matchingState);
        after_(_id, _matchingId, _replicaIndex, _matchingState);
    }
}

/// @title FilecoinClaimIdTestSuiteBase
/// @dev Base contract for test suites related to Filecoin claim IDs in the carstore.
abstract contract FilecoinClaimIdTestSuiteBase is CarstoreTestBase, Test {
    constructor(
        ICarstore _carstore,
        ICarstoreAssertion _assertion
    ) CarstoreTestBase(_carstore, _assertion) {}

    /// @dev Called before running the test to set up the test scenario.
    /// @param _hash The content ID of the car replica.
    /// @param _datasetId The dataset ID of the car replica.
    /// @param _size The size of the car replica.
    /// @param _matchingId The matching ID of the car replica.
    /// @param _claimId The Filecoin claim ID associated with the car replica.
    function before(
        bytes32 _hash,
        uint64 _datasetId,
        uint64 _size,
        uint64 _matchingId,
        uint64 _claimId
    ) internal virtual returns (uint64);

    /// @dev The main action of the test, where a Filecoin claim ID is processed.
    /// @param _id The content ID of the car replica.
    /// @param _matchingId The matching ID of the car replica.
    /// @param _claimId The Filecoin claim ID to be processed.
    function action(
        uint64 _id,
        uint64 _matchingId,
        uint64 _claimId
    ) internal virtual;

    /// @dev Called after running the test to perform any necessary cleanup or validation.
    /// @param _id The content ID of the car replica.
    /// @param _datasetId The dataset ID of the car replica.
    /// @param _size The size of the car replica.
    /// @param _matchingId The matching ID of the car replica.
    /// @param _claimId The Filecoin claim ID associated with the car replica.
    function after_(
        uint64 _id,
        uint64 _datasetId,
        uint64 _size,
        uint64 _matchingId,
        uint64 _claimId // solhint-disable-next-line
    ) internal virtual {}

    /// @dev Runs the test to process a Filecoin claim ID in the carstore.
    /// @param _hash The content Hash of the car replica.
    /// @param _datasetId The dataset ID of the car replica.
    /// @param _size The size of the car replica.
    /// @param _matchingId The matching ID of the car replica.
    /// @param _claimId The Filecoin claim ID to be processed.
    function run(
        bytes32 _hash,
        uint64 _datasetId,
        uint64 _size,
        uint64 _matchingId,
        uint64 _claimId
    ) public {
        uint64 _id = before(_hash, _datasetId, _size, _matchingId, _claimId);
        action(_id, _matchingId, _claimId);
        after_(_id, _datasetId, _size, _matchingId, _claimId);
    }
}

/// @title ReportCarReplicaExpiredTestSuiteBase
/// @dev Base contract for test suites related to reporting an expired car replica in the carstore.
abstract contract ReportCarReplicaExpiredTestSuiteBase is
    FilecoinClaimIdTestSuiteBase
{
    constructor(
        ICarstore _carstore,
        ICarstoreAssertion _assertion
    ) FilecoinClaimIdTestSuiteBase(_carstore, _assertion) {}

    /// @dev The main action of the test, where a car replica is reported as expired.
    /// @param _id The content ID of the car replica.
    /// @param _matchingId The matching ID of the car replica.
    /// @param _claimId The Filecoin claim ID associated with the car replica.
    function action(
        uint64 _id,
        uint64 _matchingId,
        uint64 _claimId
    ) internal virtual override {
        assertion.reportCarReplicaExpiredAssertion(_id, _matchingId, _claimId);
    }
}

/// @title ReportCarReplicaSlashedTestSuiteBase
/// @dev Base contract for test suites related to reporting a slashed car replica in the carstore.
abstract contract ReportCarReplicaSlashedTestSuiteBase is
    FilecoinClaimIdTestSuiteBase
{
    constructor(
        ICarstore _carstore,
        ICarstoreAssertion _assertion
    ) FilecoinClaimIdTestSuiteBase(_carstore, _assertion) {}

    /// @dev The main action of the test, where a car replica is reported as slashed.
    /// @param _id The content ID of the car replica.
    /// @param _matchingId The matching ID of the car replica.
    /// @param _claimId The Filecoin claim ID associated with the car replica.
    function action(
        uint64 _id,
        uint64 _matchingId,
        uint64 _claimId
    ) internal virtual override {
        assertion.reportCarReplicaSlashedAssertion(_id, _matchingId, _claimId);
    }
}

/// @title SetCarReplicaFilecoinClaimIdAssertionTestSuiteBase
/// @dev Base contract for test suites related to setting a Filecoin claim ID for a car replica in the carstore.
abstract contract SetCarReplicaFilecoinClaimIdAssertionTestSuiteBase is
    FilecoinClaimIdTestSuiteBase
{
    constructor(
        ICarstore _carstore,
        ICarstoreAssertion _assertion
    ) FilecoinClaimIdTestSuiteBase(_carstore, _assertion) {}

    /// @dev The main action of the test, where a Filecoin claim ID is set for a car replica.
    /// @param _id The content ID of the car replica.
    /// @param _matchingId The matching ID of the car replica.
    /// @param _claimId The Filecoin claim ID to be set for the car replica.
    function action(
        uint64 _id,
        uint64 _matchingId,
        uint64 _claimId
    ) internal virtual override {
        assertion.setCarReplicaFilecoinClaimIdAssertion(
            _id,
            _matchingId,
            _claimId
        );
    }
}
