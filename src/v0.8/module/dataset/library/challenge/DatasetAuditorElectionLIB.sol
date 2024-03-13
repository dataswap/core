/*******************************************************************************
 *   (c) 2023 Dataswap
 *
 *  Licensed under the GNU General Public License, Version 3.0 or later (the "License");
 *  you may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at
 *
 *      https://www.gnu.org/licenses/gpl-3.0.en.html *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 ********************************************************************************/

// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity ^0.8.21;
import {IRoles} from "src/v0.8/interfaces/core/IRoles.sol";
import {FinanceType} from "src/v0.8/types/FinanceType.sol";

contract DatasetAuditorElectionLIB {
    ///@notice Internal function to stake tokens.
    ///@param _candidates The storage array to store candidate addresses.
    ///@param _roles The contract instance of IRoles.
    ///@param _datasetId The ID of the dataset.
    ///@param _token The address of the token to stake.
    function _stake(
        address[] storage _candidates,
        IRoles _roles,
        uint64 _datasetId,
        address _token
    ) internal {
        (, , uint256 escrow, ) = _roles.finance().getAccountEscrow(
            _datasetId,
            0,
            msg.sender,
            _token,
            FinanceType.Type.EscrowChallengeAuditCollateral
        );

        require(
            escrow >= _roles.filplus().getProofAuditFee(),
            "auditor escrow invalid"
        );

        // Add or update candidate
        bool isNewCandidate = true;
        for (uint256 i = 0; i < _candidates.length; i++) {
            if (_candidates[i] == msg.sender) {
                isNewCandidate = false;
                break;
            }
        }

        if (isNewCandidate) {
            _candidates.push(msg.sender);
        }
    }

    ///@notice Internal function to elect winners based on staked amounts.
    ///@param _candidates The storage array containing candidate addresses.
    ///@param _roles The contract instance of IRoles.
    ///@param _datasetId The ID of the dataset.
    ///@param _token The address of the token used for staking.
    ///@param _numWinners The number of winners to be elected.
    ///@return winners An array containing the addresses of the elected winners.
    function _electWinners(
        address[] storage _candidates,
        IRoles _roles,
        uint64 _datasetId,
        address _token,
        uint256 _numWinners
    ) internal returns (address[] memory winners) {
        require(
            _numWinners > 0 && _numWinners <= _candidates.length,
            "Invalid number of winners"
        );

        winners = new address[](_numWinners);

        // Sort candidates by staked amount
        for (uint256 i = 0; i < _candidates.length - 1; i++) {
            for (uint256 j = 0; j < _candidates.length - i - 1; j++) {
                (, , uint256 jEscrow, ) = _roles.finance().getAccountEscrow(
                    _datasetId,
                    0,
                    _candidates[j],
                    _token,
                    FinanceType.Type.EscrowChallengeAuditCollateral
                );
                (, , uint256 iEscrow, ) = _roles.finance().getAccountEscrow(
                    _datasetId,
                    0,
                    _candidates[i],
                    _token,
                    FinanceType.Type.EscrowChallengeAuditCollateral
                );

                if (jEscrow < iEscrow) {
                    (_candidates[j], _candidates[j + 1]) = (
                        _candidates[j + 1],
                        _candidates[j]
                    );
                }
            }
        }

        for (uint256 i = 0; i < winners.length; i++) {
            winners[i] = _candidates[i];
        }

        return winners;
    }

    function isElectionFailed() internal returns (bool) {}
}
