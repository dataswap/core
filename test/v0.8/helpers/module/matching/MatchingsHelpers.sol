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

// Import required external contracts and interfaces
import {Test} from "forge-std/Test.sol";
import {RolesType} from "src/v0.8/types/RolesType.sol";
import {DatasetType} from "src/v0.8/types/DatasetType.sol";
import {MatchingType} from "src/v0.8/types/MatchingType.sol";
import {IMatchings} from "src/v0.8/interfaces/module/IMatchings.sol";
import {IMatchingsHelpers} from "test/v0.8/interfaces/helpers/module/IMatchingsHelpers.sol";
import {IDatasetsHelpers} from "test/v0.8/interfaces/helpers/module/IDatasetsHelpers.sol";
import {IMatchingsAssertion} from "test/v0.8/interfaces/assertions/module/IMatchingsAssertion.sol";

/// @title MatchingsHelpers contract for testing
contract MatchingsHelpers is Test, IMatchingsHelpers {
    IMatchings matchings;
    IDatasetsHelpers datasetsHelpers;
    IMatchingsAssertion assertion;

    constructor(
        IMatchings _matchings,
        IDatasetsHelpers _datasetsHelpers,
        IMatchingsAssertion _assertion
    ) {
        matchings = _matchings;
        datasetsHelpers = _datasetsHelpers;
        assertion = _assertion;
    }

    /// @notice Setup a dataset and complete the dataset workflow.
    /// @param _accessMethod The access method for the dataset.
    /// @param _sourceLeavesCount The number of leaves for the source data.
    /// @param _mappingFilesLeavesCount The number of leaves for the mapping files data.
    /// @param _challengeCount The number of challenges.
    /// @param _challengeLeavesCount The number of leaves for each challenge.
    /// @return datasetId The ID of the created dataset.
    function setup(
        string memory _accessMethod,
        uint64 _sourceLeavesCount,
        uint64 _mappingFilesLeavesCount,
        uint64 _challengeCount,
        uint64 _challengeLeavesCount
    ) public returns (uint64 datasetId) {
        return
            datasetsHelpers.completeDatasetWorkflow(
                _accessMethod,
                _sourceLeavesCount,
                _mappingFilesLeavesCount,
                _challengeCount,
                _challengeLeavesCount
            );
    }

    /// @notice Get the cars and car count for a dataset of a specific data type.
    /// @param _datasetId The ID of the dataset.
    /// @param _dataType The data type of the dataset.
    /// @return cars An array of car hashes.
    /// @return size The size of the dataset.
    function getDatasetCarsAndCarsCount(
        uint64 _datasetId,
        DatasetType.DataType _dataType
    ) public view returns (bytes32[] memory cars, uint64 size) {
        size = matchings.datasets().getDatasetSize(_datasetId, _dataType);
        uint64 carsCount = matchings.datasets().getDatasetCarsCount(
            _datasetId,
            _dataType
        );
        cars = new bytes32[](carsCount);
        cars = matchings.datasets().getDatasetCars(
            _datasetId,
            DatasetType.DataType.MappingFiles,
            0,
            carsCount
        );
        return (cars, size);
    }

    /// @notice Complete the matching workflow for testing.
    /// @return datasetId The ID of the created dataset.
    /// @return matchingId The ID of the created matching.
    function completeMatchingWorkflow()
        external
        returns (uint64 datasetId, uint64 matchingId)
    {
        datasetId = setup("testAccessMethod", 100, 10, 10, 10);

        address admin = matchings.datasets().roles().getRoleMember(
            bytes32(0x00),
            0
        );
        vm.startPrank(admin);
        matchings.datasets().roles().grantRole(
            RolesType.DATASET_PROVIDER,
            address(99)
        );
        vm.stopPrank();

        (bytes32[] memory cars, uint64 size) = getDatasetCarsAndCarsCount(
            datasetId,
            DatasetType.DataType.MappingFiles
        );
        assertion.publishMatchingAssertion(
            address(99),
            datasetId,
            cars,
            size,
            DatasetType.DataType.MappingFiles,
            0,
            MatchingType.BidSelectionRule.HighestBid,
            100,
            100,
            100,
            100,
            "TEST"
        );
        matchingId = matchings.matchingsCount();

        vm.startPrank(admin);
        matchings.datasets().roles().grantRole(
            RolesType.STORAGE_PROVIDER,
            address(199)
        );
        vm.stopPrank();
        vm.roll(101);
        vm.prank(address(199));
        matchings.bidding(matchingId, 200);

        address initiator = matchings.getMatchingInitiator(matchingId);
        vm.roll(201);
        assertion.closeMatchingAssertion(initiator, matchingId, address(199));

        return (datasetId, matchingId);
    }
}
