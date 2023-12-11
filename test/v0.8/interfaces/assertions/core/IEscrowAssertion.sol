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

import {EscrowType} from "src/v0.8/types/EscrowType.sol";

/// @title IEscrowAssertion
/// @dev This interface defines assertion methods for testing conditional escrow-related functionality.
/// All methods that do not change the state must be tested by methods that will change the state to ensure test coverage.
interface IEscrowAssertion {
    /// @dev Asserts the get beneficiaries list.
    /// @param _type The Escrow type for the credited funds.
    /// @param _owner The destination address for the credited funds.
    /// @param _id The business id associated with the credited funds.
    /// @param _beneficiaries The beneficiary list.
    function getBeneficiariesListAssertion(
        EscrowType.Type _type,
        address _owner,
        uint64 _id,
        address[] memory _beneficiaries
    ) external;

    /// @dev Asserts the get beneficiary funds.
    /// @param _type The Escrow type for the credited funds.
    /// @param _owner The destination address for the credited funds.
    /// @param _id The business id associated with the credited funds.
    /// @param _beneficiary The beneficiary address for the payment credited funds.
    function getBeneficiaryFundAssertion(
        EscrowType.Type _type,
        address _owner,
        uint64 _id,
        address _beneficiary,
        uint256 _total, // Total amount in fund account
        uint256 _lock, // Lock amount in fund account for payment beneficiaries
        uint256 _collateral, // Collateral amount in fund account for withdraw and punishment
        uint256 _burned, // burned amount in fund account
        uint64 _createdBlockNumber // Fund account created block number
    ) external;

    /// @dev Asserts the get owner funds.
    /// @param _type The Escrow type for the credited funds.
    /// @param _owner The destination address for the credited funds.
    /// @param _id The business id associated with the credited funds.
    function getOwnerFundAssertion(
        EscrowType.Type _type,
        address _owner,
        uint64 _id,
        uint256 _total, // Total amount in fund account
        uint256 _lock, // Lock amount in fund account for payment beneficiaries
        uint256 _collateral, // Collateral amount in fund account for withdraw and punishment
        uint256 _burned, // burned amount in fund account
        uint64 _createdBlockNumber // Fund account created block number
    ) external;
}
