// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity ^0.8.21;

import "./types/FilPlusType.sol";

library FilPlusLIB {
    function setMinRegionCount(
        FilPlusType.Rules storage rules,
        uint256 _minRegionCount
    ) external {
        rules.minRegionCount = _minRegionCount;
    }

    function setDefaultMaxReplicasPerCountry(
        FilPlusType.Rules storage rules,
        uint256 _defaultMaxReplicasPerCountry
    ) external {
        rules.defaultMaxReplicasPerCountry = _defaultMaxReplicasPerCountry;
    }

    function addMaxReplicasInCountry(
        FilPlusType.Rules storage rules,
        bytes2 cityCode,
        uint256 _maxReplicasInCountry
    ) external {
        rules.maxReplicasInCountry[cityCode] = _maxReplicasInCountry;
    }

    function setMaxReplicasPerCity(
        FilPlusType.Rules storage rules,
        uint256 _maxReplicasPerCity
    ) external {
        rules.maxReplicasPerCity = _maxReplicasPerCity;
    }

    function setMinSPCount(
        FilPlusType.Rules storage rules,
        uint256 _minSPCount
    ) external {
        rules.minSPCount = _minSPCount;
    }

    function setMaxReplicasPerSP(
        FilPlusType.Rules storage rules,
        uint256 _maxReplicasPerSP
    ) external {
        rules.maxReplicasPerSP = _maxReplicasPerSP;
    }

    function setMinTotalReplicas(
        FilPlusType.Rules storage rules,
        uint256 _minTotalReplicas
    ) external {
        rules.minTotalReplicas = _minTotalReplicas;
    }

    function setMaxTotalReplicas(
        FilPlusType.Rules storage rules,
        uint256 _maxTotalReplicas
    ) external {
        rules.maxTotalReplicas = _maxTotalReplicas;
    }
}
