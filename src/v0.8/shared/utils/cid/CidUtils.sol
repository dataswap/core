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

/// @title CidUtils
library CidUtils {
    /// @notice Convert a bytes32 hash to a CID.
    /// @dev This function converts a bytes32 hash to a CID using the specified encoding.
    ///      TODO:https://github.com/dataswap/core/issues/32
    /// @return The CID corresponding to the input hash.
    function hashToCID(bytes32 _hash) internal pure returns (bytes memory) {
        // Hardcoded, to be refined for full implementation.
        // From https://github.com/filecoin-project/go-fil-commcid/blob/master/commcid.go#CommitmentToCID
        uint64 filCommitmentUnsealed = 0xf101;
        uint64 sha256Trunc254Padded = 0x1012;

        bytes memory fBuf = bytes.concat(
            putUvarint(1),
            putUvarint(filCommitmentUnsealed)
        );

        bytes memory result = bytes.concat(
            putUvarint(sha256Trunc254Padded),
            putUvarint(_hash.length)
        );
        result = bytes.concat(result, _hash);

        return bytes.concat(fBuf, result);
    }

    /// @notice Convert an array of bytes32 hashes to an array of CIDs.
    /// @dev This function converts an array of bytes32 hashes to an array of CIDs using the specified encoding.
    /// @param _hashes The array of bytes32 hashes to convert.
    /// @return The array of CIDs corresponding to the input hashes.
    function hashesToCIDs(
        bytes32[] memory _hashes
    ) internal pure returns (bytes[] memory) {
        bytes[] memory cids = new bytes[](_hashes.length);
        for (uint256 i = 0; i < _hashes.length; i++) {
            cids[i] = hashToCID(bytes32(_hashes[i]));
        }
        return cids;
    }

    function putUvarint(uint64 _x) public pure returns (bytes memory) {
        uint8 i = 0;
        uint8[] memory buffer = new uint8[](10); // Requires up to 10 bytes

        while (_x >= 0x80) {
            buffer[i] = uint8(_x) | 0x80;
            _x >>= 7;
            i++;
        }
        buffer[i] = uint8(_x);

        bytes memory result = new bytes(i + 1);
        for (uint8 j = 0; j <= i; j++) {
            result[j] = bytes1(buffer[j]);
        }

        return result;
    }
}
