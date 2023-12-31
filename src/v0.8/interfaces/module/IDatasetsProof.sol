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

import {DatasetType} from "src/v0.8/types/DatasetType.sol";
import {IRoles} from "src/v0.8/interfaces/core/IRoles.sol";
import {IMerkleUtils} from "src/v0.8/interfaces/utils/IMerkleUtils.sol";
import {IDatasets} from "src/v0.8/interfaces/module/IDatasets.sol";
import {IDatasetsChallenge} from "src/v0.8/interfaces/module/IDatasetsChallenge.sol";
import {IDatasetsRequirement} from "src/v0.8/interfaces/module/IDatasetsRequirement.sol";

/// @title IDatasetsProof
interface IDatasetsProof {
    ///@notice Submit proof root for a dataset
    function submitDatasetProofRoot(
        uint64 _datasetId,
        DatasetType.DataType _dataType,
        string calldata _mappingFilesAccessMethod,
        bytes32 _rootHash
    ) external;

    ///@notice Submit proof for a dataset
    function submitDatasetProof(
        uint64 _datasetId,
        DatasetType.DataType _dataType,
        bytes32[] memory _leafHashes,
        uint64 _leafIndex,
        uint64[] memory _leafSizes,
        bool _completed
    ) external;

    ///@notice Submit proof completed for a dataset
    function submitDatasetProofCompleted(uint64 _datasetId) external;

    /// @notice Append dataset escrow funds. include datacap collateral and dataset auditor calculate fees.
    function appendDatasetFunds(
        uint64 _datasetId,
        uint256 _datacapCollateral,
        uint256 _dataAuditorFees
    ) external payable;

    /// @notice Get dataset need append collateral funds
    function getDatasetAppendCollateral(
        uint64 _datasetId
    ) external view returns (uint256);

    /// @notice Get the dataset requires funding for dataset auditor fees
    function getDatasetDataAuditorFeesRequirement(
        uint64 _datasetId
    ) external view returns (uint256);

    /// @notice Get an audit fee
    function getDatasetDataAuditorFees(
        uint64 _datasetId
    ) external view returns (uint256);

    ///@notice Get dataset source CIDs
    function getDatasetProof(
        uint64 _datasetId,
        DatasetType.DataType _dataType,
        uint64 _index,
        uint64 _len
    ) external view returns (bytes32[] memory);

    ///@notice Get dataset proof count
    function getDatasetProofCount(
        uint64 _datasetId,
        DatasetType.DataType _dataType
    ) external view returns (uint64);

    ///@notice Get dataset proof's submitter
    function getDatasetProofSubmitter(
        uint64 _datasetId
    ) external view returns (address);

    ///@notice Get dataset size
    function getDatasetSize(
        uint64 _datasetId,
        DatasetType.DataType _dataType
    ) external view returns (uint64);

    ///@notice Get dataset minimum conditional
    function getDatasetCollateralRequirement(
        uint64 _datasetId
    ) external view returns (uint256);

    ///@notice Check if a dataset has a car id
    function isDatasetContainsCar(
        uint64 _datasetId,
        uint64 _id
    ) external returns (bool);

    ///@notice Check if a dataset has car ids
    function isDatasetContainsCars(
        uint64 _datasetId,
        uint64[] memory _ids
    ) external view returns (bool);

    ///@notice Check if a dataset has submitter
    function isDatasetProofSubmitter(
        uint64 _datasetId,
        address _submitter
    ) external view returns (bool);

    ///@notice Check if a dataset proof all completed
    function isDatasetProofallCompleted(
        uint64 _datasetId,
        DatasetType.DataType _dataType
    ) external view returns (bool);

    ///@notice get datasets instance
    function datasets() external view returns (IDatasets);

    ///@notice get datasetsChallenge instance
    function datasetsChallenge() external view returns (IDatasetsChallenge);

    ///@notice get datasetsRequirement instance
    function datasetsRequirement() external view returns (IDatasetsRequirement);
}
