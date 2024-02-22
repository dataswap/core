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
import "test/v0.8/testcases/core/filplus/CompliantFilplusRuleTestSuite.sol";
import {FilplusTestSetup} from "test/v0.8/uinttests/core/filplus/setup/FilplusTestSetup.sol";

contract CompliantFilplusRuleTest is Test, FilplusTestSetup {
    /// @notice test case with success
    function testCompliantFilplusRuleWithGeolocationSuccess() public {
        setup();
        CompliantFilplusRuleTestCaseWithGeolocationSuccess testCase = new CompliantFilplusRuleTestCaseWithGeolocationSuccess(
                filplus(),
                assertion,
                generator(),
                governanceContractAddresss()
            );
        testCase.run();
    }

    /// @notice test case with min regions per dataset
    function testCompliantFilplusRuleWithMinRegions() public {
        setup();
        CompliantFilplusRuleTestCaseWithMinRegions testCase = new CompliantFilplusRuleTestCaseWithMinRegions(
                filplus(),
                assertion,
                generator(),
                governanceContractAddresss()
            );
        testCase.run();
    }

    /// @notice test case with max replicas per country
    function testCompliantFilplusRuleWithMaxReplicasPerCountry() public {
        setup();
        CompliantFilplusRuleTestCaseWithMaxReplicasPerCountry testCase = new CompliantFilplusRuleTestCaseWithMaxReplicasPerCountry(
                filplus(),
                assertion,
                generator(),
                governanceContractAddresss()
            );
        testCase.run();
    }

    /// @notice test case with invalid citys
    function testCompliantFilplusRuleWithInvalidNilCitys() public {
        setup();
        CompliantFilplusRuleTestCaseWithInvalidNilCitys testCase = new CompliantFilplusRuleTestCaseWithInvalidNilCitys(
                filplus(),
                assertion,
                generator(),
                governanceContractAddresss()
            );
        testCase.run();
    }

    /// @notice test case with invalid duplicate citys
    function testCompliantFilplusRuleWithInvalidDuplicateCity() public {
        setup();
        CompliantFilplusRuleTestCaseWithInvalidDuplicateCity testCase = new CompliantFilplusRuleTestCaseWithInvalidDuplicateCity(
                filplus(),
                assertion,
                generator(),
                governanceContractAddresss()
            );
        testCase.run();
    }

    /// @notice test case with over max replicas per city
    function testCompliantFilplusRuleWithMaxReplicasPerCity() public {
        setup();
        CompliantFilplusRuleTestCaseWithMaxReplicasPerCity testCase = new CompliantFilplusRuleTestCaseWithMaxReplicasPerCity(
                filplus(),
                assertion,
                generator(),
                governanceContractAddresss()
            );
        testCase.run();
    }

    /// @notice test case proportion with success.
    function testCompliantFilplusRuleWithProportionSuccess() public {
        setup();
        CompliantFilplusRuleTestCaseWithProportionSuccess testCase = new CompliantFilplusRuleTestCaseWithProportionSuccess(
                filplus(),
                assertion,
                generator(),
                governanceContractAddresss()
            );
        testCase.run();
    }

    /// @notice test case proportion with overflow.
    function testCompliantFilplusRuleWithProportionOverflow() public {
        setup();
        CompliantFilplusRuleTestCaseWithProportionOverflow testCase = new CompliantFilplusRuleTestCaseWithProportionOverflow(
                filplus(),
                assertion,
                generator(),
                governanceContractAddresss()
            );
        testCase.run();
    }

    /// @notice test case total replicas with success.
    function testCompliantFilplusRuleWithTotalReplicasSuccess() public {
        setup();
        CompliantFilplusRuleTestCaseWithTotalReplicasSuccess testCase = new CompliantFilplusRuleTestCaseWithTotalReplicasSuccess(
                filplus(),
                assertion,
                generator(),
                governanceContractAddresss()
            );
        testCase.run();
    }

    /// @notice test case total replicas with invalid countrys.
    function testCompliantFilplusRuleWithInvalidCountrys() public {
        setup();
        CompliantFilplusRuleTestCaseWithInvalidCountrys testCase = new CompliantFilplusRuleTestCaseWithInvalidCountrys(
                filplus(),
                assertion,
                generator(),
                governanceContractAddresss()
            );
        testCase.run();
    }

    /// @notice test case total replicas with max replicas overflow.
    function testCompliantFilplusRuleWithMaxReplicasOverflow() public {
        setup();
        CompliantFilplusRuleTestCaseWithMaxReplicasOverflow testCase = new CompliantFilplusRuleTestCaseWithMaxReplicasOverflow(
                filplus(),
                assertion,
                generator(),
                governanceContractAddresss()
            );
        testCase.run();
    }

    /// @notice test case total replicas with min replicas overflow.
    function testCompliantFilplusRuleWithMinReplicasOverflow() public {
        setup();
        CompliantFilplusRuleTestCaseWithMinReplicasOverflow testCase = new CompliantFilplusRuleTestCaseWithMinReplicasOverflow(
                filplus(),
                assertion,
                generator(),
                governanceContractAddresss()
            );
        testCase.run();
    }

    /// @notice test case sps per dataset with success.
    function testCompliantFilplusRuleWithSPsPerDatasetSuccess() public {
        setup();
        CompliantFilplusRuleTestCaseWithSPsPerDatasetSuccess testCase = new CompliantFilplusRuleTestCaseWithSPsPerDatasetSuccess(
                filplus(),
                assertion,
                generator(),
                governanceContractAddresss()
            );
        testCase.run();
    }

    /// @notice test case sps per dataset with overflow.
    function testCompliantFilplusRuleWithSPsPerDatasetOverflow() public {
        setup();
        CompliantFilplusRuleTestCaseWithSPsPerDatasetOverflow testCase = new CompliantFilplusRuleTestCaseWithSPsPerDatasetOverflow(
                filplus(),
                assertion,
                generator(),
                governanceContractAddresss()
            );
        testCase.run();
    }
}
