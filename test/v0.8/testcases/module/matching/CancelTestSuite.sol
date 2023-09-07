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
import {IMatchingsAssertion} from "test/v0.8/interfaces/assertions/module/IMatchingsAssertion.sol";
import {IMatchingsHelpers} from "test/v0.8/interfaces/helpers/module/IMatchingsHelpers.sol";
import {MatchingType} from "src/v0.8/types/MatchingType.sol";
import {DatasetType} from "src/v0.8/types/DatasetType.sol";
import {IRoles} from "src/v0.8/interfaces/core/IRoles.sol";
import {RolesType} from "src/v0.8/types/RolesType.sol";
import {MatchingsEvents} from "src/v0.8/shared/events/MatchingsEvents.sol";
import {Errors} from "src/v0.8/shared/errors/Errors.sol";

///@notice cancel matching test case with success
contract CancelTestCaseWithSuccess is ControlTestSuiteBase {
    constructor(
        IMatchings _matchings,
        IMatchingsHelpers _matchingsHelpers,
        IMatchingsAssertion _matchingsAssertion
    )
        ControlTestSuiteBase(_matchings, _matchingsHelpers, _matchingsAssertion) // solhint-disable-next-line
    {}

    function action(
        uint64 _matchingId,
        uint64 /*_amount*/
    ) internal virtual override {
        address initiator = matchings.getMatchingInitiator(_matchingId);
        vm.expectEmit(true, false, false, true);
        emit MatchingsEvents.MatchingCancelled(_matchingId);
        matchingsAssertion.cancelMatchingAssertion(initiator, _matchingId);
    }
}

///@notice cancel matching test case with after started
contract CancelTestCaseWithAfterStarted is ControlTestSuiteBase {
    constructor(
        IMatchings _matchings,
        IMatchingsHelpers _matchingsHelpers,
        IMatchingsAssertion _matchingsAssertion
    )
        ControlTestSuiteBase(_matchings, _matchingsHelpers, _matchingsAssertion) // solhint-disable-next-line
    {}

    function action(
        uint64 _matchingId,
        uint64 /*_amount*/
    ) internal virtual override {
        address initiator = matchings.getMatchingInitiator(_matchingId);
        vm.roll(150);
        vm.expectRevert(bytes("bid alreay start,can't cancel"));
        matchingsAssertion.cancelMatchingAssertion(initiator, _matchingId);
    }
}

///@notice cancel matching test case with invalid state
contract CancelTestCaseWithInvalidState is MatchingsTestBase {
    constructor(
        IMatchings _matchings,
        IMatchingsHelpers _matchingsHelpers,
        IMatchingsAssertion _matchingsAssertion
    )
        MatchingsTestBase(_matchings, _matchingsHelpers, _matchingsAssertion) // solhint-disable-next-line
    {}

    function before() internal virtual override returns (uint64) {
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
            MatchingType.BidSelectionRule.HighestBid,
            100,
            100,
            100,
            100,
            "TEST"
        );
        return matchings.matchingsCount();
    }

    function action(uint64 _matchingId) internal virtual override {
        address initiator = matchings.getMatchingInitiator(_matchingId);
        vm.expectRevert(bytes("Invalid state"));
        matchingsAssertion.cancelMatchingAssertion(initiator, _matchingId);
    }
}

///@notice cancel matching test case with invalid sender
contract CancelTestCaseWithAtInvalidSender is ControlTestSuiteBase {
    constructor(
        IMatchings _matchings,
        IMatchingsHelpers _matchingsHelpers,
        IMatchingsAssertion _matchingsAssertion
    )
        ControlTestSuiteBase(_matchings, _matchingsHelpers, _matchingsAssertion) // solhint-disable-next-line
    {}

    function action(
        uint64 _matchingId,
        uint64 /*_amount*/
    ) internal virtual override {
        address initiator = matchings.getMatchingInitiator(_matchingId);
        vm.roll(201);
        vm.expectRevert(
            abi.encodeWithSelector(
                Errors.NotMatchingInitiator.selector,
                _matchingId,
                initiator,
                address(101)
            )
        );
        matchingsAssertion.cancelMatchingAssertion(address(101), _matchingId);
    }
}
