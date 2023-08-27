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

import {DatacapTestBase} from "test/v0.8/testcases/module/datacap/abstract/DatacapTestBase.sol";

import {IDatacaps} from "src/v0.8/interfaces/module/IDatacaps.sol";
import {IDatacapsAssertion} from "test/v0.8/interfaces/assertions/module/IDatacapsAssertion.sol";
import {IDatacapsHelpers} from "test/v0.8/interfaces/helpers/module/IDatacapsHelpers.sol";

import {MatchingType} from "src/v0.8/types/MatchingType.sol";
import {DatasetType} from "src/v0.8/types/DatasetType.sol";

contract RequestAllocateTestCaseWithSuccess is DatacapTestBase {
    constructor(
        IDatacaps _datacaps,
        IDatacapsHelpers _datacapsHelpers,
        IDatacapsAssertion _datacapsAssertion
    )
        DatacapTestBase(_datacaps, _datacapsHelpers, _datacapsAssertion) // solhint-disable-next-line
    {}

    function action(uint64 _matchingId) internal virtual override {
        address initiator = datacaps
            .storages()
            .matchings()
            .getMatchingInitiator(_matchingId);

        // datacapsAssertion.requestAllocateDatacapAssertion(
        //     initiator,
        //     _matchingId
        // );
    }
}

contract RequestAllocateTestSuiteWithInvalidMatchingId is DatacapTestBase {
    constructor(
        IDatacaps _datacaps,
        IDatacapsHelpers _datacapsHelpers,
        IDatacapsAssertion _datacapsAssertion
    )
        DatacapTestBase(_datacaps, _datacapsHelpers, _datacapsAssertion) // solhint-disable-next-line
    {}

    function before() internal virtual override returns (uint64) {}

    function action(uint64 _matchingId) internal virtual override {
        address initiator = datacaps
            .storages()
            .matchings()
            .getMatchingInitiator(_matchingId);
        vm.expectRevert();
        datacapsAssertion.requestAllocateDatacapAssertion(
            initiator,
            _matchingId
        );
    }
}

contract RequestAllocateTestSuiteWithInvalidCaller is DatacapTestBase {
    constructor(
        IDatacaps _datacaps,
        IDatacapsHelpers _datacapsHelpers,
        IDatacapsAssertion _datacapsAssertion
    )
        DatacapTestBase(_datacaps, _datacapsHelpers, _datacapsAssertion) // solhint-disable-next-line
    {}

    function action(uint64 _matchingId) internal virtual override {
        address initiator = datacaps
            .storages()
            .matchings()
            .getMatchingInitiator(_matchingId);
        vm.assume(msg.sender != initiator);
        vm.expectRevert();
        datacapsAssertion.requestAllocateDatacapAssertion(
            msg.sender,
            _matchingId
        );
    }
}

contract RequestAllocateTestSuiteWithInvalidNextRequest is DatacapTestBase {
    constructor(
        IDatacaps _datacaps,
        IDatacapsHelpers _datacapsHelpers,
        IDatacapsAssertion _datacapsAssertion
    )
        DatacapTestBase(_datacaps, _datacapsHelpers, _datacapsAssertion) // solhint-disable-next-line
    {}

    function action(uint64 _matchingId) internal virtual override {
        address initiator = datacaps
            .storages()
            .matchings()
            .getMatchingInitiator(_matchingId);
        datacapsAssertion.requestAllocateDatacapAssertion(
            initiator,
            _matchingId
        );
        vm.expectRevert();
        datacapsAssertion.requestAllocateDatacapAssertion(
            initiator,
            _matchingId
        );
    }
}
