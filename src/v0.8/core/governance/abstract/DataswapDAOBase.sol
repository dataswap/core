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

import {Governor, IGovernor, IERC165} from "@openzeppelin/contracts/governance/Governor.sol";
import {GovernorCompatibilityBravo} from "@openzeppelin/contracts/governance/compatibility/GovernorCompatibilityBravo.sol";
import {GovernorVotes, IVotes} from "@openzeppelin/contracts/governance/extensions/GovernorVotes.sol";
import {GovernorVotesQuorumFraction} from "@openzeppelin/contracts/governance/extensions/GovernorVotesQuorumFraction.sol";

// import "@openzeppelin/contracts/governance/extensions/GovernorTimelockControl.sol";

/// @title DataswapDAOBase Contract
/// @notice This contract serves as the base for the DataSwap DAO governance mechanism.
/// @dev This contract inherits from various Governor-related contracts and Ownable2Step.
abstract contract DataswapDAOBase is
    Governor,
    GovernorCompatibilityBravo,
    GovernorVotes,
    GovernorVotesQuorumFraction
    // GovernorTimelockControl
{
    /// @notice Constructor function to initialize the DataswapDAOBase contract.
    /// @param _token The token used for voting.
    //  @param _timelock The timelock contract.
    constructor(
        IVotes _token
    )
        // TimelockController _timelock
        Governor("DataswapDAO")
        GovernorVotes(_token)
        GovernorVotesQuorumFraction(4)
    // GovernorTimelockControl(_timelock)
    {

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
        return 2880; // 1 day
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
        return 2880 * 7; // 1 week
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

    // The functions below are overrides required by Solidity.
    function state(
        uint256 proposalId
    )
        public
        view
        override(Governor, IGovernor)
        returns (
            // override(Governor, IGovernor, GovernorTimelockControl)
            ProposalState
        )
    {
        return super.state(proposalId);
    }

    function propose(
        address[] memory targets,
        uint256[] memory values,
        bytes[] memory calldatas,
        string memory description
    ) public override(Governor, GovernorCompatibilityBravo) returns (uint256) {
        return super.propose(targets, values, calldatas, description);
    }

    function cancel(
        address[] memory targets,
        uint256[] memory values,
        bytes[] memory calldatas,
        bytes32 descriptionHash
    ) public override(Governor, GovernorCompatibilityBravo) returns (uint256) {
        return super.cancel(targets, values, calldatas, descriptionHash);
    }

    function _execute(
        uint256 proposalId,
        address[] memory targets,
        uint256[] memory values,
        bytes[] memory calldatas,
        bytes32 descriptionHash
    )
        internal
        override(
            // ) internal override(Governor, GovernorTimelockControl) {
            Governor
        )
    {
        super._execute(proposalId, targets, values, calldatas, descriptionHash);
    }

    function _cancel(
        address[] memory targets,
        uint256[] memory values,
        bytes[] memory calldatas,
        bytes32 descriptionHash
    )
        internal
        override(
            // ) internal override(Governor, GovernorTimelockControl) returns (uint256) {
            Governor
        )
        returns (uint256)
    {
        return super._cancel(targets, values, calldatas, descriptionHash);
    }

    function _executor()
        internal
        view
        override(
            // override(Governor, GovernorTimelockControl)
            Governor
        )
        returns (address)
    {
        return super._executor();
    }

    function supportsInterface(
        bytes4 interfaceId
    )
        public
        view
        override(Governor, IERC165)
        returns (
            //override(Governor, IERC165, GovernorTimelockControl)
            bool
        )
    {
        return super.supportsInterface(interfaceId);
    }
}
