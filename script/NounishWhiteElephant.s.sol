// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "forge-std/Test.sol";

import "../src/NounishWhiteElephant.sol";
import {NounishChristmasMetadata} from "../src/NounishChristmasMetadata.sol";
import {SevenThroughNineteenCharacterRenderHelper} from
    "../src/CharacterContracts/SevenThroughNineteenCharacterRenderHelper.sol";
import {TwentyThroughTwentyEightCharacterRenderHelper} from
    "../src/CharacterContracts/TwentyThroughTwentyEightCharacterRenderHelper.sol";
import {TwentyNineThroughThirtyTwoCharacterRenderHelper} from
    "../src/CharacterContracts/TwentyNineThroughThirtyTwoCharacterRenderHelper.sol";

contract NounishWhiteElephantScript is Script, Test {
    function setUp() public {}

    function run() public {
        vm.startBroadcast();
        NounishWhiteElephant whiteElephant = new NounishWhiteElephant(0.01 ether, 1672531199, new NounishChristmasMetadata(
            new SevenThroughNineteenCharacterRenderHelper(),
            new TwentyThroughTwentyEightCharacterRenderHelper(),
            new TwentyNineThroughThirtyTwoCharacterRenderHelper()
        ));
        whiteElephant.setOwner(0xbF8060106D2e83C106915A575BaeA3dc90c892a6);
    }

}
