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

import {DatasetType} from "src/v0.8/types/DatasetType.sol";

library DatasetChallengeProofLIB {
    function setChallengeProof(
        DatasetType.DatasetChallengeProof memory self,
        bytes32 _leaf,
        bytes32[] memory _siblings,
        uint32 _path
    ) internal pure {
        for (uint256 i = 0; i < _siblings.length; i++) {
            self.siblings[i] = _siblings[i];
        }
        self.leaf = _leaf;
        self.path = _path;
    }

    function getChallengeProof(
        DatasetType.DatasetChallengeProof storage self
    )
        internal
        view
        returns (bytes32 _leaf, bytes32[] memory _siblings, uint32 _path)
    {
        bytes32[] memory result = new bytes32[](self.siblings.length);
        bytes32 leaf;
        uint32 path;
        for (uint256 i = 0; i < self.siblings.length; i++) {
            result[i] = self.siblings[i];
        }
        leaf = self.leaf;
        path = self.path;
        return (leaf, result, path);
    }
}
