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
import "../abstract/DataswapDAOPerPersonVoting.sol";
import "../interface/IDatasetDAO.sol";

/// @title DataswapDAOPerPersonVoting Contract
/// @notice This contract serves as the base for the DataSwap DAO governance mechanism with per-person voting.
/// @dev This contract inherits from DataswapDAOBase and provides the foundation for individual voting.
abstract contract DatasetDAO is DataswapDAOPerPersonVoting, IDatasetDAO {
    /// @notice Constructor function to initialize the DataswapDAOPerPersonVoting contract.
    /// @param _token The token used for voting.
    constructor(IVotes _token) DataswapDAOPerPersonVoting(_token) {}
}
