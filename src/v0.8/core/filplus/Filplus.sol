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

///interface
import {IRoles} from "src/v0.8/interfaces/core/IRoles.sol";
import {IFilplus} from "src/v0.8/interfaces/core/IFilplus.sol";
///shared
import {FilplusEvents} from "src/v0.8/shared/events/FilplusEvents.sol";
import "src/v0.8/shared/utils/array/ArrayLIB.sol";
///type
import {RolesType} from "src/v0.8/types/RolesType.sol";
import {RolesModifiers} from "src/v0.8/shared/modifiers/RolesModifiers.sol";
import {FilplusType} from "src/v0.8/types/FilplusType.sol";

import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {UUPSUpgradeable} from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

import {FinanceType} from "src/v0.8/types/FinanceType.sol";

/// @title Filplus
contract Filplus is Initializable, UUPSUpgradeable, IFilplus, RolesModifiers {
    using ArrayUint16LIB for uint16[];
    using ArrayUint32LIB for uint32[];
    IRoles public roles;
    // solhint-disable-next-line
    address public GOVERNANCE_ADDRESS; //The address of the governance contract.

    // Number of blocks per day.
    uint64 public constant PER_DAY_BLOCKNUMBER = 2880;
    uint64 public constant PER_TIB_BYTE = (1024 * 1024 * 1024 * 1024);
    address payable public constant BURN_ADDRESS =
        payable(0xff00000000000000000000000000000000000063); // Filecoin burn address.

    FilplusType.Rules private rules;

    /// @dev This empty reserved space is put in place to allow future versions to add new
    uint256[32] private __gap;

    /// @notice initialize function to initialize the contract and grant the default admin role to the deployer.
    // solhint-disable-next-line
    function initialize(
        address payable _governanceAddress,
        address _roles
    ) public initializer {
        roles = IRoles(_roles);
        GOVERNANCE_ADDRESS = _governanceAddress;

        //defalut dataset region rules
        rules.datasetRuleMinRegionsPerDataset = 3;
        rules.datasetRuleDefaultMaxReplicasPerCountry = 1;
        rules.datasetRuleMaxReplicasPerCity = 1;
        rules.datasetRuleMaxProportionOfMappingFilesToDataset = 40; // 40/10000

        //defalut dataset sp rules
        rules.datasetRuleMinSPsPerDataset = 5;
        rules.datasetRuleMaxReplicasPerSP = 1;
        rules.datasetRuleMinTotalReplicasPerDataset = 5;
        rules.datasetRuleMaxTotalReplicasPerDataset = 10;

        // default dataset runtime rules
        rules.datasetRuleMinProofTimeout = 2880 * 60;
        rules.datasetRuleMinAuditTimeout = 2880 * 10;
        rules.datasetRuleRequirementTimeout = 2880 * 2;

        //defalut datacap rules
        rules.datacapRuleMaxAllocatedSizePerTime =
            50 *
            1024 *
            1024 *
            1024 *
            1024; //50TB
        rules.datacapRuleMaxRemainingPercentageForNext = 20; //20%
        rules.financeRuleDatacapChunkLandPricePreByte = (1000000000000000000 /
            PER_TIB_BYTE); // 1/1T
        rules.financeRuleChallengeProofsPricePrePoint = (1000000000000000000 /
            1000); // 0.0001/POINT
        rules.datasetRuleChallengePointsPerAuditor = 5;
        rules.financeRuleDatacapPricePreByte = rules
            .financeRuleDatacapChunkLandPricePreByte; // 1/1T
        rules.financeRuleDatacapCollateralMaxLockDays =
            365 *
            PER_DAY_BLOCKNUMBER; // 1 year
        rules.financeRuleDatacapDatasetApprovedLockDays =
            180 *
            PER_DAY_BLOCKNUMBER; // 180 days
        rules.finaceRuleDatasetProofCollateral = 1000000000000000000;
        rules.finaceRuleDatasetChallengeProofCollateral = rules
            .finaceRuleDatasetProofCollateral;
        rules.financeRuleDisputeAuditCollateral = rules
            .finaceRuleDatasetProofCollateral;
        rules.datasetRuleAuditorsElectionTime = 2880;

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

    /// @notice Set the minimum proof submission timeout for the dataset rule.
    function setDatasetRuleMinProofTimeout(uint64 _blocks) external {
        rules.datasetRuleMinProofTimeout = _blocks;
        emit FilplusEvents.SetDatasetRuleMinProofTimeout(_blocks);
    }

    /// @notice Set the minimum audit timeout for the dataset rule.
    function setDatasetRuleMinAuditTimeout(uint64 _blocks) external {
        rules.datasetRuleMinAuditTimeout = _blocks;
        emit FilplusEvents.SetDatasetRuleMinAuditTimeout(_blocks);
    }

    /// @notice Set the requirement timout for the dataset rule.
    function setDatasetRuleRequirementTimeout(uint64 _blocks) external {
        rules.datasetRuleRequirementTimeout = _blocks;
        emit FilplusEvents.SetDatasetRuleRequirementTimeout(_blocks);
    }

    function setDatasetRuleMinRegionsPerDataset(
        uint16 _newValue
    ) external onlyAddress(GOVERNANCE_ADDRESS) {
        rules.datasetRuleMinRegionsPerDataset = _newValue;
        emit FilplusEvents.SetDatasetRuleMinRegionsPerDataset(_newValue);
    }

    function setDatasetRuleDefaultMaxReplicasPerCountry(
        uint16 _newValue
    ) external onlyAddress(GOVERNANCE_ADDRESS) {
        rules.datasetRuleDefaultMaxReplicasPerCountry = _newValue;
        emit FilplusEvents.SetDatasetRuleDefaultMaxReplicasPerCountry(
            _newValue
        );
    }

    function setDatasetRuleMaxReplicasInCountry(
        uint16 _countryCode,
        uint16 _newValue
    ) external onlyAddress(GOVERNANCE_ADDRESS) onlyNotZero(_newValue) {
        rules.datasetRuleMaxReplicasInCountries[_countryCode] = _newValue;
        emit FilplusEvents.SetDatasetRuleMaxReplicasInCountry(
            _countryCode,
            _newValue
        );
    }

    function setDatasetRuleMaxReplicasPerCity(
        uint16 _newValue
    ) external onlyAddress(GOVERNANCE_ADDRESS) {
        rules.datasetRuleMaxReplicasPerCity = _newValue;
        emit FilplusEvents.SetDatasetRuleMaxReplicasPerCity(_newValue);
    }

    /// @notice set maximum proportion of dataset mapping files
    function setDatasetRuleMaxProportionOfMappingFilesToDataset(
        uint8 _newValue
    ) external onlyAddress(GOVERNANCE_ADDRESS) {
        rules.datasetRuleMaxProportionOfMappingFilesToDataset = _newValue;
        emit FilplusEvents.SetDatasetRuleMaxProportionOfMappingFilesToDataset(
            _newValue
        );
    }

    function setDatasetRuleMinSPsPerDataset(
        uint16 _newValue
    ) external onlyAddress(GOVERNANCE_ADDRESS) {
        rules.datasetRuleMinSPsPerDataset = _newValue;
        emit FilplusEvents.SetDatasetRuleMinSPsPerDataset(_newValue);
    }

    function setDatasetRuleMaxReplicasPerSP(
        uint16 _newValue
    ) external onlyAddress(GOVERNANCE_ADDRESS) {
        rules.datasetRuleMaxReplicasPerSP = _newValue;
        emit FilplusEvents.SetDatasetRuleMaxReplicasPerSP(_newValue);
    }

    function setDatasetRuleMinTotalReplicasPerDataset(
        uint16 _newValue
    ) external onlyAddress(GOVERNANCE_ADDRESS) {
        rules.datasetRuleMinTotalReplicasPerDataset = _newValue;
        emit FilplusEvents.SetDatasetRuleMinTotalReplicasPerDataset(_newValue);
    }

    function setDatasetRuleMaxTotalReplicasPerDataset(
        uint16 _newValue
    ) external onlyAddress(GOVERNANCE_ADDRESS) {
        rules.datasetRuleMaxTotalReplicasPerDataset = _newValue;
        emit FilplusEvents.SetDatasetRuleMaxTotalReplicasPerDataset(_newValue);
    }

    function setDatacapRuleMaxAllocatedSizePerTime(
        uint64 _newValue
    ) external onlyAddress(GOVERNANCE_ADDRESS) {
        rules.datacapRuleMaxAllocatedSizePerTime = _newValue;
        emit FilplusEvents.SetDatacapRuleMaxAllocatedSizePerTime(_newValue);
    }

    function setDatacapRuleMaxRemainingPercentageForNext(
        uint8 _newValue
    ) external onlyAddress(GOVERNANCE_ADDRESS) {
        rules.datacapRuleMaxRemainingPercentageForNext = _newValue;
        emit FilplusEvents.SetDatacapRuleMaxRemainingPercentageForNext(
            _newValue
        );
    }

    ///TODO:impl
    function setIncomeReleaseRule(
        FinanceType.Type _type,
        FinanceType.ReleaseType _releaseType,
        uint64 _delayBlocks,
        uint64 _durationBlocks // solhint-disable-next-line
    ) external {}

    ///TODO:impl
    function setEscrowReleaseRule(
        FinanceType.Type _type,
        FinanceType.ReleaseType _releaseType,
        uint64 _delayBlocks,
        uint64 _durationBlocks // solhint-disable-next-line
    ) external {}

    /// @notice Set the datacap price pre byte complies with filplus rules.
    function setFinanceRuleDatacapPricePreByte(
        uint256 _newValue
    ) external onlyAddress(GOVERNANCE_ADDRESS) {
        rules.financeRuleDatacapPricePreByte = _newValue;
        emit FilplusEvents.SetFinanceRuleDatacapPricePreByte(_newValue);
    }

    /// @notice Set the datacap chunk land price pre byte complies with filplus rules.
    function setFinanceRuleDatacapChunkLandPricePreByte(
        uint256 _newValue
    ) external onlyAddress(GOVERNANCE_ADDRESS) {
        rules.financeRuleDatacapChunkLandPricePreByte = _newValue;
        emit FilplusEvents.SetFinanceRuleDatacapChunkLandPricePreByte(
            _newValue
        );
    }

    /// @notice Set the challenge points per auditor with filplus rules.
    function setDatasetRuleChallengePointsPerAuditor(
        uint64 _newValue
    ) external onlyAddress(GOVERNANCE_ADDRESS) {
        require(_newValue > 1, "invalid value");
        rules.datasetRuleChallengePointsPerAuditor = _newValue;
        emit FilplusEvents.SetDatasetRuleChallengePointsPerAuditor(_newValue);
    }
    /// @notice Set the challenge proofs price pre point complies with filplus rules.
    function setFinanceRuleChallengeProofsPricePrePoint(
        uint256 _newValue
    ) external onlyAddress(GOVERNANCE_ADDRESS) {
        rules.financeRuleChallengeProofsPricePrePoint = _newValue;
        emit FilplusEvents.SetFinanceRuleChallengeProofsPricePrePoint(
            _newValue
        );
    }

    /// @notice Set the datacap collateral lock days when dataset approved complies with filplus rules.
    function setFinanceRuleDatacapDatasetApprovedLockDays(
        uint64 _newValue
    ) external onlyAddress(GOVERNANCE_ADDRESS) {
        rules.financeRuleDatacapDatasetApprovedLockDays = _newValue;
        emit FilplusEvents.SetFinanceRuleDatacapDatasetApprovedLockDays(
            _newValue
        );
    }

    /// @notice Set the challenge audit fee complies with filplus rules.
    function setFinaceRuleDatasetChallengeProofCollateral(
        uint256 _newValue
    ) external onlyAddress(GOVERNANCE_ADDRESS) {
        rules.finaceRuleDatasetChallengeProofCollateral = _newValue;
        emit FilplusEvents.SetFinaceRuleDatasetChallengeProofCollateral(
            _newValue
        );
    }

    /// @notice Set the proof audit fee complies with filplus rules.
    function setFinaceRuleDatasetProofCollateral(
        uint256 _newValue
    ) external onlyAddress(GOVERNANCE_ADDRESS) {
        rules.finaceRuleDatasetProofCollateral = _newValue;
        emit FilplusEvents.SetFinaceRuleDatasetProofCollateral(_newValue);
    }

    /// @notice Set the dispute audit fee complies with filplus rules.
    function setFinanceRuleDisputeAuditCollateral(
        uint256 _newValue
    ) external onlyAddress(GOVERNANCE_ADDRESS) {
        rules.financeRuleDisputeAuditCollateral = _newValue;
        emit FilplusEvents.SetFinanceRuleDisputeAuditCollateral(_newValue);
    }

    /// @notice Set the datacap collateral lock max days complies with filplus rules.
    function setFinanceRuleDatacapCollateralMaxLockDays(
        uint64 _newValue
    ) external onlyAddress(GOVERNANCE_ADDRESS) {
        rules.financeRuleDatacapCollateralMaxLockDays = _newValue;
        emit FilplusEvents.SetFinanceRuleDatacapCollateralMaxLockDays(
            _newValue
        );
    }

    ///@notice Sets the election time for auditors.
    ///@param _blocks The number of blocks to set as the election time.
    function setDatasetRuleAuditorsElectionTime(
        uint64 _blocks
    ) external onlyAddress(GOVERNANCE_ADDRESS) {
        rules.datasetRuleAuditorsElectionTime = _blocks;
        emit FilplusEvents.SetAuditorsElectionTime(_blocks);
    }

    // Public getter function to access datasetRuleMaxReplicasInCountries
    function getDatasetRuleMaxReplicasInCountry(
        uint16 _countryCode
    ) public view returns (uint16) {
        if (rules.datasetRuleMaxReplicasInCountries[_countryCode] == 0) {
            return rules.datasetRuleDefaultMaxReplicasPerCountry;
        } else {
            return rules.datasetRuleMaxReplicasInCountries[_countryCode];
        }
    }

    ///TODO:impl
    function getIncomeReleaseRule(
        FinanceType.Type _type
    )
        external
        view
        returns (
            FinanceType.ReleaseType releaseType,
            uint64 delayBlocks,
            uint64 durationBlocks
        )
    // solhint-disable-next-line
    {

    }

    ///TODO:impl
    function getEscrowReleaseRule(
        FinanceType.Type _type
    )
        external
        view
        returns (
            FinanceType.ReleaseType releaseType,
            uint64 delayBlocks,
            uint64 durationBlocks
        )
    // solhint-disable-next-line
    {

    }
    /// @notice Returns the burn address
    function getBurnAddress() external pure returns (address) {
        return BURN_ADDRESS;
    }

    /// @notice Returns the block number per day
    function getPerDayBlocknumber() external pure returns (uint64) {
        return PER_DAY_BLOCKNUMBER;
    }

    /// @notice Returns the datacap collateral days when dataset approved
    function financeRuleDatacapDatasetApprovedLockDays()
        external
        view
        returns (uint64)
    {
        return rules.financeRuleDatacapDatasetApprovedLockDays;
    }

    /// @notice Returns the datacap collateral max lock days
    function financeRuleDatacapCollateralMaxLockDays()
        external
        view
        returns (uint64)
    {
        return rules.financeRuleDatacapCollateralMaxLockDays;
    }

    /// @notice Returns the proof audit fee
    function finaceRuleDatasetProofCollateral()
        external
        view
        returns (uint256)
    {
        return rules.finaceRuleDatasetProofCollateral;
    }

    /// @notice Returns the dispute audit fee
    function financeRuleDisputeAuditCollateral()
        external
        view
        returns (uint256)
    {
        return rules.financeRuleDisputeAuditCollateral;
    }

    /// @notice Returns the challenge audit fee
    function finaceRuleDatasetChallengeProofCollateral()
        external
        view
        returns (uint256)
    {
        return rules.finaceRuleDatasetChallengeProofCollateral;
    }

    /// @notice Get the challenge proofs price pre point complies with filplus rules.
    function financeRuleChallengeProofsPricePrePoint()
        external
        view
        returns (uint256 price)
    {
        price = rules.financeRuleChallengeProofsPricePrePoint;
    }

    /// @dev Returns the number of challenge points per auditor for dataset rules.
    /// @return count The number of challenge points per auditor.
    function datasetRuleChallengePointsPerAuditor()
        external
        view
        returns (uint64 count)
    {
        count = rules.datasetRuleChallengePointsPerAuditor;
    }

    /// @notice Get the datacap price pre byte complies with filplus rules.
    function financeRuleDatacapPricePreByte()
        external
        view
        returns (uint256 price)
    {
        price = rules.financeRuleDatacapPricePreByte;
    }

    /// @notice Get the datacap chunk land price pre byte complies with filplus rules.
    function financeRuleDatacapChunkLandPricePreByte()
        external
        view
        returns (uint256 price)
    {
        price = rules.financeRuleDatacapChunkLandPricePreByte;
    }

    /// @notice The default minimum dataset proof submission timeout
    function datasetRuleMinProofTimeout() external view returns (uint64) {
        return rules.datasetRuleMinProofTimeout;
    }

    /// @notice The default minimum dataset challenge submission timeout
    function datasetRuleMinAuditTimeout() external view returns (uint64) {
        return rules.datasetRuleMinAuditTimeout;
    }

    /// @notice Returns the requirement timeout for the dataset rule.
    function datasetRuleRequirementTimeout() external view returns (uint64) {
        return rules.datasetRuleRequirementTimeout;
    }

    // Default getter functions for public variables
    function datasetRuleMinRegionsPerDataset() external view returns (uint16) {
        return rules.datasetRuleMinRegionsPerDataset;
    }

    /// @notice Returns the default maximum number of replicas per country.
    function datasetRuleDefaultMaxReplicasPerCountry()
        external
        view
        returns (uint16)
    {
        return rules.datasetRuleDefaultMaxReplicasPerCountry;
    }

    /// @notice Returns the maximum number of replicas per city.
    function datasetRuleMaxReplicasPerCity() external view returns (uint16) {
        return rules.datasetRuleMaxReplicasPerCity;
    }

    /// @notice Returns the maximum proportion of mapping files allowed per dataset.
    function datasetRuleMaxProportionOfMappingFilesToDataset()
        external
        view
        returns (uint8)
    {
        return rules.datasetRuleMaxProportionOfMappingFilesToDataset;
    }

    /// @notice Returns the minimum number of storage providers required per dataset.
    function datasetRuleMinSPsPerDataset() external view returns (uint16) {
        return rules.datasetRuleMinSPsPerDataset;
    }

    /// @notice Returns the maximum number of replicas per storage provider.
    function datasetRuleMaxReplicasPerSP() external view returns (uint16) {
        return rules.datasetRuleMaxReplicasPerSP;
    }

    /// @notice Returns the minimum total number of replicas required per dataset.
    function datasetRuleMinTotalReplicasPerDataset()
        external
        view
        returns (uint16)
    {
        return rules.datasetRuleMinTotalReplicasPerDataset;
    }

    /// @notice Returns the maximum total number of replicas allowed per dataset.
    function datasetRuleMaxTotalReplicasPerDataset()
        external
        view
        returns (uint16)
    {
        return rules.datasetRuleMaxTotalReplicasPerDataset;
    }

    /// @notice Returns the maximum size that can be allocated per time for datacap rules.
    function datacapRuleMaxAllocatedSizePerTime()
        external
        view
        returns (uint64)
    {
        return rules.datacapRuleMaxAllocatedSizePerTime;
    }

    /// @notice Returns the maximum remaining percentage allowed for the next datacap rule.
    function datacapRuleMaxRemainingPercentageForNext()
        external
        view
        returns (uint8)
    {
        return rules.datacapRuleMaxRemainingPercentageForNext;
    }

    ///@notice Returns the election time for auditors.
    function datasetRuleAuditorsElectionTime() external view returns (uint64) {
        return rules.datasetRuleAuditorsElectionTime;
    }

    /// @notice Check if the storage regions complies with filplus rules.
    function isCompliantRuleMinRegionsPerDataset(
        uint16[] memory _regions
    ) internal view returns (bool) {
        uint256 count = _regions.countUniqueElements();
        if (count < rules.datasetRuleMinRegionsPerDataset) {
            return false;
        }
        return true;
    }

    /// @notice Check if the distribution of storage replica countries complies with filplus rules.
    function isCompliantRuleMaxReplicasPerCountry(
        uint16[] memory _countrys,
        uint32[][] memory _citys
    ) internal view returns (bool) {
        (uint256 uniqueCountryCount, uint16[] memory uniqueCountrys) = _countrys
            .uniqueElements();

        for (uint256 i = 0; i < uniqueCountryCount; i++) {
            uint256 _value = _countrys.countOccurrences(uniqueCountrys[i]);
            if (_value > 1) {
                for (uint32 j = 0; j < _countrys.length; j++) {
                    if (uniqueCountrys[i] == _countrys[j]) {
                        require(_citys[j].length > 0, "City is required");
                    }
                }
            }
            if (
                _value > getDatasetRuleMaxReplicasInCountry(uniqueCountrys[i])
            ) {
                return false;
            }
        }

        return true;
    }

    /// @notice Check if the distribution of storage replica cities complies with filplus rules
    function isCompliantRuleMaxReplicasPerCity(
        uint32[][] memory _citys
    ) internal view returns (bool) {
        uint256 cityCount = 0;
        for (uint256 i = 0; i < _citys.length; i++) {
            require(!_citys[i].hasDuplicates(), "Invalid duplicate city");
            cityCount += _citys[i].length;
        }
        uint32[] memory totalCitys = new uint32[](cityCount);
        uint256 cnt = 0;

        for (uint256 i = 0; i < _citys.length; i++) {
            for (uint256 j = 0; j < _citys[i].length; j++) {
                totalCitys[cnt] = _citys[i][j];
                cnt++;
            }
        }

        (uint256 count, uint32[] memory uniqueCitys) = totalCitys
            .uniqueElements();

        for (uint256 i = 0; i < count; i++) {
            uint256 _value = totalCitys.countOccurrences(uniqueCitys[i]);
            if (_value > rules.datasetRuleMaxReplicasPerCity) {
                return false;
            }
        }
        return true;
    }

    /// @notice Check if the storage geolocation complies with filplus rules.
    function isCompliantRuleGeolocation(
        uint16[] memory _regions,
        uint16[] memory _countrys,
        uint32[][] memory _citys
    ) external view returns (bool) {
        if (!isCompliantRuleMinRegionsPerDataset(_regions)) {
            return false;
        }

        if (!isCompliantRuleMaxReplicasPerCountry(_countrys, _citys)) {
            return false;
        }

        if (!isCompliantRuleMaxReplicasPerCity(_citys)) {
            return false;
        }

        return true;
    }

    /// @notice Check if the mappingFiles percentage in the dataset complies with filplus rules.
    function isCompliantRuleMaxProportionOfMappingFilesToDataset(
        uint64 _mappingFilesSize,
        uint64 _sourceSize
    ) external view returns (bool) {
        uint64 proportion = (_mappingFilesSize * 10000) / _sourceSize;
        if (
            proportion > rules.datasetRuleMaxProportionOfMappingFilesToDataset
        ) {
            return false;
        }
        return true;
    }

    /// @notice Check if the total number of storage replicas complies with filplus rules.
    function isCompliantRuleTotalReplicasPerDataset(
        address[][] memory _dataPreparers,
        address[][] memory _storageProviders,
        uint16[] memory _regions,
        uint16[] memory _countrys,
        uint32[][] memory _citys
    ) external view returns (bool) {
        if (
            _regions.length != _dataPreparers.length ||
            _regions.length != _storageProviders.length ||
            _regions.length != _countrys.length ||
            _regions.length != _citys.length
        ) {
            return false;
        }

        if (
            _regions.length > rules.datasetRuleMaxTotalReplicasPerDataset ||
            _regions.length < rules.datasetRuleMinTotalReplicasPerDataset ||
            _regions.length < rules.datasetRuleMinSPsPerDataset
        ) {
            return false;
        }

        return true;
    }

    /// @notice Check if the storage provider for each dataset complies with filplus rules `datasetRuleMinSPsPerDataset`.
    function isCompliantRuleMinSPsPerDataset(
        uint16 _requirementValue,
        uint16 _totalExists,
        uint16 _uniqueExists
    ) external view returns (bool) {
        if (_uniqueExists >= rules.datasetRuleMinSPsPerDataset) {
            return true;
        }

        if (
            _uniqueExists >= _requirementValue ||
            _totalExists >= _requirementValue
        ) {
            return false;
        }

        if (
            (_requirementValue - _totalExists + _uniqueExists) >=
            rules.datasetRuleMinSPsPerDataset
        ) {
            return true;
        }

        return false;
    }

    /// @notice Check if the storage provider for each dataset complies with filplus rules `datasetRuleMaxReplicasPerSP`.
    function isCompliantRuleMaxReplicasPerSP(
        uint16 _value
    ) external view returns (bool) {
        if (_value > rules.datasetRuleMaxReplicasPerSP) {
            return false;
        }
        return true;
    }
}
