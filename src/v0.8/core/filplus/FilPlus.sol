// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity ^0.8.21;

import "../../types/FilPlusType.sol";
import "./library/FilPlusLIB.sol";
import "./interface/IFilPlus.sol";

contract FilPlus is IFilPlus {
    FilPlusType.Rules rules;

    using FilPlusLIB for FilPlusType.Rules;

    function setMinRegionCount(uint256 _minRegionCount) external {
        rules.setMinRegionCount(_minRegionCount);
    }

    function setDefaultMaxReplicasPerCountry(
        uint256 _defaultMaxReplicasPerCountry
    ) external {
        rules.setDefaultMaxReplicasPerCountry(_defaultMaxReplicasPerCountry);
    }

    function addMaxReplicasInCountry(
        bytes2 cityCode,
        uint256 _maxReplicasInCountry
    ) external {
        rules.addMaxReplicasInCountry(cityCode, _maxReplicasInCountry);
    }

    function setMaxReplicasPerCity(uint256 _maxReplicasPerCity) external {
        rules.setMaxReplicasPerCity(_maxReplicasPerCity);
    }

    function setMinSPCount(uint256 _minSPCount) external {
        rules.setMinSPCount(_minSPCount);
    }

    function setMaxReplicasPerSP(uint256 _maxReplicasPerSP) external {
        rules.setMaxReplicasPerSP(_maxReplicasPerSP);
    }

    function setMinTotalReplicas(uint256 _minTotalReplicas) external {
        rules.setMinTotalReplicas(_minTotalReplicas);
    }

    function setMaxTotalReplicas(uint256 _maxTotalReplicas) external {
        rules.setMaxTotalReplicas(_maxTotalReplicas);
    }
}
