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
    /// @notice Convert car size to piece size.
    /// @param _size The input car size.
    /// @return The piece size.
    function carSizeToPieceSize(uint64 _size) internal pure returns (uint64) {
        // Hardcoded, to be refined for full implementation.
        // From https://github.com/dataswap/go-metadata/blob/main/service/proof.go#GenCommP
        uint64 sourceChunkSize = 127;
        uint64 mod = _size % sourceChunkSize;
        uint64 size = (mod != 0) ? _size + sourceChunkSize - mod : _size;
        return calculatePaddedPieceSize(size);
    }

    /// @notice Convert a bytes32 hash to a CID.
    /// @dev This function converts a bytes32 hash to a CID using the specified encoding.
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

    /// @notice Function to encode an unsigned integer as a Uvarint byte array
    /// @dev Encode an unsigned integer as a Uvarint byte array
    /// @param _x input parameter an unsigned integer
    /// @return the return of Uvarint byte array
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

    /**
     * @dev Calculates the number of set bits (ones) in a 64-bit unsigned integer.
     * @param _x The input 64-bit unsigned integer.
     * @return The number of set bits in the input integer.
     */
    function onesCount64(uint64 _x) public pure returns (uint256) {
        uint256 count = 0;
        for (uint256 i = 0; i < 64; i++) {
            if ((_x & (1 << i)) != 0) {
                count++;
            }
        }
        return count;
    }

    /**
     * @dev Calculates the number of leading zeros in a 64-bit unsigned integer.
     * @param _x The input 64-bit unsigned integer.
     * @return The number of leading zeros in the input integer.
     */
    function leadingZeros64(uint64 _x) public pure returns (uint256) {
        uint256 count = 0;
        for (uint256 i = 63; i >= 0; i--) {
            if ((_x & (1 << i)) == 0) {
                count++;
            } else {
                break;
            }
        }
        return count;
    }

    /// @notice Calculates the padded piece size to the nearest power of two greater than or equal to the input size.
    /// @param _size The input size.
    /// @return The nearest power of two size.
    function calculatePaddedPieceSize(
        uint64 _size
    ) public pure returns (uint64) {
        if (onesCount64(_size) != 1) {
            uint256 lz = leadingZeros64(_size);
            return uint64(1 << (64 - lz));
        } else {
            return _size;
        }
    }
}
