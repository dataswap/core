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

import {RolesType} from "src/v0.8/types/RolesType.sol";

import {Roles} from "src/v0.8/core/access/Roles.sol";
import {Filplus} from "src/v0.8/core/filplus/Filplus.sol";
import {MockFilecoin} from "src/v0.8/mocks/core/filecoin/MockFilecoin.sol";
import {MockMerkleUtils} from "src/v0.8/mocks/utils/merkle/MockMerkleUtils.sol";
import {Carstore} from "src/v0.8/core/carstore/Carstore.sol";
import {Datasets} from "src/v0.8/module/dataset/Datasets.sol";
import {DatasetsRequirement} from "src/v0.8/module/dataset/DatasetsRequirement.sol";
import {DatasetsProof} from "src/v0.8/module/dataset/DatasetsProof.sol";
import {DatasetsChallenge} from "src/v0.8/module/dataset/DatasetsChallenge.sol";
import {Matchings} from "src/v0.8/module/matching/Matchings.sol";
import {MatchingsTarget} from "src/v0.8/module/matching/MatchingsTarget.sol";
import {MatchingsBids} from "src/v0.8/module/matching/MatchingsBids.sol";
import {Storages} from "src/v0.8/module/storage/Storages.sol";
import {Generator} from "test/v0.8/helpers/utils/Generator.sol";
import {Finance} from "src/v0.8/core/finance/Finance.sol";
import {EscrowDataTradingFee} from "src/v0.8/core/finance/escrow/EscrowDataTradingFee.sol";
import {EscrowDatacapCollateral} from "src/v0.8/core/finance/escrow/EscrowDatacapCollateral.sol";
import {EscrowChallengeCommission} from "src/v0.8/core/finance/escrow/EscrowChallengeCommission.sol";
import {EscrowDatacapChunkLandCollateral} from "src/v0.8/core/finance/escrow/EscrowDatacapChunkLandCollateral.sol";

/// @title BaseTestSetup
/// @notice This contract is used for setting up the base test setup contract for testing.
contract BaseTestSetup {
    struct Setups {
        address payable governanceContractAddresss;
        Roles role;
        Filplus filplus;
        Carstore carstore;
        Storages storages;
        Generator generator;
        MockFilecoin filecoin;
        MockMerkleUtils merkleUtils;
        Finance finance;
        EscrowDataTradingFee escrowDataTradingFee;
        EscrowDatacapCollateral escrowDatacapCollateral;
        EscrowChallengeCommission escrowChallengeCommission;
        EscrowDatacapChunkLandCollateral escrowDatacapChunkLandCollateral;
        Datasets datasets;
        DatasetsProof datasetsProof;
        DatasetsChallenge datasetsChallenge;
        DatasetsRequirement datasetsRequirement;
        Matchings matchings;
        MatchingsTarget matchingsTarget;
        MatchingsBids matchingsBids;
    }

    Setups private base;

    /// @dev Internal initialize the base contracts.
    function baseSetup() internal {
        base.generator = new Generator();
        base.role = new Roles();
        base.role.initialize();
        base.filplus = new Filplus();
        base.filplus.initialize(
            base.governanceContractAddresss,
            address(base.role)
        );

        base.filecoin = new MockFilecoin();
        base.filecoin.initialize(address(base.role));

        base.finance = new Finance();
        base.finance.initialize(address(base.role));

        base.escrowDataTradingFee = new EscrowDataTradingFee();
        base.escrowDataTradingFee.initialize(address(base.role));

        base.escrowDatacapCollateral = new EscrowDatacapCollateral();
        base.escrowDatacapCollateral.initialize(address(base.role));

        base.escrowChallengeCommission = new EscrowChallengeCommission();
        base.escrowChallengeCommission.initialize(address(base.role));

        base
            .escrowDatacapChunkLandCollateral = new EscrowDatacapChunkLandCollateral();
        base.escrowDatacapChunkLandCollateral.initialize(address(base.role));

        base.merkleUtils = new MockMerkleUtils();
        base.merkleUtils.initialize(address(base.role));

        base.carstore = new Carstore();
        base.carstore.initialize(address(base.role));

        base.datasets = new Datasets();
        base.datasets.initialize(
            base.governanceContractAddresss,
            address(base.role)
        );

        base.datasetsRequirement = new DatasetsRequirement();
        base.datasetsRequirement.initialize(
            base.governanceContractAddresss,
            address(base.role)
        );

        base.datasetsProof = new DatasetsProof();
        base.datasetsProof.initialize(
            base.governanceContractAddresss,
            address(base.role)
        );

        base.datasetsChallenge = new DatasetsChallenge();
        base.datasetsChallenge.initialize(
            base.governanceContractAddresss,
            address(base.role)
        );
    }

    /// @dev Initialize the enhance contracts.
    function enhanceSetup() internal {
        baseSetup();
        base.matchings = new Matchings();
        base.matchings.initialize(
            base.governanceContractAddresss,
            address(base.role)
        );

        base.matchingsTarget = new MatchingsTarget();
        base.matchingsTarget.initialize(
            base.governanceContractAddresss,
            address(base.role)
        );

        base.matchingsBids = new MatchingsBids();
        base.matchingsBids.initialize(
            base.governanceContractAddresss,
            address(base.role)
        );

        base.storages = new Storages();
        base.storages.initialize(
            base.governanceContractAddresss,
            address(base.role)
        );
        base.storages.registDataswapDatacap(100000000000000);

        address[] memory _contracts = new address[](14);
        _contracts[0] = address(0);
        _contracts[1] = address(base.role);
        _contracts[2] = address(base.filplus);
        _contracts[3] = address(base.carstore);
        _contracts[4] = address(base.storages);

        _contracts[5] = address(base.datasets);
        _contracts[6] = address(base.datasetsProof);
        _contracts[7] = address(base.datasetsChallenge);
        _contracts[8] = address(base.datasetsRequirement);
        _contracts[9] = address(base.matchings);
        _contracts[10] = address(base.matchingsTarget);
        _contracts[11] = address(base.matchingsBids);
        _contracts[12] = address(base.filecoin);
        _contracts[13] = address(base.merkleUtils);
        base.role.grantDataswapContractRole(_contracts);

        base.role.registerContract(
            RolesType.ContractType.Filplus,
            address(base.filplus)
        );
        base.role.registerContract(
            RolesType.ContractType.Filecoin,
            address(base.filecoin)
        );
        base.role.registerContract(
            RolesType.ContractType.Carstore,
            address(base.carstore)
        );
        base.role.registerContract(
            RolesType.ContractType.Storages,
            address(base.storages)
        );
        base.role.registerContract(
            RolesType.ContractType.MerkleUtils,
            address(base.merkleUtils)
        );
        base.role.registerContract(
            RolesType.ContractType.Datasets,
            address(base.datasets)
        );
        base.role.registerContract(
            RolesType.ContractType.DatasetsProof,
            address(base.datasetsProof)
        );
        base.role.registerContract(
            RolesType.ContractType.DatasetsChallenge,
            address(base.datasetsChallenge)
        );
        base.role.registerContract(
            RolesType.ContractType.DatasetsRequirement,
            address(base.datasetsRequirement)
        );
        base.role.registerContract(
            RolesType.ContractType.Matchings,
            address(base.matchings)
        );
        base.role.registerContract(
            RolesType.ContractType.MatchingsBids,
            address(base.matchingsBids)
        );
        base.role.registerContract(
            RolesType.ContractType.MatchingsTarget,
            address(base.matchingsTarget)
        );
        base.role.registerContract(
            RolesType.ContractType.Finance,
            address(base.finance)
        );
        base.role.registerContract(
            RolesType.ContractType.EscrowDataTradingFee,
            address(base.escrowDataTradingFee)
        );
        base.role.registerContract(
            RolesType.ContractType.EscrowDatacapCollateral,
            address(base.escrowDatacapCollateral)
        );
        base.role.registerContract(
            RolesType.ContractType.EscrowChallengeCommission,
            address(base.escrowChallengeCommission)
        );
        base.role.registerContract(
            RolesType.ContractType.EscrowDatacapChunkLandCollateral,
            address(base.escrowDatacapChunkLandCollateral)
        );
        base.role.registerContract(
            RolesType.ContractType.Finance,
            address(base.finance)
        );
        base.role.registerContract(
            RolesType.ContractType.EscrowDataTradingFee,
            address(base.escrowDataTradingFee)
        );
        base.role.registerContract(
            RolesType.ContractType.EscrowDatacapCollateral,
            address(base.escrowDatacapCollateral)
        );
        base.role.registerContract(
            RolesType.ContractType.EscrowChallengeCommission,
            address(base.escrowChallengeCommission)
        );
        base.role.registerContract(
            RolesType.ContractType.EscrowDatacapChunkLandCollateral,
            address(base.escrowDatacapChunkLandCollateral)
        );
    }

    /// @dev Get the governanceContractAddresss contract.
    /// @return Address The governanceContractAddresss.
    function governanceContractAddresss() public view returns (address) {
        return base.governanceContractAddresss;
    }

    /// @dev Get the role contract.
    /// @return Roles The Roles contract.
    function role() public view returns (Roles) {
        return base.role;
    }

    /// @dev Get the Filplus contract.
    /// @return Filplus The Filplus contract.
    function filplus() public view returns (Filplus) {
        return base.filplus;
    }

    /// @dev Get the Carstore contract.
    /// @return Carstore The Carstore contract.
    function carstore() public view returns (Carstore) {
        return base.carstore;
    }

    /// @dev Get the Storages (storages) contract.
    /// @return Storages The Storages  contract.
    function storages() public view returns (Storages) {
        return base.storages;
    }

    /// @dev Get the Generator contract.
    /// @return Generator The Generator contract.
    function generator() public view returns (Generator) {
        return base.generator;
    }

    /// @dev Get the MockFilecoin contract.
    /// @return MockFilecoin The MockFilecoin contract.
    function filecoin() public view returns (MockFilecoin) {
        return base.filecoin;
    }

    /// @dev Get the MockMerkleUtils contract.
    /// @return MockMerkleUtils The MockMerkleUtils contract.
    function merkleUtils() public view returns (MockMerkleUtils) {
        return base.merkleUtils;
    }

    /// @dev Get the Finance contract.
    /// @return Finance The Finance contract.
    function finance() public view returns (Finance) {
        return base.finance;
    }

    /// @dev Get the EscrowChallengeCommission contract.
    /// @return EscrowChallengeCommission The EscrowChallengeCommission contract.
    function escrowChallengeCommission()
        public
        view
        returns (EscrowChallengeCommission)
    {
        return base.escrowChallengeCommission;
    }

    /// @dev Get the EscrowDatacapChunkLandCollateral contract.
    /// @return EscrowDatacapChunkLandCollateral The EscrowDatacapChunkLandCollateral contract.
    function escrowDatacapChunkLandCollateral()
        public
        view
        returns (EscrowDatacapChunkLandCollateral)
    {
        return base.escrowDatacapChunkLandCollateral;
    }

    /// @dev Get the EscrowDatacapCollateral contract.
    /// @return EscrowDatacapCollateral The EscrowDatacapCollateral contract.
    function escrowDatacapCollateral()
        public
        view
        returns (EscrowDatacapCollateral)
    {
        return base.escrowDatacapCollateral;
    }

    /// @dev Get the EscrowDataTradingFee contract.
    /// @return EscrowDataTradingFee The EscrowDataTradingFee contract.
    function escrowDataTradingFee() public view returns (EscrowDataTradingFee) {
        return base.escrowDataTradingFee;
    }

    /// @dev Get the Datasets contract.
    /// @return Datasets The Datasets contract.
    function datasets() public view returns (Datasets) {
        return base.datasets;
    }

    /// @dev Get the DatasetsProof contract.
    /// @return DatasetsProof The DatasetsProof contract.
    function datasetsProof() public view returns (DatasetsProof) {
        return base.datasetsProof;
    }

    /// @dev Get the DatasetsChallenge contract.
    /// @return DatasetsChallenge The DatasetsChallenge contract.
    function datasetsChallenge() public view returns (DatasetsChallenge) {
        return base.datasetsChallenge;
    }

    /// @dev Get the DatasetsRequirement contract.
    /// @return DatasetsRequirement The DatasetsRequirement contract.
    function datasetsRequirement() public view returns (DatasetsRequirement) {
        return base.datasetsRequirement;
    }

    /// @dev Get the Matchings contract.
    /// @return Matchings The Matchings contract.
    function matchings() public view returns (Matchings) {
        return base.matchings;
    }

    /// @dev Get the MatchingsTarget contract.
    /// @return MatchingsTarget The MatchingsTarget contract.
    function matchingsTarget() public view returns (MatchingsTarget) {
        return base.matchingsTarget;
    }

    /// @dev Get the MatchingsBids contract.
    /// @return MatchingsBids The MatchingsBids contract.
    function matchingsBids() public view returns (MatchingsBids) {
        return base.matchingsBids;
    }
}
