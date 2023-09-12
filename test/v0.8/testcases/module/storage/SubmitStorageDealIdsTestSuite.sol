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

import {Generator} from "test/v0.8/helpers/utils/Generator.sol";

import {IStorages} from "src/v0.8/interfaces/module/IStorages.sol";
import {IStoragesAssertion} from "test/v0.8/interfaces/assertions/module/IStoragesAssertion.sol";
import {IStoragesHelpers} from "test/v0.8/interfaces/helpers/module/IStoragesHelpers.sol";

/// NOTE: Exception test cases submit storage deal id already covered

///@notice submit storage filecoin deal ids test case with success
contract SubmitStorageDealIdsTestCaseWithSuccess is StoragesTestBase {
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
        uint64[] memory filecoinDealIds = storagesHelpers
            .generateFilecoinDealIds(uint64(cars.length));
        address winner = storages.matchings().getMatchingWinner(_matchingId);
        storagesAssertion.isAllStoredDoneAssertion(_matchingId, false);
        storagesAssertion.submitStorageDealIdsAssertion(
            winner,
            _matchingId,
            cars,
            filecoinDealIds
        );
        storagesAssertion.isAllStoredDoneAssertion(_matchingId, true);
    }
}
