/*******************************************************************************
 *   (c) 2022 Zondax AG
 *
 *  Licensed under the Apache License, Version 2.0 (the "License");
 *  you may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 ********************************************************************************/
// THIS CODE WAS SECURITY REVIEWED BY KUDELSKI SECURITY, BUT NOT FORMALLY AUDITED

// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.17;

import "src/v0.8/vendor/solidity-bignumber/src/BigNumbers.sol";

import "../types/CommonTypes.sol";
import "../utils/Misc.sol";

/// @notice This library is a set a functions that allows to handle filecoin addresses conversions and validations
/// @author Zondax AG
library BigInts {
    uint256 constant MAX_UINT = (2 ** 256) - 1;
    uint256 constant MAX_INT = ((2 ** 256) / 2) - 1;

    error NegativeValueNotAllowed();

    /// @notice allow to get a BigInt from a uint256 value
    /// @param value uint256 number
    /// @return new BigInt
    function fromUint256(
        uint256 value
    ) internal view returns (CommonTypes.BigInt memory) {
        BigNumber memory bigNum = BigNumbers.init(value, false);
        return CommonTypes.BigInt(bigNum.val, bigNum.neg);
    }

    /// @notice allow to get a BigInt from a int256 value
    /// @param value int256 number
    /// @return new BigInt
    function fromInt256(
        int256 value
    ) internal view returns (CommonTypes.BigInt memory) {
        uint256 valueAbs = Misc.abs(value);
        BigNumber memory bigNum = BigNumbers.init(valueAbs, value < 0);
        return CommonTypes.BigInt(bigNum.val, bigNum.neg);
    }

    /// @notice allow to get a uint256 from a BigInt value.
    /// @notice If the value is negative, it will generate an error.
    /// @param value BigInt number
    /// @return a uint256 value and flog that indicates whether it was possible to convert or not (the value overflows uint256 type)
    function toUint256(
        CommonTypes.BigInt memory value
    ) internal view returns (uint256, bool) {
        if (value.neg) {
            revert NegativeValueNotAllowed();
        }

        BigNumber memory max = BigNumbers.init(MAX_UINT, false);
        BigNumber memory bigNumValue = BigNumbers.init(value.val, value.neg);
        if (BigNumbers.gt(bigNumValue, max)) {
            return (0, true);
        }

        return (uint256(bytes32(bigNumValue.val)), false);
    }

    /// @notice allow to get a int256 from a BigInt value.
    /// @notice If the value is grater than what a int256 can store, it will generate an error.
    /// @param value BigInt number
    /// @return a int256 value and flog that indicates whether it was possible to convert or not (the value overflows int256 type)
    function toInt256(
        CommonTypes.BigInt memory value
    ) internal view returns (int256, bool) {
        BigNumber memory max = BigNumbers.init(MAX_INT, false);
        BigNumber memory bigNumValue = BigNumbers.init(value.val, false);
        if (BigNumbers.gt(bigNumValue, max)) {
            return (0, true);
        }

        int256 parsedValue = int256(uint256(bytes32(bigNumValue.val)));
        return (value.neg ? -1 * parsedValue : parsedValue, false);
    }
}
