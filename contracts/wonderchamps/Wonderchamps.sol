// SPDX-License-Identifier: MIT

pragma solidity ^0.8.26;

import "./inventory/IInventory.sol";
import "./items/Item.sol";
import "./items/IItemFragment.sol";
import "./player/Player.sol";
import "./stats/IInGameStats.sol";
import "./stats/ILeagueData.sol";

contract Wonderchamps is IInventory, Item, Player {
    constructor() {
        _grantRole(DEFAULT_ADMIN_ROLE, _msgSender());
    }
}