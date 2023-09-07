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

import {MatchingsTestBase} from "test/v0.8/testcases/module/matching/abstract/MatchingsTestBase.sol";

import {IMatchings} from "src/v0.8/interfaces/module/IMatchings.sol";
import {IMatchingsAssertion} from "test/v0.8/interfaces/assertions/module/IMatchingsAssertion.sol";
import {IMatchingsHelpers} from "test/v0.8/interfaces/helpers/module/IMatchingsHelpers.sol";
import {MatchingType} from "src/v0.8/types/MatchingType.sol";
import {DatasetType} from "src/v0.8/types/DatasetType.sol";
import {RolesType} from "src/v0.8/types/RolesType.sol";
import {MatchingsEvents} from "src/v0.8/shared/events/MatchingsEvents.sol";

///@notice publish matching test case with success
contract PublishMatchingTestCaseWithSuccess is MatchingsTestBase {
    constructor(
        IMatchings _matchings,
        IMatchingsHelpers _matchingsHelpers,
        IMatchingsAssertion _matchingsAssertion
    )
        MatchingsTestBase(_matchings, _matchingsHelpers, _matchingsAssertion) // solhint-disable-next-line
    {}

    function before() internal virtual override returns (uint64) {
        uint64 datasetId = matchingsHelpers.setup("testAccessMethod", 100, 10);
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

        matchingsAssertion.createMatchingAssertion(
            address(99),
            datasetId,
            DatasetType.DataType.MappingFiles,
            0,
            MatchingType.BidSelectionRule.HighestBid,
            100,
            100,
            100,
            100,
            "TEST"
        );
        return datasetId;
    }

    function action(uint64 _datasetId) internal virtual override {
        uint64 carsCount = matchings.datasets().getDatasetCarsCount(
            _datasetId,
            DatasetType.DataType.MappingFiles
        );
        bytes32[] memory cars = new bytes32[](carsCount);
        cars = matchings.datasets().getDatasetCars(
            _datasetId,
            DatasetType.DataType.MappingFiles,
            0,
            carsCount
        );

        uint64 matchingId = matchings.matchingsCount();
        vm.expectEmit(true, true, false, true);
        emit MatchingsEvents.MatchingPublished(matchingId, address(99));
        matchingsAssertion.publishMatchingAssertion(
            address(99),
            matchingId,
            _datasetId,
            cars,
            true
        );
    }
}

///@notice publish matching test case with invalid role
contract PublishMatchingTestCaseWithInvalidRole is MatchingsTestBase {
    constructor(
        IMatchings _matchings,
        IMatchingsHelpers _matchingsHelpers,
        IMatchingsAssertion _matchingsAssertion
    )
        MatchingsTestBase(_matchings, _matchingsHelpers, _matchingsAssertion) // solhint-disable-next-line
    {}

    function before() internal virtual override returns (uint64) {
        uint64 datasetId = matchingsHelpers.setup("testAccessMethod", 100, 10);
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

        matchingsAssertion.createMatchingAssertion(
            address(99),
            datasetId,
            DatasetType.DataType.MappingFiles,
            0,
            MatchingType.BidSelectionRule.HighestBid,
            100,
            100,
            100,
            100,
            "TEST"
        );
        return datasetId;
    }

    function action(uint64 _datasetId) internal virtual override {
        uint64 carsCount = matchings.datasets().getDatasetCarsCount(
            _datasetId,
            DatasetType.DataType.MappingFiles
        );
        bytes32[] memory cars = new bytes32[](carsCount);
        cars = matchings.datasets().getDatasetCars(
            _datasetId,
            DatasetType.DataType.MappingFiles,
            0,
            carsCount
        );

        uint64 matchingId = matchings.matchingsCount();

        address admin = matchings.datasets().roles().getRoleMember(
            bytes32(0x00),
            0
        );
        vm.startPrank(admin);
        matchings.datasets().roles().revokeRole(
            RolesType.DATASET_PROVIDER,
            address(99)
        );
        vm.stopPrank();

        vm.expectRevert(bytes("Only allowed role can call"));
        matchingsAssertion.publishMatchingAssertion(
            address(99),
            matchingId,
            _datasetId,
            cars,
            true
        );
    }
}

///@notice publish matching test case with invalid sender
contract PublishMatchingTestCaseWithInvalidSender is MatchingsTestBase {
    constructor(
        IMatchings _matchings,
        IMatchingsHelpers _matchingsHelpers,
        IMatchingsAssertion _matchingsAssertion
    )
        MatchingsTestBase(_matchings, _matchingsHelpers, _matchingsAssertion) // solhint-disable-next-line
    {}

    function before() internal virtual override returns (uint64) {
        uint64 datasetId = matchingsHelpers.setup("testAccessMethod", 100, 10);
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

        matchingsAssertion.createMatchingAssertion(
            address(99),
            datasetId,
            DatasetType.DataType.MappingFiles,
            0,
            MatchingType.BidSelectionRule.HighestBid,
            100,
            100,
            100,
            100,
            "TEST"
        );
        return datasetId;
    }

    function action(uint64 _datasetId) internal virtual override {
        uint64 carsCount = matchings.datasets().getDatasetCarsCount(
            _datasetId,
            DatasetType.DataType.MappingFiles
        );
        bytes32[] memory cars = new bytes32[](carsCount);
        cars = matchings.datasets().getDatasetCars(
            _datasetId,
            DatasetType.DataType.MappingFiles,
            0,
            carsCount
        );

        uint64 matchingId = matchings.matchingsCount();

        address admin = matchings.datasets().roles().getRoleMember(
            bytes32(0x00),
            0
        );
        vm.startPrank(admin);
        matchings.datasets().roles().grantRole(
            RolesType.DATASET_PROVIDER,
            address(98)
        );
        vm.stopPrank();

        vm.expectRevert(bytes("invalid sender"));
        matchingsAssertion.publishMatchingAssertion(
            address(98),
            matchingId,
            _datasetId,
            cars,
            true
        );
    }
}

///@notice publish matching test case with invalid dataset
contract PublishMatchingTestCaseWithInvalidDataset is MatchingsTestBase {
    constructor(
        IMatchings _matchings,
        IMatchingsHelpers _matchingsHelpers,
        IMatchingsAssertion _matchingsAssertion
    )
        MatchingsTestBase(_matchings, _matchingsHelpers, _matchingsAssertion) // solhint-disable-next-line
    {}

    function before() internal virtual override returns (uint64) {
        uint64 datasetId = matchingsHelpers.setup("testAccessMethod", 100, 10);
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

        matchingsAssertion.createMatchingAssertion(
            address(99),
            datasetId,
            DatasetType.DataType.MappingFiles,
            0,
            MatchingType.BidSelectionRule.HighestBid,
            100,
            100,
            100,
            100,
            "TEST"
        );
        return datasetId;
    }

    function action(uint64 _datasetId) internal virtual override {
        uint64 carsCount = matchings.datasets().getDatasetCarsCount(
            _datasetId,
            DatasetType.DataType.MappingFiles
        );
        bytes32[] memory cars = matchings.datasets().getDatasetCars(
            _datasetId,
            DatasetType.DataType.MappingFiles,
            0,
            carsCount
        );

        uint64 matchingId = matchings.matchingsCount();

        vm.prank(address(99));
        vm.expectRevert(bytes("invalid dataset id"));
        matchings.publishMatching(matchingId, _datasetId + 1, cars, true);
    }
}
