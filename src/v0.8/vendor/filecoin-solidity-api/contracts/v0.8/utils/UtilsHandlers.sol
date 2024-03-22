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

import "../types/CommonTypes.sol";

import "../cbor/FilecoinCbor.sol";

import "../utils/Actor.sol";

/// @title Library containing common handler functions used in the project
/// @author Zondax AG
library UtilsHandlers {
    using FilecoinCBOR for *;

    /// @notice the codec received is not valid
    error InvalidCodec(uint64);

    /// @notice filecoin method not handled
    error MethodNotHandled(uint64);

    /// @notice utility function meant to handle calls from other builtin actors. Arguments are passed as cbor serialized data (in filecoin native format)
    /// @param method the filecoin method id that is being called
    /// @param params raw data (in bytes) passed as arguments to the method call
    function handleFilecoinMethod(uint64 method, uint64 codec, bytes calldata params) internal pure returns (CommonTypes.UniversalReceiverParams memory) {
        if (method == CommonTypes.UniversalReceiverHookMethodNum) {
            if (codec != Misc.CBOR_CODEC) {
                revert InvalidCodec(codec);
            }

            return params.deserializeUniversalReceiverParams();
        } else {
            revert MethodNotHandled(method);
        }
    }

    /// @param target The actor id you want to interact with
    function universalReceiverHook(CommonTypes.FilActorId target, CommonTypes.UniversalReceiverParams memory params) internal returns (int256, bytes memory) {
        bytes memory raw_request = params.serializeUniversalReceiverParams();

        (int256 exit_code, bytes memory result) = Actor.callByID(target, CommonTypes.UniversalReceiverHookMethodNum, Misc.CBOR_CODEC, raw_request, 0, false);

        return (exit_code, result);
    }
}
