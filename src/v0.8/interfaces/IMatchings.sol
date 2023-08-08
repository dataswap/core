// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity ^0.8.21;

import "../libraries/types/MatchingType.sol";
import "../libraries/MatchingLIB.sol";
import "./IRoles.sol";
import "./IDatasets.sol";
import "../libraries/types/RolesType.sol";
import "../libraries/types/DatasetType.sol";

abstract contract IMatchings {
    uint256 public matchingsCount;
    mapping(uint256 => MatchingType.Matching) public matchings;
    address public immutable rolesContract;
    address public immutable carsStorageContract;
    address public immutable datasetsContract;

    using MatchingLIB for MatchingType.Matching;

    constructor(
        address _rolesContract,
        address _carsStorageContract,
        address _datasetsContract
    ) {
        rolesContract = _rolesContract;
        carsStorageContract = _carsStorageContract;
        datasetsContract = _datasetsContract;
    }

    modifier validMatchingId(uint256 _matchingId) {
        require(
            _matchingId > 0 && _matchingId <= matchingsCount,
            "Invalid matching ID"
        );
        _;
    }

    modifier onlyInitiator(uint256 _matchingId) {
        MatchingType.Matching storage matching = matchings[_matchingId];
        require(matching.initiator == msg.sender, "No permission!");
        _;
    }

    modifier onlyRole(bytes32 _role) {
        IRoles role = IRoles(rolesContract);
        require(role.hasRole(_role, msg.sender), "No permission!");
        _;
    }

    modifier onlyDPorSP() {
        IRoles role = IRoles(rolesContract);
        require(
            role.hasRole(RolesType.DATASET_PROVIDER, msg.sender) ||
                role.hasRole(RolesType.STORAGE_PROVIDER, msg.sender),
            "No permission!"
        );
        _;
    }

    function publish(
        MatchingType.Target memory _target,
        uint256 _biddingDelayBlockCount,
        uint256 _biddingPeriodBlockCount,
        uint256 _storagePeriodBlockCount,
        uint256 _biddingThreshold,
        string memory _additionalInfo
    ) external onlyDPorSP {
        IDatasets datasets = IDatasets(datasetsContract);
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
    }

    function pause(
        uint256 _matchingId
    ) external validMatchingId(_matchingId) onlyInitiator(_matchingId) {
        MatchingType.Matching storage matching = matchings[_matchingId];
        matching.pause();
    }

    function reportPauseExpired(
        uint256 _matchingId
    ) external validMatchingId(_matchingId) {
        MatchingType.Matching storage matching = matchings[_matchingId];
        matching.reportPauseExpired();
    }

    function resume(
        uint256 _matchingId
    ) external validMatchingId(_matchingId) onlyInitiator(_matchingId) {
        MatchingType.Matching storage matching = matchings[_matchingId];
        matching.resume();
    }

    function cancel(
        uint256 _matchingId
    ) external validMatchingId(_matchingId) onlyInitiator(_matchingId) {
        MatchingType.Matching storage matching = matchings[_matchingId];
        matching.cancel();
    }

    function bidding(
        uint256 _matchingId,
        MatchingType.Bid memory _bid
    ) external validMatchingId(_matchingId) onlyDPorSP {
        MatchingType.Matching storage matching = matchings[_matchingId];
        matching.bidding(_bid);
    }

    function close(
        uint256 _matchingId,
        MatchingType.WinnerBidRule _rule
    ) external validMatchingId(_matchingId) {
        MatchingType.Matching storage matching = matchings[_matchingId];
        matching.close(_rule, carsStorageContract, _matchingId);
    }

    /// TODO: cid check,etc
    function filPlusCheck(
        uint256 _matchingId
    ) internal pure virtual returns (bool);

    function getState(
        uint256 _matchingId
    ) public view validMatchingId(_matchingId) returns (MatchingType.State) {
        MatchingType.Matching storage matching = matchings[_matchingId];
        return matching.getState();
    }
}
