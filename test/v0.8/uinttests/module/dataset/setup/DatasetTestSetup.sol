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

import {BaseTestSetup} from "test/v0.8/uinttests/helpers/BaseTestSetup.sol";
import {DatasetsAssertion} from "test/v0.8/assertions/module/dataset/DatasetsAssertion.sol";
import {DatasetsHelpers} from "test/v0.8/helpers/module/dataset/DatasetsHelpers.sol";

/// @title DatasetTestSetup
/// @notice This contract is used for setting up the dataset contract for testing.
contract DatasetTestSetup is BaseTestSetup {
    DatasetsAssertion assertion;
    DatasetsHelpers helpers;

    /// @dev Initialize the Datacaps and helpers,assertion contracts.
    function setup() internal {
        enhanceSetup();

        assertion = new DatasetsAssertion(
            carstore(),
            datasets(),
            datasetsRequirement(),
            datasetsProof(),
            datasetsChallenge()
        );

        helpers = new DatasetsHelpers(role(), generator(), assertion);
    }
}
