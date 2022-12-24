// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {WhiteElephantNFT, ERC721} from "./base/WhiteElephantNFT.sol";
import {WhiteElephant} from "./base/WhiteElephant.sol";

contract NounishChristmasNFT is WhiteElephantNFT {
    /* 
    characters:
    1. cardinal
    2. swan
    3. block head
    4. dad
    5. trout sniffer
    6. elf
    7. mothertrucker
    8. hoo
    9. lamp
    10. mean one
    11. miner
    12. mrs claus
    13. noggleman 
    14. noggletree 
    15. nutcracker 
    16. patridge pear tree
    17. rat king
    18. reindeer 
    19. Reindeer Pro
    20. santa
    21. Santa Pro
    22. skeleton 
    23. chunky snowman
    24. slender snowman
    25. Snowman Pro 
    26. sugar plum fairy
    27. short thief 
    28. tall thief
    29. train
    30. christmas tree
    31. yeti 
    32. yeti pro

    noggle types:
    1. Noggles
    2. Cool Noggles
    3. Noggles Pro

    tint:
    1. ffffff
    2. 000000
    3. 2a46ff
    4. f38b7c
    5. 7c3c58
    6. 16786c
    7. 36262d
    8. cb7300
    9. 06534a
    10. 369f49
    11. ff0e0e
    12. fd5442
    13. 453f41

    background color: 
    1. 3e5d25
    2. 100d98
    3. 403037
    4. 326849
    5. 651d19

    noggle color: 
    1. 513340
    2. bd2d24
    3. 4ab49a
    4. 0827f5
    5. f0c14d

     */

    uint256 _nonce;
    WhiteElephant whiteElephant;

    constructor() ERC721("Nounish White Elephant Christmas", "NWEC") {
        whiteElephant = WhiteElephant(msg.sender);
    }

    function mint(address to) external override returns (uint256 id) {
        require(msg.sender == address(whiteElephant), "FORBIDDEN");

        _mint(to, (id = _nonce++));
        require(id < 1 << 64, "MAX_MINT");
    }

    /// @dev steal should be guarded as an owner/admin function
    function steal(address from, address to, uint256 id) external override returns (uint256) {
        require(msg.sender == address(whiteElephant), "FORBIDDEN");

        // Underflow of the sender's balance is impossible because we check for
        // ownership above and the recipient's balance can't realistically overflow.
        unchecked {
            _balanceOf[from]--;

            _balanceOf[to]++;
        }

        nftInfo[id].owner = to;

        delete getApproved[id];

        emit Transfer(from, to, id);
    }

    function transferFrom(address from, address to, uint256 id) public override {
        require(whiteElephant.state(whiteElephant.tokenGameID(id)).gameOver, "GAME_IN_PROGRESS");
        super.transferFrom(from, to, id);
    }

    function tokenURI(uint256 id) public view override returns (string memory) {
        return "";
    }
}
