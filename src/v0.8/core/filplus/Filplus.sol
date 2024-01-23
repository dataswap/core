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

import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {UUPSUpgradeable} from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

import {FinanceType} from "src/v0.8/types/FinanceType.sol";

/// @title Filplus
contract Filplus is Initializable, UUPSUpgradeable, IFilplus, RolesModifiers {
    using ArrayUint16LIB for uint16[];
    using ArrayUint32LIB for uint32[];
    IRoles private roles;
    // solhint-disable-next-line
    address public GOVERNANCE_ADDRESS; //The address of the governance contract.

    // Number of blocks per day.
    uint64 public constant PER_DAY_BLOCKNUMBER = 2880;
    uint64 public constant PER_TIB_BYTE = (1024 * 1024 * 1024 * 1024);
    address payable public constant BURN_ADDRESS =
        payable(0xff00000000000000000000000000000000000063); // Filecoin burn address.

    ///@notice dataset region rules
    uint16 public datasetRuleMinRegionsPerDataset; // Minimum required number of regions (e.g., 3).

    uint16 public datasetRuleDefaultMaxReplicasPerCountry; // Default maximum replicas allowed per country.

    mapping(uint16 => uint16) private datasetRuleMaxReplicasInCountries; // Maximum replicas allowed per country.

    uint16 public datasetRuleMaxReplicasPerCity; // Maximum replicas allowed per city (e.g., 1).

    uint8 public datasetRuleMaxProportionOfMappingFilesToDataset; //Maximum proportion of dataset mapping files,measured in ten-thousandths.(e.g.,40)

    ///@notice dataset sp rules
    uint16 public datasetRuleMinSPsPerDataset; // Minimum required number of storage providers (e.g., 5).

    uint16 public datasetRuleMaxReplicasPerSP; // Maximum replicas allowed per storage provider (e.g., 1).

    uint16 public datasetRuleMinTotalReplicasPerDataset; // Minimum required total replicas (e.g., 5).

    uint16 public datasetRuleMaxTotalReplicasPerDataset; // Maximum allowed total replicas (e.g., 10).

    ///@notice datacap rules
    uint64 public datacapRulesMaxAllocatedSizePerTime; // Maximum allocate datacap size per time.

    uint8 public datacapRulesMaxRemainingPercentageForNext; // Minimum completion percentage for the next allocation.

    uint64 public datacapCollateralExpireBlocks; // Datacap collateral expire blocks.

    uint64 public datasetApprovedExpireBlocks; // Dataset approved expire blocks.

    uint256 public datasetPricePreByte; // The dataset storage price pre byte.

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
        datasetRuleMinRegionsPerDataset = 3;
        datasetRuleDefaultMaxReplicasPerCountry = 1;
        datasetRuleMaxReplicasPerCity = 1;
        datasetRuleMaxProportionOfMappingFilesToDataset = 40; // 40/10000

        //defalut dataset sp rules
        datasetRuleMinSPsPerDataset = 5;
        datasetRuleMaxReplicasPerSP = 1;
        datasetRuleMinTotalReplicasPerDataset = 5;
        datasetRuleMaxTotalReplicasPerDataset = 10;

        //defalut datacap rules
        datacapRulesMaxAllocatedSizePerTime = 50 * 1024 * 1024 * 1024 * 1024; //50TB
        datacapRulesMaxRemainingPercentageForNext = 20; //20%

        //default datacap collateral expire blocks rule
        datacapCollateralExpireBlocks = PER_DAY_BLOCKNUMBER * 365; // 365 day

        datasetApprovedExpireBlocks = PER_DAY_BLOCKNUMBER * 180; // 180 day

        datasetPricePreByte = (1000000000000000000 / PER_TIB_BYTE); // 1/1T

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

    /// @notice Returns the burn address
    function getBurnAddress() external view returns (address) {
        return BURN_ADDRESS;
    }

    // Public getter function to access datasetRuleMaxReplicasInCountries
    function getDatasetRuleMaxReplicasInCountry(
        uint16 _countryCode
    ) public view returns (uint16) {
        if (datasetRuleMaxReplicasInCountries[_countryCode] == 0) {
            return datasetRuleDefaultMaxReplicasPerCountry;
        } else {
            return datasetRuleMaxReplicasInCountries[_countryCode];
        }
    }

    function setDatasetRuleMinRegionsPerDataset(
        uint16 _newValue
    ) external onlyAddress(GOVERNANCE_ADDRESS) {
        datasetRuleMinRegionsPerDataset = _newValue;
        emit FilplusEvents.SetDatasetRuleMinRegionsPerDataset(_newValue);
    }

    function setDatasetRuleDefaultMaxReplicasPerCountry(
        uint16 _newValue
    ) external onlyAddress(GOVERNANCE_ADDRESS) {
        datasetRuleDefaultMaxReplicasPerCountry = _newValue;
        emit FilplusEvents.SetDatasetRuleDefaultMaxReplicasPerCountry(
            _newValue
        );
    }

    function setDatasetRuleMaxReplicasInCountry(
        uint16 _countryCode,
        uint16 _newValue
    ) external onlyAddress(GOVERNANCE_ADDRESS) onlyNotZero(_newValue) {
        datasetRuleMaxReplicasInCountries[_countryCode] = _newValue;
        emit FilplusEvents.SetDatasetRuleMaxReplicasInCountry(
            _countryCode,
            _newValue
        );
    }

    function setDatasetRuleMaxReplicasPerCity(
        uint16 _newValue
    ) external onlyAddress(GOVERNANCE_ADDRESS) {
        datasetRuleMaxReplicasPerCity = _newValue;
        emit FilplusEvents.SetDatasetRuleMaxReplicasPerCity(_newValue);
    }

    /// @notice set maximum proportion of dataset mapping files
    function setDatasetRuleMaxProportionOfMappingFilesToDataset(
        uint8 _newValue
    ) external onlyAddress(GOVERNANCE_ADDRESS) {
        datasetRuleMaxProportionOfMappingFilesToDataset = _newValue;
        emit FilplusEvents.SetDatasetRuleMaxProportionOfMappingFilesToDataset(
            _newValue
        );
    }

    function setDatasetRuleMinSPsPerDataset(
        uint16 _newValue
    ) external onlyAddress(GOVERNANCE_ADDRESS) {
        datasetRuleMinSPsPerDataset = _newValue;
        emit FilplusEvents.SetDatasetRuleMinSPsPerDataset(_newValue);
    }

    function setDatasetRuleMaxReplicasPerSP(
        uint16 _newValue
    ) external onlyAddress(GOVERNANCE_ADDRESS) {
        datasetRuleMaxReplicasPerSP = _newValue;
        emit FilplusEvents.SetDatasetRuleMaxReplicasPerSP(_newValue);
    }

    function setDatasetRuleMinTotalReplicasPerDataset(
        uint16 _newValue
    ) external onlyAddress(GOVERNANCE_ADDRESS) {
        datasetRuleMinTotalReplicasPerDataset = _newValue;
        emit FilplusEvents.SetDatasetRuleMinTotalReplicasPerDataset(_newValue);
    }

    function setDatasetRuleMaxTotalReplicasPerDataset(
        uint16 _newValue
    ) external onlyAddress(GOVERNANCE_ADDRESS) {
        datasetRuleMaxTotalReplicasPerDataset = _newValue;
        emit FilplusEvents.SetDatasetRuleMaxTotalReplicasPerDataset(_newValue);
    }

    function setDatacapRulesMaxAllocatedSizePerTime(
        uint64 _newValue
    ) external onlyAddress(GOVERNANCE_ADDRESS) {
        datacapRulesMaxAllocatedSizePerTime = _newValue;
        emit FilplusEvents.SetDatacapRulesMaxAllocatedSizePerTime(_newValue);
    }

    function setDatacapRulesMaxRemainingPercentageForNext(
        uint8 _newValue
    ) external onlyAddress(GOVERNANCE_ADDRESS) {
        datacapRulesMaxRemainingPercentageForNext = _newValue;
        emit FilplusEvents.SetDatacapRulesMaxRemainingPercentageForNext(
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

    /// @notice Set the datacap collateral expire blocks number complies with filplus rules.
    function setDatacapCollateralExpireBlocks(
        uint64 _newValue
    ) external onlyAddress(GOVERNANCE_ADDRESS) {
        datacapCollateralExpireBlocks = _newValue;
        emit FilplusEvents.SetDatacapCollateralExpireBlocks(_newValue);
    }

    /// @notice Set the dataset approved expire blocks number complies with filplus rules.
    function setDatasetApprovedExpireBlocks(
        uint64 _newValue
    ) external onlyAddress(GOVERNANCE_ADDRESS) {
        datasetApprovedExpireBlocks = _newValue;
        emit FilplusEvents.SetDatasetApprovedExpireBlocks(_newValue);
    }

    /// @notice Set the dataset price pre byte complies with filplus rules.
    function setDatasetPricePreByte(
        uint256 _newValue
    ) external onlyAddress(GOVERNANCE_ADDRESS) {
        datasetPricePreByte = _newValue;
        emit FilplusEvents.SetDatasetPricePreByte(_newValue);
    }

    /// @notice Get the dataset price pre byte complies with filplus rules.
    function getDatasetPricePreByte() external view returns (uint256 price) {
        price = datasetPricePreByte;
    }

    /// @notice Check if the blocks number complies with filplus rules.
    function isCompliantDatasetApprovedExpireBlocks(
        uint64 _blocks
    ) external view returns (bool) {
        if (_blocks < datasetApprovedExpireBlocks) {
            return false;
        }
        return true;
    }

    /// @notice Check if the blocks number complies with filplus rules.
    function isCompliantDatacapCollateralExpireBlocks(
        uint64 _blocks
    ) external view returns (bool) {
        if (_blocks < datacapCollateralExpireBlocks) {
            return false;
        }
        return true;
    }

    /// @notice Check if the storage regions complies with filplus rules.
    function isCompliantRuleMinRegionsPerDataset(
        uint16[] memory _regions
    ) internal view returns (bool) {
        uint256 count = _regions.countUniqueElements();
        if (count < datasetRuleMinRegionsPerDataset) {
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
            if (_value > datasetRuleMaxReplicasPerCity) {
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
        if (proportion > datasetRuleMaxProportionOfMappingFilesToDataset) {
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
            _regions.length > datasetRuleMaxTotalReplicasPerDataset ||
            _regions.length < datasetRuleMinTotalReplicasPerDataset ||
            _regions.length < datasetRuleMinSPsPerDataset
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
        if (_uniqueExists >= datasetRuleMinSPsPerDataset) {
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
            datasetRuleMinSPsPerDataset
        ) {
            return true;
        }

        return false;
    }

    /// @notice Check if the storage provider for each dataset complies with filplus rules `datasetRuleMaxReplicasPerSP`.
    function isCompliantRuleMaxReplicasPerSP(
        uint16 _value
    ) external view returns (bool) {
        if (_value > datasetRuleMaxReplicasPerSP) {
            return false;
        }
        return true;
    }
}
