// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/WhiteElephant.sol";

contract WhiteElephantTest is Test {
    event StartGame(bytes32 indexed gameID, WhiteElephant.Game game);

    WhiteElephant public whiteElephant;
    WhiteElephant.Game game;

    function setUp() public {
        whiteElephant = new WhiteElephant();
        address[] memory participants = new address[](3);
        participants[0] = address(1);
        participants[1] = address(2);
        participants[2] = address(3);
        game =  WhiteElephant.Game({
            participants: participants,
            nonce: block.timestamp
        });
    }

    /// start game ///

    function testStartGameStarts() public {
        whiteElephant.startGame(game);
        bytes32 id = whiteElephant.gameID(game);
        assertEq(1, whiteElephant.state(id).round);
    }

    function testStartGameEmits() public {
        bytes32 id = whiteElephant.gameID(game);
        vm.expectEmit(true, false, false, true);
        emit StartGame(id, game);
        whiteElephant.startGame(game);
    }

    function testStartGameRevertsIfGameExists() public {
        whiteElephant.startGame(game);
        vm.expectRevert(WhiteElephant.GameExists.selector);
        whiteElephant.startGame(game);
    }
}
