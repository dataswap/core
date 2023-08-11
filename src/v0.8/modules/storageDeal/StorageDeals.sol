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

import "../../types/StorageDealType.sol";
import "../matching/Matchings.sol";
import "../../shared/filecoin/FilecoinDealUtils.sol";
import "../../types/FilecoinDealType.sol";

abstract contract StorageDeals is Matchings {
    mapping(uint256 => StorageDealType.StorageDeal) private storageDeals; //matchingId=>StorageDeal

    /// @notice  Modifier to restrict access to the matching initiator
    modifier onlyFilecoinDealIsSuccess(bytes32 _cid, uint256 _filecoinDealId) {
        require(
            FilecoinStorageDealState.Successed ==
                FilecoinDealUtils.getFilecoinStorageDealState(
                    _cid,
                    _filecoinDealId
                ),
            "filecoin deal Id is not success"
        );
        _;
    }

    modifier onlyFilecoinDealIsNotSet(
        uint256 _matchingId,
        bytes32 _cid,
        uint256 _filecoinDealId
    ) {
        require(
            !_isStorageDealsFilecoinDealSetted(
                _matchingId,
                _cid,
                _filecoinDealId
            ),
            "filecoin deal Id is not success"
        );
        _;
    }

    function _storageDealsSetCarReplicaFilecoinDealId(
        uint256 _matchingId,
        bytes32 _cid,
        uint256 _filecoinDealId
    ) internal virtual;

    function _isStorageDealsFilecoinDealSetted(
        uint256 _matchingId,
        bytes32 _cid,
        uint256 _filecoinDealId
    ) internal virtual returns (bool);

    function submitCarReplicaFilecoinDealId(
        uint256 _matchingId,
        bytes32 _cid,
        uint256 _filecoinDealId
    )
        public
        onlyMatchingContainsCid(_matchingId, _cid)
        onlyFilecoinDealIsNotSet(_matchingId, _cid, _filecoinDealId)
        onlyFilecoinDealIsSuccess(_cid, _filecoinDealId)
    {
        StorageDealType.StorageDeal storage storageDeal = storageDeals[
            _matchingId
        ];
        storageDeal.doneCars.push(_cid);
        _storageDealsSetCarReplicaFilecoinDealId(
            _matchingId,
            _cid,
            _filecoinDealId
        );
    }

    function submitCarsReplicaFilecoinDealId(
        uint256 _matchingId,
        bytes32[] memory _cids,
        uint256[] memory _filecoinDealIds
    ) external {
        require(
            _cids.length == _filecoinDealIds.length,
            "param length is not match!"
        );
        for (uint256 i = 0; i < _cids.length; i++) {
            submitCarReplicaFilecoinDealId(
                _matchingId,
                _cids[i],
                _filecoinDealIds[i]
            );
        }
    }

    function getStorageDealDoneCarsCids(
        uint256 _matchingId
    ) public view returns (bytes32[] memory) {
        StorageDealType.StorageDeal storage storageDeal = storageDeals[
            _matchingId
        ];
        return storageDeal.doneCars;
    }

    function getStorageDealDoneCarsCount(
        uint256 _matchingId
    ) public view returns (uint256) {
        StorageDealType.StorageDeal storage storageDeal = storageDeals[
            _matchingId
        ];
        return storageDeal.doneCars.length;
    }

    function isStorageDealDone(uint256 _matchingId) public view returns (bool) {
        StorageDealType.StorageDeal storage storageDeal = storageDeals[
            _matchingId
        ];
        uint256 matchingCidsCount = getMatchingCids(_matchingId).length;
        return storageDeal.doneCars.length == matchingCidsCount;
    }
}
