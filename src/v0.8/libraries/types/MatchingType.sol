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

    enum DataType {
        MetaDataset,
        Dataset
    }

    struct Target {
        uint256 datasetID;
        bytes32[] cars;
        uint256 size;
        DataType dataType;
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
