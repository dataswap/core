// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity ^0.8.21;

import "../../../types/StorageDealType.sol";
import "../../../types/RolesType.sol";
import "../../../core/accessControl/interface/IRoles.sol";
import "../library/StorageDealLIB.sol";
import "@openzeppelin/contracts/access/Ownable2Step.sol";

abstract contract StorageDealsBase is Ownable2Step {
    uint256 public storageDealsCount;
    mapping(uint256 => StorageDealType.StorageDeal) public storageDeals;
    address public immutable rolesContract;
    address public immutable carsStorageContract;
    address public immutable datasetsContract;
    address public immutable matchingContract;

    using StorageDealLIB for StorageDealType.StorageDeal;

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

    modifier onlyRole(bytes32 _role) {
        IRoles role = IRoles(rolesContract);
        require(role.hasRole(_role, msg.sender), "No permission!");
        _;
    }

    modifier onlyDPorSP() {
        IRoles role = IRoles(rolesContract);
        require(
            role.hasRole(RolesType.DATASET_PROVIDER, msg.sender) ||
                role.hasRole(RolesType.STORAGE_PROVIDER, msg.sender),
            "No permission!"
        );
        _;
    }

    modifier onlyAddress(address _address) {
        require(_address == msg.sender, "No permission!");
        _;
    }

    modifier onlyStorageDealExistsByMatchingId(uint256 _matchingId) {
        (bool exsits, ) = hasStorageDealByMatchingId(_matchingId);
        require(exsits, "StorageDeal is not exists");
        _;
    }

    modifier onlyStorageDealNotExistsByMatchingId(uint256 _matchingId) {
        (bool exsits, ) = hasStorageDealByMatchingId(_matchingId);
        require(!exsits, "StorageDeal is exists");
        _;
    }

    modifier onlyStorageDealExistsByStorageId(uint256 _storageDealId) {
        require(
            hasStorageDealbyStorageDealId(_storageDealId),
            "StorageDeal is not exists"
        );
        _;
    }

    modifier onlyStorageDealNotExistsByStorageId(uint256 _storageDealId) {
        require(
            !hasStorageDealbyStorageDealId(_storageDealId),
            "StorageDeal is exists"
        );
        _;
    }

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
    }

    function reportSubmitPreviousDataCapProofExpired(
        uint256 _storageDealId
    ) external onlyStorageDealExistsByStorageId(_storageDealId) {
        StorageDealType.StorageDeal storage storageDeal = storageDeals[
            _storageDealId
        ];
        storageDeal.reportSubmitPreviousDataCapProofExpired();
    }

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
    }

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

    function hasStorageDealByMatchingId(
        uint256 _matchingId
    ) public view returns (bool, uint256) {
        require(_matchingId != 0, "Invalid matching id");
        for (uint256 i = 1; i <= storageDealsCount; i++) {
            if (_matchingId == storageDeals[i].matchingId) return (true, i);
        }
        return (false, 0);
    }

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
