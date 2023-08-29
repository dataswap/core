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
import {SetVariableOfUint8TestSuiteBase} from "test/v0.8/testcases/core/filplus/abstract/FilplusTestSuiteBase.sol";

/// @notice set datasetRuleMaxProportionOfMappingFilesToDataset test case,it should be success
contract SetDatasetRuleMaxProportionOfMappingFilesToDatasetTestCaseWithSuccess is
    SetVariableOfUint8TestSuiteBase
{
    constructor(
        IFilplus _filplus,
        IFilplusAssertion _assertion,
        Generator _generator,
        address _governanceContractAddresss
    )
        SetVariableOfUint8TestSuiteBase(
            _filplus,
            _assertion,
            _generator,
            _governanceContractAddresss
        ) // solhint-disable-next-line
    {}

    function before(uint8 _newValue) internal virtual override {}

    function action(uint8 _newValue) internal virtual override {
        vm.expectEmit(true, false, false, true);
        emit FilplusEvents.SetDatasetRuleMaxProportionOfMappingFilesToDataset(
            _newValue
        );
        assertion.setDatasetRuleMaxProportionOfMappingFilesToDatasetAssertion(
            governanceContractAddresss,
            _newValue
        );
    }
}

/// @notice set datasetRuleMaxProportionOfMappingFilesToDataset test case with invalid governancer,it should be capture revert
contract SetDatasetRuleMaxProportionOfMappingFilesToDatasetTestCaseWithInvalidGovernancer is
    SetVariableOfUint8TestSuiteBase
{
    constructor(
        IFilplus _filplus,
        IFilplusAssertion _assertion,
        Generator _generator,
        address _governanceContractAddresss
    )
        SetVariableOfUint8TestSuiteBase(
            _filplus,
            _assertion,
            _generator,
            _governanceContractAddresss
        ) // solhint-disable-next-line
    {}

    function before(uint8 _newValue) internal virtual override {}

    function action(uint8 _newValue) internal virtual override {
        address addr = generator.generateAddress(100);
        vm.expectRevert(bytes("Only allowed address can call"));
        assertion.setDatasetRuleMaxProportionOfMappingFilesToDatasetAssertion(
            addr,
            _newValue
        );
    }
}
