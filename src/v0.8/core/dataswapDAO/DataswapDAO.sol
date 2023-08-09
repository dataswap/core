// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.21;

import "../accessControl/interface/IRoles.sol";
import "./abstract/DataswapDAOBase.sol";
import "./../..//types/RolesType.sol";

contract DataswapDAO is DataswapDAOBase {
    constructor(
        IVotes _token,
        address _roleContract,
        TimelockController _timelock
    ) DataswapDAOBase(_token, _roleContract, _timelock) {}

    function votingDelay() public pure override returns (uint256) {
        return 2880; // 1days
    }

    function votingPeriod() public pure override returns (uint256) {
        return 2880 * 7; //1weeks
    }

    function proposalThreshold() public pure override returns (uint256) {
        return 3;
    }

    function castVote(
        uint256 proposalId,
        uint8 support
    )
        public
        override
        onlyRole(RolesType.DATASET_AUDITOR)
        returns (uint256 balance)
    {
        return super.castVote(proposalId, support);
    }
}
