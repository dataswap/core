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

import "@openzeppelin/contracts/access/Ownable2Step.sol";
import "../../types/MatchingType.sol";
import "../../types/RolesType.sol";
import "../../types/DatasetType.sol";
import "../../core/accessControl/IRoles.sol";
import "../dataset/Datasets.sol";
import "./library/MatchingLIB.sol";

/// @title Matchings Base Contract
/// @notice This contract serves as the base for managing matchings, their states, and associated actions.
/// @dev This contract is intended to be inherited by specific matching-related contracts.
abstract contract Matchings is Ownable2Step {
    uint256 public matchingsCount;
    mapping(uint256 => MatchingType.Matching) public matchings;
    address public immutable rolesContract;
    address public immutable carsStorageContract;
    address public immutable datasetsContract;

    using MatchingLIB for MatchingType.Matching;

    // @notice Contract constructor.
    /// @dev Initializes the contract with the provided addresses for roles, cars storage, and datasets contracts.
    /// @param _rolesContract The address of the roles contract.
    /// @param _carsStorageContract The address of the cars storage contract.
    /// @param _datasetsContract The address of the datasets contract.
    constructor(
        address _rolesContract,
        address _carsStorageContract,
        address _datasetsContract
    ) {
        rolesContract = _rolesContract;
        carsStorageContract = _carsStorageContract;
        datasetsContract = _datasetsContract;
    }

    /// @notice Event emitted when a matching is published.
    /// @param _matchingId The ID of the published matching.
    event MatchingPublished(uint256 indexed _matchingId);

    /// @notice Event emitted when a matching is paused.
    /// @param _matchingId The ID of the paused matching.
    event MatchingPaused(uint256 indexed _matchingId);

    /// @notice Event emitted when the pause of a matching is reported as expired.
    /// @param _matchingId The ID of the matching for which the pause expired.
    event PauseExpiredReported(uint256 indexed _matchingId);

    /// @notice Event emitted when a matching is resumed.
    /// @param _matchingId The ID of the resumed matching.
    event MatchingResumed(uint256 indexed _matchingId);

    /// @notice Event emitted when a matching is canceled.
    /// @param _matchingId The ID of the canceled matching.
    event MatchingCanceled(uint256 indexed _matchingId);

    /// @notice Event emitted when a bid is placed in a matching.
    /// @param _matchingId The ID of the matching in which the bid was placed.
    event BidPlaced(uint256 indexed _matchingId);

    /// @notice Event emitted when a matching is closed.
    /// @param _matchingId The ID of the closed matching.
    event MatchingClosed(uint256 indexed _matchingId);

    /// @notice Modifier: Check if the provided matching ID is valid.
    /// @dev This modifier ensures that the provided matching ID is within a valid range.
    /// @param _matchingId The matching ID to be checked.
    modifier validMatchingId(uint256 _matchingId) {
        require(
            _matchingId > 0 && _matchingId <= matchingsCount,
            "Invalid matching ID"
        );
        _;
    }

    /// @notice Modifier: Check if the sender is the initiator of the matching.
    /// @dev This modifier ensures that the sender is the initiator of the specified matching.
    /// @param _matchingId The matching ID for which the initiator is checked.
    modifier onlyInitiator(uint256 _matchingId) {
        MatchingType.Matching storage matching = matchings[_matchingId];
        require(matching.initiator == msg.sender, "No permission!");
        _;
    }

    /// @notice Modifier: Check if the sender has a specific role.
    /// @dev This modifier ensures that the sender has a specific role as defined by the provided role parameter.
    /// @param _role The role required for access.
    modifier onlyRole(bytes32 _role) {
        IRoles role = IRoles(rolesContract);
        require(role.hasRole(_role, msg.sender), "No permission!");
        _;
    }

    /// @notice Modifier: Check if the sender is a dataset provider or storage provider.
    /// @dev This modifier ensures that the sender is either a dataset provider or a storage provider.
    modifier onlyDPorSP() {
        IRoles role = IRoles(rolesContract);
        require(
            role.hasRole(RolesType.DATASET_PROVIDER, msg.sender) ||
                role.hasRole(RolesType.STORAGE_PROVIDER, msg.sender),
            "No permission!"
        );
        _;
    }

    /// @notice Publish a matching.
    /// @dev This function is used to publish a matching and initiate the matching process.
    /// @param _target The target information for the matching.
    /// @param _biddingDelayBlockCount The delay in blocks before bidding starts.
    /// @param _biddingPeriodBlockCount The duration in blocks for the bidding period.
    /// @param _storagePeriodBlockCount The duration in blocks for the storage period.
    /// @param _biddingThreshold The minimum bid required to participate in the matching.
    /// @param _additionalInfo Additional information about the matching.
    function publish(
        MatchingType.Target memory _target,
        uint256 _biddingDelayBlockCount,
        uint256 _biddingPeriodBlockCount,
        uint256 _storagePeriodBlockCount,
        uint256 _biddingThreshold,
        string memory _additionalInfo
    ) external onlyDPorSP {
        Datasets datasets = Datasets(datasetsContract);
        require(
            DatasetType.State.DatasetApproved ==
                datasets.getState(_target.datasetID),
            "dataset isn't approved"
        );
        if (_target.dataType == MatchingType.DataType.Dataset) {
            MatchingType.Matching storage metaDatasetMatching = matchings[
                _target.associatedMappingFilesMatchingID
            ];
            require(
                MatchingType.State.Completed == metaDatasetMatching.getState(),
                "associated mapping files matching isn't completed"
            );
            //TODO: require storage completed
        }

        matchingsCount++;
        MatchingType.Matching storage newMatching = matchings[matchingsCount];

        newMatching.target = _target;
        newMatching.biddingDelayBlockCount = _biddingDelayBlockCount;
        newMatching.biddingPeriodBlockCount = _biddingPeriodBlockCount;
        newMatching.storagePeriodBlockCount = _storagePeriodBlockCount;
        newMatching.biddingThreshold = _biddingThreshold;
        newMatching.additionalInfo = _additionalInfo;
        newMatching.initiator = msg.sender;
        newMatching.createdBlockNumber = block.number;

        newMatching.publish();
        emit MatchingPublished(matchingsCount);
    }

    /// @notice Pause a matching.
    /// @dev This function is used by the initiator to pause a matching.
    /// @param _matchingId The ID of the matching to be paused.
    function pause(
        uint256 _matchingId
    ) external validMatchingId(_matchingId) onlyInitiator(_matchingId) {
        MatchingType.Matching storage matching = matchings[_matchingId];
        matching.pause();
        emit MatchingPaused(_matchingId);
    }

    /// @notice Report the expiration of a pause for a matching.
    /// @dev This function is used to report that the pause period of a matching has expired.
    /// @param _matchingId The ID of the matching.
    function reportPauseExpired(
        uint256 _matchingId
    ) external validMatchingId(_matchingId) {
        MatchingType.Matching storage matching = matchings[_matchingId];
        matching.reportPauseExpired();
        emit PauseExpiredReported(_matchingId);
    }

    /// @notice Resume a paused matching.
    /// @dev This function is used by the initiator to resume a paused matching.
    /// @param _matchingId The ID of the matching to be resumed.
    function resume(
        uint256 _matchingId
    ) external validMatchingId(_matchingId) onlyInitiator(_matchingId) {
        MatchingType.Matching storage matching = matchings[_matchingId];
        matching.resume();
        emit MatchingResumed(_matchingId);
    }

    /// @notice Cancel a matching.
    /// @dev This function is used by the initiator to cancel a matching.
    /// @param _matchingId The ID of the matching to be canceled.
    function cancel(
        uint256 _matchingId
    ) external validMatchingId(_matchingId) onlyInitiator(_matchingId) {
        MatchingType.Matching storage matching = matchings[_matchingId];
        matching.cancel();
        emit MatchingCanceled(_matchingId);
    }

    /// @notice Place a bid in a matching.
    /// @dev This function is used by a dataset provider or storage provider to place a bid in a matching.
    /// @param _matchingId The ID of the matching to place a bid in.
    /// @param _bid The bid information to be placed.
    function bidding(
        uint256 _matchingId,
        MatchingType.Bid memory _bid
    ) external validMatchingId(_matchingId) onlyDPorSP {
        MatchingType.Matching storage matching = matchings[_matchingId];
        matching.bidding(_bid);
        emit BidPlaced(_matchingId);
    }

    /// @notice Close a matching and determine the winner.
    /// @dev This function is used to close a matching, determine the winner based on the specified rule,
    /// and perform necessary actions.
    /// @param _matchingId The ID of the matching to be closed.
    /// @param _rule The rule to determine the winner (highest or lowest bid).
    function close(
        uint256 _matchingId,
        MatchingType.WinnerBidRule _rule
    ) external validMatchingId(_matchingId) {
        MatchingType.Matching storage matching = matchings[_matchingId];
        matching.close(_rule);
        emit MatchingClosed(_matchingId);
    }

    /// @dev TODO: cid check, etc
    function filPlusCheck(
        uint256 _matchingId
    ) internal pure virtual returns (bool);

    /// @notice Get the state of a matching.
    /// @param _matchingId The ID of the matching to retrieve the state for.
    /// @return The current state of the matching.
    function getState(
        uint256 _matchingId
    ) public view validMatchingId(_matchingId) returns (MatchingType.State) {
        MatchingType.Matching storage matching = matchings[_matchingId];
        return matching.getState();
    }
}
