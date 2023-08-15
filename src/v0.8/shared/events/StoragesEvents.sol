/// SPDX-License-Identifier: GPL-3.0-or-later
/// (c) 2023 DataSwap
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

library StoragesEvents {
    /// @dev Submits a Filecoin deal ID for a matched store after successful matching.
    /// @param _matchingId The ID of the matching store.
    /// @param _cid The CID of the file.
    /// @param _filecoinDealId The Filecoin deal ID.
    event StorageDealIdSubmitted(
        uint256 indexed _matchingId,
        bytes32 indexed _cid,
        uint64 _filecoinDealId
    );
}
