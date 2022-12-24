// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";

import "../src/NounishWhiteElephant.sol";
import {NounishChristmasMetadata} from "../src/NounishChristmasMetadata.sol";
import {SevenThroughNineteenCharacterRenderHelper} from
    "../src/CharacterContracts/SevenThroughNineteenCharacterRenderHelper.sol";
import {TwentyThroughTwentyEightCharacterRenderHelper} from
    "../src/CharacterContracts/TwentyThroughTwentyEightCharacterRenderHelper.sol";
import {TwentyNineThroughThirtyTwoCharacterRenderHelper} from
    "../src/CharacterContracts/TwentyNineThroughThirtyTwoCharacterRenderHelper.sol";

contract NounishWhiteElephantScript is Script {
    function setUp() public {}

    function run() public {
        uint256 pk = vm.envUint("GOERLI_PRIVATE_KEY");
        address deployer = vm.addr(pk);
        vm.startBroadcast();
        NounishWhiteElephant whiteElephant =
        new NounishWhiteElephant(0.01 ether, 1672531199, new NounishChristmasMetadata(
            new SevenThroughNineteenCharacterRenderHelper(),
            new TwentyThroughTwentyEightCharacterRenderHelper(),
            new TwentyNineThroughThirtyTwoCharacterRenderHelper()
        ));
        address[] memory participants = new address[](3);
        participants[0] = address(deployer);
        participants[1] = address(0xCC692D6E11268B40A1E3C58e3D86Fc4CAAb9b77a);
        participants[2] = address(0x4298e663517593284Ad4FE199b21815BD48a9969);
        WhiteElephant.Game memory game = WhiteElephant.Game({participants: participants, nonce: block.timestamp});
        whiteElephant.startGame{value: 0.3 ether}(game);
        whiteElephant.open(game);
        whiteElephant.setOwner(0xbc3ed6B537f2980e66f396Fe14210A56ba3f72C4);
    }
}
