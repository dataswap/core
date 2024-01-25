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

import {DatacapTestBase} from "test/v0.8/testcases/module/storage/abstract/DatacapTestBase.sol";

import {IStorages} from "src/v0.8/interfaces/module/IStorages.sol";
import {IStoragesAssertion} from "test/v0.8/interfaces/assertions/module/IStoragesAssertion.sol";
import {IDatacapsHelpers} from "test/v0.8/interfaces/helpers/module/IDatacapsHelpers.sol";

import {MatchingType} from "src/v0.8/types/MatchingType.sol";
import {DatasetType} from "src/v0.8/types/DatasetType.sol";

///@notice request allocate datacap test case with success.
contract RequestAllocateTestCaseWithSuccess is DatacapTestBase {
    constructor(
        IStorages _storages,
        IDatacapsHelpers _datacapsHelpers,
        IStoragesAssertion _storagesAssertion
    ) DatacapTestBase(_storages, _datacapsHelpers, _storagesAssertion) {}

    function action(uint64 _matchingId) internal virtual override {
        address initiator = storages.matchings().getMatchingInitiator(
            _matchingId
        );

        storagesAssertion.requestAllocateDatacapAssertion(
            initiator,
            _matchingId
        );
    }
}

///@notice request allocate datacap test case ,it should be reverted due to invalid matching id.
contract RequestAllocateTestSuiteWithInvalidMatchingId is DatacapTestBase {
    constructor(
        IStorages _datacaps,
        IDatacapsHelpers _datacapsHelpers,
        IStoragesAssertion _storagesAssertion
    )
        DatacapTestBase(_datacaps, _datacapsHelpers, _storagesAssertion) // solhint-disable-next-line
    {}

    function before() internal virtual override returns (uint64) {}

    function action(uint64 _matchingId) internal virtual override {
        address initiator = storages.matchings().getMatchingInitiator(
            _matchingId
        );

        vm.expectRevert(bytes("Address must not be zero"));
        storagesAssertion.requestAllocateDatacapAssertion(
            initiator,
            _matchingId + 1
        );
    }
}

///@notice request allocate datacap test case ,it should be reverted due to invalid caller.
contract RequestAllocateTestSuiteWithInvalidCaller is DatacapTestBase {
    constructor(
        IStorages _datacaps,
        IDatacapsHelpers _datacapsHelpers,
        IStoragesAssertion _storagesAssertion
    )
        DatacapTestBase(_datacaps, _datacapsHelpers, _storagesAssertion) // solhint-disable-next-line
    {}

    function action(uint64 _matchingId) internal virtual override {
        address initiator = storages.matchings().getMatchingInitiator(
            _matchingId
        );
        vm.assume(msg.sender != initiator);
        vm.expectRevert(bytes("Only allowed address can call"));
        storagesAssertion.requestAllocateDatacapAssertion(
            msg.sender,
            _matchingId
        );
    }
}

///@notice request allocate datacap test case ,it should be reverted due to invalid next allocate request.
contract RequestAllocateTestSuiteWithInvalidNextRequest is DatacapTestBase {
    constructor(
        IStorages _datacaps,
        IDatacapsHelpers _datacapsHelpers,
        IStoragesAssertion _storagesAssertion
    )
        DatacapTestBase(_datacaps, _datacapsHelpers, _storagesAssertion) // solhint-disable-next-line
    {}

    function action(uint64 _matchingId) internal virtual override {
        address initiator = storages.matchings().getMatchingInitiator(
            _matchingId
        );
        storagesAssertion.requestAllocateDatacapAssertion(
            initiator,
            _matchingId
        );
        vm.expectRevert();
        storagesAssertion.requestAllocateDatacapAssertion(
            initiator,
            _matchingId
        );
    }
}
