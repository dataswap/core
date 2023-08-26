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

import {CancelTestSuiteBase} from "test/v0.8/testcases/module/matching/abstract/MatchingsTestSuiteBase.sol";

import {IMatchings} from "src/v0.8/interfaces/module/IMatchings.sol";
import {IMatchingsAssertion} from "test/v0.8/interfaces/assertions/module/IMatchingsAssertion.sol";
import {IMatchingsHelpers} from "test/v0.8/interfaces/helpers/module/IMatchingsHelpers.sol";
import {MatchingType} from "src/v0.8/types/MatchingType.sol";
import {DatasetType} from "src/v0.8/types/DatasetType.sol";
import {IRoles} from "src/v0.8/interfaces/core/IRoles.sol";
import {RolesType} from "src/v0.8/types/RolesType.sol";

contract CancelTestCaseWithSuccess is CancelTestSuiteBase {
    constructor(
        IMatchings _matchings,
        IMatchingsHelpers _matchingsHelpers,
        IMatchingsAssertion _matchingsAssertion
    )
        CancelTestSuiteBase(_matchings, _matchingsHelpers, _matchingsAssertion) // solhint-disable-next-line
    {}

    function before(uint64 _matchingId) internal virtual override {
        uint64 datasetId = matchingsHelpers.setup(
            "testAccessMethod",
            100,
            10,
            10,
            10
        );
        _matchingId = matchingsHelpers.publishMatching(
            datasetId,
            DatasetType.DataType.MappingFiles,
            0,
            MatchingType.BidSelectionRule.HighestBid,
            100,
            100,
            100,
            100,
            "TEST"
        );
    }
}

contract CancelTestCaseWithAtClosed is CancelTestSuiteBase {
    constructor(
        IMatchings _matchings,
        IMatchingsHelpers _matchingsHelpers,
        IMatchingsAssertion _matchingsAssertion
    )
        CancelTestSuiteBase(_matchings, _matchingsHelpers, _matchingsAssertion) // solhint-disable-next-line
    {}

    function before(uint64 _matchingId) internal virtual override {
        uint64 datasetId = matchingsHelpers.setup(
            "testAccessMethod",
            100,
            10,
            10,
            10
        );
        vm.roll(1);
        _matchingId = matchingsHelpers.publishMatching(
            datasetId,
            DatasetType.DataType.MappingFiles,
            0,
            MatchingType.BidSelectionRule.HighestBid,
            100,
            100,
            100,
            100,
            "TEST"
        );
    }

    function action(uint64 _matchingId) internal virtual override {
        vm.roll(201);
        vm.expectRevert();
        matchingsAssertion.resumeMatchingAssertion(_matchingId);
    }
}
