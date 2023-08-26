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
import {IStorages} from "src/v0.8/interfaces/module/IStorages.sol";
import {IStorageAssertion} from "test/v0.8/interfaces/assertions/module/IStorageAssertion.sol";

// assert carstore action
// NOTE: view asserton functions must all be tested by the functions that will change state
contract StorageAssertion is DSTest, Test, IStorageAssertion {
    IStorages public storages;

    constructor(IStorages _storages) {
        storages = _storages;
    }

    function submitStorageDealIdAssertion(
        uint64 _matchingId,
        bytes32 _cid,
        uint64 _filecoinDealId
    ) external {
        //before action
        uint64 oldDoneCount = storages.getStoredCarCount(_matchingId);
        // uint64 oldtotalStoredSize = storages.getTotalStoredSize(_matchingId);

        //action
        storages.submitStorageDealId(_matchingId, _cid, _filecoinDealId);

        //after action
        getStoredCarCountAssertion(_matchingId, oldDoneCount + 1);
        //TODO: add car object
        // getTotalStoredSizeAssertion(_matchingId, oldtotalStoredSize+);
    }

    function submitStorageDealIdsAssertion(
        uint64 _matchingId,
        bytes32[] memory _cids,
        uint64[] memory _filecoinDealIds
    ) external {
        //action
        storages.submitStorageDealIds(_matchingId, _cids, _filecoinDealIds);
        // after action
        getStoredCarsAssertion(_matchingId, _cids);
    }

    function getStoredCarsAssertion(
        uint64 _matchingId,
        bytes32[] memory _expectCars
    ) public {
        bytes32[] memory cars = storages.getStoredCars(_matchingId);
        assertEq(cars.length, _expectCars.length);
        for (uint64 i = 0; i < cars.length; i++) {
            assertEq(cars[i], _expectCars[i]);
        }
    }

    function getStoredCarCountAssertion(
        uint64 _matchingId,
        uint64 _expectCount
    ) public {
        assertEq(storages.getStoredCarCount(_matchingId), _expectCount);
    }

    function getTotalStoredSizeAssertion(
        uint64 _matchingId,
        uint64 _expectSize
    ) public {
        assertEq(storages.getTotalStoredSize(_matchingId), _expectSize);
    }

    //TODO: need to be test
    function isAllStoredDoneAssertion(
        uint64 _matchingId,
        bool _expectIsAllStoredDone
    ) public {
        assertEq(storages.isAllStoredDone(_matchingId), _expectIsAllStoredDone);
    }
}
