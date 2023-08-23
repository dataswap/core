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
import {CarReplicaType} from "../../../../../../src/v0.8/types/CarReplicaType.sol";
import {DatacapTestSetupHelpers} from "./setup/DatacapTestSetupHelpers.sol";

// Contract definition for test helper functions
contract DatacapTestHelpers is Test, DatacapTestSetupHelpers {
    // Helper function to set up the initial environment
    function setupForDatacapTest() internal {
        assertMatchingMappingFilesCloseExpectingSuccess();
    }
}