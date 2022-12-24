// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Test.sol";

import {NounishERC721} from "../src/base/NounishERC721.sol";
import {NounishChristmasMetadata} from "../src/NounishChristmasMetadata.sol";
import {SevenThroughNineteenCharacterRenderHelper} from
    "../src/CharacterContracts/SevenThroughNineteenCharacterRenderHelper.sol";
import {TwentyThroughTwentyEightCharacterRenderHelper} from
    "../src/CharacterContracts/TwentyThroughTwentyEightCharacterRenderHelper.sol";
import {TwentyNineThroughThirtyTwoCharacterRenderHelper} from
    "../src/CharacterContracts/TwentyNineThroughThirtyTwoCharacterRenderHelper.sol";

contract NounishChristmasMetadataTest is Test {
    NounishChristmasMetadata metadata;

    function setUp() public {
        metadata = new NounishChristmasMetadata(
            new SevenThroughNineteenCharacterRenderHelper(),
            new TwentyThroughTwentyEightCharacterRenderHelper(),
            new TwentyNineThroughThirtyTwoCharacterRenderHelper()
        );
    }

    function testAttributes() public {
        emit log_string(
            metadata.attributes(
                keccak256(abi.encode("")),
                NounishERC721.Info({
                    character: 1,
                    tint: 1,
                    backgroundColor: 1,
                    noggleType: 1,
                    noggleColor: 1,
                    owner: address(0)
                })
            )
            );
    }

    function testSvg() public {
        string memory s = string(
            metadata.svg(
                NounishERC721.Info({
                    character: 29,
                    tint: 1,
                    backgroundColor: 1,
                    noggleType: 1,
                    noggleColor: 1,
                    owner: address(0)
                })
            )
        );
        emit log_string(s);
        string[] memory inputs = new string[](4);
        inputs[0] = "echo";
        inputs[1] = "yooo";
        // ABI encoded "gm", as a hex string
        inputs[2] = ">";
        inputs[3] = "test.svg";
        // vm.ffi(inputs);
    }

    function testTokenURI() public {
        emit log_string(
            string(
                metadata.tokenURI(
                    1,
                    keccak256(abi.encode("1")),
                    NounishERC721.Info({
                        character: 1,
                        tint: 1,
                        backgroundColor: 1,
                        noggleType: 1,
                        noggleColor: 1,
                        owner: address(0)
                    })
                )
            )
            );
    }
}
