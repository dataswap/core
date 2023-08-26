/// SPDX-License-Identifier: GPL-3.0-or-later
/// (c) 2023 Dataswap
///
/// Licensed under the GNU General Public License, Version 3.0 or later (the "License");
/// you may not use this file except in compliance with the License.
/// You may obtain a copy of the License at
///     https://www.gnu.org/licenses/gpl-3.0.en.html
///
/// Unless required by applicable law or agreed to in writing, software
/// distributed under the License is distributed on an "AS IS" BASIS,
/// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
/// See the License for the specific language governing permissions and
/// limitations under the License.

pragma solidity ^0.8.21;
import {IDatacapsSetupHelpers} from "test/v0.8/interfaces/helpers/setup/IDatacapsSetupHelpers.sol";
import {DatasetType} from "src/v0.8/types/DatasetType.sol";
import {MatchingType} from "src/v0.8/types/MatchingType.sol";

import {IDatacaps} from "src/v0.8/interfaces/module/IDatacaps.sol";
import {IDatasetsAssertion} from "test/v0.8/interfaces/assertions/module/IDatasetsAssertion.sol";
import {IMatchingsAssertion} from "test/v0.8/interfaces/assertions/module/IMatchingsAssertion.sol";
import {IStoragesAssertion} from "test/v0.8/interfaces/assertions/module/IStoragesAssertion.sol";
import {IDatacapsAssertion} from "test/v0.8/interfaces/assertions/module/IDatacapsAssertion.sol";
import {IDatasetsHelpers} from "test/v0.8/interfaces/helpers/module/IDatasetsHelpers.sol";
import {IMatchingsHelpers} from "test/v0.8/interfaces/helpers/module/IMatchingsHelpers.sol";
import {IStoragesHeplers} from "test/v0.8/interfaces/helpers/module/IStoragesHeplers.sol";
import {IDatacapsHelpers} from "test/v0.8/interfaces/helpers/module/IDatacapsHelpers.sol";

/// @title IDatacap
/// @dev Interface for managing the allocation of datacap for matched data storage.
contract DatacapsSetupHelpers is IDatacapsSetupHelpers {
    IDatacaps internal datacaps;
    IDatasetsAssertion internal datasetAssertion;
    IMatchingsAssertion internal matchingAssertion;
    IStoragesAssertion internal storageAssertion;
    IDatacapsAssertion internal datacapAssertion;
    IDatasetsHelpers internal datasetHelpers;
    IMatchingsHelpers internal matchingsHelpers;
    IStoragesHeplers internal storageHelpers;
    IDatacapsHelpers internal datacapHelper;

    constructor(
        IDatacaps _datacaps,
        IDatasetsAssertion _datasetAssertion,
        IMatchingsAssertion _matchingAssertion,
        IStoragesAssertion _storageAssertion,
        IDatacapsAssertion _datacapAssertion,
        IDatasetsHelpers _datasetHelpers,
        IMatchingsHelpers _matchingsHelpers,
        IStoragesHeplers _storageHelpers,
        IDatacapsHelpers _datacapHelpers
    ) {
        datacaps = _datacaps;
        datasetAssertion = _datasetAssertion;
        matchingAssertion = _matchingAssertion;
        storageAssertion = _storageAssertion;
        datacapAssertion = _datacapAssertion;
        datasetHelpers = _datasetHelpers;
        matchingsHelpers = _matchingsHelpers;
        storageHelpers = _storageHelpers;
        datacapHelper = _datacapHelpers;
    }

    function setup(
        string memory _accessMethod,
        DatasetType.DataType _dataType,
        uint64 _associatedMappingFilesMatchingID,
        MatchingType.BidSelectionRule _bidSelectionRule,
        uint64 _biddingDelayBlockCount,
        uint64 _biddingPeriodBlockCount,
        uint64 _storageCompletionPeriodBlocks,
        uint256 _biddingThreshold
    ) external returns (uint64 datasetId, uint64 matchingId) {
        //dataset workflow
        datasetId = datasetHelpers.completeDatasetWorkflow(
            _accessMethod,
            100,
            10,
            10,
            100
        );
        datasetAssertion.approveDatasetAssertion(datasetId);

        //matching workflow
        uint64 datasetSize = datacaps
            .storages()
            .matchings()
            .datasets()
            .getDatasetSize(datasetId, _dataType);
        // TODO:dataset lack of getDatasetCarsSize method,so put all cars to matching
        bytes32[] memory mappingFilesCids = new bytes32[](datasetSize);
        mappingFilesCids = datacaps
            .storages()
            .matchings()
            .datasets()
            .getDatasetCars(datasetId, _dataType, 0, datasetSize);

        matchingId = matchingsHelpers.completeMatchingWorkflow(
            datasetId,
            mappingFilesCids,
            datasetSize,
            _dataType,
            _associatedMappingFilesMatchingID,
            _bidSelectionRule,
            _biddingDelayBlockCount,
            _biddingPeriodBlockCount,
            _storageCompletionPeriodBlocks,
            _biddingThreshold
        );

        matchingAssertion.getMatchingStateAssertion(
            matchingId,
            MatchingType.State.Completed
        );

        return (datasetId, matchingId);
    }
}
