/*******************************************************************************
 *   (c) 2023 DataSwap
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

import "./core/carStore/CarStore.sol";
import "./modules/dataset/Datasets.sol";
import "./modules/matching/Matchings.sol";

contract Dataswap is CarStore, Matchings {
    constructor(
        address payable _governanceContractAddress
    ) Datasets(_governanceContractAddress) {}

    ///@dev add cars to carStore before approve
    function _beforeApproveDataset(
        uint256 _datasetId
    ) internal virtual override {
        _addCars(getDatasetSourceCids(_datasetId), _datasetId);
        _addCars(getDatasetSourceToCarMappingFilesCids(_datasetId), _datasetId);
    }

    ///@dev add cars replica info  to carStore before complete
    function _beforeCompleteMatching(
        uint256 _matchingId
    ) internal virtual override {
        bytes32[] memory cars = getMatchingCids(_matchingId);
        for (uint256 i; i < cars.length; i++) {
            _addCarReplica(cars[i], _matchingId);
        }
    }

    /// @notice Internal function to get the state of a Filecoin storage deal for a replica.
    /// @dev This function get the state of a Filecoin storage deal associated with a replica.
    /// @return The state of the Filecoin storage deal for the replica.
    function getCarReplicaFilecoinDealState(
        bytes32 /*_cid*/,
        uint256 /*_matchingId*/
    )
        public
        view
        virtual
        override(CarStore)
        returns (CarReplicaType.FilecoinDealState)
    {}

    /// @notice Check if a matching meets the requirements of Fil+.
    function isMatchingTargetMeetsFilPlusRequirements(
        uint256 /*_datasetId*/,
        bytes32[] memory /*_cars*/,
        uint256 /*_size*/,
        MatchingType.DataType /*_dataType*/,
        uint256 /*_associatedMappingFilesMatchingID*/
    ) public view virtual override returns (bool) {
        return true;
    }
}
