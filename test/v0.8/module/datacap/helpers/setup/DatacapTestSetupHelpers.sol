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

// Import required external contracts and interfaces
import {Test} from "forge-std/Test.sol";
import {Datacaps} from "src/v0.8/module/datacap/Datacaps.sol";
import {StorageTestHelpers} from "test/v0.8/module/storage/helpers/StorageTestHelpers.sol";

// Contract definition for test helper functions
contract DatacapTestSetupHelpers is Test, StorageTestHelpers {
    // Helper function to set up the initial environment
    Datacaps public datacaps;

    function setUp() public virtual override {
        super.setUp();
        datacaps = new Datacaps(
            governanceContractAddresss,
            role,
            filplus,
            filecoin,
            carstore,
            datasets,
            matchings,
            storages
        );
    }
}
