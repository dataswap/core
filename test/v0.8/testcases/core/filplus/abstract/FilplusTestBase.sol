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

import {IFilplus} from "src/v0.8/interfaces/core/IFilplus.sol";
import {IFilplusAssertion} from "test/v0.8/interfaces/assertions/core/IFilplusAssertion.sol";
import {Generator} from "test/v0.8/helpers/utils/Generator.sol";

/// @title FilplusTestBase
/// @dev Base contract for filplus test cases with a common constructor.
abstract contract FilplusTestBase {
    IFilplus internal filplus; // The filplus contract for managing cars.
    IFilplusAssertion internal assertion; // The assertion contract for verifying filplus operations.
    Generator internal generator;
    address internal governanceContractAddresss;

    constructor(
        IFilplus _filplus,
        IFilplusAssertion _assertion,
        Generator _generator,
        address _governanceContractAddresss
    ) {
        filplus = _filplus;
        assertion = _assertion;
        generator = _generator;
        governanceContractAddresss = _governanceContractAddresss;
    }
}
