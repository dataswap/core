/*******************************************************************************
 *   (c) 2024 dataswap
 *
 *  Licensed under either the MIT License (the "MIT License") or the Apache License, Version 2.0
 *  (the "Apache License"). You may not use this file except in compliance with one of these
 *  licenses. You may obtain a copy of the MIT License at
 *
 *      https://opensource.org/licenses/MIT
 *
 *  Or the Apache License, Version 2.0 at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the MIT License or the Apache License for the specific language governing permissions and
 *  limitations under the respective licenses.
 ********************************************************************************/

// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.21;

import {FinanceType} from "src/v0.8/types/FinanceType.sol";

interface IBusinessFinance {
    /// @notice Retrieves payee information for a specific identifier and finance type.
    /// @dev This external function is used to get the payee addresses and corresponding amounts for a given identifier and finance type.
    /// @param _Id The unique identifier associated with the finance information.
    /// @param _type The type of finance information (e.g., FinanceType.Type).
    /// @return _payee An array of payee addresses.
    /// @return _amount An array of corresponding amounts for each payee.
    function getPayeeInfo(
        uint64 _Id,
        FinanceType.Type _type
    ) external returns (address[] memory _payee, uint256[] memory _amount);

    /// @notice Retrieves payer information for a specific identifier and finance type.
    /// @dev This external function is used to get the payer address and corresponding amount for a given identifier and finance type.
    /// @param _Id The unique identifier associated with the finance information.
    /// @param _type The type of finance information (e.g., FinanceType.Type).
    /// @return _payer The address of the payer.
    /// @return _amount The amount paid by the payer.
    function getPayerInfo(
        uint64 _Id,
        FinanceType.Type _type
    ) external returns (address _payer, uint256 _amount);
}
