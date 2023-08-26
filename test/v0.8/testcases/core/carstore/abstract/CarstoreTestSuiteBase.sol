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

/// @dev add car test suite
abstract contract AddCarTestSuiteBase is CarstoreTestBase, Test {
    constructor(
        ICarstore _carstore,
        ICarstoreAssertion _assertion
    )
        CarstoreTestBase(_carstore, _assertion) // solhint-disable-next-line
    {}

    function before(
        bytes32 _cid,
        uint64 _datasetId,
        uint64 _size
    ) internal virtual;

    function action(
        bytes32 _cid,
        uint64 _datasetId,
        uint64 _size
    ) internal virtual {
        assertion.addCarAssertion(_cid, _datasetId, _size);
    }

    function after_(
        bytes32 _cid,
        uint64 _datasetId,
        uint64 _size // solhint-disable-next-line
    ) internal virtual {}

    function run(bytes32 _cid, uint64 _datasetId, uint64 _size) public {
        before(_cid, _datasetId, _size);
        action(_cid, _datasetId, _size);
        after_(_cid, _datasetId, _size);
    }
}

/// @dev adds car test suite
abstract contract AddCarsTestSuiteBase is CarstoreTestBase, Test {
    constructor(
        ICarstore _carstore,
        ICarstoreAssertion _assertion
    )
        CarstoreTestBase(_carstore, _assertion) // solhint-disable-next-line
    {}

    function before(
        bytes32[] memory _cids,
        uint64 _datasetId,
        uint64[] memory _sizes
    ) internal virtual;

    function action(
        bytes32[] memory _cids,
        uint64 _datasetId,
        uint64[] memory _sizes
    ) internal virtual {
        assertion.addCarsAssertion(_cids, _datasetId, _sizes);
    }

    function after_(
        bytes32[] memory _cids,
        uint64 _datasetId,
        uint64[] memory _sizes // solhint-disable-next-line
    ) internal virtual {}

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

/// @dev adds car replica test suite
abstract contract AddCarReplicaTestSuiteBase is CarstoreTestBase, Test {
    constructor(
        ICarstore _carstore,
        ICarstoreAssertion _assertion
    )
        CarstoreTestBase(_carstore, _assertion) // solhint-disable-next-line
    {}

    function before(bytes32 _cid, uint64 _matchingId) internal virtual;

    function action(bytes32 _cid, uint64 _matchingId) internal virtual {
        assertion.addCarReplicaAssertion(_cid, _matchingId);
    }

    function after_(
        bytes32 _cid,
        uint64 _matchingId // solhint-disable-next-line
    ) internal virtual {}

    function run(bytes32 _cid, uint64 _matchingId) public {
        before(_cid, _matchingId);
        action(_cid, _matchingId);
        after_(_cid, _matchingId);
    }
}

/// @dev filecoin deal id process test suite,
/// and ReportCarReplicaExpiredTestSuiteBase,ReportCarReplicaSlashedTestSuiteBase, SetCarReplicaFilecoinDealIdAssertionTestSuiteBase
///     all base FilecoinDealIdTestSuiteBase
abstract contract FilecoinDealIdTestSuiteBase is CarstoreTestBase, Test {
    constructor(
        ICarstore _carstore,
        ICarstoreAssertion _assertion
    )
        CarstoreTestBase(_carstore, _assertion) // solhint-disable-next-line
    {}

    function before(
        bytes32 _cid,
        uint64 _datasetId,
        uint64 _size,
        uint64 _matchingId,
        uint64 _filecoinDealId
    ) internal virtual;

    function action(
        bytes32 _cid,
        uint64 _matchingId,
        uint64 _filecoinDealId
    ) internal virtual;

    function after_(
        bytes32 _cid,
        uint64 _datasetId,
        uint64 _size,
        uint64 _matchingId,
        uint64 _filecoinDealId // solhint-disable-next-line
    ) internal virtual {}

    function run(
        bytes32 _cid,
        uint64 _datasetId,
        uint64 _size,
        uint64 _matchingId,
        uint64 _filecoinDealId
    ) public {
        before(_cid, _datasetId, _size, _matchingId, _filecoinDealId);
        action(_cid, _matchingId, _filecoinDealId);
        after_(_cid, _datasetId, _size, _matchingId, _filecoinDealId);
    }
}

/// @dev report car replica expired test suite,
abstract contract ReportCarReplicaExpiredTestSuiteBase is
    FilecoinDealIdTestSuiteBase
{
    constructor(
        ICarstore _carstore,
        ICarstoreAssertion _assertion
    )
        FilecoinDealIdTestSuiteBase(_carstore, _assertion) // solhint-disable-next-line
    {}

    function action(
        bytes32 _cid,
        uint64 _matchingId,
        uint64 _filecoinDealId
    ) internal virtual override {
        assertion.reportCarReplicaExpiredAssertion(
            _cid,
            _matchingId,
            _filecoinDealId
        );
    }
}

/// @dev report car replica slashed test suite,
abstract contract ReportCarReplicaSlashedTestSuiteBase is
    FilecoinDealIdTestSuiteBase
{
    constructor(
        ICarstore _carstore,
        ICarstoreAssertion _assertion
    )
        FilecoinDealIdTestSuiteBase(_carstore, _assertion) // solhint-disable-next-line
    {}

    function action(
        bytes32 _cid,
        uint64 _matchingId,
        uint64 _filecoinDealId
    ) internal virtual override {
        assertion.reportCarReplicaSlashedAssertion(
            _cid,
            _matchingId,
            _filecoinDealId
        );
    }
}

/// @dev set car replica filecoin deal Id test suite,
abstract contract SetCarReplicaFilecoinDealIdAssertionTestSuiteBase is
    FilecoinDealIdTestSuiteBase
{
    constructor(
        ICarstore _carstore,
        ICarstoreAssertion _assertion
    )
        FilecoinDealIdTestSuiteBase(_carstore, _assertion) // solhint-disable-next-line
    {}

    function action(
        bytes32 _cid,
        uint64 _matchingId,
        uint64 _filecoinDealId
    ) internal virtual override {
        assertion.setCarReplicaFilecoinDealIdAssertion(
            _cid,
            _matchingId,
            _filecoinDealId
        );
    }
}
