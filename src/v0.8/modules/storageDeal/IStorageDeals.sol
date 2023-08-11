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

import "../../types/StorageDealType.sol";
import "../matching/Matchings.sol";
import "../../shared/filecoin/FilecoinDealUtils.sol";
import "../../types/FilecoinDealType.sol";

interface StorageDeals {
    function submitCarReplicaFilecoinDealId(
        uint256 _matchingId,
        bytes32 _cid,
        uint256 _filecoinDealId
    ) external;

    function submitCarsReplicaFilecoinDealId(
        uint256 _matchingId,
        bytes32[] memory _cids,
        uint256[] memory _filecoinDealIds
    ) external;

    function getStorageDealDoneCarsCids(
        uint256 _matchingId
    ) external view returns (bytes32[] memory);

    function getStorageDealDoneCarsCount(
        uint256 _matchingId
    ) external view returns (uint256);

    function isStorageDealDone(
        uint256 _matchingId
    ) external view returns (bool);
}
