/*******************************************************************************
 *   (c) 2024 dataswap
 *
 *  Licensed under either the MIT License (the "MIT License") or the Apache License, Version 2.0
 *  (the "Apache License"). You may not use this file except in compliance with one of these
 *  licenses. You may obtain a copy of the MIT License at
 *
 *      https://opensource.org/licenses/MIT
 *
 *  Or the Apache License, Version 2.0 at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the MIT License or the Apache License for the specific language governing permissions and
 *  limitations under the respective licenses.
 ********************************************************************************/

// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.21;
import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {IStatistics} from "src/v0.8/interfaces/core/statistics/IStatistics.sol";
import {StatisticsType} from "src/v0.8/types/StatisticsType.sol";
import {StatisticsLIB} from "src/v0.8/core/statistics/library/StatisticsLIB.sol";
import {IRoles} from "src/v0.8/interfaces/core/IRoles.sol";

abstract contract StatisticsBase is Initializable, IStatistics {
    using StatisticsLIB for StatisticsType.Statistics;
    StatisticsType.Statistics internal count;
    StatisticsType.Statistics internal size;

    /// @dev This empty reserved space is put in place to allow future versions to add new
    uint256[32] private __gap;

    /// @notice statisticsBaseInitialize function to initialize the contract and grant the default admin role to the deployer.
    //solhint-disable-next-line
    function statisticsBaseInitialize() public virtual onlyInitializing {}

    /// @notice Internal function to add to the total count in the statistics.
    /// @param _size Size to be added to the total count.
    function _addCountTotal(uint256 _size) internal {
        count.addTotal(_size);
    }

    /// @notice Internal function to add to the total size in the statistics.
    /// @param _size Size to be added to the total size.
    function _addSizeTotal(uint256 _size) internal {
        size.addTotal(_size);
    }

    /// @notice Internal function to add to the success count in the statistics.
    /// @param _size Size to be added to the success count.
    function _addCountSuccess(uint256 _size) internal {
        count.addSuccess(_size);
    }

    /// @notice Internal function to add to the success size in the statistics.
    /// @param _size Size to be added to the success size.
    function _addSizeSuccess(uint256 _size) internal {
        size.addSuccess(_size);
    }

    /// @notice Internal function to add to the failed count in the statistics.
    /// @param _size Size to be added to the failed count.
    function _addCountFailed(uint256 _size) internal {
        count.addFailed(_size);
    }

    /// @notice Internal function to add to the failed size in the statistics.
    /// @param _size Size to be added to the failed size.
    function _addSizeFailed(uint256 _size) internal {
        size.addFailed(_size);
    }

    /// @notice Internal view function to retrieve the total count.
    /// @return total Total count.
    function _totalCount() internal view returns (uint256 total) {
        (total, , , ) = count.getOverview();
        return total;
    }

    // Count-related functions

    /// @notice Get an overview of the count statistics.
    /// @return total Total count.
    /// @return success Success count.
    /// @return ongoing Ongoing count.
    /// @return failed Failed count.
    function getCountOverview()
        external
        view
        returns (
            uint256 total,
            uint256 success,
            uint256 ongoing,
            uint256 failed
        )
    {
        return count.getOverview();
    }

    // Size-related functions

    /// @notice Get an overview of the size statistics.
    /// @return total Total size.
    /// @return success Success size.
    /// @return ongoing Ongoing size.
    /// @return failed Failed size.
    function getSizeOverview()
        external
        view
        returns (
            uint256 total,
            uint256 success,
            uint256 ongoing,
            uint256 failed
        )
    {
        return size.getOverview();
    }
}
