/*******************************************************************************
 *   (c) 2023 DataSwap
 *
 *  Licensed under the GNU General Public License, Version 3.0 or later (the "License");
 *  you may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at
 *
 *      https://www.gnu.org/licenses/gpl-3.0.en.html
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 ********************************************************************************/

// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.21;

import "@openzeppelin/contracts/governance/Governor.sol";
import "@openzeppelin/contracts/governance/compatibility/GovernorCompatibilityBravo.sol";
import "@openzeppelin/contracts/governance/extensions/GovernorVotes.sol";
import "@openzeppelin/contracts/governance/extensions/GovernorVotesQuorumFraction.sol";
import "@openzeppelin/contracts/governance/extensions/GovernorTimelockControl.sol";
import "@openzeppelin/contracts/access/Ownable2Step.sol";
import "../../accessControl/interface/IRoles.sol";
import "../../../types/RolesType.sol";

/// @title DataswapDAOBase Contract
/// @notice This contract serves as the base for the DataSwap DAO governance mechanism.
/// @dev This contract inherits from various Governor-related contracts and Ownable2Step.
abstract contract DataswapDAOBase is
    Governor,
    GovernorCompatibilityBravo,
    GovernorVotes,
    GovernorVotesQuorumFraction,
    GovernorTimelockControl,
    Ownable2Step
{
    address public immutable rolesContract;

    /// @notice Modifier that restricts access to functions based on a specific role.
    /// @param _role The role required to access the function.
    modifier onlyRole(bytes32 _role) {
        IRoles role = IRoles(rolesContract);
        require(role.hasRole(_role, msg.sender), "No permission!");
        _;
    }

    /// @notice Constructor function to initialize the DataswapDAOBase contract.
    /// @param _token The token used for voting.
    /// @param _rolesContract Address of the Roles contract for role-based access control.
    /// @param _timelock The timelock contract.
    constructor(
        IVotes _token,
        address _rolesContract,
        TimelockController _timelock
    )
        Governor("DataswapDAO")
        GovernorVotes(_token)
        GovernorVotesQuorumFraction(4)
        GovernorTimelockControl(_timelock)
    {
        rolesContract = _rolesContract;
    }

    /// @notice Returns the delay between the proposal's creation and the ability to vote on it.
    /// @dev This function is an override required by the IGovernor interface.
    /// @return The delay in seconds.
    function votingDelay()
        public
        pure
        virtual
        override(IGovernor)
        returns (uint256)
    {
        return 7200; // 1 day
    }

    /// @notice Returns the duration of voting on a proposal.
    /// @dev This function is an override required by the IGovernor interface.
    /// @return The voting period in seconds.
    function votingPeriod()
        public
        pure
        virtual
        override(IGovernor)
        returns (uint256)
    {
        return 50400; // 1 week
    }

    /// @notice Returns the minimum amount of votes required for a proposal to succeed.
    /// @dev This function is an override required by the IGovernor interface.
    /// @return The proposal threshold.
    function proposalThreshold()
        public
        pure
        virtual
        override
        returns (uint256)
    {
        return 0;
    }

    /// @notice Casts a vote on a proposal.
    /// @dev This function is an override of the Governor contract and is only accessible to users with the DATASET_AUDITOR role.
    /// @param _proposalId The ID of the proposal to vote on.
    /// @param _support Indicates whether to support (1) or reject (2) the proposal.
    /// @return balance The voter's balance after the vote.
    function castVote(
        uint256 _proposalId,
        uint8 _support
    )
        public
        virtual
        override(IGovernor, Governor)
        onlyRole(RolesType.DATASET_AUDITOR)
        returns (uint256 balance)
    {
        return super.castVote(_proposalId, _support);
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
