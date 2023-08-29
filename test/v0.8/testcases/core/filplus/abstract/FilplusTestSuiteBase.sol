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
import {FilplusTestBase} from "test/v0.8/testcases/core/filplus/abstract/FilplusTestBase.sol";
import {Generator} from "test/v0.8/helpers/utils/Generator.sol";

import {IFilplus} from "src/v0.8/interfaces/core/IFilplus.sol";
import {IFilplusAssertion} from "test/v0.8/interfaces/assertions/core/IFilplusAssertion.sol";

/// @title SetVariableOfUint64TestSuiteBase
/// @dev Base contract for test suites related to variable of type uint64 to the filplus.
abstract contract SetVariableOfUint64TestSuiteBase is FilplusTestBase, Test {
    constructor(
        IFilplus _filplus,
        IFilplusAssertion _assertion,
        Generator _generator,
        address _governanceContractAddresss
    )
        FilplusTestBase(
            _filplus,
            _assertion,
            _generator,
            _governanceContractAddresss
        )
    {}

    /// @dev Called before running the test to set up the test scenario.
    /// @param _newValue The new value of the public variable.
    function before(uint64 _newValue) internal virtual;

    /// @dev The main action of the test, where the set the variable to the filplus.
    /// @param _newValue The new value of the public variables.
    function action(uint64 _newValue) internal virtual;

    /// @dev Called after running the test to perform any necessary cleanup or validation.
    /// @param _newValue The new value of the public variables.
    function after_(uint64 _newValue) internal virtual {}

    /// @dev Runs the test to set variables to the filplus.
    /// @param _newValue The new value of the public variable.
    function run(uint64 _newValue) public {
        before(_newValue);
        action(_newValue);
        after_(_newValue);
    }
}

/// @title SetVariableOfUint16TestSuiteBase
/// @dev Base contract for test suites related to variable of type uint16 to the filplus.
abstract contract SetVariableOfUint16TestSuiteBase is FilplusTestBase, Test {
    constructor(
        IFilplus _filplus,
        IFilplusAssertion _assertion,
        Generator _generator,
        address _governanceContractAddresss
    )
        FilplusTestBase(
            _filplus,
            _assertion,
            _generator,
            _governanceContractAddresss
        )
    {}

    /// @dev Called before running the test to set up the test scenario.
    /// @param _newValue The new value of the public variable.
    function before(uint16 _newValue) internal virtual;

    /// @dev The main action of the test, where the set the variable to the filplus.
    /// @param _newValue The new value of the public variables.
    function action(uint16 _newValue) internal virtual;

    /// @dev Called after running the test to perform any necessary cleanup or validation.
    /// @param _newValue The new value of the public variables.
    function after_(uint16 _newValue) internal virtual {}

    /// @dev Runs the test to set variables to the filplus.
    /// @param _newValue The new value of the public variable.
    function run(uint16 _newValue) public {
        before(_newValue);
        action(_newValue);
        after_(_newValue);
    }
}

/// @title SetVariableOfUint8TestSuiteBase
/// @dev Base contract for test suites related to variable of type uint8 to the filplus.
abstract contract SetVariableOfUint8TestSuiteBase is FilplusTestBase, Test {
    constructor(
        IFilplus _filplus,
        IFilplusAssertion _assertion,
        Generator _generator,
        address _governanceContractAddresss
    )
        FilplusTestBase(
            _filplus,
            _assertion,
            _generator,
            _governanceContractAddresss
        )
    {}

    /// @dev Called before running the test to set up the test scenario.
    /// @param _newValue The new value of the public variable.
    function before(uint8 _newValue) internal virtual;

    /// @dev The main action of the test, where the set the variable to the filplus.
    /// @param _newValue The new value of the public variables.
    function action(uint8 _newValue) internal virtual;

    /// @dev Called after running the test to perform any necessary cleanup or validation.
    /// @param _newValue The new value of the public variables.
    function after_(uint8 _newValue) internal virtual {}

    /// @dev Runs the test to set variables to the filplus.
    /// @param _newValue The new value of the public variable.
    function run(uint8 _newValue) public {
        before(_newValue);
        action(_newValue);
        after_(_newValue);
    }
}

/// @title SetDatasetRuleMaxReplicasInCountryTestSuiteBase
/// @dev Base contract for test suites related to max replicas in countries to the filplus.
abstract contract SetDatasetRuleMaxReplicasInCountryTestSuiteBase is
    FilplusTestBase,
    Test
{
    constructor(
        IFilplus _filplus,
        IFilplusAssertion _assertion,
        Generator _generator,
        address _governanceContractAddresss
    )
        FilplusTestBase(
            _filplus,
            _assertion,
            _generator,
            _governanceContractAddresss
        )
    {}

    /// @dev Called before running the test to set up the test scenario.
    /// @param _countryCode The country code the mapping datasetRuleMaxReplicasInCountries.
    /// @param _newValue The new value of max replicas in countries of the datasetRuleMaxReplicasInCountries.
    function before(bytes32 _countryCode, uint16 _newValue) internal virtual;

    /// @dev The main action of the test, where the set the datasetRuleMaxReplicasInCountries to the filplus.
    /// @param _countryCode The country code the mapping datasetRuleMaxReplicasInCountries.
    /// @param _newValue The new value of max replicas in countries of the datasetRuleMaxReplicasInCountries.
    function action(bytes32 _countryCode, uint16 _newValue) internal virtual;

    /// @dev Called after running the test to perform any necessary cleanup or validation.
    /// @param _countryCode The country code the mapping datasetRuleMaxReplicasInCountries.
    /// @param _newValue The new value of max replicas in countries of the datasetRuleMaxReplicasInCountries.
    function after_(bytes32 _countryCode, uint16 _newValue) internal virtual {}

    /// @dev Runs the test to set datasetRuleMaxReplicasInCountries to the filplus.
    /// @param _countryCode The country code the mapping datasetRuleMaxReplicasInCountries.
    /// @param _newValue The new value of max replicas in countries of the datasetRuleMaxReplicasInCountries.
    function run(bytes32 _countryCode, uint16 _newValue) public {
        before(_countryCode, _newValue);
        action(_countryCode, _newValue);
        after_(_countryCode, _newValue);
    }
}
