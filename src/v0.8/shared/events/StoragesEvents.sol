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

library StoragesEvents {
    /// @dev Submits a Filecoin claim ID for a matched store after successful matching.
    /// @param _matchingId The ID of the matching store.
    /// @param _id The ID of the file.
    /// @param _claimId The Filecoin claim ID.
    event StorageClaimIdSubmitted(
        uint64 indexed _matchingId,
        uint64 indexed _id,
        uint64 _claimId
    );
    ///notice:  Event emitted when datacap is allocated to a matching
    event DatacapAllocated(uint64 indexed matchingId, uint64 allocatedCapacity);

    ///notice:  Event emitted when chunk datacap is collateral to a matching
    event DatacapChunkCollateral(uint64 indexed, address, uint256, uint256);
}
