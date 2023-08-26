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
import {StoragesTestBase} from "test/v0.8/testcases/module/storage/abstract/StoragesTestBase.sol";

import {IStorages} from "src/v0.8/interfaces/module/IStorages.sol";
import {IStoragesAssertion} from "test/v0.8/interfaces/assertions/module/IStoragesAssertion.sol";
import {IStoragesSetupHeplers} from "test/v0.8/interfaces/helpers/setup/IStoragesSetupHeplers.sol";

abstract contract SubmitStorageDealIdTestSuiteBase is StoragesTestBase, Test {
    constructor(
        IStorages _storages,
        IStoragesSetupHeplers _storagesSetupHelpers,
        IStoragesAssertion _storagesAssertion
    )
        StoragesTestBase(_storages, _storagesSetupHelpers, _storagesAssertion) // solhint-disable-next-line
    {}

    function before(
        uint64 _matchingId,
        bytes32 _cid,
        uint64 _filecoinDealId
    ) internal virtual;

    function action(
        uint64 _matchingId,
        bytes32 _cid,
        uint64 _filecoinDealId
    ) internal virtual {
        storagesAssertion.submitStorageDealIdAssertion(
            _matchingId,
            _cid,
            _filecoinDealId
        );
    }

    function after_(
        uint64 _matchingId,
        bytes32 _cid,
        uint64 _filecoinDealId // solhint-disable-next-line
    ) internal virtual {}

    function run(
        uint64 _matchingId,
        bytes32 _cid,
        uint64 _filecoinDealId
    ) public {
        before(_matchingId, _cid, _filecoinDealId);
        action(_matchingId, _cid, _filecoinDealId);
        after_(_matchingId, _cid, _filecoinDealId);
    }
}

abstract contract SubmitStorageDealIdsTestSuiteBase is StoragesTestBase, Test {
    constructor(
        IStorages _storages,
        IStoragesSetupHeplers _storagesSetupHelpers,
        IStoragesAssertion _datacapAssertion
    )
        StoragesTestBase(_storages, _storagesSetupHelpers, _datacapAssertion) // solhint-disable-next-line
    {}

    function before(
        uint64 _matchingId,
        bytes32[] memory _cids,
        uint64[] memory _filecoinDealIds
    ) internal virtual;

    function action(
        uint64 _matchingId,
        bytes32[] memory _cids,
        uint64[] memory _filecoinDealIds
    ) internal virtual {
        storagesAssertion.submitStorageDealIdsAssertion(
            _matchingId,
            _cids,
            _filecoinDealIds
        );
    }

    function after_(
        uint64 _matchingId,
        bytes32[] memory _cids,
        uint64[] memory _filecoinDealIds // solhint-disable-next-line
    ) internal virtual {}

    function run(
        uint64 _matchingId,
        bytes32[] memory _cids,
        uint64[] memory _filecoinDealIds
    ) public {
        before(_matchingId, _cids, _filecoinDealIds);
        action(_matchingId, _cids, _filecoinDealIds);
        after_(_matchingId, _cids, _filecoinDealIds);
    }
}
