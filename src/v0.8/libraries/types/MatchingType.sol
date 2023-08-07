// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity ^0.8.21;

import "./DatasetType.sol";

library MatchingType {
    enum State {
        None,
        Published,
        InProgress,
        Paused,
        Closed,
        Completed,
        Cancelled,
        Failed
    }

    enum Event {
        Publish,
        FilPlusCheckSuccessed,
        FilPlusCheckFailed,
        Pause,
        PauseExpired,
        Resume,
        Cancel,
        Close,
        HasWinner,
        NoWinner
    }

    enum WinnerBidRule {
        HighestBid,
        LowestBid
    }

    struct Target {
        uint256 datasetID;
        bytes32[] carIDs;
        uint256 size;
        uint256 associatedMetaDatasetMatchingID;
    }

    struct Bid {
        address bidder;
        uint256 bid;
    }

    struct Matching {
        Target target;
        uint256 biddingDelayBlockCount;
        uint256 biddingPeriodBlockCount;
        uint256 storagePeriodBlockCount;
        uint256 biddingThreshold;
        string additionalInfo;
        address initiator;
        uint256 createdBlockNumber;
        State state;
        Bid[] bids;
        address winner;
    }
}
