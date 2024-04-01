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
import {IDatasetsChallenge} from "src/v0.8/interfaces/module/IDatasetsChallenge.sol";

///shared
import {DatasetsEvents} from "src/v0.8/shared/events/DatasetsEvents.sol";
import {DatasetsModifiers} from "src/v0.8/shared/modifiers/DatasetsModifiers.sol";
/// library
import {DatasetChallengeProofLIB} from "src/v0.8/module/dataset/library/challenge/DatasetChallengeProofLIB.sol";
import {DatasetAuditorElectionLIB} from "src/v0.8/module/dataset/library/challenge/DatasetAuditorElectionLIB.sol";

/// type
import {RolesType} from "src/v0.8/types/RolesType.sol";
import {DatasetType} from "src/v0.8/types/DatasetType.sol";
import {FinanceType} from "src/v0.8/types/FinanceType.sol";
import {GeolocationType} from "src/v0.8/types/GeolocationType.sol";

import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {UUPSUpgradeable} from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

/// @title DatasetsChallenge Contract
/// @notice This contract serves as the base for managing DatasetChallengeProof.
/// @dev This contract is intended to be inherited by specific dataset-related contracts.
contract DatasetsChallenge is
    Initializable,
    UUPSUpgradeable,
    IDatasetsChallenge,
    DatasetsModifiers
{
    using DatasetChallengeProofLIB for DatasetType.DatasetChallengeProof;
    using DatasetAuditorElectionLIB for DatasetType.DatasetAuditorElection;

    mapping(uint64 => DatasetType.DatasetChallengeProof)
        private datasetChallengeProofs; // Mapping of dataset ID to dataset details

    address public governanceAddress;
    IRoles public roles;

    /// @dev This empty reserved space is put in place to allow future versions to add new
    uint256[32] private __gap;

    /// @notice initialize function to initialize the contract and grant the default admin role to the deployer.
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

    /// @dev Allows a user to nominate themselves as a candidate for dataset auditor election.
    /// @param _datasetId The ID of the dataset for which the user is nominating themselves as a candidate.
    function nominateAsDatasetAuditorCandidate(uint64 _datasetId) external {
        require(
            uint64(block.number) < getAuditorElectionEndHeight(_datasetId),
            "auditors election timeout"
        );

        uint256 _amount = roles.finance().getEscrowRequirement(
            _datasetId,
            0,
            msg.sender,
            FinanceType.FIL,
            FinanceType.Type.EscrowChallengeAuditCollateral
        );

        roles.finance().__escrow(
            _datasetId,
            0,
            msg.sender,
            FinanceType.FIL,
            FinanceType.Type.EscrowChallengeAuditCollateral,
            _amount
        );

        DatasetType.DatasetChallengeProof
            storage datasetChallengeProof = datasetChallengeProofs[_datasetId];
        datasetChallengeProof.election._nominateAsDatasetAuditorCandidate();
    }

    ///@notice Submit challenge proof for a dataset
    /// Based on merkle proof challenge.
    /// random challenge method is used to reduce the amount of data and calculation while ensuring algorithm security.
    function submitDatasetChallengeProofs(
        uint64 _datasetId,
        uint64 _randomSeed,
        bytes32[] memory _leaves,
        bytes32[][] memory _siblings,
        uint32[] memory _paths
    )
        external
        onlyDatasetState(
            roles.datasets(),
            _datasetId,
            DatasetType.State.ProofSubmitted
        )
    {
        if (isDatasetAuditTimeout(_datasetId)) {
            roles.datasets().__reportDatasetWorkflowTimeout(_datasetId);
            return;
        }
        require(
            _leaves.length >=
                roles.filplus().datasetRuleChallengePointsPerAuditor(),
            "invalid challenge points"
        );

        DatasetType.DatasetChallengeProof
            storage datasetChallengeProof = datasetChallengeProofs[_datasetId];

        bytes32 seed = datasetChallengeProof.election._electSeed(
            getAuditorElectionEndHeight(_datasetId)
        );

        require(
            datasetChallengeProof.election._processCandidateTicketResult(
                getAuditorElectionEndHeight(_datasetId),
                msg.sender,
                getChallengeAuditorsCountRequirement(_datasetId),
                seed
            ),
            "Not an election winner"
        );

        bytes32[] memory roots = _getChallengeRoots(
            _datasetId,
            _randomSeed,
            roles.filplus().datasetRuleChallengePointsPerAuditor()
        );

        datasetChallengeProof._submitDatasetChallengeProofs(
            _randomSeed,
            _leaves,
            _siblings,
            _paths,
            roots,
            roles.merkleUtils()
        );

        if (
            getChallengeAuditorsCountSubmitted(_datasetId) ==
            getChallengeAuditorsCountRequirement(_datasetId)
        ) {
            roles.datasets().__reportDatasetChallengeCompleted(_datasetId);
        }

        emit DatasetsEvents.DatasetChallengeProofsSubmitted(
            _datasetId,
            msg.sender
        );
    }

    /// @notice Retrieves challenge proofs submitters for a specific dataset.
    /// @dev This external function is used to get arrays of addresses representing auditors and corresponding points for challenge proofs submitters for a given dataset.
    /// @param _datasetId The unique identifier of the dataset.
    /// @return auditors An array of addresses representing challenge proofs submitters (auditors).
    /// @return points An array of corresponding points for each challenge proofs submitter.
    function getDatasetChallengeProofsSubmitters(
        uint64 _datasetId
    )
        external
        view
        returns (address[] memory auditors, uint64[] memory points)
    {
        DatasetType.DatasetChallengeProof
            storage datasetChallengeProof = datasetChallengeProofs[_datasetId];
        points = new uint64[](datasetChallengeProof.auditors.length);
        for (uint256 i = 0; i < datasetChallengeProof.auditors.length; i++) {
            points[i] = uint64(
                datasetChallengeProof
                    .challengeProofs[datasetChallengeProof.auditors[i]]
                    .challenges
                    .length
            );
        }
        return (datasetChallengeProof.auditors, points);
    }

    ///@notice Get dataset challenge proofs
    /// @param _datasetId The ID of the dataset for which proof is submitted.
    /// @param _auditor The auditor of the dataset for which challenge proof is submitted.
    function getDatasetChallengeProofs(
        uint64 _datasetId,
        address _auditor
    )
        public
        view
        onlyNotZero(_datasetId)
        returns (
            bytes32[] memory leaves,
            bytes32[][] memory siblings,
            uint32[] memory paths,
            uint64 randomSeed
        )
    {
        DatasetType.DatasetChallengeProof
            storage datasetChallengeProof = datasetChallengeProofs[_datasetId];
        return datasetChallengeProof.getDatasetChallengeProofs(_auditor);
    }

    ///@notice Get count of dataset chellange proofs.
    /// @param _datasetId The ID of the dataset for which proof is submitted.
    function getChallengeAuditorsCountSubmitted(
        uint64 _datasetId
    ) public view onlyNotZero(_datasetId) returns (uint16) {
        DatasetType.DatasetChallengeProof
            storage datasetChallengeProof = datasetChallengeProofs[_datasetId];
        return datasetChallengeProof.getChallengeAuditorsCountSubmitted();
    }

    ///@notice Check if the challenge proof is a duplicate.
    function isDatasetChallengeProofDuplicate(
        uint64 _datasetId,
        address _auditor,
        uint64 _randomSeed
    ) public view returns (bool) {
        DatasetType.DatasetChallengeProof
            storage datasetChallengeProof = datasetChallengeProofs[_datasetId];
        return
            datasetChallengeProof.isDatasetChallengeProofDuplicate(
                _auditor,
                _randomSeed
            );
    }

    /// @notice Checks if the dataset audit has timed out.
    /// @dev This function determines if the dataset audit for the given dataset ID has timed out.
    /// @param _datasetId The ID of the dataset.
    /// @return True if the dataset audit has timed out, false otherwise.
    function isDatasetAuditTimeout(
        uint64 _datasetId
    ) public view returns (bool) {
        DatasetType.State state = roles.datasets().getDatasetState(_datasetId);
        if (state != DatasetType.State.ProofSubmitted) {
            return false;
        }
        uint64 completedHeight = roles
            .datasetsProof()
            .getDatasetProofCompleteHeight(_datasetId);

        (, uint64 auditBlockCount) = roles
            .datasets()
            .getDatasetTimeoutParameters(_datasetId);

        if (uint64(block.number) >= completedHeight + auditBlockCount) {
            return true;
        }
        return false;
    }

    /// @notice To obtain the number of challenges to be completed
    /// @param _datasetId The ID of the dataset for which proof is submitted.
    function _getSecureDatasetChallengePoints(
        uint64 _datasetId
    ) internal view returns (uint64) {
        uint64 smallDataSet = 1099511627776; //1 point per 1TB
        uint64 datasetSize = roles.datasetsProof().getDatasetUnpadSize(
            _datasetId,
            DatasetType.DataType.Source
        );
        return (datasetSize + smallDataSet - 1) / smallDataSet;
    }

    /// @dev Retrieves the required number of challenge auditors for a dataset.
    /// @param _datasetId The ID of the dataset.
    /// @return auditors The required number of challenge auditors.
    function getChallengeAuditorsCountRequirement(
        uint64 _datasetId
    ) public view returns (uint64 auditors) {
        uint64 requirementPoints = _getSecureDatasetChallengePoints(_datasetId);
        uint64 challengePointsPerAuditor = roles
            .filplus()
            .datasetRuleChallengePointsPerAuditor();

        // Calculate the minimum number of people needed for the challenge
        auditors =
            (requirementPoints + challengePointsPerAuditor - 1) /
            challengePointsPerAuditor;
    }

    /// @dev Retrieves the required number of challenge points for a dataset.
    /// @param _datasetId The ID of the dataset.
    /// @return points The required number of challenge points.
    function getChallengePointsCountRequirement(
        uint64 _datasetId
    ) public view returns (uint64 points) {
        uint64 auditors = getChallengeAuditorsCountRequirement(_datasetId);
        // Calculate the actual total challenge points achieved
        points =
            auditors *
            roles.filplus().datasetRuleChallengePointsPerAuditor();
    }

    /// @notice generate cars challenge.
    /// @dev This function returns the cars Challenge information for a specific dataset.
    /// @param _datasetId The ID of the dataset for which proof is submitted.
    /// @param _randomSeed The cars challenge random seed.
    /// @param _carChallengesCount the cars Challenge count for specific dataset.
    function _getChallengeRoots(
        uint64 _datasetId,
        uint64 _randomSeed,
        uint64 _carChallengesCount
    ) internal view returns (bytes32[] memory) {
        bytes32[] memory carChallenges = new bytes32[](_carChallengesCount);
        for (uint64 i = 0; i < _carChallengesCount; i++) {
            carChallenges[i] = _getChallengeRoot(
                _datasetId,
                _randomSeed,
                i,
                _carChallengesCount
            );
        }
        return carChallenges;
    }

    /// @notice generate a car challenge.
    /// @dev This function returns a car Challenge information for a specific dataset.
    /// @param _datasetId The ID of the dataset for which proof is submitted.
    /// @param _randomSeed The cars challenge random seed.
    /// @param _index The car index of challenge.
    /// @param _carChallengesCount the cars Challenge count for specific dataset.
    function _getChallengeRoot(
        uint64 _datasetId,
        uint64 _randomSeed,
        uint64 _index,
        uint64 _carChallengesCount
    ) internal view returns (bytes32) {
        uint64 index = DatasetChallengeProofLIB.generateChallengeIndex(
            _randomSeed,
            _index,
            _carChallengesCount
        );

        return
            roles.datasetsProof().getDatasetProof(
                _datasetId,
                DatasetType.DataType.Source,
                index,
                1
            )[0];
    }

    /// @dev Retrieves auditor candidates for a given dataset ID.
    /// @param _datasetId The ID of the dataset for which auditor candidates are requested.
    /// @return candidates An array containing addresses of auditor candidates.
    function getDatasetAuditorCandidates(
        uint64 _datasetId
    ) external view returns (address[] memory candidates) {
        DatasetType.DatasetChallengeProof
            storage datasetChallengeProof = datasetChallengeProofs[_datasetId];

        candidates = datasetChallengeProof.election.candidates;
    }

    /// @notice Retrieves the end height of the auditor election for a specific dataset.
    /// @dev Retrieves the block height at which the auditor election for the specified dataset ends.
    /// @param _datasetId The ID of the dataset for which the end height of the auditor election is retrieved.
    /// @return The end height of the auditor election.
    function getAuditorElectionEndHeight(
        uint64 _datasetId
    ) public view returns (uint64) {
        uint64 proofCompleteHeight = roles
            .datasetsProof()
            .getDatasetProofCompleteHeight(_datasetId);

        return
            uint64(
                proofCompleteHeight +
                    roles.filplus().datasetRuleAuditorsElectionTime()
            );
    }

    /// @dev Checks whether the given account is a winner for a specific dataset ID.
    /// @param _datasetId The ID of the dataset being checked.
    /// @param _account The address of the account being checked for winner status.
    /// @return A boolean indicating whether the account is a winner for the dataset ID.
    function isWinner(
        uint64 _datasetId,
        address _account
    ) public view returns (bool) {
        DatasetType.DatasetChallengeProof
            storage datasetChallengeProof = datasetChallengeProofs[_datasetId];

        bytes32 _seed = datasetChallengeProof.election._getElectSeed(
            getAuditorElectionEndHeight(_datasetId)
        );

        return
            datasetChallengeProof.election._processCandidateTicketResult(
                getAuditorElectionEndHeight(_datasetId),
                _account,
                getChallengeAuditorsCountRequirement(_datasetId),
                _seed
            );
    }
}
