// SPDX-License-Identifier: MIT

pragma solidity ^0.8.26;

import "../../base/NFTBase.sol";

/**
 * @dev NFT contract for bit cosmetics, containing a multitude of unique accessories, clothing and other items for Bits in Wonderbits.
 */
contract BitCosmetics is NFTBase {
    constructor() ERC721A("Bit Cosmetics", "BCX") {
        _grantRole(DEFAULT_ADMIN_ROLE, _msgSender());
    }
}