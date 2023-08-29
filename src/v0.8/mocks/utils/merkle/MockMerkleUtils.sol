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

import {IMerkleUtils} from "src/v0.8/interfaces/utils/IMerkleUtils.sol";

/// @title MockMerkleUtils
contract MockMerkleUtils is IMerkleUtils {
    bool private mockValidState = true;

    /// @notice Validate a Merkle proof.
    /// @dev This function checks if a given Merkle proof is valid.
    function isValidMerkleProof(
        bytes32,
        bytes32,
        bytes32[] memory,
        uint32
    ) external view returns (bool) {
        require(mockValidState == true, "mockValidState must is true");
        return mockValidState;
    }

    /// @notice Set mock valid state
    function setMockValidState(bool _state) external {
        mockValidState = _state;
    }
}
