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
import {CarstoreModifiers} from "src/v0.8/shared/modifiers/CarstoreModifiers.sol";
/// library
import {DatasetChallengeProofLIB} from "src/v0.8/module/dataset/library/challenge/DatasetChallengeProofLIB.sol";

/// type
import {RolesType} from "src/v0.8/types/RolesType.sol";
import {EscrowType} from "src/v0.8/types/EscrowType.sol";
import {DatasetType} from "src/v0.8/types/DatasetType.sol";
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
    CarstoreModifiers
{
    using DatasetChallengeProofLIB for DatasetType.DatasetChallengeProof;
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

    ///@notice Submit challenge proof for a dataset
    /// Based on merkle proof challenge.
    /// random challenge method is used to reduce the amount of data and calculation while ensuring algorithm security.
    function submitDatasetChallengeProofs(
        uint64 _datasetId,
        uint64 _randomSeed,
        bytes32[] memory _leaves,
        bytes32[][] memory _siblings,
        uint32[] memory _paths
    ) external onlyRole(roles, RolesType.DATASET_AUDITOR) {
        require(
            getDatasetChallengeProofsCount(_datasetId) <=
                roles.filplus().getChallengeProofsSubmiterCount(),
            "exceeds maximum challenge proofs count"
        );
        DatasetType.DatasetChallengeProof
            storage datasetChallengeProof = datasetChallengeProofs[_datasetId];
        bytes32[] memory roots = _getChallengeRoots(
            _datasetId,
            _randomSeed,
            getChallengeSubmissionCount(_datasetId)
        );
        datasetChallengeProof._submitDatasetChallengeProofs(
            _randomSeed,
            _leaves,
            _siblings,
            _paths,
            roots,
            roles.merkleUtils()
        );

        // Add dataset auditor to beneficiary list
        roles.escrow().__emitPaymentUpdate(
            EscrowType.Type.DatasetAuditFee,
            roles.datasets().getDatasetMetadataSubmitter(_datasetId),
            _datasetId,
            msg.sender,
            EscrowType.PaymentEvent.SyncPaymentBeneficiary
        );
        // Allow payment
        roles.escrow().__emitPaymentUpdate(
            EscrowType.Type.DatasetAuditFee,
            roles.datasets().getDatasetMetadataSubmitter(_datasetId),
            _datasetId,
            msg.sender,
            EscrowType.PaymentEvent.SyncPaymentLock
        );

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
            uint32[] memory paths
        )
    {
        DatasetType.DatasetChallengeProof
            storage datasetChallengeProof = datasetChallengeProofs[_datasetId];
        return datasetChallengeProof.getDatasetChallengeProofs(_auditor);
    }

    ///@notice Get count of dataset chellange proofs.
    /// @param _datasetId The ID of the dataset for which proof is submitted.
    function getDatasetChallengeProofsCount(
        uint64 _datasetId
    ) public view onlyNotZero(_datasetId) returns (uint16) {
        DatasetType.DatasetChallengeProof
            storage datasetChallengeProof = datasetChallengeProofs[_datasetId];
        return datasetChallengeProof.getDatasetChallengeProofsCount();
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

    /// @notice To obtain the number of challenges to be completed
    /// @param _datasetId The ID of the dataset for which proof is submitted.
    function getChallengeSubmissionCount(
        uint64 _datasetId
    ) public view returns (uint64) {
        uint32 smallDataSet = 1000;
        uint64 carCount = roles.datasetsProof().getDatasetProofCount(
            _datasetId,
            DatasetType.DataType.Source
        );
        if (carCount < smallDataSet) {
            return 1;
        } else {
            return carCount / smallDataSet + 1;
        }
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
}
