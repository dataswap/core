// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity ^0.8.21;

import "../libraries/types/MatchingType.sol";
import "../libraries/MatchingLIB.sol";
import "./IDatasets.sol";
import "../libraries/types/DatasetType.sol";

//TODO: role control
abstract contract IMatchings {
    uint256 public matchingsCount;
    mapping(uint256 => MatchingType.Matching) public matchings;
    address payable public governanceContract; // Address of the governance contract
    address public datasetsContract;
    address public roleContract;

    using MatchingLIB for MatchingType.Matching;

    modifier validMatchingId(uint256 _matchingId) {
        require(
            _matchingId > 0 && _matchingId <= matchingsCount,
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

    function pause(uint256 _matchingId) external validMatchingId(_matchingId) {
        MatchingType.Matching storage matching = matchings[_matchingId];
        matching.pause();
    }

    function reportPauseExpired(
        uint256 _matchingId
    ) external validMatchingId(_matchingId) {
        MatchingType.Matching storage matching = matchings[_matchingId];
        matching.reportPauseExpired();
    }

    function resume(uint256 _matchingId) external validMatchingId(_matchingId) {
        MatchingType.Matching storage matching = matchings[_matchingId];
        matching.resume();
    }

    function cancel(uint256 _matchingId) external validMatchingId(_matchingId) {
        MatchingType.Matching storage matching = matchings[_matchingId];
        matching.cancel();
    }

    function bidding(
        uint256 _matchingId,
        MatchingType.Bid memory _bid
    ) external validMatchingId(_matchingId) {
        MatchingType.Matching storage matching = matchings[_matchingId];
        matching.bidding(_bid);
    }

    function close(
        uint256 _matchingId,
        MatchingType.WinnerBidRule _rule,
        address _carsStorageContractAddress
    ) external validMatchingId(_matchingId) {
        MatchingType.Matching storage matching = matchings[_matchingId];
        matching.close(_rule, _carsStorageContractAddress, _matchingId);
    }

    /// TODO: cid check,etc
    function filPlusCheck(
        uint256 _matchingId
    ) internal pure virtual returns (bool);

    function getState(
        uint256 _matchingId
    ) public view validMatchingId(_matchingId) returns (MatchingType.State) {
        MatchingType.Matching storage matching = matchings[_matchingId];
        return matching.getState();
    }
}
