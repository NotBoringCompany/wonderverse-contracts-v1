// SPDX-License-Identifier: MIT

pragma solidity ^0.8.26;

import "../../base/SFTBase.sol";

/**
 * @dev Contract to handle SFTs for Wonderbits.
 */
contract WonderbitsSFT is SFTBase {
    // URI is temporarily empty upon deployment; will be set later.
    constructor() ERC1155("") {
        _grantRole(DEFAULT_ADMIN_ROLE, _msgSender());
    }
}