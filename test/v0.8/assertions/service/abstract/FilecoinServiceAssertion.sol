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
import {ServiceAssertionBase} from "test/v0.8/assertions/service/abstract/base/ServiceAssertionBase.sol";
import {FilecoinType} from "src/v0.8/types/FilecoinType.sol";

/// @title FilecoinServiceAssertion
abstract contract FilecoinServiceAssertion is ServiceAssertionBase {
    /// @notice Assertion function to get the mock Filecoin deal state for a given CID and Filecoin deal ID.
    /// @param _cid The CID (Content Identifier) of the data.
    /// @param _filecoinDealId The ID of the Filecoin deal.
    /// @param _state The expected Filecoin deal state to compare with.
    function getReplicaDealStateAssertion(
        bytes32 _cid,
        uint64 _filecoinDealId,
        FilecoinType.DealState _state
    ) public {
        filecoinAssertion.getReplicaDealStateAssertion(
            _cid,
            _filecoinDealId,
            _state
        );
    }

    /// @notice Assertion function to set the mock Filecoin deal state for a given CID and Filecoin deal ID.
    /// @param _cid The CID (Content Identifier) of the data.
    /// @param _filecoinDealId The ID of the Filecoin deal.
    /// @param _state The new Filecoin deal state to set.
    function setMockDealStateAssertion(
        bytes32 _cid,
        uint64 _filecoinDealId,
        FilecoinType.DealState _state
    ) external {
        filecoinAssertion.setMockDealStateAssertion(
            _cid,
            _filecoinDealId,
            _state
        );
    }
}
