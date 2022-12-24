// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {NounishERC721} from "./base/NounishERC721.sol";
import {NounishDescriptors} from "./libraries/NounishDescriptors.sol";

contract NounishChristmasMetadata {
    // name
    // background
    // noggle type
    // 
    function attributes(NounishERC721.Info calldata info) external returns (string memory) {
        return string.concat(
            '[',
            _traitTypeString('character', NounishDescriptors.characterName(info.character)),
            ',',
            _traitTypeString('tint', NounishDescriptors.tintColorName(info.tint)),
            ',',
            _traitTypeString('noggle', NounishDescriptors.noggleTypeName(info.noggleType)),
            ',',
            _traitTypeString('noggle color', NounishDescriptors.noggleColorName(info.noggleColor)),
            ',',
            _traitTypeString('background color', NounishDescriptors.backgroundColorName(info.backgroundColor)),
            ']'
        );
    }

    function _traitTypeString(string memory t, string memory v) internal returns (string memory) {
        return string.concat(
            '{',
            '"trait_type": "',
            t,
            '",',
            '"value": "',
            v,
            '"}'
        );
    }
}

