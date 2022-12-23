// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {WhiteElephantNFT} from "./WhiteElephantNFT.sol";

contract WhiteElephant {
    WhiteElephantNFT public nft;

    struct Game {
        address[] participants;
        uint256 nonce;
    }

    // used to prevent stealing back immediately
    // cannot be stollen if curRound == round
    // and trying to steal lastStolenID
    struct LastStealInfo {
        // which NFT was last stole
        uint64 lastStolenID;
        uint8 round;
    }

    struct GameState {
        // starts at 0
        // for whose turn, use participants[round - 1]
        uint8 round;
        bool gameOver;
        // used to track turns after a steal
        address nextToGo;
        LastStealInfo lastStealInfo;
    }

    mapping(bytes32 => GameState) internal _state;
    // how many times has a tokenID been stolen
    mapping(uint256 => uint256) public timesStolen;
    // what game does a token belong to
    mapping(uint256 => bytes32) public tokenGameID;

    /// @dev when game already Exists
    error GameExists();
    /// @dev when msg.sender is not up to go
    error NotTurn();
    error InvalidTokenIDForGame();
    error MaxSteals();
    error JustStolen();
    error GameOver();

    event StartGame(bytes32 indexed gameID, Game game);
    event Open(bytes32 indexed gameID, address indexed player, uint256 indexed tokenId);
    event Steal(bytes32 indexed gameID, address indexed stealer, uint256 indexed tokenId, address stolenFrom);

    /// @dev doesn't check for participants
    /// address(0) or incorrect address could leave game
    // unable to progress
    function startGame(Game calldata game) external returns (bytes32 _gameID) {
        _gameID = gameID(game);

        if (_state[_gameID].round != 0) {
            revert GameExists();
        }

        _state[_gameID].round = 1;

        emit StartGame(_gameID, game);
    }

    function open(Game calldata game) external {
        bytes32 _gameID = gameID(game);
        if (_state[_gameID].gameOver) {
            revert GameOver();
        }

        if (!_isTurn(_gameID, game)) {
            revert NotTurn();
        }

        uint8 newRoundCount = _state[_gameID].round + 1;
        _state[_gameID].round = newRoundCount;
        if (newRoundCount > game.participants.length) {
            _state[_gameID].gameOver = true;
        }

        _state[_gameID].nextToGo = address(0);

        uint256 tokenID = nft.mint(msg.sender);
        tokenGameID[tokenID] = _gameID;

        emit Open(_gameID, msg.sender, tokenID);
    }

    function steal(Game calldata game, uint256 tokenID) external {
        bytes32 _gameID = gameID(game);
        if (_state[_gameID].gameOver) {
            revert GameOver();
        }

        if (!_isTurn(_gameID, game)) {
            revert NotTurn();
        }

        if (_gameID != tokenGameID[tokenID]) {
            revert InvalidTokenIDForGame();
        }

        if (timesStolen[tokenID] == 2) {
            revert MaxSteals();
        }

        uint8 currentRound = _state[_gameID].round;
        if (currentRound == _state[_gameID].lastStealInfo.round) {
            if (_state[_gameID].lastStealInfo.lastStolenID == tokenID) {
                revert JustStolen();
            }
        }

        timesStolen[tokenID] += 1;
        _state[_gameID].lastStealInfo = LastStealInfo({lastStolenID: uint64(tokenID), round: currentRound});

        address currentOwner = nft.ownerOf(tokenID);
        _state[_gameID].nextToGo = currentOwner;

        nft.steal(currentOwner, msg.sender, tokenID);

        emit Steal(_gameID, msg.sender, tokenID, currentOwner);
    }

    function gameID(Game calldata game) public view returns (bytes32) {
        return keccak256(abi.encode(game));
    }

    function state(bytes32 _gameID) external view returns (GameState memory) {
        return _state[_gameID];
    }

    function _isTurn(bytes32 _gameID, Game calldata game) internal view returns (bool) {
        address next = _state[_gameID].nextToGo;
        if (next != address(0)) return msg.sender == next;

        return msg.sender == game.participants[_state[_gameID].round - 1];
    }
}
