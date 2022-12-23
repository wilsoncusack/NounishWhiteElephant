// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Owned} from "solmate/auth/Owned.sol";

import {WhiteElephantNFT, ERC721} from './WhiteElephantNFT.sol';
import {WhiteElephant} from './WhiteElephant.sol';

contract NounishChristmasNFT is WhiteElephantNFT, Owned {
    uint256 _nonce;
    WhiteElephant whiteElephant;

    constructor() ERC721("Nounish White Elephant Christmas", "NWEC") Owned(msg.sender) {
        whiteElephant = WhiteElephant(msg.sender);
    }

    function mint(address to) external override onlyOwner returns (uint256 id) {
        _mint(to, (id = _nonce++));
        require(id < 1 << 64, 'MAX_MINT');
    }

    /// @dev steal should be guarded as an owner/admin function
    function steal(address from, address to, uint256 id) external override onlyOwner returns (uint256) {
        // Underflow of the sender's balance is impossible because we check for
        // ownership above and the recipient's balance can't realistically overflow.
        unchecked {
            _balanceOf[from]--;

            _balanceOf[to]++;
        }

        _ownerOf[id] = to;

        delete getApproved[id];

        emit Transfer(from, to, id);
    }

    function transferFrom(
        address from,
        address to,
        uint256 id
    ) public override {
        require(whiteElephant.state(whiteElephant.tokenGameID(id)).gameOver, 'GAME_IN_PROGRESS');
    }

    function tokenURI(uint256 id) public view override returns (string memory) {
        return "";
    }
}