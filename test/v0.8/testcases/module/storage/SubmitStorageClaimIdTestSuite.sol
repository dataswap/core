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

import {StoragesTestBase} from "test/v0.8/testcases/module/storage/abstract/StoragesTestBase.sol";

import {Errors} from "src/v0.8/shared/errors/Errors.sol";
import {Generator} from "test/v0.8/helpers/utils/Generator.sol";
import {ICarstore} from "src/v0.8/interfaces/core/ICarstore.sol";
import {IStorages} from "src/v0.8/interfaces/module/IStorages.sol";
import {IStoragesAssertion} from "test/v0.8/interfaces/assertions/module/IStoragesAssertion.sol";
import {IStoragesHelpers} from "test/v0.8/interfaces/helpers/module/IStoragesHelpers.sol";
import {IFilecoin} from "src/v0.8/interfaces/core/IFilecoin.sol";

import {CidUtils} from "src/v0.8/shared/utils/cid/CidUtils.sol";

///@notice submit storage filecoin claim id test case with success
contract SubmitStorageClaimIdTestCaseWithSuccess is StoragesTestBase {
    constructor(
        ICarstore _carstore,
        IStorages _storages,
        Generator _generator,
        IStoragesHelpers _storagesHelpers,
        IStoragesAssertion _storagesAssertion,
        IFilecoin _filecoin
    )
        StoragesTestBase(
            _carstore,
            _storages,
            _generator,
            _storagesHelpers,
            _storagesAssertion,
            _filecoin
        ) // solhint-disable-next-line
    {}

    function before() internal virtual override returns (uint64) {
        (, uint64 matchingId) = storagesHelpers.setup();
        return matchingId;
    }

    function action(uint64 _matchingId) internal virtual override {
        uint64[] memory cars = storages.matchingsTarget().getMatchingCars(
            _matchingId
        );
        uint64 id = cars[0];
        uint64 provider = 0;
        bytes memory dataCid = CidUtils.hashToCID(carstore.getCarHash(id));
        uint64 claimId = storagesHelpers.generateFilecoinClaimId();
        filecoin.setMockClaimData(claimId, dataCid);
        address winner = storages.matchingsBids().getMatchingWinner(
            _matchingId
        );
        storagesAssertion.submitStorageClaimIdAssertion(
            winner,
            _matchingId,
            provider,
            id,
            claimId
        );
    }
}

///@notice Submit storage filecoin claim id Already includes the switch of Replica Matched status, there is no need to test its abnormal conditions.

///@notice submit storage filecoin claim id test case with invalid address
contract SubmitStorageClaimIdTestCaseWithInvalidAddress is StoragesTestBase {
    constructor(
        ICarstore _carstore,
        IStorages _storages,
        Generator _generator,
        IStoragesHelpers _storagesHelpers,
        IStoragesAssertion _storagesAssertion,
        IFilecoin _filecoin
    )
        StoragesTestBase(
            _carstore,
            _storages,
            _generator,
            _storagesHelpers,
            _storagesAssertion,
            _filecoin
        ) // solhint-disable-next-line
    {}

    function before() internal virtual override returns (uint64) {
        (, uint64 matchingId) = storagesHelpers.setup();
        return matchingId;
    }

    function action(uint64 _matchingId) internal virtual override {
        uint64[] memory cars = storages.matchingsTarget().getMatchingCars(
            _matchingId
        );
        uint64 id = cars[0];
        uint64 provider = 0;
        uint64 claimId = storagesHelpers.generateFilecoinClaimId();
        address winner = generator.generateAddress(100);
        vm.expectRevert(bytes("Only allowed address can call"));
        storagesAssertion.submitStorageClaimIdAssertion(
            winner,
            _matchingId,
            provider,
            id,
            claimId
        );
    }
}

///@notice submit storage filecoin claim id test case with invalid cid
contract SubmitStorageClaimIdTestCaseWithInvalidCid is StoragesTestBase {
    constructor(
        ICarstore _carstore,
        IStorages _storages,
        Generator _generator,
        IStoragesHelpers _storagesHelpers,
        IStoragesAssertion _storagesAssertion,
        IFilecoin _filecoin
    )
        StoragesTestBase(
            _carstore,
            _storages,
            _generator,
            _storagesHelpers,
            _storagesAssertion,
            _filecoin
        ) // solhint-disable-next-line
    {}

    function before() internal virtual override returns (uint64) {
        (, uint64 matchingId) = storagesHelpers.setup();
        return matchingId;
    }

    function action(uint64 _matchingId) internal virtual override {
        uint64 id = 1;
        uint64 provider = 0;
        uint64 claimId = storagesHelpers.generateFilecoinClaimId();
        address winner = storages.matchingsBids().getMatchingWinner(
            _matchingId
        );
        vm.expectRevert(
            abi.encodeWithSelector(
                Errors.ReplicaNotExist.selector,
                id,
                _matchingId
            )
        );
        storagesAssertion.submitStorageClaimIdAssertion(
            winner,
            _matchingId,
            provider,
            id,
            claimId
        );
    }
}

///@notice submit storage filecoin claim id test case with duplicate cid
contract SubmitStorageClaimIdTestCaseWithDuplicateCid is StoragesTestBase {
    constructor(
        ICarstore _carstore,
        IStorages _storages,
        Generator _generator,
        IStoragesHelpers _storagesHelpers,
        IStoragesAssertion _storagesAssertion,
        IFilecoin _filecoin
    )
        StoragesTestBase(
            _carstore,
            _storages,
            _generator,
            _storagesHelpers,
            _storagesAssertion,
            _filecoin
        ) // solhint-disable-next-line
    {}

    function before() internal virtual override returns (uint64) {
        (, uint64 matchingId) = storagesHelpers.setup();
        return matchingId;
    }

    function action(uint64 _matchingId) internal virtual override {
        uint64[] memory cars = storages.matchingsTarget().getMatchingCars(
            _matchingId
        );
        uint64 id = cars[0];
        uint64 provider = 0;
        bytes memory dataCid = CidUtils.hashToCID(carstore.getCarHash(id));
        uint64 claimId = storagesHelpers.generateFilecoinClaimId();
        filecoin.setMockClaimData(claimId, dataCid);

        address winner = storages.matchingsBids().getMatchingWinner(
            _matchingId
        );
        storagesAssertion.submitStorageClaimIdAssertion(
            winner,
            _matchingId,
            provider,
            id,
            claimId
        );
        vm.expectRevert(
            abi.encodeWithSelector(
                Errors.ReplicaFilecoinClaimIdExists.selector,
                id,
                _matchingId
            )
        );
        storagesAssertion.submitStorageClaimIdAssertion(
            winner,
            _matchingId,
            provider,
            id,
            claimId
        );
    }
}
