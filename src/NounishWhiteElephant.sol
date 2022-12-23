// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Owned} from "solmate/auth/Owned.sol";
import {SafeTransferLib} from "solmate/utils/SafeTransferLib.sol";

import {WhiteElephant} from "./WhiteElephant.sol";
import {NounishChristmasNFT} from "./NounishChristmasNFT.sol";

contract NounishWhiteElephant is WhiteElephant, Owned {
    error InsufficientPayment();

    uint256 participantFee;

    constructor(uint256 fee) Owned(msg.sender) {
        nft = new NounishChristmasNFT();
        participantFee = fee;
    }

    function startGame(Game calldata game) public payable override returns (bytes32 _gameID) {
        if (msg.value < game.participants.length * participantFee) {
            revert InsufficientPayment();
        }
        return super.startGame(game);
    }

    function transferFees(address to, uint256 amount) external onlyOwner {
        SafeTransferLib.safeTransferETH(to, amount);
    }
}
