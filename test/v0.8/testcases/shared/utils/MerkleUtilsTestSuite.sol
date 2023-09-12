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

// Import required external contracts and interfaces
import {Test} from "forge-std/Test.sol";
import {Roles} from "src/v0.8/core/access/Roles.sol";
import {MerkleUtils} from "src/v0.8/shared/utils/merkle/MerkleUtils.sol";
import {TestCaseBase} from "test/v0.8/testcases/module/abstract/TestCaseBase.sol";

contract MerkleUtilsTestCaseWithSuccess is TestCaseBase, Test {
    function action(uint64) internal virtual override {
        uint32 path = 130340;
        bytes32 root = 0x03b2ed13af20471b3eea52c329c29bba17568ecf0190f50c9e675cf5a453b813;
        bytes32 leaf = 0xd16db83468a3d1671cb9764b3c940a0fc46f7e00e347534085c1da62dbbdbf34;

        bytes32[] memory siblings = new bytes32[](18);

        siblings[0] = bytes32(
            0xd2926710e9c21d36c42b334e28e1fd679f15e55668e9767819a223b1b011a21f
        );
        siblings[1] = bytes32(
            0xe18ece02f2f2d3ca745adff0d93bd65b0389f9b0b20fcc9f8a9159e1d7278a2d
        );
        siblings[2] = bytes32(
            0x99f2d01532e2516c54037a7833af67f8d75f204b2b750638b51239315ac7cb3d
        );
        siblings[3] = bytes32(
            0xe427606a9131d4cf74a4c8b27de941c3f7c5b5eacc86de5f4ed603c7ec012519
        );
        siblings[4] = bytes32(
            0x8ebbb695bf75ed65a86db06c729223433f9d1a218d04bd061a565b0ec6a65a15
        );

        siblings[5] = bytes32(
            0x4997696e7cac36d091d36fcec3576508400cb53adbe763a25be02849c056d00f
        );
        siblings[6] = bytes32(
            0x1bf8733ce713a6bca25dd1df4205b2a7a3b19adfae616f2eb1c099137de13422
        );
        siblings[7] = bytes32(
            0x8dd1633c8e1f04b4abb6af2fb61451fe8cdad2875a4bc74b73c0c8ff9a12ce3d
        );
        siblings[8] = bytes32(
            0xf9931180bcf6cfc95c670332ecb1199073644699464f424b60d30deddcf1900e
        );
        siblings[9] = bytes32(
            0xec34f4239c3346cb952f8a8673a8695e2ac9a173bb7d3dd2bf6f65070d58263e
        );

        siblings[10] = bytes32(
            0x3202f30e56ba87a9005275e4e2313772afb92f0018268692026f78f647a3ef13
        );
        siblings[11] = bytes32(
            0x913ab6e232d3e9cff21e4dc37f4e0f95c9cd9eda6814a47b1a5c1c7d5d3b4d3f
        );
        siblings[12] = bytes32(
            0x667385491f40f3246e8098bd2206157ef43f0619b650e506993edc22b72b1c07
        );
        siblings[13] = bytes32(
            0xe28a30709c6e9ee8cc64231ae746480fecfe9b99082be1aa0151a3eb5478e31d
        );
        siblings[14] = bytes32(
            0xe218751512364f4de52286c3c8d0dd7227e5dabeb2d706b2814d5dc0c4167d33
        );

        siblings[15] = bytes32(
            0x18f48d99730104bc1f3c3dfec22959ea1cb2e7695e8210267aaf0dc5846f9d1a
        );
        siblings[16] = bytes32(
            0xb89a29128723590583d0c8d12945a62916c0ba54bf61bde81d0bf0c788946621
        );
        siblings[17] = bytes32(
            0xcee5fbb1d273cc6fec5593492c822f5b7bc69fc57bebf163644da4a79086ff35
        );
        Roles role = new Roles();
        role.initialize();
        MerkleUtils merkleUtils = new MerkleUtils();
        merkleUtils.initialize(address(role));
        assert(
            merkleUtils.isValidMerkleProof(root, leaf, siblings, path) == true
        );
    }
}
