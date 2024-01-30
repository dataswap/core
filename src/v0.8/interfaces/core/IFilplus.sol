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

import {FinanceType} from "src/v0.8/types/FinanceType.sol";

/// @title IFilplus
interface IFilplus {
    // Public getter function to access datasetRuleMaxReplicasInCountries
    function getDatasetRuleMaxReplicasInCountry(
        uint16 _countryCode
    ) external view returns (uint16);

    // Set functions for public variables
    function setDatasetRuleMinRegionsPerDataset(uint16 _newValue) external;

    function setDatasetRuleDefaultMaxReplicasPerCountry(
        uint16 _newValue
    ) external;

    function setDatasetRuleMaxReplicasInCountry(
        uint16 _countryCode,
        uint16 _newValue
    ) external;

    function setDatasetRuleMaxReplicasPerCity(uint16 _newValue) external;

    // set maximum proportion of dataset mapping files
    function setDatasetRuleMaxProportionOfMappingFilesToDataset(
        uint8 _newValue
    ) external;

    function setDatasetRuleMinSPsPerDataset(uint16 _newValue) external;

    function setDatasetRuleMaxReplicasPerSP(uint16 _newValue) external;

    function setDatasetRuleMinTotalReplicasPerDataset(
        uint16 _newValue
    ) external;

    function setDatasetRuleMaxTotalReplicasPerDataset(
        uint16 _newValue
    ) external;

    function setDatacapRulesMaxAllocatedSizePerTime(uint64 _newValue) external;

    function setDatacapRulesMaxRemainingPercentageForNext(
        uint8 _newValue
    ) external;

    function setIncomeReleaseRule(
        FinanceType.Type _type,
        FinanceType.ReleaseType _releaseType,
        uint64 _delayBlocks,
        uint64 _durationBlocks
    ) external;

    function setEscrowReleaseRule(
        FinanceType.Type _type,
        FinanceType.ReleaseType _releaseType,
        uint64 _delayBlocks,
        uint64 _durationBlocks
    ) external;

    function getIncomeReleaseRule(
        FinanceType.Type _type
    )
        external
        view
        returns (
            FinanceType.ReleaseType releaseType,
            uint64 delayBlocks,
            uint64 durationBlocks
        );

    function getEscrowReleaseRule(
        FinanceType.Type _type
    )
        external
        view
        returns (
            FinanceType.ReleaseType releaseType,
            uint64 delayBlocks,
            uint64 durationBlocks
        );

    /// @notice Returns the burn address
    function getBurnAddress() external view returns (address);

    /// @notice Set the datacap price pre byte complies with filplus rules.
    function setDatacapPricePreByte(uint256 _newValue) external;

    /// @notice Set the datacap chunk land price pre byte complies with filplus rules.
    function setDatacapChunkLandPricePreByte(uint256 _newValue) external;

    /// @notice Set the challenge proofs submiter Count complies with filplus rules.
    function setChallengeProofsSubmiterCount(uint16 _newValue) external;

    /// @notice Set the challenge proofs price pre point complies with filplus rules.
    function setChallengeProofsPricePrePoint(uint256 _newValue) external;

    /// @notice Get the challenge proofs price pre point complies with filplus rules.
    function getChallengeProofsPricePrePoint()
        external
        view
        returns (uint256 price);

    /// @notice Get the challenge proofs submiter count complies with filplus rules.
    function getChallengeProofsSubmiterCount()
        external
        view
        returns (uint16 count);

    /// @notice Get the datacap chunk land price pre byte complies with filplus rules.
    function getDatacapChunkLandPricePreByte()
        external
        view
        returns (uint256 price);

    /// @notice Get the datacap price pre byte complies with filplus rules.
    function getDatacapPricePreByte() external view returns (uint256 price);

    // Default getter functions for public variables
    function datasetRuleMinRegionsPerDataset() external view returns (uint16);

    function datasetRuleDefaultMaxReplicasPerCountry()
        external
        view
        returns (uint16);

    function datasetRuleMaxReplicasPerCity() external view returns (uint16);

    function datasetRuleMaxProportionOfMappingFilesToDataset()
        external
        view
        returns (uint8);

    function datasetRuleMinSPsPerDataset() external view returns (uint16);

    function datasetRuleMaxReplicasPerSP() external view returns (uint16);

    function datasetRuleMinTotalReplicasPerDataset()
        external
        view
        returns (uint16);

    function datasetRuleMaxTotalReplicasPerDataset()
        external
        view
        returns (uint16);

    function datacapRulesMaxAllocatedSizePerTime()
        external
        view
        returns (uint64);

    function datacapRulesMaxRemainingPercentageForNext()
        external
        view
        returns (uint8);

    /// @notice Check if the storage area complies with filplus rules.
    function isCompliantRuleGeolocation(
        uint16[] memory _regions,
        uint16[] memory _countrys,
        uint32[][] memory _citys
    ) external view returns (bool);

    /// @notice Check if the mappingFiles percentage in the dataset complies with filplus rules.
    function isCompliantRuleMaxProportionOfMappingFilesToDataset(
        uint64 _mappingFilesSize,
        uint64 _sourceSize
    ) external view returns (bool);

    /// @notice Check if the total number of storage replicas complies with filplus rules.
    function isCompliantRuleTotalReplicasPerDataset(
        address[][] memory _dataPreparers,
        address[][] memory _storageProviders,
        uint16[] memory _regions,
        uint16[] memory _countrys,
        uint32[][] memory _citys
    ) external view returns (bool);

    /// @notice Check if the storage provider for each dataset complies with filplus rules `datasetRuleMinSPsPerDataset`.
    function isCompliantRuleMinSPsPerDataset(
        uint16 _requirementValue,
        uint16 _totalExists,
        uint16 _uniqueExists
    ) external view returns (bool);

    /// @notice Check if the storage provider for each dataset complies with filplus rules `datasetRuleMaxReplicasPerSP`.
    function isCompliantRuleMaxReplicasPerSP(
        uint16 _value
    ) external view returns (bool);
}
