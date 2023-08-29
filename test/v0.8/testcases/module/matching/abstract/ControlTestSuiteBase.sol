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

import {MatchingsTestBase} from "test/v0.8/testcases/module/matching/abstract/MatchingsTestBase.sol";

import {IMatchings} from "src/v0.8/interfaces/module/IMatchings.sol";
import {IMatchingsAssertion} from "test/v0.8/interfaces/assertions/module/IMatchingsAssertion.sol";
import {IMatchingsHelpers} from "test/v0.8/interfaces/helpers/module/IMatchingsHelpers.sol";
import {MatchingType} from "src/v0.8/types/MatchingType.sol";
import {DatasetType} from "src/v0.8/types/DatasetType.sol";
import {IRoles} from "src/v0.8/interfaces/core/IRoles.sol";
import {RolesType} from "src/v0.8/types/RolesType.sol";

/// @title ControlTestSuiteBase
/// @dev Base contract for control test suites. Control test suites consist of three steps: before, action, and after.
/// The `before` function is used for test case setup, and the `action` function performs the main action of the test case.
/// The `after_` function can be used for cleanup or post-action code.
abstract contract ControlTestSuiteBase is MatchingsTestBase {
    /// @dev Constructor to initialize the ControlTestSuiteBase with the required contracts.
    /// @param _matchings The address of the IMatchings contract.
    /// @param _matchingsHelpers The address of the IMatchingsHelpers contract.
    /// @param _matchingsAssertion The address of the IMatchingsAssertion contract.
    constructor(
        IMatchings _matchings,
        IMatchingsHelpers _matchingsHelpers,
        IMatchingsAssertion _matchingsAssertion
    ) MatchingsTestBase(_matchings, _matchingsHelpers, _matchingsAssertion) {}

    /// @dev The `before` function is used to set up the initial state for the control test case.
    /// In this case, it sets up a dataset with certain parameters and performs administrative actions.
    /// @return The number of matchings available after setup.
    function before() internal virtual override returns (uint64) {
        // Set up a dataset with specific parameters
        uint64 datasetId = matchingsHelpers.setup("testAccessMethod", 100, 10);

        // Get the admin address for dataset roles
        address admin = matchings.datasets().roles().getRoleMember(
            bytes32(0x00),
            0
        );

        // Start a prank, perform administrative actions, and stop the prank
        vm.startPrank(admin);
        matchings.datasets().roles().grantRole(
            RolesType.DATASET_PROVIDER,
            address(99)
        );
        vm.stopPrank();

        // Get dataset cars and their count
        (bytes32[] memory cars, uint64 size) = matchingsHelpers
            .getDatasetCarsAndCarsCount(
                datasetId,
                DatasetType.DataType.MappingFiles
            );

        // Publish a matching with specific parameters
        matchingsAssertion.publishMatchingAssertion(
            address(99),
            datasetId,
            cars,
            size,
            DatasetType.DataType.MappingFiles,
            0,
            MatchingType.BidSelectionRule.HighestBid,
            100,
            100,
            100,
            100,
            "TEST"
        );

        // Get the count of available matchings
        uint64 matchingCount = matchings.matchingsCount();
        return matchingCount;
    }
}
