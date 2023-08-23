// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.21;

import {IFilecoin} from "../../../interfaces/core/IFilecoin.sol";
import {FilecoinType} from "../../../types/FilecoinType.sol";

contract MockFilecoin is IFilecoin {
    FilecoinType.DealState private mockDealState;

    function setMockDealState(FilecoinType.DealState _state) external {
        mockDealState = _state;
    }

    function getReplicaDealState(
        bytes32,
        uint64
    ) external view override returns (FilecoinType.DealState) {
        return mockDealState;
    }
}
