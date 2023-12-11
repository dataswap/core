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
import {IEscrow} from "src/v0.8/interfaces/core/IEscrow.sol";
import {IFilplus} from "src/v0.8/interfaces/core/IFilplus.sol";
import {ICarstore} from "src/v0.8/interfaces/core/ICarstore.sol";
import {IDatasetsRequirement} from "src/v0.8/interfaces/module/IDatasetsRequirement.sol";
import {IDatasetsProof} from "src/v0.8/interfaces/module/IDatasetsProof.sol";
import {IDatasets} from "src/v0.8/interfaces/module/IDatasets.sol";
import {IMatchings} from "src/v0.8/interfaces/module/IMatchings.sol";
import {IMatchingsBids} from "src/v0.8/interfaces/module/IMatchingsBids.sol";
import {IMatchingsTarget} from "src/v0.8/interfaces/module/IMatchingsTarget.sol";
/// shared
import {MatchingsEvents} from "src/v0.8/shared/events/MatchingsEvents.sol";
import {MatchingsModifiers} from "src/v0.8/shared/modifiers/MatchingsModifiers.sol";
import {Errors} from "src/v0.8/shared/errors/Errors.sol";

/// library
import {MatchingTargetLIB} from "src/v0.8/module/matching/library/MatchingTargetLIB.sol";
import "src/v0.8/shared/utils/array/ArrayLIB.sol";

/// type
import {RolesType} from "src/v0.8/types/RolesType.sol";
import {EscrowType} from "src/v0.8/types/EscrowType.sol";
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

    /// @notice  Declare private variables
    mapping(uint64 => MatchingType.MatchingTarget) private targets;

    address private governanceAddress;
    IRoles private roles;
    IEscrow public escrow;
    IFilplus private filplus;
    ICarstore private carstore;
    IDatasets public datasets;
    IDatasetsRequirement public datasetsRequirement;
    IDatasetsProof public datasetsProof;
    IMatchings public matchings;
    IMatchingsBids public matchingsBids;
    /// @dev This empty reserved space is put in place to allow future versions to add new
    uint256[32] private __gap;

    /// @notice initialize function to initialize the contract and grant the default admin role to the deployer.
    // solhint-disable-next-line
    function initialize(
        address _governanceAddress,
        address _roles,
        address _filplus,
        address _carstore,
        address _datasets,
        address _datasetsRequirement,
        address _datasetsProof,
        address _escrow
    ) public initializer {
        governanceAddress = _governanceAddress;
        roles = IRoles(_roles);
        escrow = IEscrow(_escrow);
        filplus = IFilplus(_filplus);
        carstore = ICarstore(_carstore);
        datasets = IDatasets(_datasets);
        datasetsRequirement = IDatasetsRequirement(_datasetsRequirement);
        datasetsProof = IDatasetsProof(_datasetsProof);

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

    function initDependencies(
        address _matchings,
        address _matchingsBids
    ) external onlyRole(roles, RolesType.DEFAULT_ADMIN_ROLE) {
        matchings = IMatchings(_matchings);
        matchingsBids = IMatchingsBids(_matchingsBids);
    }

    ///@dev update cars info  to carStore before bidding
    function _beforeBidding(uint64 _matchingId) internal {
        (
            ,
            uint64[] memory cars,
            ,
            ,
            ,
            uint16 replicaIndex,

        ) = getMatchingTarget(_matchingId);
        for (uint64 i; i < cars.length; i++) {
            carstore.__registCarReplica(cars[i], _matchingId, replicaIndex);
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
        onlyRole(roles, RolesType.DATASET_PROVIDER)
        //onlyMatchingState(matchings, _matchingId, MatchingType.State.None)
        onlyMatchingInitiator(matchings, _matchingId)
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

    /// @notice  Function for parse cars from indexes.
    /// @param _starts The starts of cars to publish.
    /// @param _ends The ends of cars to publish.
    /// @return The cars of the indexes.
    function parseCars(
        uint64[] memory _starts,
        uint64[] memory _ends
    ) public pure returns (uint64[] memory) {
        require(_starts.length == _ends.length, "start and end not match");
        uint64 total;
        for (uint64 i = 0; i < _starts.length; i++) {
            require(_starts[i] <= _ends[i], "start must be greater than end");
            total += _ends[i] - _starts[i] + 1;
        }
        uint64 cnt;
        uint64[] memory _cars = new uint64[](total);
        for (uint64 i = 0; i < _starts.length; i++) {
            for (uint64 j = _starts[i]; j <= _ends[i]; j++) {
                _cars[cnt] = j;
                cnt++;
            }
        }
        return _cars;
    }

    /// @notice  Internal function for after publishing a matching
    /// @param _matchingId The matching id to publish cars.
    /// @param _target The matching target object contract.
    function _afterCompletePublish(
        uint64 _matchingId,
        MatchingType.MatchingTarget storage _target
    ) internal {
        _beforeBidding(_matchingId);
        matchings.__reportPublishMatching(_matchingId);

        address datasetInitiator = datasets.getDatasetMetadataSubmitter(
            _matchingId
        );
        address matchingInitiator = matchings.getMatchingInitiator(_matchingId);
        // Emit Synchronize matching payment sub account
        escrow.__emitPaymentUpdate(
            EscrowType.Type.TotalDataPrepareFeeByClient,
            datasetInitiator,
            _matchingId,
            matchingInitiator,
            EscrowType.PaymentEvent.AddPaymentSubAccount
        );

        (uint256 total, , , , ) = escrow.getBeneficiaryFund(
            EscrowType.Type.TotalDataPrepareFeeByClient,
            datasetInitiator,
            _matchingId,
            matchingInitiator
        );
        _target._updateSubsidy(total); // update subsidy amount

        (, , uint64 datasize, , , , ) = getMatchingTarget(_matchingId);
        // update dataset used size
        datasets.addDatasetUsedSize(_matchingId, datasize);
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
    )
        external
        onlyRole(roles, RolesType.DATASET_PROVIDER)
        onlyMatchingInitiator(matchings, _matchingId)
    {
        MatchingType.MatchingTarget storage target = targets[_matchingId];
        uint64[] memory _cars = parseCars(_carsStarts, _carsEnds);
        uint64 _size;
        try carstore.getCarsSize(_cars) returns (uint64 carSize) {
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
    /// @return subsidy The subsidy amount
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
            uint16 replicaIndex,
            uint256 subsidy
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
            target.replicaIndex,
            target.subsidy
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
            datasets.getDatasetState(_datasetId) ==
                DatasetType.State.DatasetApproved,
            "datasetId is not approved!"
        );
        require(
            datasetsProof.isDatasetContainsCars(_datasetId, _cars),
            "Invalid cids!"
        );
        require(_size > 0, "Invalid size!");

        // Source data needs to ensure that the associated mapping files data has been stored
        if (_dataType == DatasetType.DataType.Source) {
            (, , , DatasetType.DataType dataType, , , ) = getMatchingTarget(
                _associatedMappingFilesMatchingID
            );

            require(
                dataType == DatasetType.DataType.MappingFiles,
                "Need a associated matching"
            );
            require(
                matchings.getMatchingState(_associatedMappingFilesMatchingID) ==
                    MatchingType.State.Completed,
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
        uint16 requirementReplicaCount = datasetsRequirement
            .getDatasetReplicasCount(target.datasetId);
        for (uint64 i; i < cars.length; i++) {
            address[] memory winners = matchingsBids.getMatchingWinners(
                carstore.getCarMatchingIds(cars[i])
            );

            uint256 alreadyStoredReplicasByWinner = winners.countOccurrences(
                candidate
            );

            if (
                !filplus.isCompliantRuleMaxReplicasPerSP(
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
                !filplus.isCompliantRuleMinSPsPerDataset(
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
