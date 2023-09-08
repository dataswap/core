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

import {Errors} from "src/v0.8/shared/errors/Errors.sol";
import {FilplusEvents} from "src/v0.8/shared/events/FilplusEvents.sol";
import {Generator} from "test/v0.8/helpers/utils/Generator.sol";
import {IFilplus} from "src/v0.8/interfaces/core/IFilplus.sol";
import {IFilplusAssertion} from "test/v0.8/interfaces/assertions/core/IFilplusAssertion.sol";
import {SetDatasetRuleMaxReplicasInCountryTestSuiteBase} from "test/v0.8/testcases/core/filplus/abstract/FilplusTestSuiteBase.sol";

/// @notice set datasetRuleMaxReplicasInCountries test case,it should be success
contract SetDatasetRuleMaxReplicasInCountryTestCaseWithSuccess is
    SetDatasetRuleMaxReplicasInCountryTestSuiteBase
{
    constructor(
        IFilplus _filplus,
        IFilplusAssertion _assertion,
        Generator _generator,
        address _governanceContractAddresss
    )
        SetDatasetRuleMaxReplicasInCountryTestSuiteBase(
            _filplus,
            _assertion,
            _generator,
            _governanceContractAddresss
        ) // solhint-disable-next-line
    {}

    function before(
        uint16 /*_countryCode*/,
        uint16 _newValue
    ) internal virtual override {
        vm.assume(_newValue != 0);
    }

    function action(
        uint16 _countryCode,
        uint16 _newValue
    ) internal virtual override {
        vm.expectEmit(true, true, false, true);
        emit FilplusEvents.SetDatasetRuleMaxReplicasInCountry(
            _countryCode,
            _newValue
        );
        assertion.setDatasetRuleMaxReplicasInCountryAssertion(
            governanceContractAddresss,
            _countryCode,
            _newValue
        );
    }
}

/// @notice set datasetRuleMaxReplicasInCountries test case with invalid governancer,it should be capture revert
contract SetDatasetRuleMaxReplicasInCountryTestCaseWithInvalidGovernancer is
    SetDatasetRuleMaxReplicasInCountryTestSuiteBase
{
    constructor(
        IFilplus _filplus,
        IFilplusAssertion _assertion,
        Generator _generator,
        address _governanceContractAddresss
    )
        SetDatasetRuleMaxReplicasInCountryTestSuiteBase(
            _filplus,
            _assertion,
            _generator,
            _governanceContractAddresss
        ) // solhint-disable-next-line
    {}

    function before(
        uint16 /*_countryCode*/,
        uint16 _newValue
    ) internal virtual override {
        vm.assume(_newValue != 0);
    }

    function action(
        uint16 _countryCode,
        uint16 _newValue
    ) internal virtual override {
        address addr = generator.generateAddress(100);
        vm.expectRevert(bytes("Only allowed address can call"));
        assertion.setDatasetRuleMaxReplicasInCountryAssertion(
            addr,
            _countryCode,
            _newValue
        );
    }
}

/// @notice set datasetRuleMaxReplicasInCountries test case with zero value,it should be capture revert
contract SetDatasetRuleMaxReplicasInCountryTestCaseWithZeroValue is
    SetDatasetRuleMaxReplicasInCountryTestSuiteBase
{
    constructor(
        IFilplus _filplus,
        IFilplusAssertion _assertion,
        Generator _generator,
        address _governanceContractAddresss
    )
        SetDatasetRuleMaxReplicasInCountryTestSuiteBase(
            _filplus,
            _assertion,
            _generator,
            _governanceContractAddresss
        ) // solhint-disable-next-line
    {}

    function before(
        uint16 /*_countryCode*/,
        uint16 _newValue
    ) internal virtual override {
        vm.assume(_newValue == 0);
    }

    function action(
        uint16 _countryCode,
        uint16 _newValue
    ) internal virtual override {
        vm.expectRevert(bytes("Value must not be zero"));
        assertion.setDatasetRuleMaxReplicasInCountryAssertion(
            governanceContractAddresss,
            _countryCode,
            _newValue
        );
    }
}
