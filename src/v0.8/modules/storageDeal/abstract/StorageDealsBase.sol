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

import "../../../types/StorageDealType.sol";
import "../../../types/RolesType.sol";
import "../../../core/accessControl/interface/IRoles.sol";
import "../library/StorageDealLIB.sol";
import "@openzeppelin/contracts/access/Ownable2Step.sol";

/// @title StorageDealsBase Contract
/// @notice This contract serves as the base for managing storage deals, their states, and associated actions.
/// @dev This contract is intended to be inherited by specific storage deal-related contracts.
abstract contract StorageDealsBase is Ownable2Step {
    uint256 public storageDealsCount;
    mapping(uint256 => StorageDealType.StorageDeal) public storageDeals;
    address public immutable rolesContract;
    address public immutable carsStorageContract;
    address public immutable datasetsContract;
    address public immutable matchingContract;

    using StorageDealLIB for StorageDealType.StorageDeal;

    /// @notice Constructor function to initialize contract with required addresses.
    /// @param _rolesContract Address of the Roles contract for role-based access control.
    /// @param _carsStorageContract Address of the CarsStorage contract.
    /// @param _datasetsContract Address of the Datasets contract.
    /// @param _matchingContract Address of the Matching contract.
    constructor(
        address _rolesContract,
        address _carsStorageContract,
        address _datasetsContract,
        address _matchingContract
    ) {
        rolesContract = _rolesContract;
        carsStorageContract = _carsStorageContract;
        datasetsContract = _datasetsContract;
        matchingContract = _matchingContract;
    }

    /// @notice Event emitted when a storage deal is submitted.
    /// @notice Event emitted when previous data cap proof is submitted.
    event PreviousDataCapProofSubmitted(
        uint256 indexed _storageDealId,
        uint256 indexed _matchingId,
        uint256 indexed _carIndex,
        uint256 _filecoinDealId
    );

    /// @notice Event emitted when the submission of previous data cap proof expires.
    event SubmitPreviousDataCapProofExpired(
        uint256 indexed _storageDealId,
        uint256 indexed _matchingId
    );

    /// @notice Event emitted when a matching is completed.
    event MatchingCompleted(
        uint256 indexed _storageDealId,
        uint256 indexed _matchingId
    );

    /// @notice Restricts access to functions based on a specific role.
    /// @param _role The role required to access the function.
    modifier onlyRole(bytes32 _role) {
        IRoles role = IRoles(rolesContract);
        require(role.hasRole(_role, msg.sender), "No permission!");
        _;
    }

    /// @notice Restricts access to functions based on being a dataset provider or storage provider.
    modifier onlyDPorSP() {
        IRoles role = IRoles(rolesContract);
        require(
            role.hasRole(RolesType.DATASET_PROVIDER, msg.sender) ||
                role.hasRole(RolesType.STORAGE_PROVIDER, msg.sender),
            "No permission!"
        );
        _;
    }

    /// @notice Restricts access to functions based on a specific address.
    /// @param _address The address required to access the function.
    modifier onlyAddress(address _address) {
        require(_address == msg.sender, "No permission!");
        _;
    }

    /// @notice Restricts access to functions based on the existence of a storage deal with a given matching ID.
    /// @param _matchingId The matching ID associated with the storage deal.
    modifier onlyStorageDealExistsByMatchingId(uint256 _matchingId) {
        (bool exsits, ) = hasStorageDealByMatchingId(_matchingId);
        require(exsits, "StorageDeal is not exists");
        _;
    }
    /// @notice Restricts access to functions based on the non-existence of a storage deal with a given matching ID.
    /// @param _matchingId The matching ID associated with the storage deal.
    modifier onlyStorageDealNotExistsByMatchingId(uint256 _matchingId) {
        (bool exsits, ) = hasStorageDealByMatchingId(_matchingId);
        require(!exsits, "StorageDeal is exists");
        _;
    }

    /// @notice Restricts access to functions based on the existence of a storage deal with a given storage deal ID.
    /// @param _storageDealId The storage deal ID associated with the storage deal.
    modifier onlyStorageDealExistsByStorageId(uint256 _storageDealId) {
        require(
            hasStorageDealbyStorageDealId(_storageDealId),
            "StorageDeal is not exists"
        );
        _;
    }

    /// @notice Restricts access to functions based on the non-existence of a storage deal with a given storage deal ID.
    /// @param _storageDealId The storage deal ID associated with the storage deal.
    modifier onlyStorageDealNotExistsByStorageId(uint256 _storageDealId) {
        require(
            !hasStorageDealbyStorageDealId(_storageDealId),
            "StorageDeal is exists"
        );
        _;
    }

    /// @notice Submit a MatchingCompleted event to signal the completion of a matching.
    /// @param _matchingId The ID of the matching associated with the storage deal.
    /// @dev This function is restricted to the matching contract address.
    function submitMatchingCompletedEvent(
        uint256 _matchingId
    )
        external
        onlyStorageDealNotExistsByMatchingId(_matchingId)
        onlyAddress(matchingContract)
    {
        storageDealsCount++;
        StorageDealType.StorageDeal storage storageDeal = storageDeals[
            storageDealsCount
        ];
        storageDeal.matchingId = _matchingId;
        storageDeal.submitMatchingCompletedEvent();
        emit MatchingCompleted(storageDealsCount, _matchingId);
    }

    /// @notice Report the expiration of submitting previous data cap proof.
    /// @param _storageDealId The storage deal ID associated with the storage deal.
    function reportSubmitPreviousDataCapProofExpired(
        uint256 _storageDealId
    ) external onlyStorageDealExistsByStorageId(_storageDealId) {
        StorageDealType.StorageDeal storage storageDeal = storageDeals[
            _storageDealId
        ];
        storageDeal.reportSubmitPreviousDataCapProofExpired();
    }

    /// @notice Submit the previous data cap proof for verification.
    /// @param _storageDealId The storage deal ID associated with the storage deal.
    /// @param _proofs Array of CarProofs containing proof data.
    function submitPreviousDataCapProof(
        uint256 _storageDealId,
        StorageDealType.CarProof[] memory _proofs
    )
        external
        virtual
        onlyStorageDealExistsByStorageId(_storageDealId)
        onlyDPorSP
    {
        StorageDealType.StorageDeal storage storageDeal = storageDeals[
            _storageDealId
        ];
        storageDeal.submitPreviousDataCapProof(_proofs, carsStorageContract);
        emit PreviousDataCapProofSubmitted(
            _storageDealId,
            storageDeal.matchingId,
            _proofs.length,
            _proofs[_proofs.length - 1].filcoinDealId
        );
    }

    /// @notice Get the state of a storage deal.
    /// @param _storageDealId The storage deal ID associated with the storage deal.
    /// @return The current state of the storage deal.
    function getState(
        uint256 _storageDealId
    )
        public
        view
        onlyStorageDealExistsByStorageId(_storageDealId)
        returns (StorageDealType.State)
    {
        StorageDealType.StorageDeal storage storageDeal = storageDeals[
            _storageDealId
        ];
        return storageDeal.getState();
    }

    /// @notice Check if a storage deal exists for a given matching ID.
    /// @param _matchingId The matching ID to check for.
    /// @return A boolean indicating whether the storage deal exists and its ID if it does.
    function hasStorageDealByMatchingId(
        uint256 _matchingId
    ) public view returns (bool, uint256) {
        require(_matchingId != 0, "Invalid matching id");
        for (uint256 i = 1; i <= storageDealsCount; i++) {
            if (_matchingId == storageDeals[i].matchingId) return (true, i);
        }
        return (false, 0);
    }

    /// @notice Check if a storage deal exists for a given storage deal ID.
    /// @param _storageDealId The storage deal ID to check for.
    /// @return A boolean indicating whether the storage deal exists.
    function hasStorageDealbyStorageDealId(
        uint256 _storageDealId
    ) public view returns (bool) {
        require(
            _storageDealId != 0 && _storageDealId < storageDealsCount,
            "Invalid storage deal id"
        );
        return storageDeals[_storageDealId].matchingId != 0;
    }
}
