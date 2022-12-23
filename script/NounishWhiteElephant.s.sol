// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";

import "../src/NounishWhiteElephant.sol";

contract NounishWhiteElephantScript is Script {
    function setUp() public {}

    function run() public {
        vm.broadcast();
        new NounishWhiteElephant(0.01 ether);
    }
}
