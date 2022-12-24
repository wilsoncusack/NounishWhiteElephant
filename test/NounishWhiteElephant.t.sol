// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import {ERC721} from "solmate/tokens/ERC721.sol";

import "../src/NounishWhiteElephant.sol";
import {ICharacterSVGRenderer} from "../src/interfaces/ICharacterSVGRenderer.sol";

contract NounishWhiteElephantTest is Test {
    event Open(bytes32 indexed gameID, address indexed player, uint256 indexed tokenId);
    event Steal(bytes32 indexed gameID, address indexed stealer, uint256 indexed tokenId, address stolenFrom);

    NounishWhiteElephant public whiteElephant;
    ICharacterSVGRenderer renderHelper = ICharacterSVGRenderer(address(1));
    WhiteElephant.Game game;

    function setUp() public {
        whiteElephant =
            new NounishWhiteElephant(0, block.timestamp + 1, new NounishChristmasMetadata(renderHelper, renderHelper));
        address[] memory participants = new address[](3);
        participants[0] = address(1);
        participants[1] = address(2);
        participants[2] = address(3);
        game = WhiteElephant.Game({participants: participants, nonce: block.timestamp});
    }

    /// start game ///
    function testRevertsIfFeeInsufficient() public {
        whiteElephant =
        new NounishWhiteElephant(0.01 ether, block.timestamp + 1, new NounishChristmasMetadata(renderHelper, renderHelper));
        vm.deal(address(this), 1 ether);
        vm.expectRevert(NounishWhiteElephant.InsufficientPayment.selector);
        whiteElephant.startGame{value: 0.001 ether * 3}(game);
    }

    function testDoesNotRevertsIfFeeSufficient() public {
        whiteElephant =
        new NounishWhiteElephant(0.01 ether, block.timestamp + 1 days, new NounishChristmasMetadata(renderHelper, renderHelper));
        vm.deal(address(this), 1 ether);
        whiteElephant.startGame{value: 0.01 ether * 3}(game);
        bytes32 id = whiteElephant.gameID(game);
        assertEq(1, whiteElephant.state(id).round);
    }

    function testRevertsIfPastEndTimestamp() public {
        whiteElephant =
        new NounishWhiteElephant(0.01 ether, block.timestamp - 1, new NounishChristmasMetadata(renderHelper, renderHelper));
        vm.expectRevert(NounishWhiteElephant.DoneForNow.selector);
        whiteElephant.startGame(game);
    }

    /// transferFees ///

    function testTransferFeesFailsIfNotOwner() public {
        vm.startPrank(address(1));
        vm.expectRevert("UNAUTHORIZED");
        whiteElephant.transferFees(address(this), 1);
    }

    function testTransferFeesWorks() public {
        whiteElephant =
        new NounishWhiteElephant(0.01 ether, block.timestamp + 1, new NounishChristmasMetadata(renderHelper, renderHelper));
        vm.deal(address(this), 1 ether);
        whiteElephant.startGame{value: 0.01 ether * 3}(game);
        whiteElephant.transferFees(address(1), 0.03 ether);
        assertEq(address(1).balance, 0.03 ether);
    }

    /// update metadata ///

    /// set end timestamp ///

    /// open ///

    function testOpenTransfersNFT() public {
        bytes32 id = whiteElephant.startGame(game);
        assertEq(whiteElephant.nft().balanceOf(address(1)), 0);
        vm.prank(address(1));
        whiteElephant.open(game);
        assertEq(whiteElephant.nft().balanceOf(address(1)), 1);
        NounishChristmasNFT nft = NounishChristmasNFT(address(whiteElephant.nft()));
        assertTrue(nft.nftInfo(0).character > 0);
        assertTrue(nft.nftInfo(0).tint > 0);
        assertTrue(nft.nftInfo(0).backgroundColor > 0);
        assertTrue(nft.nftInfo(0).noggleColor > 0);
        assertTrue(nft.nftInfo(0).noggleType > 0);
    }

    function testOpenSetsTokenGameID() public {
        bytes32 id = whiteElephant.startGame(game);
        vm.prank(address(1));
        whiteElephant.open(game);
        assertEq(whiteElephant.tokenGameID(0), id);
        vm.prank(address(2));
        whiteElephant.open(game);
        assertEq(whiteElephant.tokenGameID(1), id);
    }

    function testOpenUpdatesRound() public {
        bytes32 id = whiteElephant.startGame(game);
        vm.prank(address(1));
        whiteElephant.open(game);
        assertEq(whiteElephant.state(id).round, 2);
    }

    function testClearsNextToGo() public {
        bytes32 id = whiteElephant.startGame(game);
        vm.prank(address(1));
        whiteElephant.open(game);
        assertEq(whiteElephant.state(id).nextToGo, address(0));
    }

    function testEmitsOpen() public {
        bytes32 id = whiteElephant.startGame(game);
        vm.startPrank(address(1));
        vm.expectEmit(true, true, true, false);
        emit Open(id, address(1), 0);
        whiteElephant.open(game);
    }

    function testOpenRevertsIfCallerNotInGame() public {
        bytes32 id = whiteElephant.startGame(game);
        vm.expectRevert(WhiteElephant.NotTurn.selector);
        whiteElephant.open(game);
    }

    function testOpenRevertsIfCallerNotNextToGo() public {
        bytes32 id = whiteElephant.startGame(game);
        vm.prank(address(1));
        whiteElephant.open(game);
        vm.prank(address(2));
        whiteElephant.steal(game, 0);
        vm.prank(address(3));
        vm.expectRevert(WhiteElephant.NotTurn.selector);
        whiteElephant.open(game);
    }

    function testOpenRevertsIfNotCallerTurn() public {
        bytes32 id = whiteElephant.startGame(game);
        vm.prank(address(1));
        whiteElephant.open(game);
        vm.prank(address(3));
        vm.expectRevert(WhiteElephant.NotTurn.selector);
        whiteElephant.open(game);
    }

    function testOpenRevertsIfGameOver() public {
        address[] memory participants = new address[](1);
        participants[0] = address(1);
        game.participants = participants;
        bytes32 id = whiteElephant.startGame(game);
        vm.prank(address(1));
        whiteElephant.open(game);
        vm.expectRevert(WhiteElephant.GameOver.selector);
        whiteElephant.open(game);
    }

    function testOpenRevertsIfPastEndTimestamp() public {
        bytes32 id = whiteElephant.startGame(game);
        vm.warp(block.timestamp + 2);
        vm.expectRevert(NounishWhiteElephant.DoneForNow.selector);
        whiteElephant.open(game);
    }

    /// steal ///

    function testStealTransfersNFT() public {
        bytes32 id = whiteElephant.startGame(game);
        vm.prank(address(1));
        whiteElephant.open(game);
        vm.prank(address(2));
        whiteElephant.steal(game, 0);
        assertEq(whiteElephant.nft().ownerOf(0), address(2));
    }

    function testStealDoesNotUpdateRound() public {
        bytes32 id = whiteElephant.startGame(game);
        vm.prank(address(1));
        whiteElephant.open(game);
        uint256 roundBefore = whiteElephant.state(id).round;
        vm.prank(address(2));
        whiteElephant.steal(game, 0);
        assertEq(roundBefore, whiteElephant.state(id).round);
    }

    function testStealUpdatesNextUp() public {
        bytes32 id = whiteElephant.startGame(game);
        vm.prank(address(1));
        whiteElephant.open(game);
        vm.prank(address(2));
        whiteElephant.steal(game, 0);
        assertEq(address(1), whiteElephant.state(id).nextToGo);
    }

    function testStealUpdatesLastStealInfo() public {
        bytes32 id = whiteElephant.startGame(game);
        vm.prank(address(1));
        whiteElephant.open(game);
        vm.prank(address(2));
        whiteElephant.steal(game, 0);
        assertEq(0, whiteElephant.state(id).lastStealInfo.lastStolenID);
        assertEq(2, whiteElephant.state(id).lastStealInfo.round);
    }

    function testStealDoesNotAllowStealingSameGiftBack() public {
        bytes32 id = whiteElephant.startGame(game);
        vm.prank(address(1));
        whiteElephant.open(game);
        vm.prank(address(2));
        whiteElephant.steal(game, 0);
        vm.startPrank(address(1));
        vm.expectRevert(WhiteElephant.JustStolen.selector);
        whiteElephant.steal(game, 0);
    }

    function testStealDoesAllowStealingGiftInNextRound() public {
        bytes32 id = whiteElephant.startGame(game);
        vm.prank(address(1));
        whiteElephant.open(game);
        vm.prank(address(2));
        whiteElephant.steal(game, 0);
        vm.prank(address(1));
        whiteElephant.open(game);
        vm.prank(address(3));
        whiteElephant.steal(game, 0);
    }

    function testStealRevertsIfInvalidId() public {
        bytes32 id = whiteElephant.startGame(game);
        vm.expectRevert(WhiteElephant.NotTurn.selector);
        whiteElephant.steal(game, 0);
    }

    function testStealRevertsIfCallerNotInGame() public {
        bytes32 id = whiteElephant.startGame(game);
        vm.prank(address(1));
        vm.expectRevert(WhiteElephant.InvalidTokenIDForGame.selector);
        whiteElephant.steal(game, 0);
    }

    function testStealRevertsIfCallerNotNextToGo() public {
        bytes32 id = whiteElephant.startGame(game);
        vm.prank(address(1));
        whiteElephant.open(game);
        vm.prank(address(2));
        whiteElephant.steal(game, 0);
        vm.prank(address(3));
        vm.expectRevert(WhiteElephant.NotTurn.selector);
        whiteElephant.steal(game, 0);
    }

    function testStealRevertsIfNotCallerTurn() public {
        bytes32 id = whiteElephant.startGame(game);
        vm.prank(address(1));
        whiteElephant.open(game);
        vm.prank(address(3));
        vm.expectRevert(WhiteElephant.NotTurn.selector);
        whiteElephant.steal(game, 0);
    }

    function testStealRevertsIfGameOver() public {
        address[] memory participants = new address[](1);
        participants[0] = address(1);
        game.participants = participants;
        bytes32 id = whiteElephant.startGame(game);
        vm.prank(address(1));
        whiteElephant.open(game);
        vm.expectRevert(WhiteElephant.GameOver.selector);
        whiteElephant.steal(game, 0);
    }

    function testStealRevertsIfMaxSteals() public {
        address[] memory participants = new address[](4);
        participants[0] = address(1);
        participants[1] = address(2);
        participants[2] = address(3);
        participants[3] = address(4);
        game.participants = participants;
        bytes32 id = whiteElephant.startGame(game);
        vm.prank(address(1));
        whiteElephant.open(game);
        vm.prank(address(2));
        whiteElephant.steal(game, 0);
        vm.prank(address(1));
        whiteElephant.open(game);
        vm.prank(address(3));
        whiteElephant.steal(game, 0);
        vm.prank(address(2));
        whiteElephant.open(game);
        vm.startPrank(address(4));
        vm.expectRevert(WhiteElephant.MaxSteals.selector);
        whiteElephant.steal(game, 0);
    }

    function testStealRevertsIfPastEndTimestamp() public {
        bytes32 id = whiteElephant.startGame(game);
        vm.warp(block.timestamp + 2);
        vm.expectRevert(NounishWhiteElephant.DoneForNow.selector);
        whiteElephant.steal(game, 0);
    }

    // NFT

    function testCannotTransferDuringGame() public {
        bytes32 id = whiteElephant.startGame(game);
        vm.startPrank(address(1));
        whiteElephant.open(game);
        ERC721 nft = whiteElephant.nft();
        vm.expectRevert("GAME_IN_PROGRESS");
        nft.transferFrom(address(1), address(2), 0);
    }

    function testCanTransferAfterGame() public {
        bytes32 id = whiteElephant.startGame(game);
        vm.prank(address(1));
        whiteElephant.open(game);
        vm.prank(address(2));
        whiteElephant.open(game);
        vm.prank(address(3));
        whiteElephant.open(game);
        ERC721 nft = whiteElephant.nft();
        vm.prank(address(1));
        nft.transferFrom(address(1), address(2), 0);
        assertEq(nft.ownerOf(0), address(2));
    }
}
