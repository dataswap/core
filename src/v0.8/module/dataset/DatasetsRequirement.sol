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
import {IDatasetsRequirement} from "src/v0.8/interfaces/module/IDatasetsRequirement.sol";
///shared
import {DatasetsEvents} from "src/v0.8/shared/events/DatasetsEvents.sol";
import {DatasetsModifiers} from "src/v0.8/shared/modifiers/DatasetsModifiers.sol";
/// library
import {DatasetReplicaRequirementLIB} from "src/v0.8/module/dataset/library/requirement/DatasetReplicaRequirementLIB.sol";

/// type
import {RolesType} from "src/v0.8/types/RolesType.sol";
import {DatasetType} from "src/v0.8/types/DatasetType.sol";
import {FinanceType} from "src/v0.8/types/FinanceType.sol";
import {GeolocationType} from "src/v0.8/types/GeolocationType.sol";

import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {UUPSUpgradeable} from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

/// @title DatasetsRequirement Contract
/// @notice This contract serves as the base for managing datasetsReplicasRequirmentd.
/// @dev This contract is intended to be inherited by specific dataset-related contracts.
contract DatasetsRequirement is
    Initializable,
    UUPSUpgradeable,
    IDatasetsRequirement,
    DatasetsModifiers
{
    using DatasetReplicaRequirementLIB for DatasetType.DatasetReplicasRequirement;

    mapping(uint64 => DatasetType.DatasetReplicasRequirement)
        private datasetReplicasRequirements; // Mapping of dataset ID to dataset details

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

    ///@notice Submit replica requirement for a dataset
    ///        Note: submmiter of dataset can submit dataset replica requirement
    /// @param _datasetId The ID of the dataset for which proof is submitted.
    /// @param _dataPreparers The client specified data preparer, which the client can either specify or not, but the parameter cannot be empty.
    /// @param _storageProviders The client specified storage provider, which the client can either specify or not, but the parameter cannot be empty.
    /// @param _regions The region specified by the client, and the client must specify a region for the replicas.
    /// @param _countrys The country specified by the client, and the client must specify a country for the replicas.
    /// @param _citys The citys specified by the client, when the country of a replica is duplicated, citys must be specified and cannot be empty.
    function submitDatasetReplicaRequirements(
        uint64 _datasetId,
        address[][] memory _dataPreparers,
        address[][] memory _storageProviders,
        uint16[] memory _regions,
        uint16[] memory _countrys,
        uint32[][] memory _citys,
        uint256 /*_amount*/
    )
        external
        payable
        onlyDatasetState(
            roles.datasets(),
            _datasetId,
            DatasetType.State.MetadataSubmitted
        )
        onlyAddress(roles.datasets().getDatasetMetadataSubmitter(_datasetId))
    {
        require(
            roles.filplus().isCompliantRuleTotalReplicasPerDataset(
                _dataPreparers,
                _storageProviders,
                _regions,
                _countrys,
                _citys
            ),
            "Invalid replicas count"
        );

        require(
            roles.filplus().isCompliantRuleGeolocation(
                _regions,
                _countrys,
                _citys
            ),
            "Invalid region distribution"
        );

        DatasetType.DatasetReplicasRequirement
            storage datasetReplicasRequirement = datasetReplicasRequirements[
                _datasetId
            ];

        require(
            roles.datasets().__requireValidDatasetMetadata(_datasetId),
            "Invalid Metadata"
        );

        datasetReplicasRequirement.submitDatasetRequirements(
            _dataPreparers,
            _storageProviders,
            _regions,
            _countrys,
            _citys
        );

        _processEscrow(_datasetId);

        roles.datasets().__reportDatasetReplicaRequirementSubmitted(_datasetId);
        emit DatasetsEvents.DatasetReplicaRequirementSubmitted(
            _datasetId,
            msg.sender
        );
    }

    ///@notice Get dataset replicas count
    function getDatasetReplicasCount(
        uint64 _datasetId
    ) public view onlyNotZero(_datasetId) returns (uint16) {
        DatasetType.DatasetReplicasRequirement
            storage datasetReplicasRequirement = datasetReplicasRequirements[
                _datasetId
            ];
        return datasetReplicasRequirement.getDatasetReplicasCount();
    }

    ///@notice Get dataset replica requirement
    function getDatasetReplicaRequirement(
        uint64 _datasetId,
        uint64 _index
    )
        public
        view
        onlyNotZero(_datasetId)
        returns (
            address[] memory dataPreparers,
            address[] memory storageProviders,
            uint16 regionCode,
            uint16 countryCode,
            uint32[] memory cityCodes
        )
    {
        DatasetType.DatasetReplicasRequirement
            storage datasetReplicasRequirement = datasetReplicasRequirements[
                _datasetId
            ];
        return datasetReplicasRequirement.getDatasetReplicaRequirement(_index);
    }

    ///@notice Process escrow
    /// 1. Add EscrowDatacapCollateral escrow
    /// 2. Add EscrowDataTradingFee escrow
    function _processEscrow(
        uint64 _datasetId
    ) internal onlyNotZero(_datasetId) {
        // roles.finance().escrow(/// TODO: https://github.com/dataswap/core/issues/245
        //     _datasetId,
        //     0,
        //     FinanceType.FIL,
        //     FinanceType.Type.EscrowDatacapCollateral
        // );
        // roles.finance().escrow(
        //     _datasetId,
        //     0,
        //     FinanceType.FIL,
        //     FinanceType.Type.EscrowDataTradingFee
        // );
    }
}
