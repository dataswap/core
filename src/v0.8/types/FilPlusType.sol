// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity ^0.8.21;

library FilPlusType {
    struct Rules {
        uint256 minRegionCount; //3
        uint256 defaultMaxReplicasPerCountry;
        mapping(bytes2 => uint256) maxReplicasInCountry;
        uint256 maxReplicasPerCity; //1
        uint256 minSPCount; //5
        uint256 maxReplicasPerSP; //1
        uint256 minTotalReplicas; //5
        uint256 maxTotalReplicas; //10
    }
}
