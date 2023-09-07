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

import {MatchingsTestBase} from "test/v0.8/testcases/module/matching/abstract/MatchingsTestBase.sol";
import {ControlTestSuiteBase} from "test/v0.8/testcases/module/matching/abstract/ControlTestSuiteBase.sol";
import {IMatchings} from "src/v0.8/interfaces/module/IMatchings.sol";
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
        IMatchingsHelpers _matchingsHelpers,
        IMatchingsAssertion _matchingsAssertion
    )
        ControlTestSuiteBase(_matchings, _matchingsHelpers, _matchingsAssertion) // solhint-disable-next-line
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
        address admin = matchings.datasets().roles().getRoleMember(
            bytes32(0x00),
            0
        );
        vm.startPrank(admin);
        matchings.datasets().roles().grantRole(
            RolesType.STORAGE_PROVIDER,
            address(100)
        );
        vm.stopPrank();
        vm.roll(101);

        vm.expectEmit(true, true, true, true);
        emit MatchingsEvents.MatchingBidPlaced(
            _matchingId,
            address(100),
            _amount
        );
        matchingsAssertion.biddingAssertion(address(100), _matchingId, _amount);
    }
}

///@notice bidding matching test case with invalid role
contract BiddingTestCaseWithInvlalidRole is ControlTestSuiteBase {
    constructor(
        IMatchings _matchings,
        IMatchingsHelpers _matchingsHelpers,
        IMatchingsAssertion _matchingsAssertion
    )
        ControlTestSuiteBase(_matchings, _matchingsHelpers, _matchingsAssertion) // solhint-disable-next-line
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
        uint64 amount
    ) internal virtual override {
        address admin = matchings.datasets().roles().getRoleMember(
            bytes32(0x00),
            0
        );
        vm.startPrank(admin);
        matchings.datasets().roles().revokeRole(
            RolesType.STORAGE_PROVIDER,
            address(100)
        );
        vm.stopPrank();
        vm.roll(101);
        vm.expectRevert(bytes("Only allowed role can call"));
        matchingsAssertion.biddingAssertion(address(100), _matchingId, amount);
    }
}

///@notice bidding matching test case with invalid amount
contract BiddingTestCaseWithInvlalidAmount is ControlTestSuiteBase {
    constructor(
        IMatchings _matchings,
        IMatchingsHelpers _matchingsHelpers,
        IMatchingsAssertion _matchingsAssertion
    )
        ControlTestSuiteBase(_matchings, _matchingsHelpers, _matchingsAssertion) // solhint-disable-next-line
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
        address admin = matchings.datasets().roles().getRoleMember(
            bytes32(0x00),
            0
        );
        vm.startPrank(admin);
        matchings.datasets().roles().grantRole(
            RolesType.STORAGE_PROVIDER,
            address(100)
        );
        vm.stopPrank();
        vm.roll(101);
        vm.expectRevert(bytes("Invalid amount"));
        matchingsAssertion.biddingAssertion(address(100), _matchingId, _amount);
    }
}

///@notice bidding matching test case with duplicate bid
contract BiddingTestCaseWithInvlalidDuplicateBid is ControlTestSuiteBase {
    constructor(
        IMatchings _matchings,
        IMatchingsHelpers _matchingsHelpers,
        IMatchingsAssertion _matchingsAssertion
    )
        ControlTestSuiteBase(_matchings, _matchingsHelpers, _matchingsAssertion) // solhint-disable-next-line
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
        address admin = matchings.datasets().roles().getRoleMember(
            bytes32(0x00),
            0
        );
        vm.startPrank(admin);
        matchings.datasets().roles().grantRole(
            RolesType.STORAGE_PROVIDER,
            address(100)
        );
        vm.stopPrank();
        vm.roll(101);
        matchingsAssertion.biddingAssertion(address(100), _matchingId, _amount);
        vm.prank(address(100));
        vm.expectRevert(bytes("Invalid amount"));
        matchings.bidding(_matchingId, _amount);
    }
}

///@notice bidding matching test case with invalid State
contract BiddingTestCaseWithInvlalidState is ControlTestSuiteBase {
    constructor(
        IMatchings _matchings,
        IMatchingsHelpers _matchingsHelpers,
        IMatchingsAssertion _matchingsAssertion
    )
        ControlTestSuiteBase(_matchings, _matchingsHelpers, _matchingsAssertion) // solhint-disable-next-line
    {}

    function before(
        MatchingType.BidSelectionRule _bidRule,
        uint64 _amount
    ) internal virtual override returns (uint64) {
        vm.assume(_amount >= 100);
        uint64 datasetId = matchingsHelpers.setup("testAccessMethod", 100, 10);
        address admin = matchings.datasets().roles().getRoleMember(
            bytes32(0x00),
            0
        );
        vm.startPrank(admin);
        matchings.datasets().roles().grantRole(
            RolesType.DATASET_PROVIDER,
            address(99)
        );
        vm.stopPrank();

        matchingsAssertion.createMatchingAssertion(
            address(99),
            datasetId,
            DatasetType.DataType.MappingFiles,
            0,
            _bidRule,
            100,
            100,
            100,
            100,
            "TEST"
        );
        return matchings.matchingsCount();
    }

    function action(
        uint64 _matchingId,
        uint64 _amount
    ) internal virtual override {
        address admin = matchings.datasets().roles().getRoleMember(
            bytes32(0x00),
            0
        );
        vm.startPrank(admin);
        matchings.datasets().roles().grantRole(
            RolesType.STORAGE_PROVIDER,
            address(100)
        );
        vm.stopPrank();
        vm.roll(101);
        vm.expectRevert(bytes("Invalid state"));
        matchingsAssertion.biddingAssertion(address(100), _matchingId, _amount);
    }
}

///@notice bidding matching test case with bid not start
contract BiddingTestCaseWithNotStart is ControlTestSuiteBase {
    constructor(
        IMatchings _matchings,
        IMatchingsHelpers _matchingsHelpers,
        IMatchingsAssertion _matchingsAssertion
    )
        ControlTestSuiteBase(_matchings, _matchingsHelpers, _matchingsAssertion) // solhint-disable-next-line
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
        address admin = matchings.datasets().roles().getRoleMember(
            bytes32(0x00),
            0
        );
        vm.startPrank(admin);
        matchings.datasets().roles().grantRole(
            RolesType.STORAGE_PROVIDER,
            address(100)
        );
        vm.stopPrank();
        vm.roll(80);
        vm.expectRevert(bytes("Matching: Bidding is not start"));
        matchingsAssertion.biddingAssertion(address(100), _matchingId, _amount);
    }
}

///@notice bidding matching test case with bid is end
contract BiddingTestCaseWithBidIsEnd is ControlTestSuiteBase {
    constructor(
        IMatchings _matchings,
        IMatchingsHelpers _matchingsHelpers,
        IMatchingsAssertion _matchingsAssertion
    )
        ControlTestSuiteBase(_matchings, _matchingsHelpers, _matchingsAssertion) // solhint-disable-next-line
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
        address admin = matchings.datasets().roles().getRoleMember(
            bytes32(0x00),
            0
        );
        vm.startPrank(admin);
        matchings.datasets().roles().grantRole(
            RolesType.STORAGE_PROVIDER,
            address(100)
        );
        vm.stopPrank();
        vm.roll(300);
        vm.expectRevert(bytes("Matching: Bidding is end"));
        matchingsAssertion.biddingAssertion(address(100), _matchingId, _amount);
    }
}
