/// SPDX-License-Identifier: GPL-3.0-or-later
/// (c) 2023 Dataswap
///
/// Licensed under the GNU General Public License, Version 3.0 or later (the "License");
/// you may not use this file except in compliance with the License.
/// You may obtain a copy of the License at
///     https://www.gnu.org/licenses/gpl-3.0.en.html
///
/// Unless required by applicable law or agreed to in writing, software
/// distributed under the License is distributed on an "AS IS" BASIS,
/// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
/// See the License for the specific language governing permissions and
/// limitations under the License.

pragma solidity ^0.8.21;
import {IDatacapsHelpers} from "test/v0.8/interfaces/helpers/module/IDatacapsHelpers.sol";
import {DatasetType} from "src/v0.8/types/DatasetType.sol";
import {MatchingType} from "src/v0.8/types/MatchingType.sol";

import {IStorages} from "src/v0.8/interfaces/module/IStorages.sol";
import {IMatchingsHelpers} from "test/v0.8/interfaces/helpers/module/IMatchingsHelpers.sol";
import {IStoragesHelpers} from "test/v0.8/interfaces/helpers/module/IStoragesHelpers.sol";
import {Generator} from "test/v0.8/helpers/utils/Generator.sol";

/// @title IDatacap
/// @dev Interface for managing the allocation of datacap for matched data storage.
contract StoragesHelpers is IStoragesHelpers {
    IStorages internal storages;
    IMatchingsHelpers internal matchingsHelpers;
    Generator private generator;

    constructor(
        IStorages _storages,
        Generator _generator,
        IMatchingsHelpers _matchingsHelpers
    ) {
        storages = _storages;
        generator = _generator;
        matchingsHelpers = _matchingsHelpers;
    }

    function setup() external returns (uint64 datasetId, uint64 matchingId) {
        return matchingsHelpers.completeMatchingWorkflow();
    }

    function generateFilecoinDealIds(
        uint64 _count
    ) external returns (uint64[] memory filecoinDealIds) {
        return generator.generateFilecoinDealIds(_count);
    }

    function generateFilecoinDealId() external returns (uint64) {
        return generator.generateFilecoinDealId();
    }
}