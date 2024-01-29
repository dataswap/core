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

/// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.21;

import {Test} from "forge-std/Test.sol";
import {IStorages} from "src/v0.8/interfaces/module/IStorages.sol";
import {IStoragesAssertion} from "test/v0.8/interfaces/assertions/module/IStoragesAssertion.sol";
import {IMatchingsHelpers} from "test/v0.8/interfaces/helpers/module/IMatchingsHelpers.sol";
import {IStoragesHelpers} from "test/v0.8/interfaces/helpers/module/IStoragesHelpers.sol";
import {Generator} from "test/v0.8/helpers/utils/Generator.sol";

/// @title IDatacap
/// @dev Interface for managing the allocation of datacap for matched data storage.
contract StoragesHelpers is IStoragesHelpers, Test {
    IStorages internal storages;
    IMatchingsHelpers internal matchingsHelpers;
    Generator private generator;
    IStoragesAssertion internal assertion;

    constructor(
        IStorages _storages,
        Generator _generator,
        IMatchingsHelpers _matchingsHelpers,
        IStoragesAssertion _assertion
    ) {
        storages = _storages;
        generator = _generator;
        matchingsHelpers = _matchingsHelpers;
        assertion = _assertion;
    }

    function setup() external returns (uint64 datasetId, uint64 matchingId) {
        (datasetId, matchingId) = matchingsHelpers.completeMatchingWorkflow();
        address initiator = storages.roles().matchings().getMatchingInitiator(
            matchingId
        );
        assertion.requestAllocateDatacapAssertion(initiator, matchingId);
        return (datasetId, matchingId);
    }

    function generateFilecoinClaimIds(
        uint64 _count
    ) external returns (uint64[] memory claimIds) {
        return generator.generateFilecoinClaimIds(_count);
    }

    function generateFilecoinClaimId() external returns (uint64) {
        return generator.generateFilecoinClaimId();
    }
}
