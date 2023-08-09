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

import "../../../types/StorageDealType.sol";

/// @title DatacapChunkProofVerifier Library
/// @notice This library provides functions to verify data cap chunk proofs for storage deals.
/// @dev This library is intended to be used in conjunction with storage deal contracts.
library DatacapChunkProofVerifier {
    /// @notice Verify a data cap chunk proof for a given storage deal and car proof.
    /// @param _storageDeal The storage deal to which the data cap proof is associated.
    /// @param _proof The car proof containing the data cap chunk proof.
    /// @return A boolean indicating whether the verification was successful.
    function verify(
        StorageDealType.StorageDeal memory _storageDeal,
        StorageDealType.CarProof memory _proof
    ) external returns (bool) {}
}
