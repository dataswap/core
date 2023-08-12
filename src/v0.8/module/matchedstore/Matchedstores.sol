/// SPDX-License-Identifier: GPL-3.0-or-later
/// (c) 2023 DataSwap
///
/// Licensed under the GNU General Public License, Version 3.0 or later (the "License");
/// you may not use this file except in compliance with the License.
/// You may obtain a copy of the License at
///     https://www.gnu.org/licenses/gpl-3.0.en.html
///
/// Unless required by applicable law or agreed to in writing, software
/// distributed under the License is distributed on an "AS IS" BASIS,
/// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
/// See the License for the specific language governing permissions and
/// limitations under the License.

pragma solidity ^0.8.21;

import "../../types/MatchedstoreType.sol";
import "../matching/Matchings.sol";
import "../../shared/filecoin/FilecoinDealUtils.sol";
import "../../types/FilecoinDealType.sol";
import "./IMatchedstores.sol";

/// @title Matchedstores
/// @dev Manages the storage of matched data after successful matching with Filecoin storage deals.
abstract contract Matchedstores is Matchings, IMatchedstores {
    mapping(uint256 => MatchedstoreType.Matchedstore) private matchedstores; //matchingId=>Matchedstore

    /// @dev Modifier to check if the Filecoin deal state is 'Successed'.
    modifier onlyMatchedstoreFilecoinDealStateSuccessed(
        bytes32 _cid,
        uint256 _filecoinDealId
    ) {
        require(
            FilecoinStorageDealState.Successed ==
                FilecoinDealUtils.getFilecoinStorageDealState(
                    _cid,
                    _filecoinDealId
                ),
            "filecoin deal Id is not setted"
        );
        _;
    }

    /// @dev Modifier to check if the Filecoin deal Id is not already set.
    modifier onlyMatchedstoreFilecoinDealIdNotSetted(
        uint256 _matchingId,
        bytes32 _cid,
        uint256 _filecoinDealId
    ) {
        require(
            !_isMatchedstoreFilecoinDealIdSetted(
                _matchingId,
                _cid,
                _filecoinDealId
            ),
            "filecoin deal Id is setted"
        );
        _;
    }

    /// @dev Internal function to check if a Filecoin deal Id is set for the matchedstore.
    function _isMatchedstoreFilecoinDealIdSetted(
        uint256 _matchingId,
        bytes32 _cid,
        uint256 _filecoinDealId
    ) internal virtual returns (bool);

    /// @dev Internal function to set a Filecoin deal Id for the matchedstore.
    function _setMatchedstoreFilecoinDealId(
        uint256 _matchingId,
        bytes32 _cid,
        uint256 _filecoinDealId
    ) internal virtual;

    /// @dev Submits a Filecoin deal Id for a matchedstore after successful matching.
    function submitMatchedstoreFilecoinDealId(
        uint256 _matchingId,
        bytes32 _cid,
        uint256 _filecoinDealId
    )
        public
        onlyMatchingContainsCid(_matchingId, _cid)
        onlyMatchedstoreFilecoinDealIdNotSetted(
            _matchingId,
            _cid,
            _filecoinDealId
        )
        onlyMatchedstoreFilecoinDealStateSuccessed(_cid, _filecoinDealId)
    {
        MatchedstoreType.Matchedstore storage matchedstore = matchedstores[
            _matchingId
        ];
        matchedstore.doneCars.push(_cid);
        _setMatchedstoreFilecoinDealId(_matchingId, _cid, _filecoinDealId);
    }

    /// @dev Submits multiple Filecoin deal Ids for a matchedstore after successful matching.
    function submitMatchedstoreFilecoinDealIds(
        uint256 _matchingId,
        bytes32[] memory _cids,
        uint256[] memory _filecoinDealIds
    ) external {
        require(
            _cids.length == _filecoinDealIds.length,
            "param length is not match!"
        );
        for (uint256 i = 0; i < _cids.length; i++) {
            submitMatchedstoreFilecoinDealId(
                _matchingId,
                _cids[i],
                _filecoinDealIds[i]
            );
        }
    }

    /// @dev Gets the list of done cars in the matchedstore.
    function getMatchedstoreCars(
        uint256 _matchingId
    ) public view returns (bytes32[] memory) {
        MatchedstoreType.Matchedstore storage matchedstore = matchedstores[
            _matchingId
        ];
        return matchedstore.doneCars;
    }

    /// @dev Gets the count of done cars in the matchedstore.
    function getMatchedsotreCarsCount(
        uint256 _matchingId
    ) public view returns (uint256) {
        MatchedstoreType.Matchedstore storage matchedstore = matchedstores[
            _matchingId
        ];
        return matchedstore.doneCars.length;
    }

    /// @dev Gets the stored size in the matchedstore.
    function getMatchedsotreTotalSize(
        uint256 _matchingId
    ) public view returns (uint256) {
        MatchedstoreType.Matchedstore storage matchedstore = matchedstores[
            _matchingId
        ];
        // TODO: need be do
        return matchedstore.doneCars.length * 32 * 1024 * 1024 * 1024;
    }

    /// @dev Checks if all cars are done in the matchedstore.
    function isMatchedsotreAllDone(
        uint256 _matchingId
    ) public view returns (bool) {
        MatchedstoreType.Matchedstore storage matchedstore = matchedstores[
            _matchingId
        ];
        return
            matchedstore.doneCars.length == getMatchingCids(_matchingId).length;
    }
}
