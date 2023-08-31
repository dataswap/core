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

import {StoragesTestBase} from "test/v0.8/testcases/module/storage/abstract/StoragesTestBase.sol";

import {Errors} from "src/v0.8/shared/errors/Errors.sol";
import {Generator} from "test/v0.8/helpers/utils/Generator.sol";

import {IStorages} from "src/v0.8/interfaces/module/IStorages.sol";
import {IStoragesAssertion} from "test/v0.8/interfaces/assertions/module/IStoragesAssertion.sol";
import {IStoragesHelpers} from "test/v0.8/interfaces/helpers/module/IStoragesHelpers.sol";

import {MatchingType} from "src/v0.8/types/MatchingType.sol";
import {DatasetType} from "src/v0.8/types/DatasetType.sol";

///@notice submit storage filecoin deal id test case with success
contract SubmitStorageDealIdTestCaseWithSuccess is StoragesTestBase {
    constructor(
        IStorages _storages,
        Generator _generator,
        IStoragesHelpers _storagesHelpers,
        IStoragesAssertion _storagesAssertion
    )
        StoragesTestBase(
            _storages,
            _generator,
            _storagesHelpers,
            _storagesAssertion
        ) // solhint-disable-next-line
    {}

    function before() internal virtual override returns (uint64) {
        (, uint64 matchingId) = storagesHelpers.setup();
        return matchingId;
    }

    function action(uint64 _matchingId) internal virtual override {
        bytes32[] memory cars = storages.matchings().getMatchingCars(
            _matchingId
        );
        bytes32 cid = cars[0];
        uint64 filecoinDealId = storagesHelpers.generateFilecoinDealId();
        address winner = storages.matchings().getMatchingWinner(_matchingId);
        storagesAssertion.submitStorageDealIdAssertion(
            winner,
            _matchingId,
            cid,
            filecoinDealId
        );
    }
}

///@notice Submit storage filecoin deal id Already includes the switch of Replica Matched status, there is no need to test its abnormal conditions.

///@notice submit storage filecoin deal id test case with invalid address
contract SubmitStorageDealIdTestCaseWithInvalidAddress is StoragesTestBase {
    constructor(
        IStorages _storages,
        Generator _generator,
        IStoragesHelpers _storagesHelpers,
        IStoragesAssertion _storagesAssertion
    )
        StoragesTestBase(
            _storages,
            _generator,
            _storagesHelpers,
            _storagesAssertion
        ) // solhint-disable-next-line
    {}

    function before() internal virtual override returns (uint64) {
        (, uint64 matchingId) = storagesHelpers.setup();
        return matchingId;
    }

    function action(uint64 _matchingId) internal virtual override {
        bytes32[] memory cars = storages.matchings().getMatchingCars(
            _matchingId
        );
        bytes32 cid = cars[0];
        uint64 filecoinDealId = storagesHelpers.generateFilecoinDealId();
        address winner = generator.generateAddress(100);
        vm.expectRevert(bytes("Only allowed address can call"));
        storagesAssertion.submitStorageDealIdAssertion(
            winner,
            _matchingId,
            cid,
            filecoinDealId
        );
    }
}

///@notice submit storage filecoin deal id test case with invalid cid
contract SubmitStorageDealIdTestCaseWithInvalidCid is StoragesTestBase {
    constructor(
        IStorages _storages,
        Generator _generator,
        IStoragesHelpers _storagesHelpers,
        IStoragesAssertion _storagesAssertion
    )
        StoragesTestBase(
            _storages,
            _generator,
            _storagesHelpers,
            _storagesAssertion
        ) // solhint-disable-next-line
    {}

    function before() internal virtual override returns (uint64) {
        (, uint64 matchingId) = storagesHelpers.setup();
        return matchingId;
    }

    function action(uint64 _matchingId) internal virtual override {
        bytes32 cid = bytes32("0");
        uint64 filecoinDealId = storagesHelpers.generateFilecoinDealId();
        address winner = storages.matchings().getMatchingWinner(_matchingId);
        vm.expectRevert(
            abi.encodeWithSelector(
                Errors.ReplicaNotExist.selector,
                cid,
                _matchingId
            )
        );
        storagesAssertion.submitStorageDealIdAssertion(
            winner,
            _matchingId,
            cid,
            filecoinDealId
        );
    }
}

///@notice submit storage filecoin deal id test case with duplicate cid
contract SubmitStorageDealIdTestCaseWithDuplicateCid is StoragesTestBase {
    constructor(
        IStorages _storages,
        Generator _generator,
        IStoragesHelpers _storagesHelpers,
        IStoragesAssertion _storagesAssertion
    )
        StoragesTestBase(
            _storages,
            _generator,
            _storagesHelpers,
            _storagesAssertion
        ) // solhint-disable-next-line
    {}

    function before() internal virtual override returns (uint64) {
        (, uint64 matchingId) = storagesHelpers.setup();
        return matchingId;
    }

    function action(uint64 _matchingId) internal virtual override {
        bytes32[] memory cars = storages.matchings().getMatchingCars(
            _matchingId
        );
        bytes32 cid = cars[0];
        uint64 filecoinDealId = storagesHelpers.generateFilecoinDealId();
        address winner = storages.matchings().getMatchingWinner(_matchingId);
        storagesAssertion.submitStorageDealIdAssertion(
            winner,
            _matchingId,
            cid,
            filecoinDealId
        );
        vm.expectRevert(
            abi.encodeWithSelector(
                Errors.ReplicaFilecoinDealIdExists.selector,
                cid,
                _matchingId
            )
        );
        storagesAssertion.submitStorageDealIdAssertion(
            winner,
            _matchingId,
            cid,
            filecoinDealId
        );
    }
}
