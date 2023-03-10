// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "forge-std/Test.sol";
import {Strings} from "lib/openzeppelin-contracts/contracts/utils/Strings.sol";

import {NounishERC721} from "../src/base/NounishERC721.sol";
import {NounishChristmasMetadata, NounishDescriptors} from "../src/NounishChristmasMetadata.sol";
import {SevenThroughNineteenCharacterRenderHelper} from
    "../src/CharacterContracts/SevenThroughNineteenCharacterRenderHelper.sol";
import {TwentyThroughTwentyEightCharacterRenderHelper} from
    "../src/CharacterContracts/TwentyThroughTwentyEightCharacterRenderHelper.sol";
import {TwentyNineThroughThirtyTwoCharacterRenderHelper} from
    "../src/CharacterContracts/TwentyNineThroughThirtyTwoCharacterRenderHelper.sol";

contract saveSVGs is Script, Test {
    using Strings for uint256;

    function run() public {
        string memory rootPath = vm.projectRoot();
        NounishChristmasMetadata metadata = new NounishChristmasMetadata(
            new SevenThroughNineteenCharacterRenderHelper(),
            new TwentyThroughTwentyEightCharacterRenderHelper(),
            new TwentyNineThroughThirtyTwoCharacterRenderHelper()
        );

        string memory s;
        for (uint8 character = 1; character < 33; character++) {
            for (uint8 tint = 1; tint < 2; tint++) {
                for (uint8 backgroundColor = 1; backgroundColor < 2; backgroundColor++) {
                    for (uint8 noggleType = 1; noggleType < 4; noggleType++) {
                        for (uint8 noggleColor = 1; noggleColor < 2; noggleColor++) {
                            s = string(
                                metadata.svg(
                                    NounishERC721.Info({
                                        character: character,
                                        tint: tint,
                                        backgroundColor: backgroundColor,
                                        noggleType: noggleType,
                                        noggleColor: noggleColor,
                                        owner: address(0)
                                    })
                                )
                            );
                            // emit log_string(s);
                            emit log_string(rootPath);
                            vm.writeFile(
                                string.concat(
                                    rootPath,
                                    "/check/",
                                    NounishDescriptors.tintColorName(tint),
                                    "-",
                                    NounishDescriptors.characterName(character),
                                    "-",
                                    NounishDescriptors.noggleColorName(noggleColor),
                                    "-",
                                    NounishDescriptors.noggleTypeName(noggleType),
                                    "-",
                                    NounishDescriptors.backgroundColorName(backgroundColor),
                                    ".svg"
                                ),
                                s
                            );
                        }
                    }
                }
            }
        }
    }
}
