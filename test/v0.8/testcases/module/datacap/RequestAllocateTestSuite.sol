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

import {DatacapTestSuiteBase} from "test/v0.8/testcases/module/datacap/abstract/DatacapTestSuiteBase.sol";

import {IDatacaps} from "src/v0.8/interfaces/module/IDatacaps.sol";
import {IDatacapsAssertion} from "test/v0.8/interfaces/assertions/module/IDatacapsAssertion.sol";
import {IDatacapsSetupHelpers} from "test/v0.8/interfaces/helpers/setup/IDatacapsSetupHelpers.sol";

import {MatchingType} from "src/v0.8/types/MatchingType.sol";
import {DatasetType} from "src/v0.8/types/DatasetType.sol";

contract RequestAllocateTestSuiteWithSuccess is DatacapTestSuiteBase {
    constructor(
        IDatacaps _datacaps,
        IDatacapsSetupHelpers _datacapsSetupHelpers,
        IDatacapsAssertion _datacapsAssertion
    )
        DatacapTestSuiteBase(
            _datacaps,
            _datacapsSetupHelpers,
            _datacapsAssertion
        ) // solhint-disable-next-line
    {}

    function before(uint64 _matchingId) internal virtual override {
        (, _matchingId) = datacapsSetupHelpers.setup(
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

    function action(uint64 _matchingId) internal virtual override {
        vm.startPrank(
            datacaps.storages().matchings().getMatchingInitiator(_matchingId)
        );
        super.action(_matchingId);
        vm.stopPrank();
    }
}

contract RequestAllocateTestSuiteWithInvalidMatchingId is DatacapTestSuiteBase {
    constructor(
        IDatacaps _datacaps,
        IDatacapsSetupHelpers _datacapsSetupHelpers,
        IDatacapsAssertion _datacapsAssertion
    )
        DatacapTestSuiteBase(
            _datacaps,
            _datacapsSetupHelpers,
            _datacapsAssertion
        ) // solhint-disable-next-line
    {}

    function before(uint64 _matchingId) internal virtual override {}

    function action(uint64 _matchingId) internal virtual override {
        vm.expectRevert();
        super.action(_matchingId);
    }
}

contract RequestAllocateTestSuiteWithInvalidCaller is DatacapTestSuiteBase {
    constructor(
        IDatacaps _datacaps,
        IDatacapsSetupHelpers _datacapsSetupHelpers,
        IDatacapsAssertion _datacapsAssertion
    )
        DatacapTestSuiteBase(
            _datacaps,
            _datacapsSetupHelpers,
            _datacapsAssertion
        ) // solhint-disable-next-line
    {}

    function before(uint64 _matchingId) internal virtual override {
        (, _matchingId) = datacapsSetupHelpers.setup(
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

    function action(uint64 _matchingId) internal virtual override {
        vm.assume(
            msg.sender !=
                datacaps.storages().matchings().getMatchingInitiator(
                    _matchingId
                )
        );
        vm.startPrank(msg.sender);
        vm.expectRevert();
        super.action(_matchingId);
        vm.stopPrank();
    }
}

contract RequestAllocateTestSuiteWithInvalidNextRequest is
    DatacapTestSuiteBase
{
    constructor(
        IDatacaps _datacaps,
        IDatacapsSetupHelpers _datacapsSetupHelpers,
        IDatacapsAssertion _datacapsAssertion
    )
        DatacapTestSuiteBase(
            _datacaps,
            _datacapsSetupHelpers,
            _datacapsAssertion
        ) // solhint-disable-next-line
    {}

    function before(uint64 _matchingId) internal virtual override {
        (, _matchingId) = datacapsSetupHelpers.setup(
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

    function action(uint64 _matchingId) internal virtual override {
        vm.startPrank(
            datacaps.storages().matchings().getMatchingInitiator(_matchingId)
        );
        vm.expectRevert();
        datacapsAssertion.requestAllocateDatacapAssertion(_matchingId);
        super.action(_matchingId);
        vm.stopPrank();
    }
}
