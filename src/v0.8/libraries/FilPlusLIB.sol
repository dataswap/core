// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity ^0.8.21;

import "./types/FilPlusType.sol";

library FilPlusLIB {
    function setMinRegionCount(
        FilPlusType.Rules storage self,
        uint256 _minRegionCount
    ) external {
        self.minRegionCount = _minRegionCount;
    }

    function setDefaultMaxReplicasPerCountry(
        FilPlusType.Rules storage self,
        uint256 _defaultMaxReplicasPerCountry
    ) external {
        self.defaultMaxReplicasPerCountry = _defaultMaxReplicasPerCountry;
    }

    function addMaxReplicasInCountry(
        FilPlusType.Rules storage self,
        bytes2 cityCode,
        uint256 _maxReplicasInCountry
    ) external {
        self.maxReplicasInCountry[cityCode] = _maxReplicasInCountry;
    }

    function setMaxReplicasPerCity(
        FilPlusType.Rules storage self,
        uint256 _maxReplicasPerCity
    ) external {
        self.maxReplicasPerCity = _maxReplicasPerCity;
    }

    function setMinSPCount(
        FilPlusType.Rules storage self,
        uint256 _minSPCount
    ) external {
        self.minSPCount = _minSPCount;
    }

    function setMaxReplicasPerSP(
        FilPlusType.Rules storage self,
        uint256 _maxReplicasPerSP
    ) external {
        self.maxReplicasPerSP = _maxReplicasPerSP;
    }

    function setMinTotalReplicas(
        FilPlusType.Rules storage self,
        uint256 _minTotalReplicas
    ) external {
        self.minTotalReplicas = _minTotalReplicas;
    }

    function setMaxTotalReplicas(
        FilPlusType.Rules storage self,
        uint256 _maxTotalReplicas
    ) external {
        self.maxTotalReplicas = _maxTotalReplicas;
    }
}
