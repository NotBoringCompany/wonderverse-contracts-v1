// SPDX-License-Identifier: MIT

pragma solidity ^0.8.26;

import "../../base/NFTBaseNoSig.sol";

/**
 * @dev NFT contract for Islands, which are locations that contain resources to be farmed in Wonderbits.
 */
contract Islands is NFTBaseNoSig {
    constructor() ERC721A("Islands", "ISL") {
        _grantRole(DEFAULT_ADMIN_ROLE, _msgSender());
    }
}