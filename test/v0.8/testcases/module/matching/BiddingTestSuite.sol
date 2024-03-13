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

import {Errors} from "src/v0.8/shared/errors/Errors.sol";
import {MatchingsTestBase} from "test/v0.8/testcases/module/matching/abstract/MatchingsTestBase.sol";
import {ControlTestSuiteBase} from "test/v0.8/testcases/module/matching/abstract/ControlTestSuiteBase.sol";
import {IMatchings} from "src/v0.8/interfaces/module/IMatchings.sol";
import {IMatchingsTarget} from "src/v0.8/interfaces/module/IMatchingsTarget.sol";
import {IMatchingsBids} from "src/v0.8/interfaces/module/IMatchingsBids.sol";
import {IMatchingsAssertion} from "test/v0.8/interfaces/assertions/module/IMatchingsAssertion.sol";
import {IMatchingsHelpers} from "test/v0.8/interfaces/helpers/module/IMatchingsHelpers.sol";
import {MatchingType} from "src/v0.8/types/MatchingType.sol";
import {DatasetType} from "src/v0.8/types/DatasetType.sol";
import {RolesType} from "src/v0.8/types/RolesType.sol";
import {MatchingsEvents} from "src/v0.8/shared/events/MatchingsEvents.sol";

///@notice bidding matching test case with success
contract BiddingTestCaseWithSuccess is ControlTestSuiteBase {
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
        vm.assume(_amount >= 100);
        return super.before(_bidRule, _amount);
    }

    function action(
        uint64 _matchingId,
        uint64 _amount
    ) internal virtual override {
        vm.expectEmit(true, true, true, true);
        emit MatchingsEvents.MatchingBidPlaced(
            _matchingId,
            address(199),
            _amount
        );
        matchingsAssertion.biddingAssertion(address(199), _matchingId, _amount);
    }
}

///@notice bidding matching test case with invalid amount
contract BiddingTestCaseWithInvlalidAmount is ControlTestSuiteBase {
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
        if (
            _bidRule == MatchingType.BidSelectionRule.HighestBid ||
            _bidRule == MatchingType.BidSelectionRule.ImmediateAtLeast
        ) {
            vm.assume(_amount < 100);
        } else {
            vm.assume(_amount > 100);
        }

        return super.before(_bidRule, _amount);
    }

    function action(
        uint64 _matchingId,
        uint64 _amount
    ) internal virtual override {
        vm.expectRevert(bytes("Invalid amount"));
        matchingsAssertion.biddingAssertion(address(199), _matchingId, _amount);
    }
}

///@notice bidding matching test case with duplicate bid
contract BiddingTestCaseWithInvlalidDuplicateBid is ControlTestSuiteBase {
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
        vm.assume(_amount >= 100);
        return super.before(_bidRule, _amount);
    }

    function action(
        uint64 _matchingId,
        uint64 _amount
    ) internal virtual override {
        matchingsAssertion.biddingAssertion(address(199), _matchingId, _amount);
        vm.prank(address(199));
        vm.deal(address(199), 200 ether);
        vm.expectRevert(bytes("Invalid amount"));
        matchingsBids.bidding{value: _amount}(_matchingId, _amount);
    }
}

///@notice bidding matching test case with invalid State
contract BiddingTestCaseWithInvlalidState is ControlTestSuiteBase {
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
        vm.assume(_amount >= 100);
        uint64 datasetId = matchingsHelpers.setup("testAccessMethod", 100, 10);

        matchingsAssertion.createMatchingAssertion(
            address(99),
            datasetId,
            _bidRule,
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

    function action(
        uint64 _matchingId,
        uint64 _amount
    ) internal virtual override {
        vm.expectRevert(
            abi.encodeWithSelector(
                Errors.InvalidMatchingState.selector,
                _matchingId,
                MatchingType.State.InProgress,
                MatchingType.State.None
            )
        );
        matchingsAssertion.biddingAssertion(address(199), _matchingId, _amount);
    }
}

///@notice bidding matching test case with bid not start
contract BiddingTestCaseWithNotStart is ControlTestSuiteBase {
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
        vm.assume(_amount >= 100);
        return super.before(_bidRule, _amount);
    }

    function action(
        uint64 _matchingId,
        uint64 _amount
    ) internal virtual override {
        vm.roll(80);
        vm.expectRevert(bytes("Matching: Bidding is not start"));
        matchingsAssertion.biddingAssertion(address(199), _matchingId, _amount);
    }
}

///@notice bidding matching test case with bid is end
contract BiddingTestCaseWithBidIsEnd is ControlTestSuiteBase {
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
        vm.assume(_amount >= 100);
        return super.before(_bidRule, _amount);
    }

    function action(
        uint64 _matchingId,
        uint64 _amount
    ) internal virtual override {
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
        vm.expectRevert(bytes("Matching: Bidding is end"));
        matchingsAssertion.biddingAssertion(address(199), _matchingId, _amount);
    }
}

///@notice bidding matching test case with invalid submitter
contract BiddingTestCaseWithInvalidStorageProvider is ControlTestSuiteBase {
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
        vm.assume(_amount >= 100);
        return super.before(_bidRule, _amount);
    }

    function action(
        uint64 _matchingId,
        uint64 _amount
    ) internal virtual override {
        vm.expectRevert(bytes("Invalid SP submitter"));
        matchingsAssertion.biddingAssertion(address(200), _matchingId, _amount);
    }
}
