// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import "@openzeppelin/contracts/governance/Governor.sol";
import "@openzeppelin/contracts/governance/compatibility/GovernorCompatibilityBravo.sol";
import "@openzeppelin/contracts/governance/extensions/GovernorVotes.sol";
import "@openzeppelin/contracts/governance/extensions/GovernorVotesQuorumFraction.sol";
import "@openzeppelin/contracts/governance/extensions/GovernorTimelockControl.sol";
import "./IRoles.sol";
import "../libraries/types/RolesType.sol";

abstract contract IDataswapDAO is
    Governor,
    GovernorCompatibilityBravo,
    GovernorVotes,
    GovernorVotesQuorumFraction,
    GovernorTimelockControl
{
    IRoles public immutable rolesContract;

    /// @notice Explain to an end user what this does
    /// @dev Explain to a developer any extra details
    modifier onlyRole(bytes32 _role) {
        require(rolesContract.hasRole(_role, msg.sender), "No permission!");
        _;
    }

    constructor(
        IVotes _token,
        IRoles _rolesContract,
        TimelockController _timelock
    )
        Governor("DataswapDAO")
        GovernorVotes(_token)
        GovernorVotesQuorumFraction(4)
        GovernorTimelockControl(_timelock)
    {
        rolesContract = _rolesContract;
    }

    function votingDelay()
        public
        pure
        virtual
        override(IGovernor)
        returns (uint256)
    {
        return 7200; // 1 day
    }

    function votingPeriod()
        public
        pure
        virtual
        override(IGovernor)
        returns (uint256)
    {
        return 50400; // 1 week
    }

    function proposalThreshold()
        public
        pure
        virtual
        override
        returns (uint256)
    {
        return 0;
    }

    function castVote(
        uint256 proposalId,
        uint8 support
    )
        public
        virtual
        override(IGovernor, Governor)
        onlyRole(RolesType.DATASET_AUDITOR)
        returns (uint256 balance)
    {
        return super.castVote(proposalId, support);
    }

    // The functions below are overrides required by Solidity.
    function state(
        uint256 proposalId
    )
        public
        view
        override(Governor, IGovernor, GovernorTimelockControl)
        returns (ProposalState)
    {
        return super.state(proposalId);
    }

    function propose(
        address[] memory targets,
        uint256[] memory values,
        bytes[] memory calldatas,
        string memory description
    )
        public
        override(Governor, GovernorCompatibilityBravo, IGovernor)
        returns (uint256)
    {
        return super.propose(targets, values, calldatas, description);
    }

    function cancel(
        address[] memory targets,
        uint256[] memory values,
        bytes[] memory calldatas,
        bytes32 descriptionHash
    )
        public
        override(Governor, GovernorCompatibilityBravo, IGovernor)
        returns (uint256)
    {
        return super.cancel(targets, values, calldatas, descriptionHash);
    }

    function _execute(
        uint256 proposalId,
        address[] memory targets,
        uint256[] memory values,
        bytes[] memory calldatas,
        bytes32 descriptionHash
    ) internal override(Governor, GovernorTimelockControl) {
        super._execute(proposalId, targets, values, calldatas, descriptionHash);
    }

    function _cancel(
        address[] memory targets,
        uint256[] memory values,
        bytes[] memory calldatas,
        bytes32 descriptionHash
    ) internal override(Governor, GovernorTimelockControl) returns (uint256) {
        return super._cancel(targets, values, calldatas, descriptionHash);
    }

    function _executor()
        internal
        view
        override(Governor, GovernorTimelockControl)
        returns (address)
    {
        return super._executor();
    }

    function supportsInterface(
        bytes4 interfaceId
    )
        public
        view
        override(Governor, IERC165, GovernorTimelockControl)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
