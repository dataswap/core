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
import "test/v0.8/testcases/module/matching/PublishMatchingTestSuite.sol";
import {MatchingTestSetup} from "test/v0.8/uinttests/module/matching/setup/MatchingTestSetup.sol";

contract PublishMatchingTest is Test, MatchingTestSetup {
    /// @notice test case with success
    function testPublishMatchingWithSuccess() public {
        setup();
        PublishMatchingTestCaseWithSuccess testCase = new PublishMatchingTestCaseWithSuccess(
                matchings(),
                matchingsTarget(),
                matchingsBids(),
                helpers,
                assertion
            );
        testCase.run();
    }

    ///@notice publish matching test case with invalid sender
    function testPublishMatchingWithInvalidSender() public {
        setup();
        PublishMatchingTestCaseWithInvalidSender testCase = new PublishMatchingTestCaseWithInvalidSender(
                matchings(),
                matchingsTarget(),
                matchingsBids(),
                helpers,
                assertion
            );
        testCase.run();
    }

    ///@notice publish matching test case with invalid dataset
    function testPublishMatchingWithInvalidDataset() public {
        setup();
        PublishMatchingTestCaseWithInvalidDataset testCase = new PublishMatchingTestCaseWithInvalidDataset(
                matchings(),
                matchingsTarget(),
                matchingsBids(),
                helpers,
                assertion
            );
        testCase.run();
    }

    ///@notice publish matching test case with invalid data provider
    function testPublishMatchingWithInvalidDataPreparer() public {
        setup();
        PublishMatchingTestCaseWithInvalidDataPreparer testCase = new PublishMatchingTestCaseWithInvalidDataPreparer(
                matchings(),
                matchingsTarget(),
                matchingsBids(),
                helpers,
                assertion
            );
        testCase.run();
    }

    ///@notice publish matching test case with invalid replica
    function testPublishMatchingWithInvalidReplica() public {
        setup();
        PublishMatchingTestCaseWithInvalidReplica testCase = new PublishMatchingTestCaseWithInvalidReplica(
                matchings(),
                matchingsTarget(),
                matchingsBids(),
                helpers,
                assertion
            );
        testCase.run();
    }
}
