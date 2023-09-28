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
    /// @param _cid The content ID of the car to be added.
    /// @param _datasetId The dataset ID for the car.
    /// @param _size The size of the car.
    function before(
        bytes32 _cid,
        uint64 _datasetId,
        uint64 _size
    ) internal virtual;

    /// @dev The main action of the test, where the car is added to the carstore.
    /// @param _cid The content ID of the car to be added.
    /// @param _datasetId The dataset ID for the car.
    /// @param _size The size of the car.
    function action(
        bytes32 _cid,
        uint64 _datasetId,
        uint64 _size
    ) internal virtual {
        assertion.addCarAssertion(_cid, _datasetId, _size);
    }

    /// @dev Called after running the test to perform any necessary cleanup or validation.
    /// @param _cid The content ID of the car that was added.
    /// @param _datasetId The dataset ID for the car.
    /// @param _size The size of the car.
    function after_(
        bytes32 _cid,
        uint64 _datasetId,
        uint64 _size
    ) internal virtual {}

    /// @dev Runs the test to add a car to the carstore.
    /// @param _cid The content ID of the car to be added.
    /// @param _datasetId The dataset ID for the car.
    /// @param _size The size of the car.
    function run(bytes32 _cid, uint64 _datasetId, uint64 _size) public {
        before(_cid, _datasetId, _size);
        action(_cid, _datasetId, _size);
        after_(_cid, _datasetId, _size);
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
    /// @param _cids The content IDs of the cars to be added.
    /// @param _datasetId The dataset ID for the cars.
    /// @param _sizes The sizes of the cars.
    function before(
        bytes32[] memory _cids,
        uint64 _datasetId,
        uint64[] memory _sizes
    ) internal virtual;

    /// @dev The main action of the test, where the cars are added to the carstore.
    /// @param _cids The content IDs of the cars to be added.
    /// @param _datasetId The dataset ID for the cars.
    /// @param _sizes The sizes of the cars.
    function action(
        bytes32[] memory _cids,
        uint64 _datasetId,
        uint64[] memory _sizes
    ) internal virtual {
        assertion.addCarsAssertion(_cids, _datasetId, _sizes);
    }

    /// @dev Called after running the test to perform any necessary cleanup or validation.
    /// @param _cids The content IDs of the cars that were added.
    /// @param _datasetId The dataset ID for the cars.
    /// @param _sizes The sizes of the cars.
    function after_(
        bytes32[] memory _cids,
        uint64 _datasetId,
        uint64[] memory _sizes
    ) internal virtual {}

    /// @dev Runs the test to add multiple cars to the carstore.
    /// @param _cids The content IDs of the cars to be added.
    /// @param _datasetId The dataset ID for the cars.
    /// @param _sizes The sizes of the cars.
    function run(
        bytes32[] memory _cids,
        uint64 _datasetId,
        uint64[] memory _sizes
    ) public {
        before(_cids, _datasetId, _sizes);
        action(_cids, _datasetId, _sizes);
        after_(_cids, _datasetId, _sizes);
    }
}

/// @title AddCarReplicaTestSuiteBase
/// @dev Base contract for test suites related to adding a car replica to the carstore.
abstract contract AddCarReplicaTestSuiteBase is CarstoreTestBase, Test {
    constructor(
        ICarstore _carstore,
        ICarstoreAssertion _assertion
    ) CarstoreTestBase(_carstore, _assertion) {}

    /// @dev Called before running the test to set up the test scenario.
    /// @param _cid The content ID of the car replica to be added.
    /// @param _matchingId The matching ID of the car replica.
    function before(bytes32 _cid, uint64 _matchingId) internal virtual;

    /// @dev The main action of the test, where the car replica is added to the carstore.
    /// @param _cid The content ID of the car replica to be added.
    /// @param _matchingId The matching ID of the car replica.
    function action(bytes32 _cid, uint64 _matchingId) internal virtual {
        assertion.addCarReplicaAssertion(_cid, _matchingId);
    }

    /// @dev Called after running the test to perform any necessary cleanup or validation.
    /// @param _cid The content ID of the car replica that was added.
    /// @param _matchingId The matching ID of the car replica.
    function after_(
        bytes32 _cid,
        uint64 _matchingId // solhint-disable-next-line
    ) internal virtual {}

    /// @dev Runs the test to add a car replica to the carstore.
    /// @param _cid The content ID of the car replica to be added.
    /// @param _matchingId The matching ID of the car replica.
    function run(bytes32 _cid, uint64 _matchingId) public {
        before(_cid, _matchingId);
        action(_cid, _matchingId);
        after_(_cid, _matchingId);
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
    /// @param _cid The content ID of the car replica.
    /// @param _datasetId The dataset ID of the car replica.
    /// @param _size The size of the car replica.
    /// @param _matchingId The matching ID of the car replica.
    /// @param _claimId The Filecoin claim ID associated with the car replica.
    function before(
        bytes32 _cid,
        uint64 _datasetId,
        uint64 _size,
        uint64 _matchingId,
        uint64 _claimId
    ) internal virtual;

    /// @dev The main action of the test, where a Filecoin claim ID is processed.
    /// @param _cid The content ID of the car replica.
    /// @param _matchingId The matching ID of the car replica.
    /// @param _claimId The Filecoin claim ID to be processed.
    function action(
        bytes32 _cid,
        uint64 _matchingId,
        uint64 _claimId
    ) internal virtual;

    /// @dev Called after running the test to perform any necessary cleanup or validation.
    /// @param _cid The content ID of the car replica.
    /// @param _datasetId The dataset ID of the car replica.
    /// @param _size The size of the car replica.
    /// @param _matchingId The matching ID of the car replica.
    /// @param _claimId The Filecoin claim ID associated with the car replica.
    function after_(
        bytes32 _cid,
        uint64 _datasetId,
        uint64 _size,
        uint64 _matchingId,
        uint64 _claimId // solhint-disable-next-line
    ) internal virtual {}

    /// @dev Runs the test to process a Filecoin claim ID in the carstore.
    /// @param _cid The content ID of the car replica.
    /// @param _datasetId The dataset ID of the car replica.
    /// @param _size The size of the car replica.
    /// @param _matchingId The matching ID of the car replica.
    /// @param _claimId The Filecoin claim ID to be processed.
    function run(
        bytes32 _cid,
        uint64 _datasetId,
        uint64 _size,
        uint64 _matchingId,
        uint64 _claimId
    ) public {
        before(_cid, _datasetId, _size, _matchingId, _claimId);
        action(_cid, _matchingId, _claimId);
        after_(_cid, _datasetId, _size, _matchingId, _claimId);
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
    /// @param _cid The content ID of the car replica.
    /// @param _matchingId The matching ID of the car replica.
    /// @param _claimId The Filecoin claim ID associated with the car replica.
    function action(
        bytes32 _cid,
        uint64 _matchingId,
        uint64 _claimId
    ) internal virtual override {
        assertion.reportCarReplicaExpiredAssertion(_cid, _matchingId, _claimId);
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
    /// @param _cid The content ID of the car replica.
    /// @param _matchingId The matching ID of the car replica.
    /// @param _claimId The Filecoin claim ID associated with the car replica.
    function action(
        bytes32 _cid,
        uint64 _matchingId,
        uint64 _claimId
    ) internal virtual override {
        assertion.reportCarReplicaSlashedAssertion(_cid, _matchingId, _claimId);
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
    /// @param _cid The content ID of the car replica.
    /// @param _matchingId The matching ID of the car replica.
    /// @param _claimId The Filecoin claim ID to be set for the car replica.
    function action(
        bytes32 _cid,
        uint64 _matchingId,
        uint64 _claimId
    ) internal virtual override {
        assertion.setCarReplicaFilecoinClaimIdAssertion(
            _cid,
            _matchingId,
            _claimId
        );
    }
}
