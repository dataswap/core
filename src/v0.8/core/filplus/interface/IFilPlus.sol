// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity ^0.8.21;

import "../../../types/FilPlusType.sol";

interface IFilPlus {
    function setMinRegionCount(uint256 _minRegionCount) external;

    function setDefaultMaxReplicasPerCountry(
        uint256 _defaultMaxReplicasPerCountry
    ) external;

    function addMaxReplicasInCountry(
        bytes2 cityCode,
        uint256 _maxReplicasInCountry
    ) external;

    function setMaxReplicasPerCity(uint256 _maxReplicasPerCity) external;

    function setMinSPCount(uint256 _minSPCount) external;

    function setMaxReplicasPerSP(uint256 _maxReplicasPerSP) external;

    function setMinTotalReplicas(uint256 _minTotalReplicas) external;

    function setMaxTotalReplicas(uint256 _maxTotalReplicas) external;
}
