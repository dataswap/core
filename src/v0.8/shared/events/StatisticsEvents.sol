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

library StatisticsEvents {
    /**
     * @dev Event triggered to record count statistics.
     *
     * @param _height The height of the statistics.
     * @param _totalCount The total count.
     * @param _successCount The count of successful operations.
     * @param _failedCount The count of failed operations.
     * @param _totalSize The total size.
     * @param _successSize The size of successful operations.
     * @param _failedSize The size of failed operations.
     */
    event DataStatistics(
        uint64 indexed _height,
        uint256 _totalCount,
        uint256 _successCount,
        uint256 _failedCount,
        uint256 _totalSize,
        uint256 _successSize,
        uint256 _failedSize
    );
}
