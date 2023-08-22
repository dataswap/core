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
import "forge-std/Test.sol";
import {MatchingType} from "../../../../../../src/v0.8/types/MatchingType.sol";
import {MatchingsEvents} from "../../../../../../src/v0.8/shared/events/MatchingsEvents.sol";
import {DatasetType} from "../../../../../../src/v0.8/types/DatasetType.sol";
import {MatchingType} from "../../../../../../src/v0.8/types/MatchingType.sol";
import {RolesType} from "../../../../../../src/v0.8/types/RolesType.sol";
import {MatchingPublishTestHelpers} from "./MatchingPublishTestHelpers.sol";

// Contract definition for test functions
// @dev TODO:isMatchingTargetValid not implements and test
// @dev TODO:isMatchingTargetMeetsFilPlusRequirements not implements and test
contract MatchingMappingFilesPublishTestHelpers is
    Test,
    MatchingPublishTestHelpers
{
    /// @dev step 1: setup the env for matching publish
    function setupForMatchingMappingFilesPublish() internal {
        assertApproveDatasetExpectingSuccess();
    }

    /// @dev step 3: assert result after matching published
    function assertMatchingMappingFilesPublished(
        uint64 _matchingId,
        uint64 _datasetId,
        uint64 _oldMatchingCount
    ) internal {
        //1 assert datasetId valid
        (uint64 datasetId, , , , ) = matchings.getMatchingTarget(_matchingId);
        assertEq(_datasetId, datasetId);

        //2 assert cars valid
        bytes32[] memory cars = datasets.getDatasetCars(
            _datasetId,
            DatasetType.DataType.MappingFiles,
            0,
            datasets.getDatasetCarsCount(
                _datasetId,
                DatasetType.DataType.MappingFiles
            )
        );
        bool isMatchingContainsCars = matchings.isMatchingContainsCars(
            _matchingId,
            cars
        );
        bool isMatchingContainsCar = matchings.isMatchingContainsCar(
            _matchingId,
            cars[0]
        );
        bool isDatasetContainCars = datasets.isDatasetContainsCars(
            _datasetId,
            matchings.getMatchingCars(_matchingId)
        );
        assertTrue(isMatchingContainsCars);
        assertTrue(isMatchingContainsCar);
        assertTrue(isDatasetContainCars);

        //3 assert cars size valid
        assertEq(
            matchings.getMatchingSize(_matchingId),
            datasets.getDatasetSize(
                _datasetId,
                DatasetType.DataType.MappingFiles
            )
        );

        //4 assert matchings count valid
        assertEq(_oldMatchingCount + 1, matchings.matchingsCount());
        //5 assert the  matching initiator
        assertEq(address(this), matchings.getMatchingInitiator(_matchingId));
        //6 assert the matching state
        assertEq(
            uint8(MatchingType.State.InProgress),
            uint8(matchings.getMatchingState(_matchingId))
        );
    }

    ///@dev success test and  as env set for other module
    function assertMatchingMappingFilesPublishExpectingSuccess() internal {
        /// @dev step 1: setup the env for matching publish
        setupForMatchingMappingFilesPublish();

        uint64 datasetId = datasets.datasetsCount();
        /// @dev step 2: do matching publish action,not decouple it if this function simple
        uint64 oldMatchingCount = matchings.matchingsCount();
        role.grantRole(RolesType.DATASET_PROVIDER, address(this));
        publishMatchingWithDeaultPeriodStrategy(
            datasetId,
            DatasetType.DataType.MappingFiles,
            0,
            MatchingType.BidSelectionRule.HighestBid
        );
        uint64 matchingId = matchings.matchingsCount();

        /// @dev step 3: assert result after matching published
        assertMatchingMappingFilesPublished(
            matchingId,
            datasetId,
            oldMatchingCount
        );
    }
}
