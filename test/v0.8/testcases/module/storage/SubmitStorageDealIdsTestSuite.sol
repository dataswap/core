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

import {SubmitStorageDealIdsTestSuiteBase} from "test/v0.8/testcases/module/storage/abstract/StoragesTestSuiteBase.sol";

import {IStorages} from "src/v0.8/interfaces/module/IStorages.sol";
import {IStoragesAssertion} from "test/v0.8/interfaces/assertions/module/IStoragesAssertion.sol";
import {IStoragesSetupHeplers} from "test/v0.8/interfaces/helpers/setup/IStoragesSetupHeplers.sol";

import {MatchingType} from "src/v0.8/types/MatchingType.sol";
import {DatasetType} from "src/v0.8/types/DatasetType.sol";

contract SubmitStorageDealIdsTestCaseWithSuccess is
    SubmitStorageDealIdsTestSuiteBase
{
    constructor(
        IStorages _storages,
        IStoragesSetupHeplers _storagesSetupHelpers,
        IStoragesAssertion _storagesAssertion
    )
        SubmitStorageDealIdsTestSuiteBase(
            _storages,
            _storagesSetupHelpers,
            _storagesAssertion
        ) // solhint-disable-next-line
    {}

    function before(
        uint64 _matchingId,
        bytes32[] memory /*_cids*/,
        uint64[] memory /*_filecoinDealIds*/
    ) internal virtual override {
        (, _matchingId) = storagesSetupHelpers.setup(
            "testAccessMethod",
            DatasetType.DataType.MappingFiles,
            0,
            MatchingType.BidSelectionRule.HighestBid,
            100,
            100,
            100,
            100
        );
    }

    function action(
        uint64 _matchingId,
        bytes32[] memory _cids,
        uint64[] memory _filecoinDealIds
    ) internal virtual override {
        (, _cids /*uint64 size*/, , , ) = storages
            .matchings()
            .getMatchingTarget(_matchingId);
        vm.startPrank(storages.matchings().getMatchingWinner(_matchingId));
        super.action(_matchingId, _cids, _filecoinDealIds);
        vm.stopPrank();
    }
}
