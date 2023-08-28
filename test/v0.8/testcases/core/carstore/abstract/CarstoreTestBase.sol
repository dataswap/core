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

import {ICarstore} from "src/v0.8/interfaces/core/ICarstore.sol";
import {ICarstoreAssertion} from "test/v0.8/interfaces/assertions/core/ICarstoreAssertion.sol";

/// @title CarstoreTestBase
/// @dev Base contract for carstore test cases with a common constructor.
abstract contract CarstoreTestBase {
    ICarstore internal carstore; // The carstore contract for managing cars.
    ICarstoreAssertion internal assertion; // The assertion contract for verifying carstore operations.

    /// @dev Constructor to initialize the carstore and assertion contracts.
    /// @param _carstore The carstore contract for managing cars.
    /// @param _assertion The assertion contract for verifying carstore operations.
    constructor(ICarstore _carstore, ICarstoreAssertion _assertion) {
        carstore = _carstore;
        assertion = _assertion;
    }
}
