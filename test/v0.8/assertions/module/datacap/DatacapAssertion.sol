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

import {DSTest} from "ds-test/test.sol";
import {Test} from "forge-std/Test.sol";
import {DatasetType} from "src/v0.8/types/DatasetType.sol";
import {MatchingType} from "src/v0.8/types/MatchingType.sol";
import {IDatacaps} from "src/v0.8/interfaces/module/IDatacaps.sol";
import {IDatacapAssertion} from "test/v0.8/interfaces/assertions/module/IDatacapAssertion.sol";

// assert carstore action
// NOTE: view asserton functions must all be tested by the functions that will change state
contract DatacapAssertion is DSTest, Test, IDatacapAssertion {
    IDatacaps public datacaps;

    constructor(IDatacaps _datacaps) {
        datacaps = _datacaps;
    }

    function requestAllocateDatacapAssertion(uint64 _matchingId) external {
        //before action
        uint64 oldAvailableDatacap = datacaps.getAvailableDatacap(_matchingId);
        isNextDatacapAllocationValidAssertion(_matchingId, true);
        uint64 oldAllocatedDatacap = datacaps.getAllocatedDatacap(_matchingId);
        uint64 oldRemainingUnallocatedDatacap = datacaps
            .getRemainingUnallocatedDatacap(_matchingId);

        //action
        uint64 addDatacap = datacaps.requestAllocateDatacap(_matchingId);

        //after action
        getAvailableDatacapAssertion(
            _matchingId,
            oldAvailableDatacap + addDatacap
        );
        getAllocatedDatacapAssertion(
            _matchingId,
            oldAllocatedDatacap + addDatacap
        );
        getRemainingUnallocatedDatacapAssertion(
            _matchingId,
            oldRemainingUnallocatedDatacap - addDatacap
        );
        isNextDatacapAllocationValidAssertion(_matchingId, false);
    }

    function getAvailableDatacapAssertion(
        uint64 _matchingId,
        uint64 _expectSize
    ) public {
        assertEq(datacaps.getAvailableDatacap(_matchingId), _expectSize);
    }

    function getAllocatedDatacapAssertion(
        uint64 _matchingId,
        uint64 _expectSize
    ) public {
        assertEq(datacaps.getAllocatedDatacap(_matchingId), _expectSize);
    }

    // TODO:getRemainingUnallocatedDatacapAssertion need test
    function getTotalDatacapAllocationRequirementAssertion(
        uint64 _matchingId,
        uint64 _expectSize
    ) public {
        assertEq(
            datacaps.getTotalDatacapAllocationRequirement(_matchingId),
            _expectSize
        );
    }

    function getRemainingUnallocatedDatacapAssertion(
        uint64 _matchingId,
        uint64 _expectSize
    ) public {
        assertEq(
            datacaps.getRemainingUnallocatedDatacap(_matchingId),
            _expectSize
        );
    }

    function isNextDatacapAllocationValidAssertion(
        uint64 _matchingId,
        bool _expectOK
    ) public {
        assertEq(datacaps.isNextDatacapAllocationValid(_matchingId), _expectOK);
    }
}
