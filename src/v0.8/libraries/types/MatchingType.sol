// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity ^0.8.21;

library MatchingType {
    enum State {
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
        Pause,
        Resume,
        Cancel
    }
}
