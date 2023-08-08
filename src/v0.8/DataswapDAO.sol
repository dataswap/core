// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import "./interfaces/IRoles.sol";
import "./interfaces/IDataswapDAO.sol";
import "./libraries/types/RolesType.sol";

contract DataswapDAO is IDataswapDAO {
    constructor(
        IVotes _token,
        address _roleContract,
        TimelockController _timelock
    ) IDataswapDAO(_token, _roleContract, _timelock) {}

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
