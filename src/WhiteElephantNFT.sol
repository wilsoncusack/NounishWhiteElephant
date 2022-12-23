// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {ERC721} from "solmate/tokens/ERC721.sol";

abstract contract WhiteElephantNFT is ERC721 {
    /// @dev mint should be guarded as an owner/admin function
    function mint(address to) external virtual returns (uint256);
    /// @dev steal should be guarded as an owner/admin function
    function steal(address from, address to, uint256 id) external virtual returns (uint256);
}