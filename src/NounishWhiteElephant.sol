// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {WhiteElephant} from './WhiteElephant.sol';
import {NounishChristmasNFT} from './NounishChristmasNFT.sol';

contract NounishWhiteElephant is WhiteElephant {
    constructor() {
        nft = new NounishChristmasNFT();
    }
}