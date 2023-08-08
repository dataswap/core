// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity ^0.8.21;

import "../libraries/StorageDealLIB.sol";
import "../libraries/types/StorageDealType.sol";

abstract contract IStorageDeals {
    uint256 public storageDealsCount;
    mapping(uint256 => StorageDealType.StorageDeal) public storageDeals;

    using StorageDealLIB for StorageDealType.StorageDeal;

    modifier onlyStorageDealExists(uint256 _matchingId) {
        (bool exsits, ) = hasStorageDealByMatchingId(_matchingId);
        require(exsits, "StorageDeal is exists");
        _;
    }

    modifier onlyStorageDealNotExists(uint256 _matchingId) {
        (bool exsits, ) = hasStorageDealByMatchingId(_matchingId);
        require(!exsits, "StorageDeal is not exists");
        _;
    }

    modifier onlyStorageDealExistsByStorageId(uint256 _storageDealId) {
        require(
            hasStorageDealbyStorageDealId(_storageDealId),
            "StorageDeal is exists"
        );
        _;
    }

    modifier onlyStorageDealNotExistsByStorageId(uint256 _storageDealId) {
        require(
            !hasStorageDealbyStorageDealId(_storageDealId),
            "StorageDeal is not exists"
        );
        _;
    }

    function submitMatchingCompletedEvent(
        uint256 _matchingId
    ) external onlyStorageDealNotExists(_matchingId) {
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
        StorageDealType.CarProof[] memory _proofs,
        address _carsStorageContractAddress
    ) external virtual onlyStorageDealExistsByStorageId(_storageDealId) {
        StorageDealType.StorageDeal storage storageDeal = storageDeals[
            _storageDealId
        ];

        storageDeal.submitPreviousDataCapProof(
            _proofs,
            _carsStorageContractAddress
        );
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
