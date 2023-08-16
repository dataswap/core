/*******************************************************************************
 *   (c) 2023 DataSwap
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

import {DatasetType} from "../../../../types/DatasetType.sol";
import {CidUtils} from "../../../../shared/utils/cid/CidUtils.sol";

library DatasetLeafLIB {
    function setLeaf(
        DatasetType.Leaf[] storage self,
        bytes32[] memory _hashes,
        uint64[] memory _sizes
    ) internal {
        for (uint64 i = 0; i < _hashes.length; i++) {
            self[i].hash_ = _hashes[i];
            self[i].size = _sizes[i];
        }
    }

    function getLeaf(
        DatasetType.Leaf[] storage self
    ) internal view returns (bytes32[] memory _hashes, uint64[] memory _sizes) {
        for (uint64 i = 0; i < self.length; i++) {
            _hashes[i] = CidUtils.hashToCID(self[i].hash_);
            _sizes[i] = self[i].size;
        }
    }
}
