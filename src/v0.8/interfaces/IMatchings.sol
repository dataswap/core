// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity ^0.8.21;

import "../libraries/types/MatchingType.sol";
import "../libraries/MatchingLIB.sol";
import "./IDatasets.sol";
import "../libraries/types/DatasetType.sol";

abstract contract IMatchings {
    uint256 private matchingsCount;
    mapping(uint256 => MatchingType.Matching) internal matchings;
    address payable public governanceContract; // Address of the governance contract
    address public datasetsContract;
    address public roleContract;

    using MatchingLIB for MatchingType.Matching;

    modifier validMatchingId(uint256 matchingId) {
        require(
            matchingId > 0 && matchingId <= matchingsCount,
            "Invalid matching ID"
        );
        _;
    }

    function publish(
        MatchingType.Target memory _target,
        uint256 _biddingDelayBlockCount,
        uint256 _biddingPeriodBlockCount,
        uint256 _storagePeriodBlockCount,
        uint256 _biddingThreshold,
        string memory _additionalInfo
    ) external {
        IDatasets datasets = IDatasets(datasetsContract);
        require(
            DatasetType.State.DatasetApproved ==
                datasets.getState(_target.datasetID),
            "dataset isn't approved"
        );
        if (_target.dataType == MatchingType.DataType.Dataset) {
            MatchingType.Matching storage metaDatasetMatching = matchings[
                _target.associatedMetaDatasetMatchingID
            ];
            require(
                MatchingType.State.Completed == metaDatasetMatching.getState(),
                "meta dataset matching isn't completed"
            );
            //TODO: require storage completed
        }

        matchingsCount++;
        MatchingType.Matching storage newMatching = matchings[matchingsCount];

        newMatching.target = _target;
        newMatching.biddingDelayBlockCount = _biddingDelayBlockCount;
        newMatching.biddingPeriodBlockCount = _biddingPeriodBlockCount;
        newMatching.storagePeriodBlockCount = _storagePeriodBlockCount;
        newMatching.biddingThreshold = _biddingThreshold;
        newMatching.additionalInfo = _additionalInfo;
        newMatching.initiator = msg.sender;
        newMatching.createdBlockNumber = block.number;

        newMatching.publish();
    }

    function pause(uint256 matchingId) external validMatchingId(matchingId) {
        MatchingType.Matching storage matching = matchings[matchingId];
        matching.pause();
    }

    function reportPauseExpired(
        uint256 matchingId
    ) external validMatchingId(matchingId) {
        MatchingType.Matching storage matching = matchings[matchingId];
        matching.reportPauseExpired();
    }

    function resume(uint256 matchingId) external validMatchingId(matchingId) {
        MatchingType.Matching storage matching = matchings[matchingId];
        matching.resume();
    }

    function cancel(uint256 matchingId) external validMatchingId(matchingId) {
        MatchingType.Matching storage matching = matchings[matchingId];
        matching.cancel();
    }

    function bidding(
        uint256 matchingId,
        MatchingType.Bid memory bid
    ) external validMatchingId(matchingId) {
        MatchingType.Matching storage matching = matchings[matchingId];
        matching.bidding(bid);
    }

    function close(
        uint256 matchingId,
        MatchingType.WinnerBidRule rule
    ) external validMatchingId(matchingId) {
        MatchingType.Matching storage matching = matchings[matchingId];
        matching.close(rule);
    }

    /// TODO:
    function filPlusCheck(
        MatchingType.Matching storage /*self*/
    ) internal pure virtual returns (bool);

    function getState(
        uint256 matchingId
    ) public view returns (MatchingType.State) {
        MatchingType.Matching storage matching = matchings[matchingId];
        return matching.getState();
    }
}
