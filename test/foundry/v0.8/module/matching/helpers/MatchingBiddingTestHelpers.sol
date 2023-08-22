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

// Import required external contracts and interfaces
import "forge-std/Test.sol";
import {MatchingType} from "../../../../../../src/v0.8/types/MatchingType.sol";
import {MatchingsEvents} from "../../../../../../src/v0.8/shared/events/MatchingsEvents.sol";
import {DatasetType} from "../../../../../../src/v0.8/types/DatasetType.sol";
import {MatchingType} from "../../../../../../src/v0.8/types/MatchingType.sol";
import {RolesType} from "../../../../../../src/v0.8/types/RolesType.sol";
import {MatchingMappingFilesPublishTestHelpers} from "./MatchingMappingFilesPublishTestHelpers.sol";

// Contract definition for test functions
contract MatchingBiddingTestHelpers is
    Test,
    MatchingMappingFilesPublishTestHelpers
{
    // step 2: do bidding action,not decouple it if this function simple
    function bidding(
        address _bidder,
        uint256 _amount,
        uint64 _blocknumber
    ) internal {
        uint64 matchingId = matchings.matchingsCount();
        role.grantRole(RolesType.STORAGE_PROVIDER, address(_bidder));
        vm.prank(address(_bidder));
        vm.roll(_blocknumber);
        matchings.bidding(matchingId, _amount);
    }
}
