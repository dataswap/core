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

import {ControlTestSuiteBase} from "test/v0.8/testcases/module/matching/abstract/ControlTestSuiteBase.sol";
import {MatchingsTestBase} from "test/v0.8/testcases/module/matching/abstract/MatchingsTestBase.sol";
import {IMatchings} from "src/v0.8/interfaces/module/IMatchings.sol";
import {IMatchingsTarget} from "src/v0.8/interfaces/module/IMatchingsTarget.sol";
import {IMatchingsBids} from "src/v0.8/interfaces/module/IMatchingsBids.sol";
import {IMatchingsAssertion} from "test/v0.8/interfaces/assertions/module/IMatchingsAssertion.sol";
import {IMatchingsHelpers} from "test/v0.8/interfaces/helpers/module/IMatchingsHelpers.sol";
import {DatasetType} from "src/v0.8/types/DatasetType.sol";
import {MatchingType} from "src/v0.8/types/MatchingType.sol";
import {RolesType} from "src/v0.8/types/RolesType.sol";
import {Errors} from "src/v0.8/shared/errors/Errors.sol";

///@notice close matching test case with success
contract CloseTestCaseWithSuccess is ControlTestSuiteBase {
    constructor(
        IMatchings _matchings,
        IMatchingsTarget _matchingsTarget,
        IMatchingsBids _matchingsBids,
        IMatchingsHelpers _matchingsHelpers,
        IMatchingsAssertion _matchingsAssertion
    )
        ControlTestSuiteBase(
            _matchings,
            _matchingsTarget,
            _matchingsBids,
            _matchingsHelpers,
            _matchingsAssertion
        ) // solhint-disable-next-line
    {}

    function before(
        MatchingType.BidSelectionRule _bidRule,
        uint64 _amount
    ) internal virtual override returns (uint64) {
        uint64 matchingId = super.before(_bidRule, _amount);
        vm.prank(address(199));
        vm.deal(address(199), 200 ether);
        matchingsBids.bidding{value: 200}(matchingId, 200);
        return matchingId;
    }

    function action(
        uint64 _matchingId,
        uint64 /*_amount*/
    ) internal virtual override {
        address initiator = matchings.getMatchingInitiator(_matchingId);
        (
            ,
            uint64 biddingDelayBlockCount,
            uint64 biddingPeriodBlockCount,
            ,
            ,
            uint64 createdBlockNumber,
            ,
            ,
            uint64 pausedBlockCount
        ) = matchings.getMatchingMetadata(_matchingId);
        vm.roll(
            biddingDelayBlockCount +
                biddingPeriodBlockCount +
                createdBlockNumber +
                pausedBlockCount
        );
        matchingsAssertion.closeMatchingAssertion(
            initiator,
            _matchingId,
            address(199)
        );
    }
}

///@notice cancel matching test case with invalid state
contract CloseTestCaseWithInvalidState is MatchingsTestBase {
    constructor(
        IMatchings _matchings,
        IMatchingsTarget _matchingsTarget,
        IMatchingsBids _matchingsBids,
        IMatchingsHelpers _matchingsHelpers,
        IMatchingsAssertion _matchingsAssertion
    )
        MatchingsTestBase(
            _matchings,
            _matchingsTarget,
            _matchingsBids,
            _matchingsHelpers,
            _matchingsAssertion
        ) // solhint-disable-next-line
    {}

    function before() internal virtual override returns (uint64) {
        uint64 datasetId = matchingsHelpers.setup("testAccessMethod", 100, 10);
        matchingsAssertion.createMatchingAssertion(
            address(99),
            datasetId,
            MatchingType.BidSelectionRule.HighestBid,
            100,
            100,
            1000,
            100,
            0,
            "TEST"
        );
        uint64 matchingId = matchings.matchingsCount();

        matchingsAssertion.createTargetAssertion(
            address(99),
            matchingId,
            datasetId,
            DatasetType.DataType.MappingFiles,
            0,
            0
        );
        return matchingId;
    }

    function action(uint64 _matchingId) internal virtual override {
        address initiator = matchings.getMatchingInitiator(_matchingId);
        vm.roll(201);
        vm.expectRevert();
        matchingsAssertion.closeMatchingAssertion(
            initiator,
            _matchingId,
            address(199)
        );
    }
}

///@notice close matching test case with invalid block
contract CloseTestCaseWithAtInvalidBlock is ControlTestSuiteBase {
    constructor(
        IMatchings _matchings,
        IMatchingsTarget _matchingsTarget,
        IMatchingsBids _matchingsBids,
        IMatchingsHelpers _matchingsHelpers,
        IMatchingsAssertion _matchingsAssertion
    )
        ControlTestSuiteBase(
            _matchings,
            _matchingsTarget,
            _matchingsBids,
            _matchingsHelpers,
            _matchingsAssertion
        ) // solhint-disable-next-line
    {}

    function action(
        uint64 _matchingId,
        uint64 /*_amount*/
    ) internal virtual override {
        address initiator = matchings.getMatchingInitiator(_matchingId);
        vm.roll(20);

        vm.expectRevert();
        matchingsAssertion.closeMatchingAssertion(
            initiator,
            _matchingId,
            address(199)
        );
    }
}
