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

library FilecoinType {
    /// @notice Enum representing the possible states of a Filecoin storage deal.
    enum DealState {
        Stored, // The filecoin deal's verification was successful.
        StorageFailed, // The filecoin deal's verification failed.
        Slashed, // The filecoin deal has been slashed.
        Expired // The filecoin deal has expired.
    }

    /// @notice filecoin network type
    enum Network {
        Mainnet,
        CalibrationTestnet,
        EndIdentifier
    }
}
