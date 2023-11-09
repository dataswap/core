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
import {MatchingsAssertion} from "test/v0.8/assertions/module/matching/MatchingsAssertion.sol";
import {DatacapsAssertion} from "test/v0.8/assertions/module/datacap/DatacapsAssertion.sol";
import {DatasetsHelpers} from "test/v0.8/helpers/module/dataset/DatasetsHelpers.sol";
import {MatchingsHelpers} from "test/v0.8/helpers/module/matching/MatchingsHelpers.sol";
import {DatasetsAssertion} from "test/v0.8/assertions/module/dataset/DatasetsAssertion.sol";
import {DatacapsHelpers} from "test/v0.8/helpers/module/datacap/DatacapsHelpers.sol";

/// @title DatacapTestSetup
/// @notice This contract is used for setting up the Datacaps contract for testing.
contract DatacapTestSetup is BaseTestSetup {
    DatacapsAssertion public assertion;
    DatacapsHelpers public helpers;

    /// @dev Initialize the Datacaps and assertion contracts.
    function setup() internal {
        enhanceSetup();
        MatchingsAssertion machingsAssertion = new MatchingsAssertion(
            matchings,
            matchingsTarget,
            matchingsBids,
            carstore
        );

        DatasetsAssertion datasetAssertion = new DatasetsAssertion(
            carstore,
            datasets,
            datasetsRequirement,
            datasetsProof,
            datasetsChallenge
        );
        DatasetsHelpers datasetsHelpers = new DatasetsHelpers(
            datasets,
            datasetsRequirement,
            datasetsProof,
            datasetsChallenge,
            generator,
            datasetAssertion
        );

        MatchingsHelpers matchingsHelpers = new MatchingsHelpers(
            carstore,
            datasets,
            datasetsProof,
            matchings,
            matchingsTarget,
            matchingsBids,
            datasetsHelpers,
            machingsAssertion
        );

        helpers = new DatacapsHelpers(datacaps, matchingsHelpers);
        assertion = new DatacapsAssertion(datacaps);
    }
}
