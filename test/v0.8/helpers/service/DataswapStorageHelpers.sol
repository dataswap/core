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

// Import required external contracts and interfaces
import {Test} from "forge-std/Test.sol";
import {IDataswapStorageHelpers} from "test/v0.8/interfaces/helpers/service/IDataswapStorageHelpers.sol";
import {IDataswapStorage} from "src/v0.8/interfaces/service/IDataswapStorage.sol";
import {Generator} from "test/v0.8/helpers/utils/Generator.sol";
import {IDataswapStorageAssertion} from "test/v0.8/interfaces/assertions/service/IDataswapStorageAssertion.sol";

// Contract definition for test helper functions
contract DataswapStorageHelpers is Test, IDataswapStorageHelpers {
    IDataswapStorage public dataswapStorage;
    Generator private generator;
    IDataswapStorageAssertion private dataswapStorageAssertion;

    constructor(
        IDataswapStorage _dataswapStorage,
        Generator _generator,
        IDataswapStorageAssertion _dataswapStorageAssertion
    ) {
        dataswapStorage = _dataswapStorage;
        generator = _generator;
        dataswapStorageAssertion = _dataswapStorageAssertion;
    }

    /// @notice Generate a Merkle root hash.
    /// @return The generated Merkle root hash.
    function generateRoot() public returns (bytes32) {
        return generator.generateRoot();
    }
}
