// SPDX-License-Identifier: MIT

pragma solidity ^0.8.26;

import "../../base/NFTBaseNoSig.sol";

/**
 * @dev NFT contract for Bits, which are unique companions in Wonderbits.
 */
contract Wonderbits is NFTBaseNoSig {
    constructor() ERC721A("Wonderbits", "BITS") {
        _grantRole(DEFAULT_ADMIN_ROLE, _msgSender());
    }
}