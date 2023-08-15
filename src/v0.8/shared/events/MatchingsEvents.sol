/// SPDX-License-Identifier: GPL-3.0-or-later
/// (c) 2023 DataSwap
///
/// Licensed under the GNU General Public License, Version 3.0 or later (the "License");
/// you may not use this file except in compliance with the License.
/// You may obtain a copy of the License at
///     https://www.gnu.org/licenses/gpl-3.0.en.html
///
/// Unless required by applicable law or agreed to in writing, software
/// distributed under the License is distributed on an "AS IS" BASIS,
/// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
/// See the License for the specific language governing permissions and
/// limitations under the License.

pragma solidity ^0.8.21;

library MatchingsEvents {
    /// @notice Declare events for external monitoring

    // Event emitted when a matching is published
    event MatchingPublished(
        uint256 indexed matchingId,
        address indexed initiator
    );

    // Event emitted when a matching is paused
    event MatchingPaused(uint256 indexed _matchingId);

    // Event emitted when a matching's pause expires
    event MatchingPauseExpired(uint256 indexed _matchingId);

    // Event emitted when a matching is resumed
    event MatchingResumed(uint256 indexed _matchingId);

    // Event emitted when a matching is cancelled
    event MatchingCancelled(uint256 indexed _matchingId);

    // Event emitted when a matching has a winner
    event MatchingHasWinner(
        uint256 indexed _matchingId,
        address indexed _winner
    );

    // Event emitted when a matching has no winner
    event MatchingNoWinner(uint256 indexed _matchingId);

    // Event emitted when a bid is placed in a matching
    event MatchingBidPlaced(
        uint256 indexed _matchingId,
        address _bidder,
        uint256 _amount
    );
}
