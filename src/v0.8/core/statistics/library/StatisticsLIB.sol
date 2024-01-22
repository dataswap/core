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

import {StatisticsType} from "src/v0.8/types/StatisticsType.sol";

/// @title StatisticsLIB Library
/// @notice Library for handling general statistics operations
library StatisticsLIB {
    /// @notice Adds to the total in the statistics data
    function addTotal(
        StatisticsType.Statistics storage self,
        uint256 size
    ) external {
        self.total += size;
    }

    /// @notice Adds to the success in the statistics data
    function addSuccess(
        StatisticsType.Statistics storage self,
        uint256 size
    ) external {
        uint256 ongoing = self.total - self.success - self.failed;
        require(size <= ongoing, "invalid size to addSuccess");
        self.success += size;
    }

    /// @notice Adds to the failed in the statistics data
    function addFailed(
        StatisticsType.Statistics storage self,
        uint256 size
    ) external {
        uint256 ongoing = self.total - self.success - self.failed;
        require(size <= ongoing, "invalid size to addFailed");
        self.failed += size;
    }

    /// @notice Retrieves details from the statistics data
    function getOverview(
        StatisticsType.Statistics storage self
    )
        external
        view
        returns (
            uint256 total,
            uint256 success,
            uint256 ongoing,
            uint256 failed
        )
    {
        return (
            self.total,
            self.success,
            self.total - self.success - self.failed,
            self.failed
        );
    }
}
