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

/// @title IStoragesHelpers
/// @dev Interface for managing storage-related operations.
interface IStoragesHelpers {
    /// @notice Initialize a dataset and matching.
    /// @return datasetId The ID of the created dataset.
    /// @return matchingId The ID of the created matching.
    function setup() external returns (uint64 datasetId, uint64 matchingId);

    /// @notice Generate multiple Filecoin deal IDs.
    /// @param _count The number of Filecoin deal IDs to generate.
    /// @return filecoinDealIds An array of generated Filecoin deal IDs.
    function generateFilecoinDealIds(
        uint64 _count
    ) external returns (uint64[] memory filecoinDealIds);

    /// @notice Generate a single Filecoin deal ID.
    /// @return The generated Filecoin deal ID.
    function generateFilecoinDealId() external returns (uint64);
}
