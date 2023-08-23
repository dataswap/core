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

// Import required external contracts and interfaces
import {Test} from "forge-std/Test.sol";
import {MatchingType} from "../../../../../../src/v0.8/types/MatchingType.sol";
import {DatasetType} from "../../../../../../src/v0.8/types/DatasetType.sol";
import {MatchingType} from "../../../../../../src/v0.8/types/MatchingType.sol";
import {MatchingTestSetupHelpers} from "./setup/MatchingTestSetupHelpers.sol";

// Contract definition for test functions
// @dev TODO:isMatchingTargetValid not implements and test
// @dev TODO:isMatchingTargetMeetsFilPlusRequirements not implements and test
contract MatchingPublishTestHelpers is Test, MatchingTestSetupHelpers {
    // step 2: do matching publish action,not decouple it if this function simple
    function publishMatching(
        uint64 _datasetId,
        DatasetType.DataType _dataType,
        uint64 _associatedMappingFilesMatchingID,
        MatchingType.BidSelectionRule _bidSelectionRule,
        uint64 _biddingDelayBlockCount,
        uint64 _biddingPeriodBlockCount,
        uint64 _storageCompletionPeriodBlocks,
        uint256 _biddingThreshold
    ) internal {
        bytes32[] memory cars = datasets.getDatasetCars(
            _datasetId,
            _dataType,
            0,
            datasets.getDatasetCarsCount(_datasetId, _dataType)
        );
        uint64 size = datasets.getDatasetSize(_datasetId, _dataType);
        matchings.publishMatching(
            _datasetId,
            cars,
            size,
            _dataType,
            _associatedMappingFilesMatchingID,
            _bidSelectionRule,
            _biddingDelayBlockCount,
            _biddingPeriodBlockCount,
            _storageCompletionPeriodBlocks,
            _biddingThreshold,
            ""
        );
    }

    /// @dev step 2: usually use this for setp2
    function publishMatchingWithDeaultPeriodStrategy(
        uint64 _datasetId,
        DatasetType.DataType _dataType,
        uint64 _associatedMappingFilesMatchingID,
        MatchingType.BidSelectionRule _bidSelectionRule
    ) internal {
        publishMatching(
            _datasetId,
            _dataType,
            _associatedMappingFilesMatchingID,
            _bidSelectionRule,
            100, //biddingDelayBlockCount
            100, //biddingPeriodBlockCount
            100, //storageCompletionPeriodBlocks
            100 //biddingThreshold
        );
    }
}
