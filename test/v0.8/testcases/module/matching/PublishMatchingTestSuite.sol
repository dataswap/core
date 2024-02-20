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

import {Errors} from "src/v0.8/shared/errors/Errors.sol";
import {MatchingsTestBase} from "test/v0.8/testcases/module/matching/abstract/MatchingsTestBase.sol";

import {IMatchings} from "src/v0.8/interfaces/module/IMatchings.sol";
import {IMatchingsTarget} from "src/v0.8/interfaces/module/IMatchingsTarget.sol";
import {IMatchingsBids} from "src/v0.8/interfaces/module/IMatchingsBids.sol";
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
        IMatchingsTarget _matchingsTarget,
        IMatchingsBids _matchingsBids,
        IMatchingsHelpers _matchingsHelpers,
        IMatchingsAssertion _matchingsAssertion
    )
        MatchingsTestBase(
            _matchings,
            _matchingsTarget,
            _matchingsBids,
            _matchingsHelpers,
            _matchingsAssertion
        ) // solhint-disable-next-line
    {}

    function before() internal virtual override returns (uint64) {
        uint64 datasetId = matchingsHelpers.setup("testAccessMethod", 100, 10);
        matchingsAssertion.createMatchingAssertion(
            address(99),
            datasetId,
            MatchingType.BidSelectionRule.HighestBid,
            100,
            100,
            1000,
            100,
            0,
            "TEST"
        );
        uint64 matchingId = matchings.matchingsCount();

        matchingsAssertion.createTargetAssertion(
            address(99),
            matchingId,
            datasetId,
            DatasetType.DataType.MappingFiles,
            0,
            0
        );

        return datasetId;
    }

    function action(uint64 _datasetId) internal virtual override {
        (uint64[] memory cars, ) = matchingsHelpers.getDatasetCarsAndCarsCount(
            _datasetId,
            DatasetType.DataType.MappingFiles
        );

        uint64 matchingId = matchings.matchingsCount();
        vm.expectEmit(true, true, false, true);
        emit MatchingsEvents.MatchingPublished(matchingId, address(99));
        matchingsAssertion.publishMatchingAssertion(
            address(99),
            matchingId,
            _datasetId,
            cars,
            cars,
            true
        );
    }
}

///@notice publish matching test case with invalid sender
contract PublishMatchingTestCaseWithInvalidSender is MatchingsTestBase {
    constructor(
        IMatchings _matchings,
        IMatchingsTarget _matchingsTarget,
        IMatchingsBids _matchingsBids,
        IMatchingsHelpers _matchingsHelpers,
        IMatchingsAssertion _matchingsAssertion
    )
        MatchingsTestBase(
            _matchings,
            _matchingsTarget,
            _matchingsBids,
            _matchingsHelpers,
            _matchingsAssertion
        ) // solhint-disable-next-line
    {}

    function before() internal virtual override returns (uint64) {
        uint64 datasetId = matchingsHelpers.setup("testAccessMethod", 100, 10);

        matchingsAssertion.createMatchingAssertion(
            address(99),
            datasetId,
            MatchingType.BidSelectionRule.HighestBid,
            100,
            100,
            1000,
            100,
            0,
            "TEST"
        );
        uint64 matchingId = matchings.matchingsCount();

        matchingsAssertion.createTargetAssertion(
            address(99),
            matchingId,
            datasetId,
            DatasetType.DataType.MappingFiles,
            0,
            0
        );
        return datasetId;
    }

    function action(uint64 _datasetId) internal virtual override {
        (uint64[] memory cars, ) = matchingsHelpers.getDatasetCarsAndCarsCount(
            _datasetId,
            DatasetType.DataType.MappingFiles
        );
        uint64 matchingId = matchings.matchingsCount();

        vm.expectRevert(
            abi.encodeWithSelector(
                Errors.NotMatchingInitiator.selector,
                matchingId,
                address(99),
                address(98)
            )
        );
        matchingsAssertion.publishMatchingAssertion(
            address(98),
            matchingId,
            _datasetId,
            cars,
            cars,
            true
        );
    }
}

///@notice publish matching test case with invalid dataset
contract PublishMatchingTestCaseWithInvalidDataset is MatchingsTestBase {
    constructor(
        IMatchings _matchings,
        IMatchingsTarget _matchingsTarget,
        IMatchingsBids _matchingsBids,
        IMatchingsHelpers _matchingsHelpers,
        IMatchingsAssertion _matchingsAssertion
    )
        MatchingsTestBase(
            _matchings,
            _matchingsTarget,
            _matchingsBids,
            _matchingsHelpers,
            _matchingsAssertion
        ) // solhint-disable-next-line
    {}

    function before() internal virtual override returns (uint64) {
        uint64 datasetId = matchingsHelpers.setup("testAccessMethod", 100, 10);

        matchingsAssertion.createMatchingAssertion(
            address(99),
            datasetId,
            MatchingType.BidSelectionRule.HighestBid,
            100,
            100,
            1000,
            100,
            0,
            "TEST"
        );
        uint64 matchingId = matchings.matchingsCount();

        matchingsAssertion.createTargetAssertion(
            address(99),
            matchingId,
            datasetId,
            DatasetType.DataType.MappingFiles,
            0,
            0
        );
        return datasetId;
    }

    function action(uint64 _datasetId) internal virtual override {
        (uint64[] memory cars, ) = matchingsHelpers.getDatasetCarsAndCarsCount(
            _datasetId,
            DatasetType.DataType.MappingFiles
        );
        uint64 matchingId = matchings.matchingsCount();

        vm.prank(address(99));
        vm.expectRevert(bytes("invalid dataset id"));
        matchingsTarget.publishMatching(
            matchingId,
            _datasetId + 1,
            cars,
            cars,
            true
        );
    }
}

///@notice publish matching test case with invalid data preparer
contract PublishMatchingTestCaseWithInvalidDataPreparer is MatchingsTestBase {
    constructor(
        IMatchings _matchings,
        IMatchingsTarget _matchingsTarget,
        IMatchingsBids _matchingsBids,
        IMatchingsHelpers _matchingsHelpers,
        IMatchingsAssertion _matchingsAssertion
    )
        MatchingsTestBase(
            _matchings,
            _matchingsTarget,
            _matchingsBids,
            _matchingsHelpers,
            _matchingsAssertion
        ) // solhint-disable-next-line
    {}

    function before() internal virtual override returns (uint64) {
        return matchingsHelpers.setup("testAccessMethod", 100, 10);
    }

    function action(uint64 _datasetId) internal virtual override {
        vm.expectRevert(bytes("Invalid DP submitter"));
        matchingsAssertion.createMatchingAssertion(
            address(100),
            _datasetId,
            MatchingType.BidSelectionRule.HighestBid,
            100,
            100,
            1000,
            100,
            0,
            "TEST"
        );
    }
}

///@notice publish matching test case with invalid replica
contract PublishMatchingTestCaseWithInvalidReplica is MatchingsTestBase {
    constructor(
        IMatchings _matchings,
        IMatchingsTarget _matchingsTarget,
        IMatchingsBids _matchingsBids,
        IMatchingsHelpers _matchingsHelpers,
        IMatchingsAssertion _matchingsAssertion
    )
        MatchingsTestBase(
            _matchings,
            _matchingsTarget,
            _matchingsBids,
            _matchingsHelpers,
            _matchingsAssertion
        ) // solhint-disable-next-line
    {}

    function before() internal virtual override returns (uint64) {
        return matchingsHelpers.setup("testAccessMethod", 100, 10);
    }

    function action(uint64 _datasetId) internal virtual override {
        vm.expectRevert(bytes("Invalid matching replica"));
        matchingsAssertion.createMatchingAssertion(
            address(100),
            _datasetId,
            MatchingType.BidSelectionRule.HighestBid,
            100,
            100,
            1000,
            100,
            10,
            "TEST"
        );
    }
}
