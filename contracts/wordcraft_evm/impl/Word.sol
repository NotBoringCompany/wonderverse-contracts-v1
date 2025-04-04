// SPDX-License-Identifier: MIT

pragma solidity ^0.8.26;

import "../base/NFTBase.sol";

/**
 * @dev NFT contract for Word, which is a crafted word in Wordcraft.
 */
contract Word is NFTBase {
    constructor() ERC721A("Word", "WORD") {
        _grantRole(DEFAULT_ADMIN_ROLE, _msgSender());
    }
}