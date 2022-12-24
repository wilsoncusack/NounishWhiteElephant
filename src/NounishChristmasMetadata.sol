// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Strings} from "lib/openzeppelin-contracts/contracts/utils/Strings.sol";
import {Base64} from "base64/base64.sol";

import {NounishERC721} from "./base/NounishERC721.sol";
import {NounishDescriptors} from "./libraries/NounishDescriptors.sol";
import {ICharacterSVGRenderer} from "./interfaces/ICharacterSVGRenderer.sol";

contract NounishChristmasMetadata {
    using Strings for uint256;

    ICharacterSVGRenderer characterRenderHelper1;
    ICharacterSVGRenderer characterRenderHelper2;
    // CharacterSVGRender render3;

    constructor(ICharacterSVGRenderer renderHelper1, ICharacterSVGRenderer renderHelper2) {
        characterRenderHelper1 = renderHelper1;
        characterRenderHelper2 = renderHelper2;
        // render2 = _render2;
        // render3 = _render3;
    }

    function tokenURI(uint256 id, NounishERC721.Info calldata info) external view returns (string memory) {
        return string(
            string.concat(
                "data:application/json;base64,",
                Base64.encode(
                    bytes(
                        abi.encodePacked(
                            '{"name":"' "#",
                            id.toString(),
                            " - ",
                            NounishDescriptors.tintColorName(info.tint),
                            " ",
                            NounishDescriptors.characterName(info.character),
                            '", "description":"',
                            "Nounish Christmas NFTs are created by playing the Nounish White Elephant game, where players can open new NFTs by minting and steal opened NFTs from others.",
                            '", "attributes": ',
                            attributes(info),
                            ', "image": "' "data:image/svg+xml;base64,",
                            Base64.encode(svg(info)),
                            '"}'
                        )
                    )
                )
            )
        );
    }

    function svg(NounishERC721.Info calldata info) public view returns (bytes memory) {
        return abi.encodePacked(
            '<svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">',
            '<style type="text/css">',
            ".noggles{fill:#",
            NounishDescriptors.noggleColorHex(info.noggleColor),
            ";}",
            ".tintable{fill:#",
            NounishDescriptors.tintColorHex(info.tint),
            ";}",
            "</style>",
            '<rect x="0" y="0" width="24" height="24" fill="#',
            NounishDescriptors.backgroundColorHex(info.backgroundColor),
            '"/>',
            characterSVG(info.character),
            NounishDescriptors.noggleTypeSVG(info.noggleType),
            "</svg>"
        );
    }

    function attributes(NounishERC721.Info calldata info) public view returns (string memory) {
        return string.concat(
            "[",
            _traitTypeString("character", NounishDescriptors.characterName(info.character)),
            ",",
            _traitTypeString("tint", NounishDescriptors.tintColorName(info.tint)),
            ",",
            _traitTypeString("noggle", NounishDescriptors.noggleTypeName(info.noggleType)),
            ",",
            _traitTypeString("noggle color", NounishDescriptors.noggleColorName(info.noggleColor)),
            ",",
            _traitTypeString("background color", NounishDescriptors.backgroundColorName(info.backgroundColor)),
            "]"
        );
    }

    function characterSVG(uint8 character) public view returns (string memory) {
        if (character < 7) {
            return NounishDescriptors.characterSVG(character);
        } else if (character < 20) {
            return characterRenderHelper1.characterSVG(character);
        } else {
            return characterRenderHelper2.characterSVG(character);
        }
    }

    function _traitTypeString(string memory t, string memory v) internal pure returns (string memory) {
        return string.concat("{", '"trait_type": "', t, '",', '"value": "', v, '"}');
    }
}
