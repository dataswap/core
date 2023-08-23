/*******************************************************************************
 *   (c) 2023 DataSwap
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

/// @title ModifierCommon
contract CommonModifiers {
    /// @dev Modifier to check if an ID is not zero.
    modifier onlyNotZero(uint64 _value) {
        require(_value != 0, "Value must not be zero");
        _;
    }

    /// @dev Modifier to check if an address is not zero
    modifier onlyNotZeroAddress(address _address) {
        require(address(0) != _address, "Address must not be zero");
        _;
    }

    /// @dev Modifier to check the sender's address
    modifier onlyAddress(address allowedAddress) {
        require(msg.sender == allowedAddress, "Only allowed address can call");
        _;
    }
}
