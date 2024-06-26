/*******************************************************************************
 *   (c) 2023 Dataswap
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
/// interface
import {IRoles} from "src/v0.8/interfaces/core/IRoles.sol";
import {IMatchingsTarget} from "src/v0.8/interfaces/module/IMatchingsTarget.sol";
/// shared
import {MatchingsEvents} from "src/v0.8/shared/events/MatchingsEvents.sol";
import {MatchingsModifiers} from "src/v0.8/shared/modifiers/MatchingsModifiers.sol";
import {Errors} from "src/v0.8/shared/errors/Errors.sol";

/// library
import {MatchingTargetLIB} from "src/v0.8/module/matching/library/MatchingTargetLIB.sol";
import {ArrayAddressLIB, ArrayUint64LIB} from "src/v0.8/shared/utils/array/ArrayLIB.sol";

/// type
import {RolesType} from "src/v0.8/types/RolesType.sol";
import {DatasetType} from "src/v0.8/types/DatasetType.sol";
import {MatchingType} from "src/v0.8/types/MatchingType.sol";

import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {UUPSUpgradeable} from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

/// @title Matchings Base Contract
/// @notice This contract serves as the base for managing matchings, their states, and associated actions.
/// @dev This contract is intended to be inherited by specific matching-related contracts.
contract MatchingsTarget is
    Initializable,
    UUPSUpgradeable,
    IMatchingsTarget,
    MatchingsModifiers
{
    /// @notice  Use libraries for different matching functionalities
    using MatchingTargetLIB for MatchingType.MatchingTarget;
    using ArrayAddressLIB for address[];
    using ArrayUint64LIB for uint64[];

    /// @notice  Declare private variables
    mapping(uint64 => MatchingType.MatchingTarget) private targets;

    address private governanceAddress;
    IRoles public roles;
    /// @dev This empty reserved space is put in place to allow future versions to add new
    uint256[32] private __gap;

    /// @notice initialize function to initialize the contract and grant the default admin role to the deployer.
    // solhint-disable-next-line
    function initialize(
        address _governanceAddress,
        address _roles
    ) public initializer {
        governanceAddress = _governanceAddress;
        roles = IRoles(_roles);
        __UUPSUpgradeable_init();
    }

    /// @notice UUPS Upgradeable function to update the roles implementation
    /// @dev Only triggered by contract admin
    function _authorizeUpgrade(
        address newImplementation
    )
        internal
        override
        onlyRole(roles, RolesType.DEFAULT_ADMIN_ROLE) // solhint-disable-next-line
    {}

    /// @notice Returns the implementation contract
    function getImplementation() external view returns (address) {
        return _getImplementation();
    }

    ///@dev update cars info  to carStore before bidding
    function _beforeBidding(uint64 _matchingId) internal {
        (, uint64[] memory cars, , , , uint16 replicaIndex) = getMatchingTarget(
            _matchingId
        );
        for (uint64 i; i < cars.length; i++) {
            roles.carstore().__registCarReplica(
                cars[i],
                _matchingId,
                replicaIndex
            );
        }
    }

    /// @notice Function for create a new matching target.
    /// @param _matchingId The matching id to publish cars.
    /// @param _datasetId The dataset id to create matching.
    /// @param _dataType Identify the data type of "cars", which can be either "Source" or "MappingFiles".
    /// @param _associatedMappingFilesMatchingID The matching ID that associated with mapping files of dataset of _datasetId
    /// @param _replicaIndex The index of the replica in dataset.
    function createTarget(
        uint64 _matchingId,
        uint64 _datasetId,
        DatasetType.DataType _dataType,
        uint64 _associatedMappingFilesMatchingID,
        uint16 _replicaIndex
    )
        external
        //onlyMatchingState(matchings, _matchingId, MatchingType.State.None)
        onlyMatchingInitiator(roles.matchings(), _matchingId)
    {
        MatchingType.MatchingTarget storage target = targets[_matchingId];
        target.datasetId = _datasetId;
        target.cars = new uint64[](0);
        target.size = 0;
        target.dataType = _dataType;
        target
            .associatedMappingFilesMatchingID = _associatedMappingFilesMatchingID;
        target.replicaIndex = _replicaIndex;
    }

    /// @notice  Internal function for after publishing a matching
    /// @param _matchingId The matching id to publish cars.
    /// @param _target The matching target object contract.
    function _afterCompletePublish(
        uint64 _matchingId,
        MatchingType.MatchingTarget storage _target
    ) internal {
        _beforeBidding(_matchingId);
        roles.matchings().__reportPublishMatching(_matchingId, _target.size);
    }

    /// @notice  Function for publishing a matching
    /// @param _matchingId The matching id to publish cars.
    /// @param _datasetId The dataset id of matching.
    /// @param _carsStarts The cars to publish.
    /// @param _carsEnds The cars to publish.
    /// @param complete If the publish is complete.
    function publishMatching(
        uint64 _matchingId,
        uint64 _datasetId,
        uint64[] memory _carsStarts,
        uint64[] memory _carsEnds,
        bool complete
    ) external onlyMatchingInitiator(roles.matchings(), _matchingId) {
        MatchingType.MatchingTarget storage target = targets[_matchingId];
        uint64[] memory _cars = _carsStarts.mergeSequentialArray(_carsEnds);
        uint64 _size;
        try roles.carstore().getPiecesSize(_cars) returns (uint64 carSize) {
            _size = carSize;
        } catch {
            revert("Get cars size failed");
        }
        require(target.datasetId == _datasetId, "invalid dataset id");

        target._updateTargetCars(_cars, _size);

        require(
            isMatchingTargetValid(
                _datasetId,
                _cars,
                _size,
                target.dataType,
                target.associatedMappingFilesMatchingID
            ),
            "Target invalid"
        );

        if (complete) {
            _afterCompletePublish(_matchingId, target);
            emit MatchingsEvents.MatchingPublished(_matchingId, msg.sender);
        }
    }

    /// @notice Get the target information of a matching.
    /// @param _matchingId The ID of the matching.
    /// @return datasetID The ID of the associated dataset.
    /// @return cars An array of CIDs representing the cars in the matching.
    /// @return size The size of the matching.
    /// @return dataType The data type of the matching.
    /// @return associatedMappingFilesMatchingID The ID of the associated mapping files matching.
    /// @return replicaIndex The index of dataset's replica
    function getMatchingTarget(
        uint64 _matchingId
    )
        public
        view
        returns (
            uint64 datasetID,
            uint64[] memory cars,
            uint64 size,
            DatasetType.DataType dataType,
            uint64 associatedMappingFilesMatchingID,
            uint16 replicaIndex
        )
    {
        // Access the matching with the specified ID and retrieve the target information
        MatchingType.MatchingTarget storage target = targets[_matchingId];
        return (
            target.datasetId,
            target.cars,
            target.size,
            target.dataType,
            target.associatedMappingFilesMatchingID,
            target.replicaIndex
        );
    }

    /// @notice Check if a matching with the given matching ID contains a specific CID.
    /// @param _matchingId The ID of the matching to check.
    /// @param _cid The CID (Content Identifier) to check for.
    /// @return True if the matching contains the specified CID, otherwise false.
    function isMatchingContainsCar(
        uint64 _matchingId,
        uint64 _cid
    ) public view returns (bool) {
        MatchingType.MatchingTarget storage target = targets[_matchingId];
        uint64[] memory cids = target._getCars();
        for (uint64 i = 0; i < cids.length; i++) {
            if (_cid == cids[i]) return true;
        }
        return false;
    }

    /// @notice Check if a matching with the given matching ID contains multiple CIDs.
    /// @param _matchingId The ID of the matching to check.
    /// @param _cids An array of CIDs (Content Identifiers) to check for.
    /// @return True if the matching contains all the specified CIDs, otherwise false.
    function isMatchingContainsCars(
        uint64 _matchingId,
        uint64[] memory _cids
    ) public view returns (bool) {
        for (uint64 i = 0; i < _cids.length; i++) {
            if (!isMatchingContainsCar(_matchingId, _cids[i])) return false;
        }
        return true;
    }

    /// @notice check is matching targe valid
    function isMatchingTargetValid(
        uint64 _datasetId,
        uint64[] memory _cars,
        uint64 _size,
        DatasetType.DataType _dataType,
        uint64 _associatedMappingFilesMatchingID
    ) public view returns (bool) {
        require(
            roles.datasets().getDatasetState(_datasetId) ==
                DatasetType.State.Approved,
            "datasetId is not approved!"
        );
        require(
            roles.datasetsProof().isDatasetContainsCars(_datasetId, _cars),
            "Invalid cids!"
        );
        require(_size > 0, "Invalid size!");

        // Source data needs to ensure that the associated mapping files data has been stored
        if (_dataType == DatasetType.DataType.Source) {
            (
                ,
                uint64[] memory mappingsCars,
                ,
                DatasetType.DataType dataType,
                ,

            ) = getMatchingTarget(_associatedMappingFilesMatchingID);

            require(
                dataType == DatasetType.DataType.MappingFiles,
                "Need a associated matching"
            );

            require(
                roles.datasetsProof().isDatasetContainsCars(
                    _datasetId,
                    mappingsCars
                ),
                "Invalid mapping files cars"
            );

            require(
                roles.matchings().getMatchingState(
                    _associatedMappingFilesMatchingID
                ) == MatchingType.State.Completed,
                "datasetId is not completed!"
            );
        }
        return true;
    }

    /// @notice Check if a matching meets the requirements of Fil+.
    function isMatchingTargetMeetsFilPlusRequirements(
        uint64 _matchingId,
        address candidate
    ) external view returns (bool) {
        MatchingType.MatchingTarget storage target = targets[_matchingId];
        uint64[] memory cars = target._getCars();
        uint16 requirementReplicaCount = roles
            .datasetsRequirement()
            .getDatasetReplicasCount(target.datasetId);
        for (uint64 i; i < cars.length; i++) {
            address[] memory winners = roles.matchingsBids().getMatchingWinners(
                roles.carstore().getCarMatchingIds(cars[i])
            );

            uint256 alreadyStoredReplicasByWinner = winners.countOccurrences(
                candidate
            );

            if (
                !roles.filplus().isCompliantRuleMaxReplicasPerSP(
                    uint16(alreadyStoredReplicasByWinner + 1)
                )
            ) {
                return false;
            }

            uint256 uniqueCount = winners.countUniqueElements();

            if (winners.isContains(candidate)) {
                uniqueCount++;
            }

            if (
                !roles.filplus().isCompliantRuleMinSPsPerDataset(
                    requirementReplicaCount,
                    uint16(winners.length),
                    uint16(uniqueCount)
                )
            ) {
                return false;
            }
        }

        return true;
    }
}
