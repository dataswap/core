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

import {Test} from "forge-std/Test.sol";
import {IMatchings} from "src/v0.8/interfaces/module/IMatchings.sol";
import {IMatchingsTarget} from "src/v0.8/interfaces/module/IMatchingsTarget.sol";
import {IMatchingsBids} from "src/v0.8/interfaces/module/IMatchingsBids.sol";
import {IMatchingsAssertion} from "test/v0.8/interfaces/assertions/module/IMatchingsAssertion.sol";
import {IMatchingsHelpers} from "test/v0.8/interfaces/helpers/module/IMatchingsHelpers.sol";
import {MatchingType} from "src/v0.8/types/MatchingType.sol";
import {DatasetType} from "src/v0.8/types/DatasetType.sol";
import {RolesType} from "src/v0.8/types/RolesType.sol";

/// @title ControlTestSuiteBase
/// @dev Base contract for control test suites. Control test suites consist of three steps: before, action, and after.
/// The `before` function is used for test case setup, and the `action` function performs the main action of the test case.
/// The `after_` function can be used for cleanup or post-action code.
abstract contract ControlTestSuiteBase is Test {
    IMatchings internal matchings;
    IMatchingsTarget internal matchingsTarget;
    IMatchingsBids internal matchingsBids;
    IMatchingsHelpers internal matchingsHelpers;
    IMatchingsAssertion internal matchingsAssertion;

    /// @dev Constructor to initialize the MatchingsTestBase with the required contracts.
    /// @param _matchings The address of the IMatchings contract.
    /// @param _matchingsHelpers The address of the IMatchingsHelpers contract.
    /// @param _matchingsAssertion The address of the IMatchingsAssertion contract.
    constructor(
        IMatchings _matchings,
        IMatchingsTarget _matchingsTarget,
        IMatchingsBids _matchingsBids,
        IMatchingsHelpers _matchingsHelpers,
        IMatchingsAssertion _matchingsAssertion
    ) {
        matchings = _matchings;
        matchingsTarget = _matchingsTarget;
        matchingsBids = _matchingsBids;
        matchingsHelpers = _matchingsHelpers;
        matchingsAssertion = _matchingsAssertion;
    }

    /// @dev The `before` function is used to set up the initial state for the control test case.
    /// In this case, it sets up a dataset with certain parameters and performs administrative actions.
    /// @param _bidRule The rules for determining the winning bid.
    /// @param /*_amount*/ The ammount of the matching.
    /// @return The number of matchings available after setup.
    function before(
        MatchingType.BidSelectionRule _bidRule,
        uint64 /*_amount*/
    ) internal virtual returns (uint64) {
        // Set up a dataset with specific parameters
        uint64 datasetId = matchingsHelpers.setup("testAccessMethod", 100, 10);
        // Get the admin address for dataset roles
        address admin = matchingsHelpers.datasets().roles().getRoleMember(
            bytes32(0x00),
            0
        );
        // Start a prank, perform administrative actions, and stop the prank
        vm.startPrank(admin);
        matchingsHelpers.datasets().roles().grantRole(
            RolesType.DATASET_PROVIDER,
            address(99)
        );
        vm.stopPrank();

        // Get dataset cars and their count
        (uint64[] memory cars, ) = matchingsHelpers.getDatasetCarsAndCarsCount(
            datasetId,
            DatasetType.DataType.MappingFiles
        );

        matchingsAssertion.createMatchingAssertion(
            address(99),
            datasetId,
            _bidRule,
            100,
            100,
            1000,
            100,
            0,
            "TEST"
        );

        uint64 matchingId = matchings.matchingsCount();

        matchingsAssertion.createTargetAssertion(
            address(99),
            matchingId,
            datasetId,
            DatasetType.DataType.MappingFiles,
            0,
            0
        );

        // Publish a matching with specific parameters
        matchingsAssertion.publishMatchingAssertion(
            address(99),
            matchingId,
            datasetId,
            cars,
            cars,
            true
        );
        // Get the count of available matchings
        return matchingId;
    }

    /// @dev The main action of the test, where the sp bidding a matching.
    /// @param _matchingId The address of the IMatchings contract.
    /// @param _amount The ammount of the matching.
    function action(uint64 _matchingId, uint64 _amount) internal virtual;

    /// @dev Called after running the test to perform any necessary cleanup or validation.
    /// @param _matchingId The address of the IMatchings contract.
    /// @param _amount The ammount of the matching.
    function after_(uint64 _matchingId, uint64 _amount) internal virtual {}

    /// @dev Runs the test to bidding a matching.
    function run(
        MatchingType.BidSelectionRule _bidRule,
        uint64 _amount
    ) public {
        uint64 matchingId = before(_bidRule, _amount);
        action(matchingId, _amount);
        after_(matchingId, _amount);
    }
}
