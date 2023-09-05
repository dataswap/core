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

import {IDataswapStorageAssertion} from "test/v0.8/interfaces/assertions/service/IDataswapStorageAssertion.sol";
import {IStoragesAssertion} from "test/v0.8/interfaces/assertions/module/IStoragesAssertion.sol";
import {IMatchingsAssertion} from "test/v0.8/interfaces/assertions/module/IMatchingsAssertion.sol";
import {IDatasetsAssertion} from "test/v0.8/interfaces/assertions/module/IDatasetsAssertion.sol";
import {IDatacapsAssertion} from "test/v0.8/interfaces/assertions/module/IDatacapsAssertion.sol";
import {IRolesAssertion} from "test/v0.8/interfaces/assertions/core/IRolesAssertion.sol";
import {IFilplusAssertion} from "test/v0.8/interfaces/assertions/core/IFilplusAssertion.sol";
import {IFilecoinAssertion} from "test/v0.8/interfaces/assertions/core/IFilecoinAssertion.sol";
import {ICarstoreAssertion} from "test/v0.8/interfaces/assertions/core/ICarstoreAssertion.sol";

/// @title ServiceAssertionBase
/// @notice Abstract contract that defines the base for Dataswap storage service assertion base.
abstract contract ServiceAssertionBase is IDataswapStorageAssertion {
    address internal governanceContractAddress; // solhint-disable-next-line
    ICarstoreAssertion carstoreAssertion; // solhint-disable-next-line
    IFilecoinAssertion filecoinAssertion; // solhint-disable-next-line
    IFilplusAssertion filplusAssertion; // solhint-disable-next-line
    IRolesAssertion rolesAssertion; // solhint-disable-next-line
    IDatacapsAssertion datacapsAssertion; // solhint-disable-next-line
    IDatasetsAssertion datasetsAssertion; // solhint-disable-next-line
    IStoragesAssertion storagesAssertion; // solhint-disable-next-line
    IMatchingsAssertion matchingsAssertion; // solhint-disable-next-line

    /// @notice Constructor to initialize contract instances and setup environment
    /// @param _governanceContractAddress Address of the governance contract
    constructor(
        address _governanceContractAddress,
        ICarstoreAssertion _carstoreAssertion,
        IFilecoinAssertion _filecoinAssertion,
        IFilplusAssertion _filplusAssertion,
        IRolesAssertion _rolesAssertion,
        IDatacapsAssertion _datacapsAssertion,
        IDatasetsAssertion _datasetsAssertion,
        IMatchingsAssertion _matchingsAssertion,
        IStoragesAssertion _storagesAssertion
    ) {
        governanceContractAddress = _governanceContractAddress;
        carstoreAssertion = _carstoreAssertion;
        filecoinAssertion = _filecoinAssertion;
        filplusAssertion = _filplusAssertion;
        rolesAssertion = _rolesAssertion;
        datacapsAssertion = _datacapsAssertion;
        datasetsAssertion = _datasetsAssertion;
        matchingsAssertion = _matchingsAssertion;
        storagesAssertion = _storagesAssertion;
    }
}
