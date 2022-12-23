// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

interface Mintable {
    function mint(address to) external returns (uint256);
}

contract WhiteElephant {
    Mintable nft;
    
    struct Game {
        address[] participants;
        uint256 nonce;
    }

    // used to prevent stealing back immediately
    // cannot be stollen if curRound == round
    // and trying to steal lastStolenId
    struct LastStealInfo {
        // which NFT was last stole
        uint64 lastStolenId;
        uint8 round;
    }

    struct ItemInfo {
        address owner;
        uint96 timesStolen;
    }

    struct GameState {
        // starts at 0
        // for whose turn, use participants[round - 1]
        uint8 round;
        // how many NFTs have been opened
        // cannot exceed participants 
        uint8 opened;
        // used to track turns after a steal
        address nextToGo;
        LastStealInfo lastStealInfo;
    }

    mapping(bytes32 => GameState) internal _state;
    mapping(bytes32 => mapping(uint256 => ItemInfo)) internal _itemInfo;
    mapping(uint256 => uint256) public timesStolen;
    mapping(uint256 => bytes32) public tokenGameID;

    /// @dev when game already exisits
    error GameExisits();
    /// @dev when msg.sender is not up to go
    error NotTurn();
    error InvalidTokenIDForGame();
    error MaxSteals();

    event StartGame(bytes32 indexed gameID, Game game);
    event Open(bytes32 indexed gameID, address indexed player, uint256 indexed tokenId);

    /// @dev doesn't check for participants
    /// address(0) or incorrect address could leave game
    // unable to progress 
    function startGame(Game calldata game) external returns (bytes32 _gameID) {
        _gameID = gameID(game);

        if (_state[_gameID].round != 0) {
            revert GameExisits();
        }

        _state[_gameID].round = 1;

        emit StartGame(_gameID, game);
    }

    function open(Game calldata game) external {
        bytes32 _gameID = gameID(game);
        if (!_isTurn(_gameID, game)) {
            revert NotTurn();
        }

        uint256 tokenID = nft.mint(msg.sender);

        emit Open(_gameID, msg.sender, tokenID);
    }

    function steal(Game calldata game, uint256 tokenID) external {
        bytes32 _gameID = gameID(game);
        if (!_isTurn(_gameID, game)) {
            revert NotTurn();
        }

        if (_gameID != tokenGameID[tokenID]) {
            revert InvalidTokenIDForGame();
        }

        if (timesStolen[tokenID] == 2) {
            revert MaxSteals();
        }

        address currentOwner = nft.ownerOf(tokenID);
        _state[_gameID].nextToGo = currentOwner;

        
    }

    function gameID(Game calldata game) public view returns (bytes32) {
        return keccak256(abi.encode(game));
    }

    function _isTurn(bytes32 _gameID, Game calldata game) internal view returns (bool) {
        address next = _state[_gameID].nextToGo;
        if (next != address(0)) return msg.sender == next;

        return msg.sender == game.participants[_state[_gameID].round - 1];
    }
}
