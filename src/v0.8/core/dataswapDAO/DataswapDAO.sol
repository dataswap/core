// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.21;

import "../accessControl/interface/IRoles.sol";
import "./abstract/DataswapDAOBase.sol";
import "../../types/RolesType.sol";

/// @title DataswapDAO Contract
/// @notice This contract implements the governance functionality for the Dataswap platform.
/// @dev This contract inherits from the DataswapDAOBase contract and sets specific parameter values.
contract DataswapDAO is DataswapDAOBase {
    /// @notice Constructor function to initialize the DataswapDAO contract.
    /// @param _token Address of the governance token.
    /// @param _roleContract Address of the Roles contract for role-based access control.
    /// @param _timelock Address of the TimelockController contract for timelock functionality.
    constructor(
        IVotes _token,
        address _roleContract,
        TimelockController _timelock
    ) DataswapDAOBase(_token, _roleContract, _timelock) {}

    /// @notice Returns the delay between the proposal's creation and the ability to vote on it.
    /// @dev This function is an override required by the DataswapDAOBase contract.
    /// @return The delay in seconds.
    function votingDelay() public pure override returns (uint256) {
        return 2880; // 1 day
    }

    /// @notice Returns the duration of voting on a proposal.
    /// @dev This function is an override required by the DataswapDAOBase contract.
    /// @return The voting period in seconds.
    function votingPeriod() public pure override returns (uint256) {
        return 2880 * 7; // 1 week
    }

    /// @notice Returns the minimum amount of votes required for a proposal to succeed.
    /// @dev This function is an override required by the DataswapDAOBase contract.
    /// @return The proposal threshold.
    function proposalThreshold() public pure override returns (uint256) {
        return 3;
    }

    /// @notice Casts a vote on a proposal.
    /// @dev This function is an override of the DataswapDAOBase contract and is only accessible to users with the DATASET_AUDITOR role.
    /// @param proposalId The ID of the proposal to vote on.
    /// @param support Indicates whether to support (1) or reject (2) the proposal.
    /// @return balance The voter's balance after the vote.
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
