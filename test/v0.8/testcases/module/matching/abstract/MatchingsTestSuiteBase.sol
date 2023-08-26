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

import {Test} from "forge-std/Test.sol";
import {MatchingsTestBase} from "test/v0.8/testcases/module/matching/abstract/MatchingsTestBase.sol";
import {DatasetType} from "src/v0.8/types/DatasetType.sol";
import {MatchingType} from "src/v0.8/types/MatchingType.sol";

import {IMatchings} from "src/v0.8/interfaces/module/IMatchings.sol";
import {IMatchingsAssertion} from "test/v0.8/interfaces/assertions/module/IMatchingsAssertion.sol";
import {IMatchingsHelpers} from "test/v0.8/interfaces/helpers/module/IMatchingsHelpers.sol";

abstract contract PublishMatchingTestSuiteBase is MatchingsTestBase, Test {
    constructor(
        IMatchings _matchings,
        IMatchingsHelpers _matchingsHelpers,
        IMatchingsAssertion _matchingsAssertion
    )
        MatchingsTestBase(_matchings, _matchingsHelpers, _matchingsAssertion) // solhint-disable-next-line
    {}

    function before(
        uint64 _datasetId,
        bytes32[] memory _cars,
        uint64 _size,
        DatasetType.DataType _dataType,
        uint64 _associatedMappingFilesMatchingID,
        MatchingType.BidSelectionRule _bidSelectionRule,
        uint64 _biddingDelayBlockCount,
        uint64 _biddingPeriodBlockCount,
        uint64 _storageCompletionPeriodBlocks,
        uint256 _biddingThreshold,
        string memory _additionalInfo
    ) internal virtual;

    function action(
        uint64 _datasetId,
        bytes32[] memory _cars,
        uint64 _size,
        DatasetType.DataType _dataType,
        uint64 _associatedMappingFilesMatchingID,
        MatchingType.BidSelectionRule _bidSelectionRule,
        uint64 _biddingDelayBlockCount,
        uint64 _biddingPeriodBlockCount,
        uint64 _storageCompletionPeriodBlocks,
        uint256 _biddingThreshold,
        string memory _additionalInfo
    ) internal virtual {
        matchingsAssertion.publishMatchingAssertion(
            _datasetId,
            _cars,
            _size,
            _dataType,
            _associatedMappingFilesMatchingID,
            _bidSelectionRule,
            _biddingDelayBlockCount,
            _biddingPeriodBlockCount,
            _storageCompletionPeriodBlocks,
            _biddingThreshold,
            _additionalInfo
        );
    }

    function after_(
        uint64 _datasetId,
        bytes32[] memory _cars,
        uint64 _size,
        DatasetType.DataType _dataType,
        uint64 _associatedMappingFilesMatchingID,
        MatchingType.BidSelectionRule _bidSelectionRule,
        uint64 _biddingDelayBlockCount,
        uint64 _biddingPeriodBlockCount,
        uint64 _storageCompletionPeriodBlocks,
        uint256 _biddingThreshold,
        string memory _additionalInfo // solhint-disable-next-line
    ) internal virtual {}

    function run(
        uint64 _datasetId,
        bytes32[] memory _cars,
        uint64 _size,
        DatasetType.DataType _dataType,
        uint64 _associatedMappingFilesMatchingID,
        MatchingType.BidSelectionRule _bidSelectionRule,
        uint64 _biddingDelayBlockCount,
        uint64 _biddingPeriodBlockCount,
        uint64 _storageCompletionPeriodBlocks,
        uint256 _biddingThreshold,
        string memory _additionalInfo
    ) public {
        before(
            _datasetId,
            _cars,
            _size,
            _dataType,
            _associatedMappingFilesMatchingID,
            _bidSelectionRule,
            _biddingDelayBlockCount,
            _biddingPeriodBlockCount,
            _storageCompletionPeriodBlocks,
            _biddingThreshold,
            _additionalInfo
        );
        action(
            _datasetId,
            _cars,
            _size,
            _dataType,
            _associatedMappingFilesMatchingID,
            _bidSelectionRule,
            _biddingDelayBlockCount,
            _biddingPeriodBlockCount,
            _storageCompletionPeriodBlocks,
            _biddingThreshold,
            _additionalInfo
        );
        after_(
            _datasetId,
            _cars,
            _size,
            _dataType,
            _associatedMappingFilesMatchingID,
            _bidSelectionRule,
            _biddingDelayBlockCount,
            _biddingPeriodBlockCount,
            _storageCompletionPeriodBlocks,
            _biddingThreshold,
            _additionalInfo
        );
    }
}

abstract contract BiddingTestSuiteBase is MatchingsTestBase, Test {
    constructor(
        IMatchings _matchings,
        IMatchingsHelpers _matchingsHelpers,
        IMatchingsAssertion _matchingsAssertion
    )
        MatchingsTestBase(_matchings, _matchingsHelpers, _matchingsAssertion) // solhint-disable-next-line
    {}

    function before(uint64 _matchingId, uint256 _amount) internal virtual;

    function action(uint64 _matchingId, uint256 _amount) internal virtual {
        matchingsAssertion.biddingAssertion(_matchingId, _amount);
    }

    function after_(
        uint64 _matchingId,
        uint256 _amount // solhint-disable-next-line
    ) internal virtual {}

    function run(uint64 _matchingId, uint256 _amount) public {
        before(_matchingId, _amount);
        action(_matchingId, _amount);
        after_(_matchingId, _amount);
    }
}
