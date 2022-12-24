// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Test.sol";

import {NounishERC721} from "../src/base/NounishERC721.sol";
import {NounishChristmasMetadata} from "../src/NounishChristmasMetadata.sol";

contract NounishChristmasMetadataTest is Test {
    NounishChristmasMetadata metadata = new NounishChristmasMetadata();

    function testAttributes() public {
        emit log_string(metadata.attributes(NounishERC721.Info({character: 1, tint: 1, backgroundColor: 1, noggleType: 1, noggleColor: 1, owner: address(0)})));
    }
}