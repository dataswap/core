/*******************************************************************************
 *   (c) 2023 Dataswap
 *
 *  Licensed under the GNU General Public License, Version 3.0 or later (the "License");
 *  you may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at
 *
 *      https://www.gnu.org/licenses/gpl-3.0.en.html *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 ********************************************************************************/

// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity ^0.8.21;
import {IRoles} from "src/v0.8/interfaces/core/IRoles.sol";
import {FinanceType} from "src/v0.8/types/FinanceType.sol";
import {DatasetType} from "src/v0.8/types/DatasetType.sol";

library DatasetAuditorElectionLIB {
    ///@notice Internal function to stake tokens.
    ///@param self The storage to store candidate.
    function _nominateAsDatasetAuditorCandidate(
        DatasetType.DatasetAuditorElection storage self
    ) internal {
        // Add or update candidate
        bool isNewCandidate = true;
        for (uint256 i = 0; i < self.candidates.length; i++) {
            if (self.candidates[i] == msg.sender) {
                isNewCandidate = false;
                break;
            }
        }

        if (isNewCandidate) {
            self.candidates.push(msg.sender);
        }
    }

    /// @dev Internal function to retrieve the block hash at a specific height.
    /// @param _height The target block height to retrieve the hash for.
    /// @return _hash The block hash at the specified height.
    function _getBlockHashBaseHeight(
        uint64 _height
    ) internal view returns (bytes32 _hash) {
        uint64 currentHeight = uint64(block.number);
        uint64 _targetHeight;

        // If the difference between current height and specified height is less than 256,
        // set target height to the specified height.
        if (currentHeight - _height < 256) {
            _targetHeight = _height;
        } else {
            // Otherwise, set targetHeight to the nearest higher multiple of 256 from _height
            _targetHeight = _height + ((currentHeight - _height) / 256) * 256;
        }

        // Retrieve the block hash at the target height
        _hash = blockhash(uint32(_targetHeight));
    }

    /// @dev Internal function to retrieve the block hash at a specified height.
    /// @param self The storage reference to the dataset auditor candidate.
    /// @param _height The target block height to retrieve the hash for.
    /// @return blockHash The block hash at the specified height.
    function _electSeed(
        DatasetType.DatasetAuditorElection storage self,
        uint64 _height
    ) internal returns (bytes32) {
        if (self.seed == bytes32(0)) {
            self.seed = _getBlockHashBaseHeight(_height);
        }
        return self.seed;
    }

    /// @dev Internal function to process the ticket result.
    /// @param self The storage reference to the dataset auditor candidate.
    /// @param _height The target block height.
    /// @param _account The account address.
    /// @param _numWinners The number of winners to be selected.
    /// @return success A boolean indicating whether the ticket result is successfully processed.
    function _processTicketResult(
        DatasetType.DatasetAuditorElection storage self,
        uint64 _height,
        address _account,
        uint256 _numWinners
    ) internal returns (bool) {
        require(
            _numWinners <= self.candidates.length,
            "The number of candidates is insufficient"
        );
        bytes32 _seed = _electSeed(self, _height);

        bytes32[] memory weights = new bytes32[](self.candidates.length);

        for (uint256 i = 0; i < self.candidates.length; i++) {
            weights[i] = keccak256(abi.encodePacked(_seed, self.candidates[i]));
        }

        for (uint256 i = 0; i < _numWinners; i++) {
            bytes32 maxWeight = 0;
            uint256 maxIndex = 0;

            for (uint256 j = 0; j < self.candidates.length; j++) {
                if (weights[j] > maxWeight) {
                    maxWeight = weights[j];
                    maxIndex = j;
                }
            }

            if (self.candidates[maxIndex] == _account) {
                return true;
            }

            weights[maxIndex] = 0;
        }

        return false;
    }
}
