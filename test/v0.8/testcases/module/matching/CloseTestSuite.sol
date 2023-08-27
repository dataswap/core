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

import {IMatchings} from "src/v0.8/interfaces/module/IMatchings.sol";
import {IMatchingsAssertion} from "test/v0.8/interfaces/assertions/module/IMatchingsAssertion.sol";
import {IMatchingsHelpers} from "test/v0.8/interfaces/helpers/module/IMatchingsHelpers.sol";
import {MatchingType} from "src/v0.8/types/MatchingType.sol";
import {DatasetType} from "src/v0.8/types/DatasetType.sol";
import {IRoles} from "src/v0.8/interfaces/core/IRoles.sol";
import {RolesType} from "src/v0.8/types/RolesType.sol";

contract CloseTestCaseWithSuccess is ControlTestSuiteBase {
    constructor(
        IMatchings _matchings,
        IMatchingsHelpers _matchingsHelpers,
        IMatchingsAssertion _matchingsAssertion
    )
        ControlTestSuiteBase(_matchings, _matchingsHelpers, _matchingsAssertion) // solhint-disable-next-line
    {}

    function before() internal virtual override returns (uint64) {
        uint64 matchingId = super.before();

        address admin = matchings.datasets().roles().getRoleMember(
            bytes32(0x00),
            0
        );
        vm.startPrank(admin);
        matchings.datasets().roles().grantRole(
            RolesType.STORAGE_PROVIDER,
            address(199)
        );
        vm.stopPrank();
        vm.roll(101);
        vm.prank(address(199));
        matchings.bidding(matchingId, 200);
        return matchingId;
    }

    function action(uint64 _matchingId) internal virtual override {
        address initiator = matchings.getMatchingInitiator(_matchingId);
        vm.roll(201);
        matchingsAssertion.closeMatchingAssertion(
            initiator,
            _matchingId,
            address(199)
        );
    }
}
