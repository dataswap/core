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

// import {Governor, IGovernor, IERC165} from "@openzeppelin/contracts/governance/Governor.sol";
// import {GovernorCompatibilityBravo} from "@openzeppelin/contracts/governance/compatibility/GovernorCompatibilityBravo.sol";
import {IVotes} from "@openzeppelin/contracts/governance/extensions/GovernorVotes.sol";
// import {GovernorVotesQuorumFraction} from "@openzeppelin/contracts/governance/extensions/GovernorVotesQuorumFraction.sol";
// import {GovernorTimelockControl} from "@openzeppelin/contracts/governance/extensions/GovernorTimelockControl.sol";
import {DataswapDAOBase} from "src/v0.8/core/governance/abstract/DataswapDAOBase.sol";

/// @title DataswapDAOPerPersonVoting Contract
/// @notice This contract serves as the base for the DataSwap DAO governance mechanism with per-person voting.
/// @dev This contract inherits from DataswapDAOBase and provides the foundation for individual voting.
abstract contract DataswapDAOPerPersonVoting is DataswapDAOBase {
    /// @notice Constructor function to initialize the DataswapDAOPerPersonVoting contract.
    /// @param _token The token used for voting.
    // solhint-disable-next-line
    constructor(IVotes _token) DataswapDAOBase(_token) {}
}
