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

/// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.21;

/// @title CommonType Library
/// @notice This library defines common data structures used for geolocation and storage provider information.
/// @dev This library provides structs to represent geolocation and storage provider details.
library CommonType {
    /// @notice Struct representing geolocation information.
    struct Geolocation {
        bytes2 regionCode; // Code representing the region
        bytes2 countryCode; // Code representing the country
        bytes2 cityCode; // Code representing the city
    }

    /// @notice Struct representing storage provider information.
    struct StorageProvider {
        string nodeId; // Identifier for the storage provider's node
        string organization; // Name of the organization providing storage
    }
}
