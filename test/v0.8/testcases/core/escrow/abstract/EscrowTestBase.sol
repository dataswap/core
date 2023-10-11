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

import {IDatasets} from "src/v0.8/interfaces/module/IDatasets.sol";
import {IEscrow} from "src/v0.8/interfaces/core/IEscrow.sol";
import {IEscrowAssertion} from "test/v0.8/interfaces/assertions/core/IEscrowAssertion.sol";

/// @title EscrowTestBase
/// @dev Base contract for escrow test cases with a common constructor.
abstract contract EscrowTestBase {
    IDatasets internal datasets;
    IEscrow internal escrow;
    IEscrowAssertion internal assertion;

    /// @dev Constructor to initialize the escrow and assertion contracts.
    /// @param _datasets The datasets contract for managing datasets.
    /// @param _escrow The escrow contract for managing escrow.
    /// @param _assertion The assertion contract for verifying escrow operations.
    constructor(
        IDatasets _datasets,
        IEscrow _escrow,
        IEscrowAssertion _assertion
    ) {
        datasets = _datasets;
        escrow = _escrow;
        assertion = _assertion;
    }
}
