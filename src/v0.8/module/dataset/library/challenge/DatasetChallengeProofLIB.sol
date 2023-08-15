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

library DatasetChallengeProofLIB {
    function setChallengeProof(
        DatasetType.DatasetChallengeProof storage self,
        bytes32[] memory _siblings,
        uint32 _path
    ) internal {
        for (uint256 i = 0; i < _siblings.length; i++) {
            self.siblings[i] = _siblings[i];
        }
        self.path = _path;
    }

    function getChallengeProof(
        DatasetType.DatasetChallengeProof storage self
    ) internal view returns (bytes32[] memory _siblings, uint32 _path) {
        for (uint256 i = 0; i < self.siblings.length; i++) {
            _siblings[i] = self.siblings[i];
            _path = self.path;
        }
    }
}
