// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/WhiteElephant.sol";

contract WhiteElephantTest is Test {
    WhiteElephant public whiteElephant;

    function setUp() public {
        whiteElephant = new WhiteElephant();
    }
}
